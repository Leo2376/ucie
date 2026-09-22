module lnk_init(
  input        clock,
  input        reset,
  input  [3:0] io_fdi_lp_state_req,
  input  [3:0] io_fdi_lp_state_req_prev,
  input        io_fdi_lp_rxactive_sts,
  output       io_linkinit_fdi_pl_inband_pres,
  output       io_linkinit_fdi_pl_rxactive_req,
  input  [3:0] io_rdi_pl_state_sts,
  input        io_rdi_pl_inband_pres,
  output [3:0] io_linkinit_rdi_lp_state_req,
  input  [3:0] io_link_state,
  output       io_active_entry,
  output [5:0] io_linkinit_sb_snd,
  input  [5:0] io_linkinit_sb_rcv,
  input        io_linkinit_sb_rdy
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
`endif // RANDOMIZE_REG_INIT
  reg [2:0] linkinit_state_reg;
  reg  param_exch_sbmsg_rcv_flag;
  reg  param_exch_sbmsg_snt_flag;
  reg  active_sbmsg_req_rcv_flag;
  reg  active_sbmsg_rsp_rcv_flag;
  reg  active_sbmsg_ext_rsp_reg;
  reg  active_sbmsg_ext_req_reg;
  reg  transition_to_active_reg;
  wire [2:0] _GEN_1 = io_rdi_pl_state_sts == 4'h1 ? 3'h2 : linkinit_state_reg;
  wire [5:0] _GEN_2 = ~param_exch_sbmsg_snt_flag ? 6'h24 : 6'h0;
  wire  _GEN_3 = io_linkinit_sb_rcv == 6'h24 | param_exch_sbmsg_rcv_flag;
  wire  _GEN_4 = io_linkinit_sb_rdy & io_linkinit_sb_snd == 6'h24 | param_exch_sbmsg_snt_flag;
  wire [2:0] _GEN_5 = param_exch_sbmsg_snt_flag & param_exch_sbmsg_rcv_flag ? 3'h3 : linkinit_state_reg;
  // ACTIVE RSP goes out when the partner asked (req received) even if our
  // own rxactive path is not up yet; otherwise neither side can send the
  // first RSP (both wait on rxactive_sts, which needs an established link).
  wire _rsp_trig = active_sbmsg_req_rcv_flag |
    (io_fdi_lp_rxactive_sts & io_linkinit_fdi_pl_rxactive_req);
  wire [5:0] _GEN_7 = transition_to_active_reg & ~active_sbmsg_ext_req_reg ? 6'h1 : 6'h0;
  wire [5:0] _GEN_8 = _rsp_trig & ~active_sbmsg_ext_rsp_reg ? 6'h11 : _GEN_7;
  wire  _GEN_9 = io_linkinit_sb_rcv == 6'h11 | active_sbmsg_rsp_rcv_flag;
  wire  _GEN_10 = io_linkinit_sb_rcv == 6'h1 | active_sbmsg_req_rcv_flag;
  wire  _GEN_11 = io_linkinit_sb_snd == 6'h11 & io_linkinit_sb_rdy | active_sbmsg_ext_rsp_reg;
  wire  _GEN_12 = io_linkinit_sb_snd == 6'h1 & io_linkinit_sb_rdy | active_sbmsg_ext_req_reg;
  wire  _T_31 = io_fdi_lp_state_req_prev == 4'h0;
  wire  _T_32 = io_fdi_lp_state_req == 4'h1 & _T_31;
  wire  _GEN_13 = _T_32 | transition_to_active_reg;
  wire [2:0] _GEN_14 = active_sbmsg_ext_rsp_reg & active_sbmsg_rsp_rcv_flag ? 3'h4 : linkinit_state_reg;
  wire [2:0] _GEN_17 = 3'h4 == linkinit_state_reg ? 3'h4 : linkinit_state_reg;
  wire  _GEN_18 = 3'h3 == linkinit_state_reg | 3'h4 == linkinit_state_reg;
  wire  _GEN_19 = 3'h3 == linkinit_state_reg ? active_sbmsg_req_rcv_flag : 3'h4 == linkinit_state_reg;
  wire [5:0] _GEN_20 = 3'h3 == linkinit_state_reg ? _GEN_8 : 6'h0;
  wire [2:0] _GEN_26 = 3'h3 == linkinit_state_reg ? _GEN_14 : _GEN_17;
  wire  _GEN_27 = 3'h3 == linkinit_state_reg ? 1'h0 : 3'h4 == linkinit_state_reg;
  wire  _GEN_28 = 3'h2 == linkinit_state_reg | _GEN_18;
  wire [5:0] _GEN_29 = 3'h2 == linkinit_state_reg ? _GEN_2 : _GEN_20;
  wire [2:0] _GEN_32 = 3'h2 == linkinit_state_reg ? _GEN_5 : _GEN_26;
  wire  _GEN_33 = 3'h2 == linkinit_state_reg ? 1'h0 : _GEN_18;
  wire  _GEN_34 = 3'h2 == linkinit_state_reg ? 1'h0 : _GEN_19;
  wire  _GEN_35 = 3'h2 == linkinit_state_reg ? 1'h0 : 3'h3 == linkinit_state_reg & _GEN_9;
  wire  _GEN_36 = 3'h2 == linkinit_state_reg ? 1'h0 : 3'h3 == linkinit_state_reg & _GEN_10;
  wire  _GEN_37 = 3'h2 == linkinit_state_reg ? 1'h0 : 3'h3 == linkinit_state_reg & _GEN_11;
  wire  _GEN_38 = 3'h2 == linkinit_state_reg ? 1'h0 : 3'h3 == linkinit_state_reg & _GEN_12;
  wire  _GEN_39 = 3'h2 == linkinit_state_reg ? 1'h0 : 3'h3 == linkinit_state_reg & _GEN_13;
  wire  _GEN_40 = 3'h2 == linkinit_state_reg ? 1'h0 : _GEN_27;
  wire  _GEN_41 = 3'h1 == linkinit_state_reg | _GEN_28;
  wire [5:0] _GEN_43 = 3'h1 == linkinit_state_reg ? 6'h0 : _GEN_29;
  wire  _GEN_44 = 3'h1 == linkinit_state_reg ? 1'h0 : 3'h2 == linkinit_state_reg & _GEN_3;
  wire  _GEN_45 = 3'h1 == linkinit_state_reg ? 1'h0 : 3'h2 == linkinit_state_reg & _GEN_4;
  wire  _GEN_46 = 3'h1 == linkinit_state_reg ? 1'h0 : _GEN_33;
  wire  _GEN_47 = 3'h1 == linkinit_state_reg ? 1'h0 : _GEN_34;
  wire  _GEN_53 = 3'h1 == linkinit_state_reg ? 1'h0 : _GEN_40;
  wire  _GEN_54 = 3'h0 == linkinit_state_reg ? 1'h0 : _GEN_53;
  wire  _GEN_55 = 3'h0 == linkinit_state_reg ? 1'h0 : _GEN_41;
  wire  _GEN_56 = 3'h0 == linkinit_state_reg ? 1'h0 : _GEN_47;
  wire [5:0] _GEN_57 = 3'h0 == linkinit_state_reg ? 6'h0 : _GEN_43;
  wire  _GEN_59 = 3'h0 == linkinit_state_reg ? 1'h0 : _GEN_44;
  wire  _GEN_60 = 3'h0 == linkinit_state_reg ? 1'h0 : _GEN_45;
  wire  _GEN_61 = 3'h0 == linkinit_state_reg ? 1'h0 : _GEN_46;
  wire  _GEN_68 = io_link_state == 4'h0 & _GEN_55;
  wire  _GEN_71 = io_link_state == 4'h0 & _GEN_59;
  wire  _GEN_72 = io_link_state == 4'h0 & _GEN_60;
  assign io_linkinit_fdi_pl_inband_pres = io_link_state == 4'h0 & _GEN_61;
  assign io_linkinit_fdi_pl_rxactive_req = io_link_state == 4'h0 & _GEN_56;
  assign io_linkinit_rdi_lp_state_req = {{3'd0}, _GEN_68};
  assign io_active_entry = io_link_state == 4'h0 & _GEN_54;
  assign io_linkinit_sb_snd = io_link_state == 4'h0 ? _GEN_57 : 6'h0;
  always @(posedge clock) begin
    if (reset) begin
      linkinit_state_reg <= 3'h0;
    end else if (io_link_state == 4'h0) begin
      if (3'h0 == linkinit_state_reg) begin
        if (io_rdi_pl_inband_pres) begin
          linkinit_state_reg <= 3'h1;
        end
      end else if (3'h1 == linkinit_state_reg) begin
        linkinit_state_reg <= _GEN_1;
      end else begin
        linkinit_state_reg <= _GEN_32;
      end
    end else begin
      linkinit_state_reg <= 3'h0;
    end
    if (reset) begin
      param_exch_sbmsg_rcv_flag <= 1'h0;
    end else begin
      param_exch_sbmsg_rcv_flag <= _GEN_71;
    end
    if (reset) begin
      param_exch_sbmsg_snt_flag <= 1'h0;
    end else begin
      param_exch_sbmsg_snt_flag <= _GEN_72;
    end
    if (reset) begin
      active_sbmsg_req_rcv_flag <= 1'h0;
    end else if (io_link_state == 4'h0) begin
      if (3'h0 == linkinit_state_reg) begin
        active_sbmsg_req_rcv_flag <= 1'h0;
      end else if (3'h1 == linkinit_state_reg) begin
        active_sbmsg_req_rcv_flag <= 1'h0;
      end else begin
        active_sbmsg_req_rcv_flag <= _GEN_36;
      end
    end
    if (reset) begin
      active_sbmsg_rsp_rcv_flag <= 1'h0;
    end else if (io_link_state == 4'h0) begin
      if (3'h0 == linkinit_state_reg) begin
        active_sbmsg_rsp_rcv_flag <= 1'h0;
      end else if (3'h1 == linkinit_state_reg) begin
        active_sbmsg_rsp_rcv_flag <= 1'h0;
      end else begin
        active_sbmsg_rsp_rcv_flag <= _GEN_35;
      end
    end
    if (reset) begin
      active_sbmsg_ext_rsp_reg <= 1'h0;
    end else if (io_link_state == 4'h0) begin
      if (3'h0 == linkinit_state_reg) begin
        active_sbmsg_ext_rsp_reg <= 1'h0;
      end else if (3'h1 == linkinit_state_reg) begin
        active_sbmsg_ext_rsp_reg <= 1'h0;
      end else begin
        active_sbmsg_ext_rsp_reg <= _GEN_37;
      end
    end
    if (reset) begin
      active_sbmsg_ext_req_reg <= 1'h0;
    end else if (io_link_state == 4'h0) begin
      if (3'h0 == linkinit_state_reg) begin
        active_sbmsg_ext_req_reg <= 1'h0;
      end else if (3'h1 == linkinit_state_reg) begin
        active_sbmsg_ext_req_reg <= 1'h0;
      end else begin
        active_sbmsg_ext_req_reg <= _GEN_38;
      end
    end
    if (reset) begin
      transition_to_active_reg <= 1'h0;
    end else if (io_link_state == 4'h0) begin
      if (3'h0 == linkinit_state_reg) begin
        transition_to_active_reg <= 1'h0;
      end else if (3'h1 == linkinit_state_reg) begin
        transition_to_active_reg <= 1'h0;
      end else begin
        transition_to_active_reg <= _GEN_39;
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
  linkinit_state_reg = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  param_exch_sbmsg_rcv_flag = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  param_exch_sbmsg_snt_flag = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  active_sbmsg_req_rcv_flag = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  active_sbmsg_rsp_rcv_flag = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  active_sbmsg_ext_rsp_reg = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  active_sbmsg_ext_req_reg = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  transition_to_active_reg = _RAND_7[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
