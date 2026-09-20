module mb_init(
  input          clock,
  input          reset,
  input          io_sbTrainIO_msgReq_ready,
  output         io_sbTrainIO_msgReq_valid,
  output [127:0] io_sbTrainIO_msgReq_bits_msg,
  output         io_sbTrainIO_msgReqStatus_ready,
  input          io_sbTrainIO_msgReqStatus_valid,
  output         io_transition,
  output         io_error
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [2:0] state;
  reg [1:0] paramSubState;
  wire  _T_13 = io_sbTrainIO_msgReqStatus_ready & io_sbTrainIO_msgReqStatus_valid;
  wire [2:0] _GEN_9 = _T_13 ? 3'h3 : state;
  wire [2:0] _GEN_11 = 2'h3 == paramSubState ? _GEN_9 : state;
  wire [2:0] _GEN_18 = 2'h2 == paramSubState ? state : _GEN_11;
  wire [2:0] _GEN_21 = 2'h1 == paramSubState ? state : _GEN_18;
  wire [2:0] _GEN_33 = 2'h0 == paramSubState ? state : _GEN_21;
  wire [2:0] nextState = 3'h0 == state ? _GEN_33 : state;
  wire [1:0] _GEN_0 = nextState == 3'h0 & state != 3'h0 ? 2'h0 : paramSubState;
  wire  _T_9 = io_sbTrainIO_msgReq_ready & io_sbTrainIO_msgReq_valid;
  wire [1:0] _GEN_6 = _T_13 ? 2'h2 : _GEN_0;
  wire [1:0] _GEN_7 = _T_9 ? 2'h3 : _GEN_0;
  wire [1:0] _GEN_16 = 2'h2 == paramSubState ? _GEN_7 : _GEN_0;
  wire  _GEN_17 = 2'h2 == paramSubState ? 1'h0 : 2'h3 == paramSubState;
  wire  _GEN_19 = 2'h1 == paramSubState | _GEN_17;
  wire  _GEN_23 = 2'h1 == paramSubState ? 1'h0 : 2'h2 == paramSubState;
  wire  _GEN_27 = 2'h0 == paramSubState | _GEN_23;
  wire  _GEN_31 = 2'h0 == paramSubState ? 1'h0 : _GEN_19;
  assign io_sbTrainIO_msgReq_valid = 3'h0 == state & _GEN_27;
  assign io_sbTrainIO_msgReq_bits_msg = 2'h0 == paramSubState ? 128'h20000a54000001b : 128'h20000aa4000001b;
  assign io_sbTrainIO_msgReqStatus_ready = 3'h0 == state & _GEN_31;
  assign io_transition = nextState == 3'h3 | nextState == 3'h4;
  assign io_error = state == 3'h4;
  always @(posedge clock) begin
    if (reset) begin
      state <= 3'h0;
    end else if (3'h0 == state) begin
      if (!(2'h0 == paramSubState)) begin
        if (!(2'h1 == paramSubState)) begin
          state <= _GEN_18;
        end
      end
    end
    if (reset) begin
      paramSubState <= 2'h0;
    end else if (3'h0 == state) begin
      if (2'h0 == paramSubState) begin
        if (_T_9) begin
          paramSubState <= 2'h1;
        end else begin
          paramSubState <= _GEN_0;
        end
      end else if (2'h1 == paramSubState) begin
        paramSubState <= _GEN_6;
      end else begin
        paramSubState <= _GEN_16;
      end
    end else begin
      paramSubState <= _GEN_0;
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
  state = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  paramSubState = _RAND_1[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
