module AsyncResetSynchronizerShiftReg_w1_d3_i0(
  input   clock,
  input   reset,
  input   io_d,
  output  io_q
);
  wire  output_chain_clock;
  wire  output_chain_reset;
  wire  output_chain_io_d;
  wire  output_chain_io_q;
  AsyncResetSynchronizerPrimitiveShiftReg_d3_i0 output_chain (
    .clock(output_chain_clock),
    .reset(output_chain_reset),
    .io_d(output_chain_io_d),
    .io_q(output_chain_io_q)
  );
  assign io_q = output_chain_io_q;
  assign output_chain_clock = clock;
  assign output_chain_reset = reset;
  assign output_chain_io_d = io_d;
endmodule
