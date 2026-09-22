// ahb_fdi: native AHB-Lite 64-bit host port to FDI bridge + config mailbox.
//
// Two spaces selected by HADDR[31] (docs/cfg_spec.md):
//   0 = streaming flit port (unchanged): HWDATA drives the FDI Tx bits
//       directly, HRDATA from FDI Rx bits, HREADYOUT = FDI Tx ready on
//       writes (1 on reads/idle). HADDR/HSIZE/HBURST otherwise ignored.
//   1 = config space (32b words in HWDATA[31:0]):
//       offset 0 (data): write -> plConfig TX packet buffer (4 words =
//         one sideband packet, HREADYOUT low while full); read <- lpConfig
//         RX buffer (pops one word, 0 when empty).
//       offset 4 (status): read -> {28'b0, rx_overflow, link_error,
//         tx_ready, rx_valid}; write clears rx_overflow.
// Link controls stay discrete pins. HRESP = link_error (level): while the
// flit link_error latch is set, every AHB transfer errors.
module ahb_fdi (
  input  wire        HCLK,
  input  wire        HRESETn,
  input  wire        HSEL,
  input  wire [31:0] HADDR,
  input  wire [63:0] HWDATA,
  input  wire        HWRITE,
  input  wire [2:0]  HSIZE,
  input  wire [2:0]  HBURST,
  input  wire [1:0]  HTRANS,
  input  wire        HREADY,
  output wire [63:0] HRDATA,
  output wire        HREADYOUT,
  output wire        HRESP,
  input  wire        io_lpData_irdy,
  output wire [3:0]  io_plStateStatus,
  output wire [63:0] io_plData_bits,
  output wire        io_plData_valid,
  input  wire        io_ready_to_rcv,
  input  wire        io_fault,
  input  wire        io_soft_reset,
  input  wire        io_fdi_lpData_ready,
  output wire        io_fdi_lpData_valid,
  output wire        io_fdi_lpData_irdy,
  output wire [63:0] io_fdi_lpData_bits,
  input  wire        io_fdi_plData_valid,
  input  wire [63:0] io_fdi_plData_bits,
  output wire [3:0]  io_fdi_lpStateReq,
  output wire        io_fdi_lpLinkError,
  input  wire [3:0]  io_fdi_plStateStatus,
  input  wire        io_fdi_plInbandPres,
  input  wire        io_fdi_plRxActiveReq,
  output wire        io_fdi_lpRxActiveStatus,
  input  wire        io_fdi_plStallReq,
  output wire        io_fdi_lpStallAck,
  // Config mailbox (FDI config legs, docs/cfg_spec.md).
  input  wire        io_link_error,
  output wire        io_fdi_plConfig_valid,
  output wire [31:0] io_fdi_plConfig_bits,
  input  wire        io_fdi_plConfigCredit,
  input  wire        io_fdi_lpConfig_valid,
  input  wire [31:0] io_fdi_lpConfig_bits,
  output wire        io_fdi_lpConfigCredit
);
  wire _unused = &{HSIZE, HBURST, HADDR[30:4], HADDR[1:0], 1'b0};

  // ---- Streaming datapath (HADDR[31]==0), unchanged ----
  // HREADYOUT must not depend on HREADY (muxed ready) to avoid a
  // combinational loop through the interconnect.
  wire xfer = HSEL & HREADY & HTRANS[1] & ~HADDR[31];
  wire wr   = xfer & HWRITE;
  wire wsel = HSEL & HWRITE & HTRANS[1] & ~HADDR[31];

  assign io_fdi_lpData_valid = wr;
  assign io_fdi_lpData_bits  = HWDATA;
  assign io_fdi_lpData_irdy  = io_lpData_irdy;

  // ---- Config mailbox (HADDR[31]==1) ----
  wire cfg_xfer  = HSEL & HREADY & HTRANS[1] & HADDR[31];
  wire cfg_data  = (HADDR[3:2] == 2'd0);
  wire cfg_sts   = (HADDR[3:2] == 2'd1);
  wire cfg_wr    = cfg_xfer & HWRITE;
  wire cfg_rd    = cfg_xfer & ~HWRITE;
  wire wr_cfg_data = cfg_wr & cfg_data;
  wire rd_cfg_data = cfg_rd & cfg_data;
  wire rd_cfg_sts  = cfg_rd & cfg_sts;
  wire wr_cfg_sts  = cfg_wr & cfg_sts;

  // TX: 4-deep (one sideband packet). Accepts AHB writes while room;
  // presents 4 words back-to-back, then waits for the fabric credit.
  reg [31:0] tx_buf [0:3];
  reg [2:0]  tx_n;
  reg        tx_sending;
  reg [1:0]  tx_idx;
  reg        tx_wait;
  wire tx_ready = (tx_n < 3'd4) && !tx_sending && !tx_wait;

  assign io_fdi_plConfig_valid = tx_sending;
  assign io_fdi_plConfig_bits  = tx_buf[tx_idx];

  // RX: 4-deep. Samples every valid cycle (ser has no backpressure);
  // overrun while 4 unread sets sticky rx_ovf. Credit returned once per
  // completed non-management packet (credit-wrap rule, cfg_spec.md).
  reg [31:0] rx_buf [0:3];
  reg [2:0]  rx_n;
  reg [1:0]  rx_ri;
  reg        rx_full;
  reg        rx_ovf;
  reg        rx_mgmt;
  wire rx_accept = io_fdi_lpConfig_valid && !rx_full;
  wire rx_pkt_done = io_fdi_lpConfig_valid && !rx_full && (rx_n == 3'd3);

  assign io_fdi_lpConfigCredit = rx_pkt_done && !rx_mgmt;

  wire [63:0] cfg_rdata = cfg_sts
      ? {60'b0, rx_ovf, io_link_error, tx_ready, rx_full}
      : ({32'b0, rx_buf[rx_ri]} & {64{rx_full}});

  assign HRDATA    = HADDR[31] ? cfg_rdata : io_fdi_plData_bits;
  assign HREADYOUT = (HSEL & HWRITE & HTRANS[1] & HADDR[31] & cfg_data)
                     ? tx_ready
                     : (wsel ? io_fdi_lpData_ready : 1'b1);
  assign HRESP = io_link_error;

  // Host-side monitors, straight through from FDI.
  assign io_plStateStatus = io_fdi_plStateStatus;
  assign io_plData_bits   = io_fdi_plData_bits;
  assign io_plData_valid  = io_fdi_plData_valid;

  // Link-state sequencer, fed by discrete pins.
  reg  lp_rx_active_sts_reg;
  reg [3:0] lp_state_req_reg;
  reg  lp_stall_reg;
  wire lp_rx_active_pl_state = (io_fdi_plStateStatus == 4'h1);
  wire req_active = ((io_fdi_plStateStatus == 4'h0) &
                     (lp_state_req_reg == 4'h0) &
                     io_fdi_plInbandPres) |
                    (io_fdi_plStateStatus == 4'h9);

  integer j;
  always @(posedge HCLK) begin
    if (!HRESETn) begin
      lp_rx_active_sts_reg <= 1'b0;
      lp_state_req_reg     <= 4'h0;
      lp_stall_reg         <= 1'b0;
      tx_n <= 3'd0;
      tx_sending <= 1'b0;
      tx_idx <= 2'd0;
      tx_wait <= 1'b0;
      rx_n <= 3'd0;
      rx_ri <= 2'd0;
      rx_full <= 1'b0;
      rx_ovf <= 1'b0;
      rx_mgmt <= 1'b0;
      for (j = 0; j < 4; j = j + 1) begin
        tx_buf[j] <= 32'h0;
        rx_buf[j] <= 32'h0;
      end
    end else begin
      lp_rx_active_sts_reg <= io_fdi_plRxActiveReq & io_ready_to_rcv &
                              lp_rx_active_pl_state | lp_rx_active_sts_reg;
      if (req_active)
        lp_state_req_reg <= 4'h1;
      else if (~req_active & io_soft_reset)
        lp_state_req_reg <= 4'h9;
      else
        lp_state_req_reg <= 4'h0;
      lp_stall_reg <= io_fdi_plStallReq;
      // TX: accept AHB word (exactly-once: ignored while full).
      if (wr_cfg_data && tx_ready) begin
        tx_buf[tx_n[1:0]] <= HWDATA[31:0];
        tx_n <= tx_n + 3'd1;
      end
      // TX: present full packet, then wait for fabric credit.
      if (!tx_sending && !tx_wait && tx_n == 3'd4) begin
        tx_sending <= 1'b1;
        tx_idx <= 2'd0;
      end else if (tx_sending) begin
        if (tx_idx == 2'd3) begin
          tx_sending <= 1'b0;
          tx_wait <= 1'b1;
        end
        tx_idx <= tx_idx + 2'd1;
      end
      if (tx_wait && io_fdi_plConfigCredit) begin
        tx_wait <= 1'b0;
        tx_n <= 3'd0;
      end
      // RX: sample every valid cycle; flag overrun; pop on data read.
      if (rx_accept) begin
        rx_buf[rx_n[1:0]] <= io_fdi_lpConfig_bits;
        if (rx_n == 3'd0)
          rx_mgmt <= (io_fdi_lpConfig_bits[4:0] == 5'h10) ||
                     (io_fdi_lpConfig_bits[4:0] == 5'h11) ||
                     (io_fdi_lpConfig_bits[4:0] == 5'h19);
        if (rx_n == 3'd3)
          rx_full <= 1'b1;
        rx_n <= rx_n + 3'd1;
      end
      if (io_fdi_lpConfig_valid && rx_full)
        rx_ovf <= 1'b1;
      if (rd_cfg_data && rx_full) begin
        if (rx_ri == 2'd3) begin
          rx_full <= 1'b0;
          rx_n <= 3'd0;
          rx_ri <= 2'd0;
        end else begin
          rx_ri <= rx_ri + 2'd1;
        end
      end
      if (wr_cfg_sts)
        rx_ovf <= 1'b0;
    end
  end

  assign io_fdi_lpStateReq       = lp_state_req_reg;
  assign io_fdi_lpLinkError      = io_fault;
  assign io_fdi_lpRxActiveStatus = lp_rx_active_sts_reg;
  assign io_fdi_lpStallAck       = lp_stall_reg;
endmodule
