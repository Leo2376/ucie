module AsyncResetSynchronizerShiftReg_w4_d3_i0(
  input        clock,
  input        reset,
  input  [3:0] io_d,
  output [3:0] io_q
);
  wire  output_chain_clock;
  wire  output_chain_reset;
  wire  output_chain_io_d;
  wire  output_chain_io_q;
  wire  output_chain_1_clock;
  wire  output_chain_1_reset;
  wire  output_chain_1_io_d;
  wire  output_chain_1_io_q;
  wire  output_chain_2_clock;
  wire  output_chain_2_reset;
  wire  output_chain_2_io_d;
  wire  output_chain_2_io_q;
  wire  output_chain_3_clock;
  wire  output_chain_3_reset;
  wire  output_chain_3_io_d;
  wire  output_chain_3_io_q;
  wire  output_1 = output_chain_1_io_q;
  wire  output_0 = output_chain_io_q;
  wire [1:0] io_q_lo = {output_1,output_0};
  wire  output_3 = output_chain_3_io_q;
  wire  output_2 = output_chain_2_io_q;
  wire [1:0] io_q_hi = {output_3,output_2};
  AsyncResetSynchronizerPrimitiveShiftReg_d3_i0 output_chain (
    .clock(output_chain_clock),
    .reset(output_chain_reset),
    .io_d(output_chain_io_d),
    .io_q(output_chain_io_q)
  );
  AsyncResetSynchronizerPrimitiveShiftReg_d3_i0 output_chain_1 (
    .clock(output_chain_1_clock),
    .reset(output_chain_1_reset),
    .io_d(output_chain_1_io_d),
    .io_q(output_chain_1_io_q)
  );
  AsyncResetSynchronizerPrimitiveShiftReg_d3_i0 output_chain_2 (
    .clock(output_chain_2_clock),
    .reset(output_chain_2_reset),
    .io_d(output_chain_2_io_d),
    .io_q(output_chain_2_io_q)
  );
  AsyncResetSynchronizerPrimitiveShiftReg_d3_i0 output_chain_3 (
    .clock(output_chain_3_clock),
    .reset(output_chain_3_reset),
    .io_d(output_chain_3_io_d),
    .io_q(output_chain_3_io_q)
  );
  assign io_q = {io_q_hi,io_q_lo};
  assign output_chain_clock = clock;
  assign output_chain_reset = reset;
  assign output_chain_io_d = io_d[0];
  assign output_chain_1_clock = clock;
  assign output_chain_1_reset = reset;
  assign output_chain_1_io_d = io_d[1];
  assign output_chain_2_clock = clock;
  assign output_chain_2_reset = reset;
  assign output_chain_2_io_d = io_d[2];
  assign output_chain_3_clock = clock;
  assign output_chain_3_reset = reset;
  assign output_chain_3_io_d = io_d[3];
endmodule
