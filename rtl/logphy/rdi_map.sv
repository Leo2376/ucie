module rdi_map(
  input         clock,
  input         reset,
  output        io_rdi_lpData_ready,
  input         io_rdi_lpData_valid,
  input         io_rdi_lpData_irdy,
  input  [63:0] io_rdi_lpData_bits,
  output        io_rdi_plData_valid,
  output [63:0] io_rdi_plData_bits,
  input         io_mainbandLaneIO_txData_ready,
  output        io_mainbandLaneIO_txData_valid,
  output [15:0] io_mainbandLaneIO_txData_bits,
  input         io_mainbandLaneIO_rxData_valid,
  input  [15:0] io_mainbandLaneIO_rxData_bits
);
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
endmodule
