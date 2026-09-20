module AsyncValidSync(
  input   io_in,
  output  io_out,
  input   clock,
  input   reset
);
  wire  io_out_source_valid_0_clock;
  wire  io_out_source_valid_0_reset;
  wire  io_out_source_valid_0_io_d;
  wire  io_out_source_valid_0_io_q;
  AsyncResetSynchronizerShiftReg_w1_d3_i0 io_out_source_valid_0 (
    .clock(io_out_source_valid_0_clock),
    .reset(io_out_source_valid_0_reset),
    .io_d(io_out_source_valid_0_io_d),
    .io_q(io_out_source_valid_0_io_q)
  );
  assign io_out = io_out_source_valid_0_io_q;
  assign io_out_source_valid_0_clock = clock;
  assign io_out_source_valid_0_reset = reset;
  assign io_out_source_valid_0_io_d = io_in;
endmodule
