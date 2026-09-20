module async_q1(
  input         io_enq_clock,
  input         io_enq_reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [15:0] io_enq_bits_0,
  input         io_deq_clock,
  input         io_deq_reset,
  output        io_deq_valid,
  output [15:0] io_deq_bits_0
);
  wire  source_clock;
  wire  source_reset;
  wire  source_io_enq_ready;
  wire  source_io_enq_valid;
  wire [15:0] source_io_enq_bits_0;
  wire [15:0] source_io_async_mem_0_0;
  wire [15:0] source_io_async_mem_1_0;
  wire [15:0] source_io_async_mem_2_0;
  wire [15:0] source_io_async_mem_3_0;
  wire [15:0] source_io_async_mem_4_0;
  wire [15:0] source_io_async_mem_5_0;
  wire [15:0] source_io_async_mem_6_0;
  wire [15:0] source_io_async_mem_7_0;
  wire [3:0] source_io_async_ridx;
  wire [3:0] source_io_async_widx;
  wire  source_io_async_safe_ridx_valid;
  wire  source_io_async_safe_widx_valid;
  wire  source_io_async_safe_source_reset_n;
  wire  source_io_async_safe_sink_reset_n;
  wire  sink_clock;
  wire  sink_reset;
  wire  sink_io_deq_ready;
  wire  sink_io_deq_valid;
  wire [15:0] sink_io_deq_bits_0;
  wire [15:0] sink_io_async_mem_0_0;
  wire [15:0] sink_io_async_mem_1_0;
  wire [15:0] sink_io_async_mem_2_0;
  wire [15:0] sink_io_async_mem_3_0;
  wire [15:0] sink_io_async_mem_4_0;
  wire [15:0] sink_io_async_mem_5_0;
  wire [15:0] sink_io_async_mem_6_0;
  wire [15:0] sink_io_async_mem_7_0;
  wire [3:0] sink_io_async_ridx;
  wire [3:0] sink_io_async_widx;
  wire  sink_io_async_safe_ridx_valid;
  wire  sink_io_async_safe_widx_valid;
  wire  sink_io_async_safe_source_reset_n;
  wire  sink_io_async_safe_sink_reset_n;
  AsyncQueueSource source (
    .clock(source_clock),
    .reset(source_reset),
    .io_enq_ready(source_io_enq_ready),
    .io_enq_valid(source_io_enq_valid),
    .io_enq_bits_0(source_io_enq_bits_0),
    .io_async_mem_0_0(source_io_async_mem_0_0),
    .io_async_mem_1_0(source_io_async_mem_1_0),
    .io_async_mem_2_0(source_io_async_mem_2_0),
    .io_async_mem_3_0(source_io_async_mem_3_0),
    .io_async_mem_4_0(source_io_async_mem_4_0),
    .io_async_mem_5_0(source_io_async_mem_5_0),
    .io_async_mem_6_0(source_io_async_mem_6_0),
    .io_async_mem_7_0(source_io_async_mem_7_0),
    .io_async_ridx(source_io_async_ridx),
    .io_async_widx(source_io_async_widx),
    .io_async_safe_ridx_valid(source_io_async_safe_ridx_valid),
    .io_async_safe_widx_valid(source_io_async_safe_widx_valid),
    .io_async_safe_source_reset_n(source_io_async_safe_source_reset_n),
    .io_async_safe_sink_reset_n(source_io_async_safe_sink_reset_n)
  );
  AsyncQueueSink sink (
    .clock(sink_clock),
    .reset(sink_reset),
    .io_deq_ready(sink_io_deq_ready),
    .io_deq_valid(sink_io_deq_valid),
    .io_deq_bits_0(sink_io_deq_bits_0),
    .io_async_mem_0_0(sink_io_async_mem_0_0),
    .io_async_mem_1_0(sink_io_async_mem_1_0),
    .io_async_mem_2_0(sink_io_async_mem_2_0),
    .io_async_mem_3_0(sink_io_async_mem_3_0),
    .io_async_mem_4_0(sink_io_async_mem_4_0),
    .io_async_mem_5_0(sink_io_async_mem_5_0),
    .io_async_mem_6_0(sink_io_async_mem_6_0),
    .io_async_mem_7_0(sink_io_async_mem_7_0),
    .io_async_ridx(sink_io_async_ridx),
    .io_async_widx(sink_io_async_widx),
    .io_async_safe_ridx_valid(sink_io_async_safe_ridx_valid),
    .io_async_safe_widx_valid(sink_io_async_safe_widx_valid),
    .io_async_safe_source_reset_n(sink_io_async_safe_source_reset_n),
    .io_async_safe_sink_reset_n(sink_io_async_safe_sink_reset_n)
  );
  assign io_enq_ready = source_io_enq_ready;
  assign io_deq_valid = sink_io_deq_valid;
  assign io_deq_bits_0 = sink_io_deq_bits_0;
  assign source_clock = io_enq_clock;
  assign source_reset = io_enq_reset;
  assign source_io_enq_valid = io_enq_valid;
  assign source_io_enq_bits_0 = io_enq_bits_0;
  assign source_io_async_ridx = sink_io_async_ridx;
  assign source_io_async_safe_ridx_valid = sink_io_async_safe_ridx_valid;
  assign source_io_async_safe_sink_reset_n = sink_io_async_safe_sink_reset_n;
  assign sink_clock = io_deq_clock;
  assign sink_reset = io_deq_reset;
  assign sink_io_deq_ready = 1'h1;
  assign sink_io_async_mem_0_0 = source_io_async_mem_0_0;
  assign sink_io_async_mem_1_0 = source_io_async_mem_1_0;
  assign sink_io_async_mem_2_0 = source_io_async_mem_2_0;
  assign sink_io_async_mem_3_0 = source_io_async_mem_3_0;
  assign sink_io_async_mem_4_0 = source_io_async_mem_4_0;
  assign sink_io_async_mem_5_0 = source_io_async_mem_5_0;
  assign sink_io_async_mem_6_0 = source_io_async_mem_6_0;
  assign sink_io_async_mem_7_0 = source_io_async_mem_7_0;
  assign sink_io_async_widx = source_io_async_widx;
  assign sink_io_async_safe_widx_valid = source_io_async_safe_widx_valid;
  assign sink_io_async_safe_source_reset_n = source_io_async_safe_source_reset_n;
endmodule
