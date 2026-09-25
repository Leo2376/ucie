// rdi_map: RDI <-> mainband-lane width conversion.
//
// RDI_W=64 (legacy): 64b word <-> 4x16b via dw_cpl / 4-slice RX.
// Flit mode: RDI beats <-> flit <-> lanes. Default 128b beats x4 <->
//   512b flit <-> 32x16b. 256B mode: 256b beats x9 <-> 2304b flit
//   (32x64b payload + hdr/CRC + reserved pad) <-> 9x256b striped
//   (9 cycles at NLANES=16, 144 at NLANES=1).
//   TX collects TX_BEATS beats then shifts out LSB-first; RX accumulates
//   NCHUNK lane chunks then presents TX_BEATS beats (1-flit tolerance,
//   overflow latches).
module rdi_map #(
  parameter RDI_W = 64,
  parameter NLANES = 1,
  parameter int FLIT_W = 512
) (
  input         clock,
  input         reset,
  output        io_rdi_lpData_ready,
  input         io_rdi_lpData_valid,
  input         io_rdi_lpData_irdy,
  input  [RDI_W-1:0] io_rdi_lpData_bits,
  output        io_rdi_plData_valid,
  output [RDI_W-1:0] io_rdi_plData_bits,
  input         io_mainbandLaneIO_txData_ready,
  output        io_mainbandLaneIO_txData_valid,
  output [NLANES*16-1:0] io_mainbandLaneIO_txData_bits,
  input         io_mainbandLaneIO_rxData_valid,
  input  [NLANES*16-1:0] io_mainbandLaneIO_rxData_bits
);
generate if (RDI_W == 64) begin : gen_legacy
  // Legacy 64b path is single-lane only.
  initial begin
    if (NLANES != 1) $error("rdi_map legacy RDI_W=64 needs NLANES=1");
  end
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  wire  txWidthCoupler_clock;
  wire  txWidthCoupler_reset;
  wire  txWidthCoupler_io_in_ready;
  wire  txWidthCoupler_io_in_valid;
  wire [63:0] txWidthCoupler_io_in_bits;
  wire  txWidthCoupler_io_out_ready;
  wire  txWidthCoupler_io_out_valid;
  wire [15:0] txWidthCoupler_io_out_bits;
  reg [1:0] rxSliceCounter;
  reg [15:0] rxData_0;
  reg [15:0] rxData_1;
  reg [15:0] rxData_2;
  reg [15:0] rxData_3;
  reg  hasRxData;
  // Sticky overwrite flag: a completed word arrived while the previous
  // word was still presented (downstream samples a 1-cycle pulse with no
  // backpressure, so back-to-back completion loses data). Hierarchical
  // TB check (lane_pll_tb); no port churn.
  reg  rx_overwrite;
  wire [1:0] _T_1 = 2'h3 - rxSliceCounter;
  wire [1:0] _rxSliceCounter_T_1 = rxSliceCounter + 2'h1;
  wire  _T_2 = rxSliceCounter == 2'h3;
  wire  _GEN_11 = io_mainbandLaneIO_rxData_valid & _T_2;
  wire [31:0] io_rdi_plData_bits_lo = {rxData_1,rxData_0};
  wire [31:0] io_rdi_plData_bits_hi = {rxData_3,rxData_2};
  dw_cpl txWidthCoupler (
    .clock(txWidthCoupler_clock),
    .reset(txWidthCoupler_reset),
    .io_in_ready(txWidthCoupler_io_in_ready),
    .io_in_valid(txWidthCoupler_io_in_valid),
    .io_in_bits(txWidthCoupler_io_in_bits),
    .io_out_ready(txWidthCoupler_io_out_ready),
    .io_out_valid(txWidthCoupler_io_out_valid),
    .io_out_bits(txWidthCoupler_io_out_bits)
  );
  assign io_rdi_lpData_ready = txWidthCoupler_io_in_ready;
  assign io_rdi_plData_valid = hasRxData;
  assign io_rdi_plData_bits = {io_rdi_plData_bits_hi,io_rdi_plData_bits_lo};
  assign io_mainbandLaneIO_txData_valid = txWidthCoupler_io_out_valid;
  assign io_mainbandLaneIO_txData_bits = txWidthCoupler_io_out_bits;
  assign txWidthCoupler_clock = clock;
  assign txWidthCoupler_reset = reset;
  assign txWidthCoupler_io_in_valid = io_rdi_lpData_valid & io_rdi_lpData_irdy;
  assign txWidthCoupler_io_in_bits = io_rdi_lpData_bits;
  assign txWidthCoupler_io_out_ready = io_mainbandLaneIO_txData_ready;
  always @(posedge clock) begin
    if (reset) begin
      rxSliceCounter <= 2'h0;
    end else if (io_mainbandLaneIO_rxData_valid) begin
      if (rxSliceCounter == 2'h3) begin
        rxSliceCounter <= 2'h0;
      end else begin
        rxSliceCounter <= _rxSliceCounter_T_1;
      end
    end
    if (reset) begin
      rxData_0 <= 16'h0;
    end else if (io_mainbandLaneIO_rxData_valid) begin
      if (2'h0 == _T_1) begin
        rxData_0 <= io_mainbandLaneIO_rxData_bits;
      end
    end
    if (reset) begin
      rxData_1 <= 16'h0;
    end else if (io_mainbandLaneIO_rxData_valid) begin
      if (2'h1 == _T_1) begin
        rxData_1 <= io_mainbandLaneIO_rxData_bits;
      end
    end
    if (reset) begin
      rxData_2 <= 16'h0;
    end else if (io_mainbandLaneIO_rxData_valid) begin
      if (2'h2 == _T_1) begin
        rxData_2 <= io_mainbandLaneIO_rxData_bits;
      end
    end
    if (reset) begin
      rxData_3 <= 16'h0;
    end else if (io_mainbandLaneIO_rxData_valid) begin
      if (2'h3 == _T_1) begin
        rxData_3 <= io_mainbandLaneIO_rxData_bits;
      end
    end
    if (reset) begin
      hasRxData <= 1'h0;
    end else begin
      hasRxData <= _GEN_11;
    end
    // Latch overwrite (clear on reset only).
    if (reset) begin
      rx_overwrite <= 1'h0;
    end else if (_GEN_11 && hasRxData) begin
      rx_overwrite <= 1'h1;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  rxSliceCounter = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  rxData_0 = _RAND_1[15:0];
  _RAND_2 = {1{`RANDOM}};
  rxData_1 = _RAND_2[15:0];
  _RAND_3 = {1{`RANDOM}};
  rxData_2 = _RAND_3[15:0];
  _RAND_4 = {1{`RANDOM}};
  rxData_3 = _RAND_4[15:0];
  _RAND_5 = {1{`RANDOM}};
  hasRxData = _RAND_5[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
end else begin : gen_flit
  // ---- flit mode: RDI beats <-> flit <-> lanes ----
  // NLANES=1: serial 16b (legacy timing). NLANES=16: 256b striped.
  // CHUNK=NLANES*16 bits per lane-side cycle LSB-first.
  localparam int CHUNK = NLANES * 16;
  localparam int NCHUNK = FLIT_W / CHUNK;
  localparam int TX_BEATS = FLIT_W / RDI_W;
  localparam int CNT_W = (TX_BEATS <= 4) ? 3 : $clog2(TX_BEATS + 1);
  localparam int CH_W = (NCHUNK <= 32) ? 6 : $clog2(NCHUNK);
  initial begin
    if (FLIT_W % CHUNK != 0) $error("rdi_map flit: FLIT_W %% (NLANES*16) != 0");
    if (FLIT_W % RDI_W != 0) $error("rdi_map flit: FLIT_W %% RDI_W != 0");
  end
  reg [FLIT_W-1:0] tx_flit;
  reg [CNT_W-1:0] tx_beats;   // beats collected (0..TX_BEATS-1)
  reg tx_have;          // full flit ready to shift out
  reg [CH_W-1:0] tx_out;     // chunks emitted (0..NCHUNK-1)
  reg [FLIT_W-1:0] rx_acc;
  reg [CH_W-1:0] rx_cnt;     // chunks accumulated (0..NCHUNK-1)
  reg [FLIT_W-1:0] rx_out;
  reg [CNT_W-1:0] rx_left;    // beats left to present (0=idle)
  reg rx_ovf;

  wire tx_collect = (io_rdi_lpData_valid & io_rdi_lpData_irdy & ~tx_have);

  assign io_rdi_lpData_ready = ~tx_have;
  assign io_mainbandLaneIO_txData_valid = tx_have;
  assign io_mainbandLaneIO_txData_bits = tx_flit[tx_out*CHUNK+:CHUNK];
  assign io_rdi_plData_valid = (rx_left != CNT_W'(0));
  assign io_rdi_plData_bits = rx_out[(TX_BEATS-int'(rx_left))*RDI_W+:RDI_W];

  wire _unused_flit = &{rx_ovf, 1'b0};

  always @(posedge clock) begin
    if (reset) begin
      tx_flit <= {FLIT_W{1'b0}};
      tx_beats <= CNT_W'(0);
      tx_have <= 1'b0;
      tx_out <= CH_W'(0);
      rx_acc <= {FLIT_W{1'b0}};
      rx_cnt <= CH_W'(0);
      rx_out <= {FLIT_W{1'b0}};
      rx_left <= CNT_W'(0);
      rx_ovf <= 1'b0;
    end else begin
      // TX collect TX_BEATS beats.
      if (tx_collect) begin
        tx_flit[tx_beats*RDI_W+:RDI_W] <= io_rdi_lpData_bits;
        if (tx_beats == CNT_W'(TX_BEATS - 1)) begin
          tx_have <= 1'b1;
          tx_out <= CH_W'(0);
          tx_beats <= CNT_W'(0);
        end else begin
          tx_beats <= tx_beats + CNT_W'(1);
        end
      end
      // TX shift out LSB-first, one CHUNK per ready cycle.
      if (tx_have && io_mainbandLaneIO_txData_ready) begin
        if (tx_out == CH_W'(NCHUNK-1)) begin
          tx_have <= 1'b0;
        end else begin
          tx_out <= tx_out + CH_W'(1);
        end
      end
      // RX accumulate CHUNK-wide (shift-right: first chunk ends at LSB).
      if (io_mainbandLaneIO_rxData_valid) begin
        rx_acc <= {io_mainbandLaneIO_rxData_bits, rx_acc[FLIT_W-1:CHUNK]};
        if (rx_cnt == CH_W'(NCHUNK-1)) begin
          if (rx_left != CNT_W'(0)) begin
            rx_ovf <= 1'b1; // no room: drop (back-to-back flits)
          end else begin
            rx_out <= {io_mainbandLaneIO_rxData_bits, rx_acc[FLIT_W-1:CHUNK]};
            rx_left <= CNT_W'(TX_BEATS);
          end
          rx_cnt <= CH_W'(0);
        end else begin
          rx_cnt <= rx_cnt + CH_W'(1);
        end
      end
      // RX present beats (reasm side is always ready: 1 beat/cycle).
      if (rx_left != CNT_W'(0)) rx_left <= rx_left - CNT_W'(1);
    end
  end
end
endgenerate
endmodule
