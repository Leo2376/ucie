module rdi_up(
  input          clock,
  input          reset,
  input  [3:0]   io_rdiIO_lpStateReq,
  output [3:0]   io_rdiIO_plStateStatus,
  output         io_rdiIO_plStallReq,
  input          io_rdiIO_lpStallAck,
  input          io_rdiIO_lpLinkError,
  input          io_sbTrainIO_msgReq_ready,
  output         io_sbTrainIO_msgReq_valid,
  output [127:0] io_sbTrainIO_msgReq_bits_msg,
  output         io_sbTrainIO_msgReqStatus_ready,
  input          io_sbTrainIO_msgReqStatus_valid,
  output         io_active,
  input          io_internalError
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] state;
  wire [3:0] _GEN_1 = io_internalError | io_rdiIO_lpLinkError ? 4'ha : state;
  reg [2:0] resetSubstate;
  wire  _T_1 = state != 4'h0;
  reg [3:0] prevReq;
  wire [3:0] _GEN_4 = _T_1 | prevReq == 4'h0 ? io_rdiIO_lpStateReq : _GEN_1;
  wire [3:0] _GEN_5 = io_rdiIO_lpStateReq != 4'h0 ? _GEN_4 : _GEN_1;
  wire  _T_33 = io_sbTrainIO_msgReqStatus_ready & io_sbTrainIO_msgReqStatus_valid;
  wire [3:0] _GEN_11 = _T_33 ? 4'h1 : _GEN_5;
  wire [3:0] _GEN_13 = 3'h6 == resetSubstate ? _GEN_11 : _GEN_5;
  wire [3:0] _GEN_19 = 3'h5 == resetSubstate ? _GEN_5 : _GEN_13;
  wire [3:0] _GEN_25 = 3'h4 == resetSubstate ? _GEN_5 : _GEN_19;
  wire [3:0] _GEN_31 = 3'h3 == resetSubstate ? _GEN_5 : _GEN_25;
  wire [3:0] _GEN_38 = 3'h2 == resetSubstate ? _GEN_5 : _GEN_31;
  wire [3:0] nextState = 4'h0 == state ? _GEN_38 : _GEN_5;
  wire [2:0] _GEN_2 = state != 4'h0 & nextState == 4'h0 ? 3'h2 : resetSubstate;
  reg [1:0] stallReqAckState;
  wire  _T_5 = nextState == 4'h1;
  wire [1:0] _GEN_3 = state != 4'h1 & nextState == 4'h1 ? 2'h0 : stallReqAckState;
  wire  _T_21 = io_sbTrainIO_msgReq_ready & io_sbTrainIO_msgReq_valid;
  wire [2:0] _GEN_8 = _T_21 ? 3'h4 : _GEN_2;
  wire [2:0] _GEN_9 = _T_33 ? 3'h5 : _GEN_2;
  wire [2:0] _GEN_10 = _T_33 ? 3'h6 : _GEN_2;
  wire [2:0] _GEN_17 = 3'h5 == resetSubstate ? _GEN_10 : _GEN_2;
  wire  _GEN_18 = 3'h5 == resetSubstate ? 1'h0 : 3'h6 == resetSubstate;
  wire  _GEN_20 = 3'h4 == resetSubstate | _GEN_18;
  wire [2:0] _GEN_21 = 3'h4 == resetSubstate ? _GEN_9 : _GEN_17;
  wire  _GEN_22 = 3'h4 == resetSubstate ? 1'h0 : 3'h5 == resetSubstate;
  wire  _GEN_26 = 3'h3 == resetSubstate | _GEN_22;
  wire [142:0] _GEN_27 = 3'h3 == resetSubstate ? 143'h200000140004012 : 143'h200000140008012;
  wire  _GEN_30 = 3'h3 == resetSubstate ? 1'h0 : _GEN_20;
  wire  _GEN_34 = 3'h2 == resetSubstate ? 1'h0 : _GEN_26;
  wire  _GEN_37 = 3'h2 == resetSubstate ? 1'h0 : _GEN_30;
  reg [3:0] nextStateReq;
  wire  _T_44 = nextState == 4'hb | nextState == 4'h9 | nextState == 4'hc;
  wire [1:0] _GEN_39 = _T_44 ? 2'h1 : _GEN_3;
  wire [3:0] _GEN_40 = _T_44 ? 4'h1 : nextState;
  wire [1:0] _GEN_42 = io_rdiIO_lpStallAck ? 2'h2 : _GEN_3;
  wire [3:0] _GEN_43 = io_rdiIO_lpStallAck ? 4'h1 : nextState;
  wire [3:0] _GEN_44 = ~io_rdiIO_lpStallAck ? nextStateReq : nextState;
  wire [3:0] _GEN_45 = 2'h2 == stallReqAckState ? _GEN_44 : nextState;
  wire [1:0] _GEN_46 = 2'h1 == stallReqAckState ? _GEN_42 : _GEN_3;
  wire [3:0] _GEN_47 = 2'h1 == stallReqAckState ? _GEN_43 : _GEN_45;
  assign io_rdiIO_plStateStatus = state;
  assign io_rdiIO_plStallReq = stallReqAckState == 2'h1;
  assign io_sbTrainIO_msgReq_valid = 4'h0 == state & _GEN_34;
  assign io_sbTrainIO_msgReq_bits_msg = _GEN_27[127:0];
  assign io_sbTrainIO_msgReqStatus_ready = 4'h0 == state & _GEN_37;
  assign io_active = state == 4'h1;
  always @(posedge clock) begin
    if (reset) begin
      state <= 4'h0;
    end else if (4'h0 == state) begin
      if (3'h2 == resetSubstate) begin
        if (_T_5) begin
          state <= 4'h0;
        end else begin
          state <= nextState;
        end
      end else begin
        state <= nextState;
      end
    end else if (4'h1 == state) begin
      if (2'h0 == stallReqAckState) begin
        state <= _GEN_40;
      end else begin
        state <= _GEN_47;
      end
    end else begin
      state <= nextState;
    end
    if (reset) begin
      resetSubstate <= 3'h2;
    end else if (4'h0 == state) begin
      if (3'h2 == resetSubstate) begin
        if (_T_5) begin
          resetSubstate <= 3'h3;
        end else begin
          resetSubstate <= _GEN_2;
        end
      end else if (3'h3 == resetSubstate) begin
        resetSubstate <= _GEN_8;
      end else begin
        resetSubstate <= _GEN_21;
      end
    end else begin
      resetSubstate <= _GEN_2;
    end
    if (reset) begin
      prevReq <= 4'h0;
    end else begin
      prevReq <= io_rdiIO_lpStateReq;
    end
    if (reset) begin
      stallReqAckState <= 2'h0;
    end else if (4'h0 == state) begin
      stallReqAckState <= _GEN_3;
    end else if (4'h1 == state) begin
      if (2'h0 == stallReqAckState) begin
        stallReqAckState <= _GEN_39;
      end else begin
        stallReqAckState <= _GEN_46;
      end
    end else begin
      stallReqAckState <= _GEN_3;
    end
    if (reset) begin
      nextStateReq <= 4'h0;
    end else if (2'h0 == stallReqAckState) begin
      if (_T_44) begin
        if (4'h0 == state) begin
          nextStateReq <= _GEN_38;
        end else begin
          nextStateReq <= _GEN_5;
        end
      end
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
  state = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  resetSubstate = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  prevReq = _RAND_2[3:0];
  _RAND_3 = {1{`RANDOM}};
  stallReqAckState = _RAND_3[1:0];
  _RAND_4 = {1{`RANDOM}};
  nextStateReq = _RAND_4[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
