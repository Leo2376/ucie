module sb_ser(
  input          clock,
  input          reset,
  output         io_in_ready,
  input          io_in_valid,
  input  [127:0] io_in_bits,
  output [31:0]  io_out_bits,
  output         io_out_valid,
  input          io_out_credit
);
`ifdef RANDOMIZE_REG_INIT
  reg [127:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [127:0] data;
  reg  sending;
  reg [1:0] sendCount;
  wire  wrap_wrap = sendCount == 2'h3;
  wire [1:0] _wrap_value_T_1 = sendCount + 2'h1;
  wire  sendDone = io_out_valid & wrap_wrap;
  reg [5:0] current_credit;
  reg  isComplete;
  wire [127:0] _io_in_ready_T_1 = io_in_bits & 128'h1f;
  wire  _io_in_ready_T_8 = 128'h10 == _io_in_ready_T_1 | 128'h11 == _io_in_ready_T_1 | 128'h19 == _io_in_ready_T_1;
  wire  _io_in_ready_T_9 = current_credit > 6'h0;
  wire  _io_in_ready_T_10 = _io_in_ready_T_8 | current_credit > 6'h0;
  wire  _T = io_in_ready & io_in_valid;
  wire  _GEN_3 = _T | sending;
  wire [127:0] _data_T = {{32'd0}, data[127:32]};
  wire [5:0] _current_credit_T_1 = current_credit - 6'h1;
  wire [5:0] _current_credit_T_3 = current_credit + 6'h1;
  assign io_in_ready = ~sending & _io_in_ready_T_10;
  assign io_out_bits = data[31:0];
  assign io_out_valid = (_io_in_ready_T_9 | isComplete) & sending;
  always @(posedge clock) begin
    if (io_out_valid) begin
      data <= _data_T;
    end else if (_T) begin
      data <= io_in_bits;
    end
    if (reset) begin
      sending <= 1'h0;
    end else if (sendDone) begin
      sending <= 1'h0;
    end else begin
      sending <= _GEN_3;
    end
    if (reset) begin
      sendCount <= 2'h0;
    end else if (io_out_valid) begin
      sendCount <= _wrap_value_T_1;
    end
    if (reset) begin
      current_credit <= 6'h20;
    end else if (io_out_credit) begin
      current_credit <= _current_credit_T_3;
    end else if (sendDone) begin
      if (~isComplete) begin
        current_credit <= _current_credit_T_1;
      end
    end
    if (reset) begin
      isComplete <= 1'h0;
    end else if (_T) begin
      isComplete <= _io_in_ready_T_8;
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
  _RAND_0 = {4{`RANDOM}};
  data = _RAND_0[127:0];
  _RAND_1 = {1{`RANDOM}};
  sending = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  sendCount = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  current_credit = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  isComplete = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
