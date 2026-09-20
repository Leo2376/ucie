module sb_prioq(
  input          clock,
  input          reset,
  input          io_enq_valid,
  input  [127:0] io_enq_bits,
  input          io_deq_ready,
  output         io_deq_valid,
  output [127:0] io_deq_bits
);
  wire  p0_queue_clock;
  wire  p0_queue_reset;
  wire  p0_queue_io_enq_ready;
  wire  p0_queue_io_enq_valid;
  wire [127:0] p0_queue_io_enq_bits;
  wire  p0_queue_io_deq_ready;
  wire  p0_queue_io_deq_valid;
  wire [127:0] p0_queue_io_deq_bits;
  wire  p1_queue_clock;
  wire  p1_queue_reset;
  wire  p1_queue_io_enq_ready;
  wire  p1_queue_io_enq_valid;
  wire [127:0] p1_queue_io_enq_bits;
  wire  p1_queue_io_deq_ready;
  wire  p1_queue_io_deq_valid;
  wire [127:0] p1_queue_io_deq_bits;
  wire  p2_queue_clock;
  wire  p2_queue_reset;
  wire  p2_queue_io_enq_ready;
  wire  p2_queue_io_enq_valid;
  wire [127:0] p2_queue_io_enq_bits;
  wire  p2_queue_io_deq_ready;
  wire  p2_queue_io_deq_valid;
  wire [127:0] p2_queue_io_deq_bits;
  wire  enq_arb_io_out_0_valid;
  wire [127:0] enq_arb_io_out_0_bits;
  wire  enq_arb_io_out_1_valid;
  wire [127:0] enq_arb_io_out_1_bits;
  wire  enq_arb_io_out_2_valid;
  wire [127:0] enq_arb_io_out_2_bits;
  wire  enq_arb_io_in_valid;
  wire [127:0] enq_arb_io_in_bits;
  wire  deq_arb_io_out_ready;
  wire  deq_arb_io_out_valid;
  wire [127:0] deq_arb_io_out_bits;
  wire  deq_arb_io_in_0_ready;
  wire  deq_arb_io_in_0_valid;
  wire [127:0] deq_arb_io_in_0_bits;
  wire  deq_arb_io_in_1_ready;
  wire  deq_arb_io_in_1_valid;
  wire [127:0] deq_arb_io_in_1_bits;
  wire  deq_arb_io_in_2_ready;
  wire  deq_arb_io_in_2_valid;
  wire [127:0] deq_arb_io_in_2_bits;
  Queue p0_queue (
    .clock(p0_queue_clock),
    .reset(p0_queue_reset),
    .io_enq_ready(p0_queue_io_enq_ready),
    .io_enq_valid(p0_queue_io_enq_valid),
    .io_enq_bits(p0_queue_io_enq_bits),
    .io_deq_ready(p0_queue_io_deq_ready),
    .io_deq_valid(p0_queue_io_deq_valid),
    .io_deq_bits(p0_queue_io_deq_bits)
  );
  Queue_1 p1_queue (
    .clock(p1_queue_clock),
    .reset(p1_queue_reset),
    .io_enq_ready(p1_queue_io_enq_ready),
    .io_enq_valid(p1_queue_io_enq_valid),
    .io_enq_bits(p1_queue_io_enq_bits),
    .io_deq_ready(p1_queue_io_deq_ready),
    .io_deq_valid(p1_queue_io_deq_valid),
    .io_deq_bits(p1_queue_io_deq_bits)
  );
  Queue_1 p2_queue (
    .clock(p2_queue_clock),
    .reset(p2_queue_reset),
    .io_enq_ready(p2_queue_io_enq_ready),
    .io_enq_valid(p2_queue_io_enq_valid),
    .io_enq_bits(p2_queue_io_enq_bits),
    .io_deq_ready(p2_queue_io_deq_ready),
    .io_deq_valid(p2_queue_io_deq_valid),
    .io_deq_bits(p2_queue_io_deq_bits)
  );
  SidebandEnqArbiter enq_arb (
    .io_out_0_valid(enq_arb_io_out_0_valid),
    .io_out_0_bits(enq_arb_io_out_0_bits),
    .io_out_1_valid(enq_arb_io_out_1_valid),
    .io_out_1_bits(enq_arb_io_out_1_bits),
    .io_out_2_valid(enq_arb_io_out_2_valid),
    .io_out_2_bits(enq_arb_io_out_2_bits),
    .io_in_valid(enq_arb_io_in_valid),
    .io_in_bits(enq_arb_io_in_bits)
  );
  SidebandDeqArbiter deq_arb (
    .io_out_ready(deq_arb_io_out_ready),
    .io_out_valid(deq_arb_io_out_valid),
    .io_out_bits(deq_arb_io_out_bits),
    .io_in_0_ready(deq_arb_io_in_0_ready),
    .io_in_0_valid(deq_arb_io_in_0_valid),
    .io_in_0_bits(deq_arb_io_in_0_bits),
    .io_in_1_ready(deq_arb_io_in_1_ready),
    .io_in_1_valid(deq_arb_io_in_1_valid),
    .io_in_1_bits(deq_arb_io_in_1_bits),
    .io_in_2_ready(deq_arb_io_in_2_ready),
    .io_in_2_valid(deq_arb_io_in_2_valid),
    .io_in_2_bits(deq_arb_io_in_2_bits)
  );
  assign io_deq_valid = deq_arb_io_out_valid;
  assign io_deq_bits = deq_arb_io_out_bits;
  assign p0_queue_clock = clock;
  assign p0_queue_reset = reset;
  assign p0_queue_io_enq_valid = enq_arb_io_out_0_valid;
  assign p0_queue_io_enq_bits = enq_arb_io_out_0_bits;
  assign p0_queue_io_deq_ready = deq_arb_io_in_0_ready;
  assign p1_queue_clock = clock;
  assign p1_queue_reset = reset;
  assign p1_queue_io_enq_valid = enq_arb_io_out_1_valid;
  assign p1_queue_io_enq_bits = enq_arb_io_out_1_bits;
  assign p1_queue_io_deq_ready = deq_arb_io_in_1_ready;
  assign p2_queue_clock = clock;
  assign p2_queue_reset = reset;
  assign p2_queue_io_enq_valid = enq_arb_io_out_2_valid;
  assign p2_queue_io_enq_bits = enq_arb_io_out_2_bits;
  assign p2_queue_io_deq_ready = deq_arb_io_in_2_ready;
  assign enq_arb_io_in_valid = io_enq_valid;
  assign enq_arb_io_in_bits = io_enq_bits;
  assign deq_arb_io_out_ready = io_deq_ready;
  assign deq_arb_io_in_0_valid = p0_queue_io_deq_valid;
  assign deq_arb_io_in_0_bits = p0_queue_io_deq_bits;
  assign deq_arb_io_in_1_valid = p1_queue_io_deq_valid;
  assign deq_arb_io_in_1_bits = p1_queue_io_deq_bits;
  assign deq_arb_io_in_2_valid = p2_queue_io_deq_valid;
  assign deq_arb_io_in_2_bits = p2_queue_io_deq_bits;
endmodule
