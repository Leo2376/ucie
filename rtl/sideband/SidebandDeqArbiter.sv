module SidebandDeqArbiter(
  input          io_out_ready,
  output         io_out_valid,
  output [127:0] io_out_bits,
  output         io_in_0_ready,
  input          io_in_0_valid,
  input  [127:0] io_in_0_bits,
  output         io_in_1_ready,
  input          io_in_1_valid,
  input  [127:0] io_in_1_bits,
  output         io_in_2_ready,
  input          io_in_2_valid,
  input  [127:0] io_in_2_bits
);
  wire  _GEN_1 = io_in_2_valid & io_out_ready;
  wire [127:0] _GEN_2 = io_in_2_valid ? io_in_2_bits : io_in_0_bits;
  wire  _GEN_4 = io_in_1_valid & io_out_ready;
  wire  _GEN_5 = io_in_1_valid ? 1'h0 : _GEN_1;
  wire [127:0] _GEN_6 = io_in_1_valid ? io_in_1_bits : _GEN_2;
  assign io_out_valid = io_in_0_valid | io_in_1_valid | io_in_2_valid;
  assign io_out_bits = io_in_0_valid ? io_in_0_bits : _GEN_6;
  assign io_in_0_ready = io_in_0_valid & io_out_ready;
  assign io_in_1_ready = io_in_0_valid ? 1'h0 : _GEN_4;
  assign io_in_2_ready = io_in_0_valid ? 1'h0 : _GEN_5;
endmodule
