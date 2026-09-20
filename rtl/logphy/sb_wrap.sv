module sb_wrap(
  input          clock,
  input          reset,
  output         io_trainIO_msgReq_ready,
  input          io_trainIO_msgReq_valid,
  input  [127:0] io_trainIO_msgReq_bits_msg,
  input  [63:0]  io_trainIO_msgReq_bits_timeoutCycles,
  input          io_trainIO_msgReqStatus_ready,
  output         io_trainIO_msgReqStatus_valid,
  input          io_laneIO_txData_ready,
  output         io_laneIO_txData_valid,
  output [127:0] io_laneIO_txData_bits,
  output         io_laneIO_rxData_ready,
  input          io_laneIO_rxData_valid,
  input  [127:0] io_laneIO_rxData_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [63:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [63:0] _RAND_4;
  reg [127:0] _RAND_5;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] currentState;
  reg [63:0] timeoutCounter;
  reg  sentMsg;
  reg  receivedMsg;
  wire  _T_3 = 2'h0 == currentState;
  wire  _T_4 = io_trainIO_msgReq_ready & io_trainIO_msgReq_valid;
  wire [1:0] _GEN_5 = _T_4 ? 2'h1 : currentState;
  wire  _T_7 = 2'h1 == currentState;
  reg [63:0] currentReqTimeoutMax;
  wire  _justReceivedMsg_T = io_laneIO_rxData_ready & io_laneIO_rxData_valid;
  reg [127:0] currentReq;
  wire  _justReceivedMsg_T_8 = io_laneIO_rxData_bits[21:14] == currentReq[21:14];
  wire  _justReceivedMsg_T_9 = io_laneIO_rxData_bits[4:0] == currentReq[4:0] & _justReceivedMsg_T_8;
  wire  _justReceivedMsg_T_12 = io_laneIO_rxData_bits[39:32] == currentReq[39:32];
  wire  _justReceivedMsg_T_13 = _justReceivedMsg_T_9 & _justReceivedMsg_T_12;
  wire  justReceivedMsg = _justReceivedMsg_T & _justReceivedMsg_T_13;
  wire  hasReceivedMsg = justReceivedMsg | receivedMsg;
  wire  _hasSentMsg_T = io_laneIO_txData_ready & io_laneIO_txData_valid;
  wire  hasSentMsg = _hasSentMsg_T | sentMsg;
  wire [1:0] _GEN_8 = hasReceivedMsg & hasSentMsg ? 2'h2 : currentState;
  wire [1:0] _GEN_9 = timeoutCounter == currentReqTimeoutMax ? 2'h2 : _GEN_8;
  wire  _T_12 = 2'h2 == currentState;
  wire  _T_15 = io_trainIO_msgReqStatus_ready & io_trainIO_msgReqStatus_valid;
  wire [1:0] _GEN_11 = _T_15 ? 2'h0 : currentState;
  wire [1:0] _GEN_13 = 2'h2 == currentState ? _GEN_11 : currentState;
  wire [1:0] _GEN_20 = 2'h1 == currentState ? _GEN_9 : _GEN_13;
  wire [1:0] nextState = 2'h0 == currentState ? _GEN_5 : _GEN_20;
  wire [63:0] _GEN_0 = currentState != nextState ? 64'h0 : timeoutCounter;
  wire  _GEN_1 = currentState != nextState ? 1'h0 : sentMsg;
  wire  _GEN_2 = currentState != nextState ? 1'h0 : receivedMsg;
  wire [63:0] _timeoutCounter_T_1 = timeoutCounter + 64'h1;
  wire  _GEN_22 = 2'h1 == currentState ? 1'h0 : 2'h2 == currentState;
  assign io_trainIO_msgReq_ready = 2'h0 == currentState;
  assign io_trainIO_msgReqStatus_valid = 2'h0 == currentState ? 1'h0 : _GEN_22;
  assign io_laneIO_txData_valid = 2'h0 == currentState ? 1'h0 : 2'h1 == currentState;
  assign io_laneIO_txData_bits = currentReq;
  assign io_laneIO_rxData_ready = 2'h0 == currentState ? 1'h0 : 2'h1 == currentState;
  always @(posedge clock) begin
    if (reset) begin
      currentState <= 2'h0;
    end else if (2'h0 == currentState) begin
      if (_T_4) begin
        currentState <= 2'h1;
      end
    end else if (2'h1 == currentState) begin
      if (timeoutCounter == currentReqTimeoutMax) begin
        currentState <= 2'h2;
      end else begin
        currentState <= _GEN_8;
      end
    end else if (2'h2 == currentState) begin
      currentState <= _GEN_11;
    end
    if (reset) begin
      timeoutCounter <= 64'h0;
    end else if (2'h0 == currentState) begin
      timeoutCounter <= _GEN_0;
    end else if (2'h1 == currentState) begin
      timeoutCounter <= _timeoutCounter_T_1;
    end else begin
      timeoutCounter <= _GEN_0;
    end
    if (reset) begin
      sentMsg <= 1'h0;
    end else if (2'h0 == currentState) begin
      sentMsg <= _GEN_1;
    end else if (2'h1 == currentState) begin
      sentMsg <= hasSentMsg;
    end else begin
      sentMsg <= _GEN_1;
    end
    if (reset) begin
      receivedMsg <= 1'h0;
    end else if (2'h0 == currentState) begin
      receivedMsg <= _GEN_2;
    end else if (2'h1 == currentState) begin
      receivedMsg <= hasReceivedMsg;
    end else begin
      receivedMsg <= _GEN_2;
    end
    if (reset) begin
      currentReqTimeoutMax <= 64'h0;
    end else if (2'h0 == currentState) begin
      if (_T_4) begin
        currentReqTimeoutMax <= io_trainIO_msgReq_bits_timeoutCycles;
      end
    end
    if (reset) begin
      currentReq <= 128'h0;
    end else if (2'h0 == currentState) begin
      if (_T_4) begin
        currentReq <= io_trainIO_msgReq_bits_msg;
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~_T_3 & ~_T_7 & _T_12 & ~reset) begin
          $fwrite(32'h80000002,"ack\n");
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
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
  currentState = _RAND_0[1:0];
  _RAND_1 = {2{`RANDOM}};
  timeoutCounter = _RAND_1[63:0];
  _RAND_2 = {1{`RANDOM}};
  sentMsg = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  receivedMsg = _RAND_3[0:0];
  _RAND_4 = {2{`RANDOM}};
  currentReqTimeoutMax = _RAND_4[63:0];
  _RAND_5 = {4{`RANDOM}};
  currentReq = _RAND_5[127:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
