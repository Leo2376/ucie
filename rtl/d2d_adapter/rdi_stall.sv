module rdi_stall(
  input   clock,
  input   reset,
  output  io_mainband_stallreq,
  input   io_mainband_stalldone,
  input   io_rdi_pl_stallreq,
  output  io_rdi_lp_stallack
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg  rdi_lp_stallack_reg;
  reg  mainband_stallreq_reg;
  reg [1:0] stall_handshake_state_reg;
  wire  _GEN_6 = ~io_rdi_pl_stallreq ? 1'h0 : 1'h1;
  wire [1:0] _GEN_7 = ~io_rdi_pl_stallreq ? 2'h0 : stall_handshake_state_reg;
  wire  _GEN_8 = 2'h2 == stall_handshake_state_reg ? _GEN_6 : mainband_stallreq_reg;
  assign io_mainband_stallreq = mainband_stallreq_reg;
  assign io_rdi_lp_stallack = rdi_lp_stallack_reg;
  always @(posedge clock) begin
    if (reset) begin
      rdi_lp_stallack_reg <= 1'h0;
    end else if (2'h0 == stall_handshake_state_reg) begin
      rdi_lp_stallack_reg <= 1'h0;
    end else if (2'h1 == stall_handshake_state_reg) begin
      rdi_lp_stallack_reg <= io_mainband_stalldone;
    end else if (2'h2 == stall_handshake_state_reg) begin
      rdi_lp_stallack_reg <= _GEN_6;
    end
    if (reset) begin
      mainband_stallreq_reg <= 1'h0;
    end else if (2'h0 == stall_handshake_state_reg) begin
      mainband_stallreq_reg <= io_rdi_pl_stallreq;
    end else begin
      mainband_stallreq_reg <= 2'h1 == stall_handshake_state_reg | _GEN_8;
    end
    if (reset) begin
      stall_handshake_state_reg <= 2'h0;
    end else if (2'h0 == stall_handshake_state_reg) begin
      if (io_rdi_pl_stallreq) begin
        stall_handshake_state_reg <= 2'h1;
      end
    end else if (2'h1 == stall_handshake_state_reg) begin
      if (io_mainband_stalldone) begin
        stall_handshake_state_reg <= 2'h2;
      end
    end else if (2'h2 == stall_handshake_state_reg) begin
      stall_handshake_state_reg <= _GEN_7;
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
  rdi_lp_stallack_reg = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  mainband_stallreq_reg = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  stall_handshake_state_reg = _RAND_2[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
