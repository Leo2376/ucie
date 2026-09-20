module SidebandEnqArbiter(
  output         io_out_0_valid,
  output [127:0] io_out_0_bits,
  output         io_out_1_valid,
  output [127:0] io_out_1_bits,
  output         io_out_2_valid,
  output [127:0] io_out_2_bits,
  input          io_in_valid,
  input  [127:0] io_in_bits
);
  wire [127:0] _io_out_0_valid_T = io_in_bits & 128'h1f;
  wire  _io_out_0_valid_T_7 = 128'h10 == _io_out_0_valid_T | 128'h11 == _io_out_0_valid_T | 128'h19 == _io_out_0_valid_T
    ;
  wire  _io_out_1_valid_T_4 = 128'h12 == _io_out_0_valid_T | 128'h1b == _io_out_0_valid_T;
  wire  _io_out_2_valid_T_1 = ~io_in_bits[4];
  assign io_out_0_valid = io_in_valid & _io_out_0_valid_T_7;
  assign io_out_0_bits = io_in_bits;
  assign io_out_1_valid = io_in_valid & _io_out_1_valid_T_4;
  assign io_out_1_bits = io_in_bits;
  assign io_out_2_valid = io_in_valid & _io_out_2_valid_T_1;
  assign io_out_2_bits = io_in_bits;
endmodule
