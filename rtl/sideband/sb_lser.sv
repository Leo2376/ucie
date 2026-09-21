module sb_lser(
  input          clock,
  input          reset,
  output         io_in_ready,
  input          io_in_valid,
  input  [127:0] io_in_bits,
  output         io_out_bits,
  output         io_out_clock
);
`ifdef RANDOMIZE_REG_INIT
  reg [127:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [127:0] data;
  reg [4:0] counter;
  reg  done;
  wire  _T = io_in_ready & io_in_valid;
  wire  _counter_next_T = counter == 5'h1f;
  wire [4:0] _counter_next_T_2 = counter + 5'h1;
  reg  sending;
  reg  waited;
  reg [6:0] sendCount;
  // Minimum idle gap between bursts: the partner (and our own RX)
  // detects end-of-packet from sending dropping, so back-to-back
  // bursts need idle HCLK cycles in between. started_burst latches at
  // accept; gap counts sending==0 cycles after sendDone.
  reg [1:0] gap;
  wire gap_ok = (gap == 2'h3);
  wire  wrap_wrap = sendCount == 7'h7f;
  wire [6:0] _wrap_value_T_1 = sendCount + 7'h1;
  wire  sendDone = sending & wrap_wrap;
  wire  _GEN_4 = _T | sending;
  wire  _GEN_5 = _T ? 1'h0 : waited;
  // Ready only when fully idle: accepting mid-burst would dequeue
  // upstream (ready=1) while the shift path ignores the load (drop).
  // waited re-arms 32 cycles after burst start, so ~sending alone is
  // not sufficient; gap_ok enforces idle cycles after sendDone.
  wire  tx_idle = ~sending;
  wire [127:0] _data_T = {{1'd0}, data[127:1]};
  wire  _GEN_9 = sendDone | done;
  wire  _GEN_11 = done ? _counter_next_T : _GEN_5;
  assign io_in_ready = waited & tx_idle & gap_ok;
  assign io_out_bits = data[0];
  assign io_out_clock = sending & clock;
  always @(posedge clock) begin
    if (sending) begin
      data <= _data_T;
    end else if (_T) begin
      data <= io_in_bits;
    end
    if (reset) begin
      counter <= 5'h0;
    end else if (done) begin
      if (_T) begin
        counter <= 5'h0;
      end else if (counter == 5'h1f) begin
        counter <= 5'h1f;
      end else begin
        counter <= _counter_next_T_2;
      end
    end
    if (reset) begin
      done <= 1'h0;
    end else begin
      done <= _GEN_9;
    end
    if (reset) begin
      sending <= 1'h0;
    end else if (sendDone) begin
      sending <= 1'h0;
    end else begin
      sending <= _GEN_4;
    end
    waited <= reset | _GEN_11;
    if (reset) begin
      gap <= 2'h0;
    end else if (_T) begin
      gap <= 2'h0;
    end else if (~sending && gap != 2'h3) begin
      gap <= gap + 2'h1;
    end
    if (reset) begin
      sendCount <= 7'h0;
    end else if (sending) begin
      sendCount <= _wrap_value_T_1;
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
  counter = _RAND_1[4:0];
  _RAND_2 = {1{`RANDOM}};
  done = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  sending = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  waited = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  sendCount = _RAND_5[6:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
