// ahb_fdi: native AHB-Lite 64-bit host port to FDI bridge + config mailbox.
//
// Brief: AHB-Lite subordinate with two spaces selected by HADDR[31]
// (see docs/cfg_spec.md). The streaming flit port has no register file:
// the AHB data phase IS the FDI transfer. The config space is a 4-word
// TX/RX packet mailbox into the sideband config fabric. Link controls
// stay discrete pins; HRESP mirrors link_error (level).
//
// Interface:
//   AHB-Lite  | HCLK/HRESETn, HSEL/HADDR/HWDATA/HWRITE/HSIZE/HBURST/
//             | HTRANS/HREADY in, HRDATA/HREADYOUT/HRESP out.
//             | HADDR[31]=0 streaming, =1 config (HADDR[3:2]: 0=data,
//             | 1=status). HSIZE/HBURST/HADDR[30:0] otherwise ignored.
//   Host pins | io_lpData_irdy in, io_plStateStatus/plData_bits/plData_valid
//             | out, io_ready_to_rcv/io_fault/io_soft_reset in.
//   FDI data  | lpData (valid/irdy/bits) out, plData (valid/bits) in,
//             | lpData_ready in; lpStateReq/lpLinkError/lpRxActiveStatus/
//             | lpStallAck out, plStateStatus/plInbandPres/plRxActiveReq/
//             | plStallReq in.
//   FDI config| plConfig (valid/bits) out, plConfigCredit in;
//             | lpConfig (valid/bits) in, lpConfigCredit out.
//   Status    | io_link_error in (drives HRESP).
//
// CDC/reset: single HCLK domain, synchronous active-low reset. No CDC.
module ahb_fdi (
  input  logic        HCLK,
  input  logic        HRESETn,
  input  logic        HSEL,
  input  logic [31:0] HADDR,
  input  logic [63:0] HWDATA,
  input  logic        HWRITE,
  input  logic [2:0]  HSIZE,
  input  logic [2:0]  HBURST,
  input  logic [1:0]  HTRANS,
  input  logic        HREADY,
  output logic [63:0] HRDATA,
  output logic        HREADYOUT,
  output logic        HRESP,
  input  logic        io_lpData_irdy,
  output logic [3:0]  io_plStateStatus,
  output logic [63:0] io_plData_bits,
  output logic        io_plData_valid,
  input  logic        io_ready_to_rcv,
  input  logic        io_fault,
  input  logic        io_soft_reset,
  input  logic        io_fdi_lpData_ready,
  output logic        io_fdi_lpData_valid,
  output logic        io_fdi_lpData_irdy,
  output logic [63:0] io_fdi_lpData_bits,
  input  logic        io_fdi_plData_valid,
  input  logic [63:0] io_fdi_plData_bits,
  output logic [3:0]  io_fdi_lpStateReq,
  output logic        io_fdi_lpLinkError,
  input  logic [3:0]  io_fdi_plStateStatus,
  input  logic        io_fdi_plInbandPres,
  input  logic        io_fdi_plRxActiveReq,
  output logic        io_fdi_lpRxActiveStatus,
  input  logic        io_fdi_plStallReq,
  output logic        io_fdi_lpStallAck,
  // Config mailbox (FDI config legs, docs/cfg_spec.md).
  input  logic        io_link_error,
  output logic        io_fdi_plConfig_valid,
  output logic [31:0] io_fdi_plConfig_bits,
  input  logic        io_fdi_plConfigCredit,
  input  logic        io_fdi_lpConfig_valid,
  input  logic [31:0] io_fdi_lpConfig_bits,
  output logic        io_fdi_lpConfigCredit
);
  // Link states and sideband management low-5-bit codes.
  localparam logic [3:0] STATE_RESET  = 4'h0;
  localparam logic [3:0] STATE_ACTIVE = 4'h1;
  localparam logic [3:0] STATE_LINKRESET = 4'h9;
  localparam logic [4:0] CODE_COMPLETE0 = 5'h10;
  localparam logic [4:0] CODE_COMPLETE1 = 5'h11;
  localparam logic [4:0] CODE_COMPLETE2 = 5'h19;
  // AHB map: space select + config offsets + packet depth.
  localparam int AHB_SPACE_BIT = 31;
  localparam logic [1:0] CFG_OFF_DATA = 2'd0;
  localparam logic [1:0] CFG_OFF_STATUS = 2'd1;
  localparam int PKT_WORDS = 4;

  logic _unused;
  assign _unused = &{HSIZE, HBURST, HADDR[30:4], HADDR[1:0], 1'b0};

  // ---- Streaming datapath (HADDR[31]==0) ----
  // HREADYOUT must not depend on HREADY (muxed ready) to avoid a
  // combinational loop through the interconnect.
  logic xfer;
  logic wr;
  logic wsel;
  assign xfer = HSEL & HREADY & HTRANS[1] & ~HADDR[AHB_SPACE_BIT];
  assign wr   = xfer & HWRITE;
  assign wsel = HSEL & HWRITE & HTRANS[1] & ~HADDR[AHB_SPACE_BIT];

  assign io_fdi_lpData_valid = wr;
  assign io_fdi_lpData_bits  = HWDATA;
  assign io_fdi_lpData_irdy  = io_lpData_irdy;

  // ---- Config mailbox (HADDR[31]==1) ----
  logic cfg_xfer;
  logic cfg_data;
  logic cfg_sts;
  logic cfg_wr;
  logic cfg_rd;
  logic wr_cfg_data;
  logic rd_cfg_data;
  logic rd_cfg_sts;
  logic wr_cfg_sts;
  assign cfg_xfer    = HSEL & HREADY & HTRANS[1] & HADDR[AHB_SPACE_BIT];
  assign cfg_data    = (HADDR[3:2] == CFG_OFF_DATA);
  assign cfg_sts     = (HADDR[3:2] == CFG_OFF_STATUS);
  assign cfg_wr      = cfg_xfer & HWRITE;
  assign cfg_rd      = cfg_xfer & ~HWRITE;
  assign wr_cfg_data = cfg_wr & cfg_data;
  assign rd_cfg_data = cfg_rd & cfg_data;
  assign rd_cfg_sts  = cfg_rd & cfg_sts;
  assign wr_cfg_sts  = cfg_wr & cfg_sts;

  // TX: 4-deep (one sideband packet). Accepts AHB writes while room;
  // presents 4 words back-to-back, then waits for the fabric credit.
  logic [31:0] tx_buf [0:PKT_WORDS-1];
  logic [2:0]  tx_n;
  logic        tx_sending;
  logic [1:0]  tx_idx;
  logic        tx_wait;
  logic        tx_ready;
  assign tx_ready = (tx_n < 3'd4) && !tx_sending && !tx_wait;

  assign io_fdi_plConfig_valid = tx_sending;
  assign io_fdi_plConfig_bits  = tx_buf[tx_idx];

  // RX: 4-deep. Samples every valid cycle (ser has no backpressure);
  // overrun while 4 unread sets sticky rx_ovf. Credit returned once per
  // completed non-management packet (credit-wrap rule, cfg_spec.md).
  logic [31:0] rx_buf [0:PKT_WORDS-1];
  logic [2:0]  rx_n;
  logic [1:0]  rx_ri;
  logic        rx_full;
  logic        rx_ovf;
  logic        rx_mgmt;
  logic        rx_accept;
  logic        rx_pkt_done;
  assign rx_accept   = io_fdi_lpConfig_valid && !rx_full;
  assign rx_pkt_done = io_fdi_lpConfig_valid && !rx_full && (rx_n == 3'd3);

  assign io_fdi_lpConfigCredit = rx_pkt_done && !rx_mgmt;

  logic [63:0] cfg_rdata;
  assign cfg_rdata = cfg_sts
      ? {60'b0, rx_ovf, io_link_error, tx_ready, rx_full}
      : ({32'b0, rx_buf[rx_ri]} & {64{rx_full}});

  assign HRDATA    = HADDR[AHB_SPACE_BIT] ? cfg_rdata : io_fdi_plData_bits;
  assign HREADYOUT = (HSEL & HWRITE & HTRANS[1] & HADDR[AHB_SPACE_BIT] & cfg_data)
                     ? tx_ready
                     : (wsel ? io_fdi_lpData_ready : 1'b1);
  assign HRESP = io_link_error;

  // Host-side monitors, straight through from FDI.
  assign io_plStateStatus = io_fdi_plStateStatus;
  assign io_plData_bits   = io_fdi_plData_bits;
  assign io_plData_valid  = io_fdi_plData_valid;

  // Link-state sequencer, fed by discrete pins.
  logic       lp_rx_active_sts_reg;
  logic [3:0] lp_state_req_reg;
  logic       lp_stall_reg;
  logic       lp_rx_active_pl_state;
  logic       req_active;
  assign lp_rx_active_pl_state = (io_fdi_plStateStatus == STATE_ACTIVE);
  assign req_active = ((io_fdi_plStateStatus == STATE_RESET) &
                       (lp_state_req_reg == STATE_RESET) &
                       io_fdi_plInbandPres) |
                      (io_fdi_plStateStatus == STATE_LINKRESET);

  always_ff @(posedge HCLK) begin
    if (!HRESETn) begin
      lp_rx_active_sts_reg <= 1'b0;
      lp_state_req_reg     <= STATE_RESET;
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
      for (int j = 0; j < PKT_WORDS; j = j + 1) begin
        tx_buf[j] <= 32'h0;
        rx_buf[j] <= 32'h0;
      end
    end else begin
      lp_rx_active_sts_reg <= io_fdi_plRxActiveReq & io_ready_to_rcv &
                              lp_rx_active_pl_state | lp_rx_active_sts_reg;
      if (req_active)
        lp_state_req_reg <= STATE_ACTIVE;
      else if (~req_active & io_soft_reset)
        lp_state_req_reg <= STATE_LINKRESET;
      else
        lp_state_req_reg <= STATE_RESET;
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
          rx_mgmt <= (io_fdi_lpConfig_bits[4:0] == CODE_COMPLETE0) ||
                     (io_fdi_lpConfig_bits[4:0] == CODE_COMPLETE1) ||
                     (io_fdi_lpConfig_bits[4:0] == CODE_COMPLETE2);
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
