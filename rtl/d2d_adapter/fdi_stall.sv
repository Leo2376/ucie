module fdi_stall(
  input   clock,
  input   reset,
  input   io_linkmgmt_stallreq,
  output  io_linkmgmt_stalldone,
  output  io_fdi_pl_stallreq,
  input   io_fdi_lp_stallack
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg  fdi_lp_stallreq_reg;
  reg  linkmgmt_stalldone_reg;
  reg [1:0] stall_handshake_state_reg;
  wire  _T_3 = ~io_fdi_lp_stallack;
  wire  _T_4 = io_linkmgmt_stallreq & ~io_fdi_lp_stallack;
  wire  _GEN_3 = io_fdi_lp_stallack ? 1'h0 : 1'h1;
  wire [1:0] _GEN_8 = _T_3 ? 2'h3 : stall_handshake_state_reg;
  wire  _GEN_10 = ~io_linkmgmt_stallreq ? 1'h0 : 1'h1;
  wire [1:0] _GEN_11 = ~io_linkmgmt_stallreq ? 2'h0 : stall_handshake_state_reg;
  wire  _GEN_13 = 2'h3 == stall_handshake_state_reg ? _GEN_10 : linkmgmt_stalldone_reg;
  wire [1:0] _GEN_14 = 2'h3 == stall_handshake_state_reg ? _GEN_11 : stall_handshake_state_reg;
  assign io_linkmgmt_stalldone = linkmgmt_stalldone_reg;
  assign io_fdi_pl_stallreq = fdi_lp_stallreq_reg;
  always @(posedge clock) begin
    if (reset) begin
      fdi_lp_stallreq_reg <= 1'h0;
    end else if (2'h0 == stall_handshake_state_reg) begin
      fdi_lp_stallreq_reg <= _T_4;
    end else begin
      fdi_lp_stallreq_reg <= 2'h1 == stall_handshake_state_reg & _GEN_3;
    end
    if (reset) begin
      linkmgmt_stalldone_reg <= 1'h0;
    end else if (2'h0 == stall_handshake_state_reg) begin
      linkmgmt_stalldone_reg <= 1'h0;
    end else if (2'h1 == stall_handshake_state_reg) begin
      linkmgmt_stalldone_reg <= 1'h0;
    end else if (2'h2 == stall_handshake_state_reg) begin
      linkmgmt_stalldone_reg <= _T_3;
    end else begin
      linkmgmt_stalldone_reg <= _GEN_13;
    end
    if (reset) begin
      stall_handshake_state_reg <= 2'h0;
    end else if (2'h0 == stall_handshake_state_reg) begin
      if (io_linkmgmt_stallreq & ~io_fdi_lp_stallack) begin
        stall_handshake_state_reg <= 2'h1;
      end
    end else if (2'h1 == stall_handshake_state_reg) begin
      if (io_fdi_lp_stallack) begin
        stall_handshake_state_reg <= 2'h2;
      end
    end else if (2'h2 == stall_handshake_state_reg) begin
      stall_handshake_state_reg <= _GEN_8;
    end else begin
      stall_handshake_state_reg <= _GEN_14;
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
  fdi_lp_stallreq_reg = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  linkmgmt_stalldone_reg = _RAND_1[0:0];
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
