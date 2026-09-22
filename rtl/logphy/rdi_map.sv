// rdi_map: RDI <-> mainband-lane width conversion.
//
// RDI_W=64 (legacy): 64b word <-> 4x16b via dw_cpl / 4-slice RX.
// RDI_W=128 (flit mode): 128b beats x4 <-> 512b flit <-> 32x16b.
//   TX collects 4 beats then shifts out LSB-first; RX accumulates 32x16b
//   then presents 4x128b beats (1-flit tolerance, overflow latches).
module rdi_map #(
  parameter RDI_W = 64,
  parameter NLANES = 1
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
end else begin : gen_flit128
  // ---- 128b flit mode: 4x128b beats <-> 512b flit <-> lanes ----
  // NLANES=1: 32x16b serial (legacy timing). NLANES=16: 2x256b striped
  // (2 cycles/flit). CHUNK=NLANES*16 bits per lane-side cycle LSB-first.
  localparam int CHUNK = NLANES * 16;
  localparam int NCHUNK = 512 / CHUNK;
  initial begin
    if (512 % CHUNK != 0) $error("rdi_map flit128: 512 %% (NLANES*16) != 0");
  end
  reg [511:0] tx_flit;
  reg [2:0] tx_beats;   // beats collected (0..4)
  reg tx_have;          // full flit ready to shift out
  reg [5:0] tx_out;     // chunks emitted (0..NCHUNK-1)
  reg [511:0] rx_acc;
  reg [5:0] rx_cnt;     // chunks accumulated (0..NCHUNK-1)
  reg [511:0] rx_out;
  reg [2:0] rx_left;    // 128b beats left to present (0=idle)
  reg rx_ovf;

  wire tx_collect = (io_rdi_lpData_valid & io_rdi_lpData_irdy & ~tx_have);
  wire [127:0] rx_beat0 = rx_out[127:0];
  wire [127:0] rx_beat1 = rx_out[255:128];
  wire [127:0] rx_beat2 = rx_out[383:256];
  wire [127:0] rx_beat3 = rx_out[511:384];

  assign io_rdi_lpData_ready = ~tx_have;
  assign io_mainbandLaneIO_txData_valid = tx_have;
  assign io_mainbandLaneIO_txData_bits = tx_flit[tx_out*CHUNK+:CHUNK];
  assign io_rdi_plData_valid = (rx_left != 3'd0);
  assign io_rdi_plData_bits = (rx_left == 3'd4) ? rx_beat0 :
                              (rx_left == 3'd3) ? rx_beat1 :
                              (rx_left == 3'd2) ? rx_beat2 : rx_beat3;

  wire _unused_flit = &{rx_ovf, 1'b0};

  always @(posedge clock) begin
    if (reset) begin
      tx_flit <= 512'h0;
      tx_beats <= 3'd0;
      tx_have <= 1'b0;
      tx_out <= 6'd0;
      rx_acc <= 512'h0;
      rx_cnt <= 6'd0;
      rx_out <= 512'h0;
      rx_left <= 3'd0;
      rx_ovf <= 1'b0;
    end else begin
      // TX collect 4 beats.
      if (tx_collect) begin
        case (tx_beats)
          3'd0: tx_flit[127:0] <= io_rdi_lpData_bits;
          3'd1: tx_flit[255:128] <= io_rdi_lpData_bits;
          3'd2: tx_flit[383:256] <= io_rdi_lpData_bits;
          3'd3: tx_flit[511:384] <= io_rdi_lpData_bits;
          default: ;
        endcase
        if (tx_beats == 3'd3) begin
          tx_have <= 1'b1;
          tx_out <= 6'd0;
          tx_beats <= 3'd0;
        end else begin
          tx_beats <= tx_beats + 3'd1;
        end
      end
      // TX shift out LSB-first, one CHUNK per ready cycle.
      if (tx_have && io_mainbandLaneIO_txData_ready) begin
        if (tx_out == 6'(NCHUNK-1)) begin
          tx_have <= 1'b0;
        end else begin
          tx_out <= tx_out + 6'd1;
        end
      end
      // RX accumulate CHUNK-wide (shift-right: first chunk ends at LSB).
      if (io_mainbandLaneIO_rxData_valid) begin
        rx_acc <= {io_mainbandLaneIO_rxData_bits, rx_acc[511:CHUNK]};
        if (rx_cnt == 6'(NCHUNK-1)) begin
          if (rx_left != 3'd0) begin
            rx_ovf <= 1'b1; // no room: drop (back-to-back flits)
          end else begin
            rx_out <= {io_mainbandLaneIO_rxData_bits, rx_acc[511:CHUNK]};
            rx_left <= 3'd4;
          end
          rx_cnt <= 6'd0;
        end else begin
          rx_cnt <= rx_cnt + 6'd1;
        end
      end
      // RX present 4 beats (reasm side is always ready: 1 beat/cycle).
      if (rx_left != 3'd0) rx_left <= rx_left - 3'd1;
    end
  end
end
endgenerate
endmodule
