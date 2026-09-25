// ucie_top: single-die UCIe 1.1 link.
//
// USE_FLIT=0 (default): legacy 64b-word datapath end to end.
// USE_FLIT=1: flit-mode datapath — host words are packed into streaming
//   flits (CRC-32 + seq + replay, see docs/flit_spec.md) and carried
//   over RDI to the MB AFE. WORDS_PER_FLIT=7 (default): 512b flits,
//   128b RDI beats. WORDS_PER_FLIT=32: 256B datapath, 2304b padded
//   flits (32x64b + hdr/CRC + reserved), 256b RDI beats, NLANES=16
//   target. Host and AFE pinouts widen with NLANES/RDI accordingly.
module ucie_top #(
  parameter USE_FLIT = 0,
  parameter NLANES = 1,
  parameter REMOTE_ACK = 0,
  parameter GATE_ACTIVE = 0,
  parameter int WORDS_PER_FLIT = 7
) (
  input         HCLK,
  input         HRESETn,
  input         HSEL,
  input  [31:0] HADDR,
  input  [63:0] HWDATA,
  input         HWRITE,
  input  [2:0]  HSIZE,
  input  [2:0]  HBURST,
  input  [1:0]  HTRANS,
  input         HREADY,
  output [63:0] HRDATA,
  output        HREADYOUT,
  output        HRESP,
  input         io_TLlpData_irdy,
  output [3:0]  io_TLplStateStatus,
  output [63:0] io_TLplData_bits,
  output        io_TLplData_valid,
  input         io_TLready_to_rcv,
  input         io_fault,
  input         io_soft_reset,
  output        io_fdi_lpStallAck,
  input         io_mbAfe_fifoParams_clk,
  input         io_mbAfe_fifoParams_reset,
  input         io_mbAfe_txData_ready,
  output        io_mbAfe_txData_valid,
  output [NLANES*16-1:0] io_mbAfe_txData_bits_0,
  output        io_mbAfe_rxData_ready,
  input         io_mbAfe_rxData_valid,
  input  [NLANES*16-1:0] io_mbAfe_rxData_bits_0,
  output [2:0]  io_mbAfe_txFreqSel,
  output        io_mbAfe_rxEn,
  input         io_mbAfe_pllLock,
  input         io_sbAfe_fifoParams_clk,
  input         io_sbAfe_fifoParams_reset,
  output        io_sbAfe_txData,
  output        io_sbAfe_txClock,
  input         io_sbAfe_rxData,
  input         io_sbAfe_rxClock,
  output        io_sbAfe_rxEn,
  input         io_sbAfe_pllLock,
  output        o_flit_link_error,
  output        o_flit_overflow
);
  wire  protocol_io_fdi_lpData_ready;
  wire  protocol_io_fdi_lpData_valid;
  wire  protocol_io_fdi_lpData_irdy;
  wire [63:0] protocol_io_fdi_lpData_bits;
  wire  protocol_io_fdi_plData_valid;
  wire [63:0] protocol_io_fdi_plData_bits;
  wire [3:0] protocol_io_fdi_lpStateReq;
  wire  protocol_io_fdi_lpLinkError;
  wire [3:0] protocol_io_fdi_plStateStatus;
  wire  protocol_io_fdi_plInbandPres;
  wire  protocol_io_fdi_plRxActiveReq;
  wire  protocol_io_fdi_lpRxActiveStatus;
  wire  protocol_io_fdi_plStallReq;
  wire  protocol_io_fdi_lpStallAck;
  wire  protocol_io_fdi_plConfig_valid;
  wire [31:0] protocol_io_fdi_plConfig_bits;
  wire  protocol_io_fdi_plConfigCredit;
  wire  protocol_io_fdi_lpConfig_valid;
  wire [31:0] protocol_io_fdi_lpConfig_bits;
  wire  protocol_io_fdi_lpConfigCredit;
  wire  protocol_io_link_error;
  wire  protocol_io_lpData_irdy;
  wire [3:0] protocol_io_plStateStatus;
  wire [63:0] protocol_io_plData_bits;
  wire  protocol_io_plData_valid;
  wire  protocol_io_ready_to_rcv;
  wire  protocol_io_fault;
  wire  protocol_io_soft_reset;
  wire  hreset;
  // RDI beat: 64b legacy, 128b (512b flits) or 256b (256B flits).
  localparam RDI_W = (USE_FLIT == 0) ? 64 :
                     (WORDS_PER_FLIT == 32 ? 256 : 128);
  wire  d2dadapter_clock;
  wire  d2dadapter_reset;
  wire  d2dadapter_io_fdi_lpData_ready;
  wire  d2dadapter_io_fdi_lpData_valid;
  wire  d2dadapter_io_fdi_lpData_irdy;
  wire [63:0] d2dadapter_io_fdi_lpData_bits;
  wire  d2dadapter_io_fdi_plData_valid;
  wire [63:0] d2dadapter_io_fdi_plData_bits;
  wire [3:0] d2dadapter_io_fdi_lpStateReq;
  wire  d2dadapter_io_fdi_lpLinkError;
  wire [3:0] d2dadapter_io_fdi_plStateStatus;
  wire  d2dadapter_io_fdi_plInbandPres;
  wire  d2dadapter_io_fdi_plRxActiveReq;
  wire  d2dadapter_io_fdi_lpRxActiveStatus;
  wire  d2dadapter_io_fdi_plStallReq;
  wire  d2dadapter_io_fdi_lpStallAck;
  wire  d2dadapter_io_fdi_plConfig_valid;
  wire [31:0] d2dadapter_io_fdi_plConfig_bits;
  wire  d2dadapter_io_fdi_plConfigCredit;
  wire  d2dadapter_io_fdi_lpConfig_valid;
  wire [31:0] d2dadapter_io_fdi_lpConfig_bits;
  wire  d2dadapter_io_fdi_lpConfigCredit;
  wire  d2dadapter_io_rdi_lpData_ready;
  wire  d2dadapter_io_rdi_lpData_valid;
  wire  d2dadapter_io_rdi_lpData_irdy;
  wire [RDI_W-1:0] d2dadapter_io_rdi_lpData_bits;
  wire  d2dadapter_io_rdi_plData_valid;
  wire [RDI_W-1:0] d2dadapter_io_rdi_plData_bits;
  wire [3:0] d2dadapter_io_rdi_lpStateReq;
  wire  d2dadapter_io_rdi_lpLinkError;
  wire [3:0] d2dadapter_io_rdi_plStateStatus;
  wire  d2dadapter_io_rdi_plInbandPres;
  wire  d2dadapter_io_rdi_plStallReq;
  wire  d2dadapter_io_rdi_lpStallAck;
  wire  d2dadapter_io_rdi_plConfig_valid;
  wire [31:0] d2dadapter_io_rdi_plConfig_bits;
  wire  d2dadapter_io_rdi_plConfigCredit;
  wire  d2dadapter_io_rdi_lpConfig_valid;
  wire [31:0] d2dadapter_io_rdi_lpConfig_bits;
  wire  d2dadapter_io_rdi_lpConfigCredit;
  wire  logPhy_clock;
  wire  logPhy_reset;
  wire  logPhy_io_rdi_lpData_ready;
  wire  logPhy_io_rdi_lpData_valid;
  wire  logPhy_io_rdi_lpData_irdy;
  wire [RDI_W-1:0] logPhy_io_rdi_lpData_bits;
  wire  logPhy_io_rdi_plData_valid;
  wire [RDI_W-1:0] logPhy_io_rdi_plData_bits;
  wire [3:0] logPhy_io_rdi_lpStateReq;
  wire  logPhy_io_rdi_lpLinkError;
  wire [3:0] logPhy_io_rdi_plStateStatus;
  wire  logPhy_io_rdi_plInbandPres;
  wire  logPhy_io_rdi_plStallReq;
  wire  logPhy_io_rdi_lpStallAck;
  wire  logPhy_io_rdi_plConfig_valid;
  wire [31:0] logPhy_io_rdi_plConfig_bits;
  wire  logPhy_io_rdi_plConfigCredit;
  wire  logPhy_io_rdi_lpConfig_valid;
  wire [31:0] logPhy_io_rdi_lpConfig_bits;
  wire  logPhy_io_rdi_lpConfigCredit;
  wire  logPhy_io_mbAfe_fifoParams_clk;
  wire  logPhy_io_mbAfe_fifoParams_reset;
  wire  logPhy_io_mbAfe_txData_ready;
  wire  logPhy_io_mbAfe_txData_valid;
  wire [NLANES*16-1:0] logPhy_io_mbAfe_txData_bits_0;
  wire  logPhy_io_mbAfe_rxData_ready;
  wire  logPhy_io_mbAfe_rxData_valid;
  wire [NLANES*16-1:0] logPhy_io_mbAfe_rxData_bits_0;
  wire  logPhy_io_mbAfe_rxEn;
  wire  logPhy_io_mbAfe_pllLock;
  wire  logPhy_io_sbAfe_txData;
  wire  logPhy_io_sbAfe_txClock;
  wire  logPhy_io_sbAfe_rxData;
  wire  logPhy_io_sbAfe_rxClock;
  wire  logPhy_io_sbAfe_pllLock;
  wire  d2d_flit_link_error;
  wire  d2d_flit_overflow;
  ahb_fdi protocol (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HSEL(HSEL),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HBURST(HBURST),
    .HTRANS(HTRANS),
    .HREADY(HREADY),
    .HRDATA(HRDATA),
    .HREADYOUT(HREADYOUT),
    .HRESP(HRESP),
    .io_lpData_irdy(protocol_io_lpData_irdy),
    .io_plStateStatus(protocol_io_plStateStatus),
    .io_plData_bits(protocol_io_plData_bits),
    .io_plData_valid(protocol_io_plData_valid),
    .io_ready_to_rcv(protocol_io_ready_to_rcv),
    .io_fault(protocol_io_fault),
    .io_soft_reset(protocol_io_soft_reset),
    .io_fdi_lpData_ready(protocol_io_fdi_lpData_ready),
    .io_fdi_lpData_valid(protocol_io_fdi_lpData_valid),
    .io_fdi_lpData_irdy(protocol_io_fdi_lpData_irdy),
    .io_fdi_lpData_bits(protocol_io_fdi_lpData_bits),
    .io_fdi_plData_valid(protocol_io_fdi_plData_valid),
    .io_fdi_plData_bits(protocol_io_fdi_plData_bits),
    .io_fdi_lpStateReq(protocol_io_fdi_lpStateReq),
    .io_fdi_lpLinkError(protocol_io_fdi_lpLinkError),
    .io_fdi_plStateStatus(protocol_io_fdi_plStateStatus),
    .io_fdi_plInbandPres(protocol_io_fdi_plInbandPres),
    .io_fdi_plRxActiveReq(protocol_io_fdi_plRxActiveReq),
    .io_fdi_lpRxActiveStatus(protocol_io_fdi_lpRxActiveStatus),
    .io_fdi_plStallReq(protocol_io_fdi_plStallReq),
    .io_fdi_lpStallAck(protocol_io_fdi_lpStallAck),
    .io_link_error(protocol_io_link_error),
    .io_fdi_plConfig_valid(protocol_io_fdi_plConfig_valid),
    .io_fdi_plConfig_bits(protocol_io_fdi_plConfig_bits),
    .io_fdi_plConfigCredit(protocol_io_fdi_plConfigCredit),
    .io_fdi_lpConfig_valid(protocol_io_fdi_lpConfig_valid),
    .io_fdi_lpConfig_bits(protocol_io_fdi_lpConfig_bits),
    .io_fdi_lpConfigCredit(protocol_io_fdi_lpConfigCredit)
  );
  d2d_adapt #(.USE_FLIT(USE_FLIT), .RDI_W(RDI_W), .REMOTE_ACK(REMOTE_ACK),
              .GATE_ACTIVE(GATE_ACTIVE), .WORDS_PER_FLIT(WORDS_PER_FLIT)) d2dadapter (
    .clock(d2dadapter_clock),
    .reset(d2dadapter_reset),
    .io_fdi_lpData_ready(d2dadapter_io_fdi_lpData_ready),
    .io_fdi_lpData_valid(d2dadapter_io_fdi_lpData_valid),
    .io_fdi_lpData_irdy(d2dadapter_io_fdi_lpData_irdy),
    .io_fdi_lpData_bits(d2dadapter_io_fdi_lpData_bits),
    .io_fdi_plData_valid(d2dadapter_io_fdi_plData_valid),
    .io_fdi_plData_bits(d2dadapter_io_fdi_plData_bits),
    .io_fdi_lpStateReq(d2dadapter_io_fdi_lpStateReq),
    .io_fdi_lpLinkError(d2dadapter_io_fdi_lpLinkError),
    .io_fdi_plStateStatus(d2dadapter_io_fdi_plStateStatus),
    .io_fdi_plInbandPres(d2dadapter_io_fdi_plInbandPres),
    .io_fdi_plRxActiveReq(d2dadapter_io_fdi_plRxActiveReq),
    .io_fdi_lpRxActiveStatus(d2dadapter_io_fdi_lpRxActiveStatus),
    .io_fdi_plStallReq(d2dadapter_io_fdi_plStallReq),
    .io_fdi_lpStallAck(d2dadapter_io_fdi_lpStallAck),
    .io_fdi_plConfig_valid(d2dadapter_io_fdi_plConfig_valid),
    .io_fdi_plConfig_bits(d2dadapter_io_fdi_plConfig_bits),
    .io_fdi_plConfigCredit(d2dadapter_io_fdi_plConfigCredit),
    .io_fdi_lpConfig_valid(d2dadapter_io_fdi_lpConfig_valid),
    .io_fdi_lpConfig_bits(d2dadapter_io_fdi_lpConfig_bits),
    .io_fdi_lpConfigCredit(d2dadapter_io_fdi_lpConfigCredit),
    .io_rdi_lpData_ready(d2dadapter_io_rdi_lpData_ready),
    .io_rdi_lpData_valid(d2dadapter_io_rdi_lpData_valid),
    .io_rdi_lpData_irdy(d2dadapter_io_rdi_lpData_irdy),
    .io_rdi_lpData_bits(d2dadapter_io_rdi_lpData_bits),
    .io_rdi_plData_valid(d2dadapter_io_rdi_plData_valid),
    .io_rdi_plData_bits(d2dadapter_io_rdi_plData_bits),
    .io_rdi_lpStateReq(d2dadapter_io_rdi_lpStateReq),
    .io_rdi_lpLinkError(d2dadapter_io_rdi_lpLinkError),
    .io_rdi_plStateStatus(d2dadapter_io_rdi_plStateStatus),
    .io_rdi_plInbandPres(d2dadapter_io_rdi_plInbandPres),
    .io_rdi_plStallReq(d2dadapter_io_rdi_plStallReq),
    .io_rdi_lpStallAck(d2dadapter_io_rdi_lpStallAck),
    .io_rdi_plConfig_valid(d2dadapter_io_rdi_plConfig_valid),
    .io_rdi_plConfig_bits(d2dadapter_io_rdi_plConfig_bits),
    .io_rdi_plConfigCredit(d2dadapter_io_rdi_plConfigCredit),
    .io_rdi_lpConfig_valid(d2dadapter_io_rdi_lpConfig_valid),
    .io_rdi_lpConfig_bits(d2dadapter_io_rdi_lpConfig_bits),
    .io_rdi_lpConfigCredit(d2dadapter_io_rdi_lpConfigCredit),
    .io_flit_link_error(d2d_flit_link_error),
    .io_flit_overflow(d2d_flit_overflow)
  );
  log_phy #(.RDI_W(RDI_W), .NLANES(NLANES), .WORDS_PER_FLIT(WORDS_PER_FLIT)) logPhy (
    .clock(logPhy_clock),
    .reset(logPhy_reset),
    .io_rdi_lpData_ready(logPhy_io_rdi_lpData_ready),
    .io_rdi_lpData_valid(logPhy_io_rdi_lpData_valid),
    .io_rdi_lpData_irdy(logPhy_io_rdi_lpData_irdy),
    .io_rdi_lpData_bits(logPhy_io_rdi_lpData_bits),
    .io_rdi_plData_valid(logPhy_io_rdi_plData_valid),
    .io_rdi_plData_bits(logPhy_io_rdi_plData_bits),
    .io_rdi_lpStateReq(logPhy_io_rdi_lpStateReq),
    .io_rdi_lpLinkError(logPhy_io_rdi_lpLinkError),
    .io_rdi_plStateStatus(logPhy_io_rdi_plStateStatus),
    .io_rdi_plInbandPres(logPhy_io_rdi_plInbandPres),
    .io_rdi_plStallReq(logPhy_io_rdi_plStallReq),
    .io_rdi_lpStallAck(logPhy_io_rdi_lpStallAck),
    .io_rdi_plConfig_valid(logPhy_io_rdi_plConfig_valid),
    .io_rdi_plConfig_bits(logPhy_io_rdi_plConfig_bits),
    .io_rdi_plConfigCredit(logPhy_io_rdi_plConfigCredit),
    .io_rdi_lpConfig_valid(logPhy_io_rdi_lpConfig_valid),
    .io_rdi_lpConfig_bits(logPhy_io_rdi_lpConfig_bits),
    .io_rdi_lpConfigCredit(logPhy_io_rdi_lpConfigCredit),
    .io_mbAfe_fifoParams_clk(logPhy_io_mbAfe_fifoParams_clk),
    .io_mbAfe_fifoParams_reset(logPhy_io_mbAfe_fifoParams_reset),
    .io_mbAfe_txData_ready(logPhy_io_mbAfe_txData_ready),
    .io_mbAfe_txData_valid(logPhy_io_mbAfe_txData_valid),
    .io_mbAfe_txData_bits_0(logPhy_io_mbAfe_txData_bits_0),
    .io_mbAfe_rxData_ready(logPhy_io_mbAfe_rxData_ready),
    .io_mbAfe_rxData_valid(logPhy_io_mbAfe_rxData_valid),
    .io_mbAfe_rxData_bits_0(logPhy_io_mbAfe_rxData_bits_0),
    .io_mbAfe_rxEn(logPhy_io_mbAfe_rxEn),
    .io_mbAfe_pllLock(logPhy_io_mbAfe_pllLock),
    .io_sbAfe_txData(logPhy_io_sbAfe_txData),
    .io_sbAfe_txClock(logPhy_io_sbAfe_txClock),
    .io_sbAfe_rxData(logPhy_io_sbAfe_rxData),
    .io_sbAfe_rxClock(logPhy_io_sbAfe_rxClock),
    .io_sbAfe_pllLock(logPhy_io_sbAfe_pllLock)
  );
  // FDI config legs: host mailbox <-> D2D sideband (were tied off).
  // The discrete top-level config ports are gone: the host reaches the
  // config fabric only through the AHB mailbox in ahb_fdi.
  assign d2dadapter_io_fdi_plConfig_valid = protocol_io_fdi_plConfig_valid;
  assign d2dadapter_io_fdi_plConfig_bits = protocol_io_fdi_plConfig_bits;
  assign protocol_io_fdi_plConfigCredit = d2dadapter_io_fdi_plConfigCredit;
  assign protocol_io_fdi_lpConfig_valid = d2dadapter_io_fdi_lpConfig_valid;
  assign protocol_io_fdi_lpConfig_bits = d2dadapter_io_fdi_lpConfig_bits;
  assign d2dadapter_io_fdi_lpConfigCredit = protocol_io_fdi_lpConfigCredit;
  assign io_fdi_lpStallAck = protocol_io_fdi_lpStallAck;
  // Flit link_error surfaces at top and drives AHB HRESP via protocol.
  assign o_flit_link_error = d2d_flit_link_error;
  assign o_flit_overflow = d2d_flit_overflow;
  assign protocol_io_link_error = d2d_flit_link_error;
  assign protocol_io_lpData_irdy = io_TLlpData_irdy;
  assign io_TLplStateStatus = protocol_io_plStateStatus;
  assign io_TLplData_bits = protocol_io_plData_bits;
  assign io_TLplData_valid = protocol_io_plData_valid;
  assign protocol_io_ready_to_rcv = io_TLready_to_rcv;
  assign protocol_io_fault = io_fault;
  assign protocol_io_soft_reset = io_soft_reset;
  assign io_mbAfe_txData_valid = logPhy_io_mbAfe_txData_valid;
  assign io_mbAfe_txData_bits_0 = logPhy_io_mbAfe_txData_bits_0;
  assign io_mbAfe_rxData_ready = logPhy_io_mbAfe_rxData_ready;
  assign io_mbAfe_txFreqSel = 3'h0;
  assign io_mbAfe_rxEn = logPhy_io_mbAfe_rxEn;
  assign io_sbAfe_txData = logPhy_io_sbAfe_txData;
  assign io_sbAfe_txClock = logPhy_io_sbAfe_txClock;
  assign io_sbAfe_rxEn = 1'h1;
  assign hreset = ~HRESETn;
  assign protocol_io_fdi_lpData_ready = d2dadapter_io_fdi_lpData_ready;
  assign protocol_io_fdi_plData_valid = d2dadapter_io_fdi_plData_valid;
  assign protocol_io_fdi_plData_bits = d2dadapter_io_fdi_plData_bits;
  assign protocol_io_fdi_plStateStatus = d2dadapter_io_fdi_plStateStatus;
  assign protocol_io_fdi_plInbandPres = d2dadapter_io_fdi_plInbandPres;
  assign protocol_io_fdi_plRxActiveReq = d2dadapter_io_fdi_plRxActiveReq;
  assign protocol_io_fdi_plStallReq = d2dadapter_io_fdi_plStallReq;
  assign d2dadapter_clock = HCLK;
  assign d2dadapter_reset = hreset;
  assign d2dadapter_io_fdi_lpData_valid = protocol_io_fdi_lpData_valid;
  assign d2dadapter_io_fdi_lpData_irdy = protocol_io_fdi_lpData_irdy;
  assign d2dadapter_io_fdi_lpData_bits = protocol_io_fdi_lpData_bits;
  assign d2dadapter_io_fdi_lpStateReq = protocol_io_fdi_lpStateReq;
  assign d2dadapter_io_fdi_lpLinkError = protocol_io_fdi_lpLinkError;
  assign d2dadapter_io_fdi_lpRxActiveStatus = protocol_io_fdi_lpRxActiveStatus;
  assign d2dadapter_io_fdi_lpStallAck = protocol_io_fdi_lpStallAck;
  assign d2dadapter_io_rdi_lpData_ready = logPhy_io_rdi_lpData_ready;
  assign d2dadapter_io_rdi_plData_valid = logPhy_io_rdi_plData_valid;
  assign d2dadapter_io_rdi_plData_bits = logPhy_io_rdi_plData_bits;
  assign d2dadapter_io_rdi_plStateStatus = logPhy_io_rdi_plStateStatus;
  assign d2dadapter_io_rdi_plInbandPres = logPhy_io_rdi_plInbandPres;
  assign d2dadapter_io_rdi_plStallReq = logPhy_io_rdi_plStallReq;
  assign d2dadapter_io_rdi_plConfig_valid = logPhy_io_rdi_plConfig_valid;
  assign d2dadapter_io_rdi_plConfig_bits = logPhy_io_rdi_plConfig_bits;
  assign d2dadapter_io_rdi_lpConfigCredit = logPhy_io_rdi_lpConfigCredit;
  assign logPhy_clock = HCLK;
  assign logPhy_reset = hreset;
  assign logPhy_io_rdi_lpData_valid = d2dadapter_io_rdi_lpData_valid;
  assign logPhy_io_rdi_lpData_irdy = d2dadapter_io_rdi_lpData_irdy;
  assign logPhy_io_rdi_lpData_bits = d2dadapter_io_rdi_lpData_bits;
  assign logPhy_io_rdi_lpStateReq = d2dadapter_io_rdi_lpStateReq;
  assign logPhy_io_rdi_lpLinkError = d2dadapter_io_rdi_lpLinkError;
  assign logPhy_io_rdi_lpStallAck = d2dadapter_io_rdi_lpStallAck;
  assign logPhy_io_rdi_plConfigCredit = d2dadapter_io_rdi_plConfigCredit;
  assign logPhy_io_rdi_lpConfig_valid = d2dadapter_io_rdi_lpConfig_valid;
  assign logPhy_io_rdi_lpConfig_bits = d2dadapter_io_rdi_lpConfig_bits;
  assign logPhy_io_mbAfe_fifoParams_clk = io_mbAfe_fifoParams_clk;
  assign logPhy_io_mbAfe_fifoParams_reset = io_mbAfe_fifoParams_reset;
  assign logPhy_io_mbAfe_txData_ready = io_mbAfe_txData_ready;
  assign logPhy_io_mbAfe_rxData_valid = io_mbAfe_rxData_valid;
  assign logPhy_io_mbAfe_rxData_bits_0 = io_mbAfe_rxData_bits_0;
  assign logPhy_io_mbAfe_pllLock = io_mbAfe_pllLock;
  assign logPhy_io_sbAfe_rxData = io_sbAfe_rxData;
  assign logPhy_io_sbAfe_rxClock = io_sbAfe_rxClock;
  assign logPhy_io_sbAfe_pllLock = io_sbAfe_pllLock;
endmodule
