module dw_cpl(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [63:0] io_in_bits,
  input         io_out_ready,
  output        io_out_valid,
  output [15:0] io_out_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [63:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg  currentState;
  reg [1:0] chunkCounter;
  reg [63:0] inData;
  wire  _T_3 = io_in_ready & io_in_valid;
  wire  _GEN_2 = _T_3 | currentState;
  wire [1:0] _io_out_bits_T_5 = 2'h3 - chunkCounter;
  wire [15:0] _GEN_4 = 2'h1 == _io_out_bits_T_5 ? inData[31:16] : inData[15:0];
  wire [15:0] _GEN_5 = 2'h2 == _io_out_bits_T_5 ? inData[47:32] : _GEN_4;
  wire  _T_7 = io_out_ready & io_out_valid;
  wire [1:0] _chunkCounter_T_1 = chunkCounter + 2'h1;
  wire  _GEN_7 = chunkCounter == 2'h3 ? 1'h0 : currentState;
  assign io_in_ready = ~currentState;
  assign io_out_valid = ~currentState ? 1'h0 : currentState;
  assign io_out_bits = 2'h3 == _io_out_bits_T_5 ? inData[63:48] : _GEN_5;
  always @(posedge clock) begin
    if (reset) begin
      currentState <= 1'h0;
    end else if (~currentState) begin
      currentState <= _GEN_2;
    end else if (currentState) begin
      if (_T_7) begin
        currentState <= _GEN_7;
      end
    end
    if (reset) begin
      chunkCounter <= 2'h0;
    end else if (~currentState) begin
      if (_T_3) begin
        chunkCounter <= 2'h0;
      end
    end else if (currentState) begin
      if (_T_7) begin
        chunkCounter <= _chunkCounter_T_1;
      end
    end
    if (reset) begin
      inData <= 64'h0;
    end else if (~currentState) begin
      if (_T_3) begin
        inData <= io_in_bits;
      end
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
  currentState = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  chunkCounter = _RAND_1[1:0];
  _RAND_2 = {2{`RANDOM}};
  inData = _RAND_2[63:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
