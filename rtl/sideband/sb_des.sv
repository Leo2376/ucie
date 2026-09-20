module sb_des(
  input          clock,
  input          reset,
  input  [31:0]  io_in_bits,
  input          io_in_valid,
  output         io_out_valid,
  output [127:0] io_out_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [31:0] data_0;
  reg [31:0] data_1;
  reg [31:0] data_2;
  reg [31:0] data_3;
  reg  receiving;
  reg [1:0] recvCount;
  wire  wrap_wrap = recvCount == 2'h3;
  wire [1:0] _wrap_value_T_1 = recvCount + 2'h1;
  wire  recvDone = io_in_valid & wrap_wrap;
  wire [63:0] io_out_bits_lo = {data_1,data_0};
  wire [63:0] io_out_bits_hi = {data_3,data_2};
  wire  _GEN_10 = recvDone ? 1'h0 : receiving;
  wire  _GEN_11 = io_out_valid | _GEN_10;
  assign io_out_valid = ~receiving;
  assign io_out_bits = {io_out_bits_hi,io_out_bits_lo};
  always @(posedge clock) begin
    if (io_in_valid) begin
      if (2'h0 == recvCount) begin
        data_0 <= io_in_bits;
      end
    end
    if (io_in_valid) begin
      if (2'h1 == recvCount) begin
        data_1 <= io_in_bits;
      end
    end
    if (io_in_valid) begin
      if (2'h2 == recvCount) begin
        data_2 <= io_in_bits;
      end
    end
    if (io_in_valid) begin
      if (2'h3 == recvCount) begin
        data_3 <= io_in_bits;
      end
    end
    receiving <= reset | _GEN_11;
    if (reset) begin
      recvCount <= 2'h0;
    end else if (io_in_valid) begin
      recvCount <= _wrap_value_T_1;
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
  data_0 = _RAND_0[31:0];
  _RAND_1 = {1{`RANDOM}};
  data_1 = _RAND_1[31:0];
  _RAND_2 = {1{`RANDOM}};
  data_2 = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  data_3 = _RAND_3[31:0];
  _RAND_4 = {1{`RANDOM}};
  receiving = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  recvCount = _RAND_5[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
