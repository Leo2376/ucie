module AsyncQueueSource(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [15:0] io_enq_bits_0,
  output [15:0] io_async_mem_0_0,
  output [15:0] io_async_mem_1_0,
  output [15:0] io_async_mem_2_0,
  output [15:0] io_async_mem_3_0,
  output [15:0] io_async_mem_4_0,
  output [15:0] io_async_mem_5_0,
  output [15:0] io_async_mem_6_0,
  output [15:0] io_async_mem_7_0,
  input  [3:0]  io_async_ridx,
  output [3:0]  io_async_widx,
  input         io_async_safe_ridx_valid,
  output        io_async_safe_widx_valid,
  output        io_async_safe_source_reset_n,
  input         io_async_safe_sink_reset_n
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  wire  ridx_ridx_gray_clock;
  wire  ridx_ridx_gray_reset;
  wire [3:0] ridx_ridx_gray_io_d;
  wire [3:0] ridx_ridx_gray_io_q;
  wire  source_valid_0_io_in;
  wire  source_valid_0_io_out;
  wire  source_valid_0_clock;
  wire  source_valid_0_reset;
  wire  source_valid_1_io_in;
  wire  source_valid_1_io_out;
  wire  source_valid_1_clock;
  wire  source_valid_1_reset;
  wire  sink_extend_io_in;
  wire  sink_extend_io_out;
  wire  sink_extend_clock;
  wire  sink_extend_reset;
  wire  sink_valid_io_in;
  wire  sink_valid_io_out;
  wire  sink_valid_clock;
  wire  sink_valid_reset;
  reg [15:0] mem_0_0;
  reg [15:0] mem_1_0;
  reg [15:0] mem_2_0;
  reg [15:0] mem_3_0;
  reg [15:0] mem_4_0;
  reg [15:0] mem_5_0;
  reg [15:0] mem_6_0;
  reg [15:0] mem_7_0;
  wire  _widx_T_1 = io_enq_ready & io_enq_valid;
  wire  sink_ready = sink_valid_io_out;
  wire  _widx_T_2 = ~sink_ready;
  reg [3:0] widx_widx_bin;
  wire [3:0] _GEN_16 = {{3'd0}, _widx_T_1};
  wire [3:0] _widx_incremented_T_1 = widx_widx_bin + _GEN_16;
  wire [3:0] widx_incremented = _widx_T_2 ? 4'h0 : _widx_incremented_T_1;
  wire [3:0] _GEN_17 = {{1'd0}, widx_incremented[3:1]};
  wire [3:0] widx = widx_incremented ^ _GEN_17;
  wire [3:0] ridx = ridx_ridx_gray_io_q;
  wire [3:0] _ready_T = ridx ^ 4'hc;
  wire [2:0] _index_T_2 = {io_async_widx[3], 2'h0};
  wire [2:0] index = io_async_widx[2:0] ^ _index_T_2;
  reg  ready_reg;
  reg [3:0] widx_gray;
  AsyncResetSynchronizerShiftReg_w4_d3_i0 ridx_ridx_gray (
    .clock(ridx_ridx_gray_clock),
    .reset(ridx_ridx_gray_reset),
    .io_d(ridx_ridx_gray_io_d),
    .io_q(ridx_ridx_gray_io_q)
  );
  AsyncValidSync source_valid_0 (
    .io_in(source_valid_0_io_in),
    .io_out(source_valid_0_io_out),
    .clock(source_valid_0_clock),
    .reset(source_valid_0_reset)
  );
  AsyncValidSync source_valid_1 (
    .io_in(source_valid_1_io_in),
    .io_out(source_valid_1_io_out),
    .clock(source_valid_1_clock),
    .reset(source_valid_1_reset)
  );
  AsyncValidSync sink_extend (
    .io_in(sink_extend_io_in),
    .io_out(sink_extend_io_out),
    .clock(sink_extend_clock),
    .reset(sink_extend_reset)
  );
  AsyncValidSync sink_valid (
    .io_in(sink_valid_io_in),
    .io_out(sink_valid_io_out),
    .clock(sink_valid_clock),
    .reset(sink_valid_reset)
  );
  assign io_enq_ready = ready_reg & sink_ready;
  assign io_async_mem_0_0 = mem_0_0;
  assign io_async_mem_1_0 = mem_1_0;
  assign io_async_mem_2_0 = mem_2_0;
  assign io_async_mem_3_0 = mem_3_0;
  assign io_async_mem_4_0 = mem_4_0;
  assign io_async_mem_5_0 = mem_5_0;
  assign io_async_mem_6_0 = mem_6_0;
  assign io_async_mem_7_0 = mem_7_0;
  assign io_async_widx = widx_gray;
  assign io_async_safe_widx_valid = source_valid_1_io_out;
  assign io_async_safe_source_reset_n = ~reset;
  assign ridx_ridx_gray_clock = clock;
  assign ridx_ridx_gray_reset = reset;
  assign ridx_ridx_gray_io_d = io_async_ridx;
  assign source_valid_0_io_in = 1'h1;
  assign source_valid_0_clock = clock;
  assign source_valid_0_reset = reset | ~io_async_safe_sink_reset_n;
  assign source_valid_1_io_in = source_valid_0_io_out;
  assign source_valid_1_clock = clock;
  assign source_valid_1_reset = reset | ~io_async_safe_sink_reset_n;
  assign sink_extend_io_in = io_async_safe_ridx_valid;
  assign sink_extend_clock = clock;
  assign sink_extend_reset = reset | ~io_async_safe_sink_reset_n;
  assign sink_valid_io_in = sink_extend_io_out;
  assign sink_valid_clock = clock;
  assign sink_valid_reset = reset;
  always @(posedge clock) begin
    if (_widx_T_1) begin
      if (3'h0 == index) begin
        mem_0_0 <= io_enq_bits_0;
      end
    end
    if (_widx_T_1) begin
      if (3'h1 == index) begin
        mem_1_0 <= io_enq_bits_0;
      end
    end
    if (_widx_T_1) begin
      if (3'h2 == index) begin
        mem_2_0 <= io_enq_bits_0;
      end
    end
    if (_widx_T_1) begin
      if (3'h3 == index) begin
        mem_3_0 <= io_enq_bits_0;
      end
    end
    if (_widx_T_1) begin
      if (3'h4 == index) begin
        mem_4_0 <= io_enq_bits_0;
      end
    end
    if (_widx_T_1) begin
      if (3'h5 == index) begin
        mem_5_0 <= io_enq_bits_0;
      end
    end
    if (_widx_T_1) begin
      if (3'h6 == index) begin
        mem_6_0 <= io_enq_bits_0;
      end
    end
    if (_widx_T_1) begin
      if (3'h7 == index) begin
        mem_7_0 <= io_enq_bits_0;
      end
    end
  end
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      widx_widx_bin <= 4'h0;
    end else if (_widx_T_2) begin
      widx_widx_bin <= 4'h0;
    end else begin
      widx_widx_bin <= _widx_incremented_T_1;
    end
  end
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      ready_reg <= 1'h0;
    end else begin
      ready_reg <= sink_ready & widx != _ready_T;
    end
  end
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      widx_gray <= 4'h0;
    end else begin
      widx_gray <= widx_incremented ^ _GEN_17;
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
  mem_0_0 = _RAND_0[15:0];
  _RAND_1 = {1{`RANDOM}};
  mem_1_0 = _RAND_1[15:0];
  _RAND_2 = {1{`RANDOM}};
  mem_2_0 = _RAND_2[15:0];
  _RAND_3 = {1{`RANDOM}};
  mem_3_0 = _RAND_3[15:0];
  _RAND_4 = {1{`RANDOM}};
  mem_4_0 = _RAND_4[15:0];
  _RAND_5 = {1{`RANDOM}};
  mem_5_0 = _RAND_5[15:0];
  _RAND_6 = {1{`RANDOM}};
  mem_6_0 = _RAND_6[15:0];
  _RAND_7 = {1{`RANDOM}};
  mem_7_0 = _RAND_7[15:0];
  _RAND_8 = {1{`RANDOM}};
  widx_widx_bin = _RAND_8[3:0];
  _RAND_9 = {1{`RANDOM}};
  ready_reg = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  widx_gray = _RAND_10[3:0];
`endif // RANDOMIZE_REG_INIT
  if (reset) begin
    widx_widx_bin = 4'h0;
  end
  if (reset) begin
    ready_reg = 1'h0;
  end
  if (reset) begin
    widx_gray = 4'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
