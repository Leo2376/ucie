// ahb_fdi: native AHB-Lite 64-bit streaming host port to FDI bridge.
//
// No registers on the data path: HWDATA drives the FDI Tx bits directly,
// HRDATA is driven directly by the FDI Rx bits, and HREADYOUT is the FDI
// Tx ready on writes (1 on reads/idle). A transfer is an AHB data phase
// (HSEL & HREADY & HTRANS NONSEQ/SEQ): HWRITE=1 pushes one flit,
// HWRITE=0 samples the latest Rx flit. HADDR/HSIZE/HBURST carry no
// meaning here (single slave, 64-bit only). All link controls stay as
// discrete pins with the original streaming semantics.
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
  output wire        io_fdi_lpStallAck
);
  wire _unused = &{HADDR, HSIZE, HBURST, 1'b0};

  // AHB data phase qualifies the streaming transfer. HREADYOUT must
  // not depend on HREADY (muxed ready) to avoid a combinational loop
  // through the interconnect: wait state is a function of select only.
  wire xfer = HSEL & HREADY & HTRANS[1];
  wire wr   = xfer & HWRITE;
  wire wsel = HSEL & HWRITE & HTRANS[1];

  // Direct datapath, no indirection.
  assign io_fdi_lpData_valid = wr;
  assign io_fdi_lpData_bits  = HWDATA;
  assign io_fdi_lpData_irdy  = io_lpData_irdy;
  assign HRDATA              = io_fdi_plData_bits;
  assign HREADYOUT           = wsel ? io_fdi_lpData_ready : 1'b1;
  assign HRESP               = 1'b0;

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

  always @(posedge HCLK) begin
    if (!HRESETn) begin
      lp_rx_active_sts_reg <= 1'b0;
      lp_state_req_reg     <= 4'h0;
      lp_stall_reg         <= 1'b0;
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
    end
  end

  assign io_fdi_lpStateReq       = lp_state_req_reg;
  assign io_fdi_lpLinkError      = io_fault;
  assign io_fdi_lpRxActiveStatus = lp_rx_active_sts_reg;
  assign io_fdi_lpStallAck       = lp_stall_reg;
endmodule
