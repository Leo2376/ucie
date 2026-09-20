module lnk_mgmt(
  input        clock,
  input        reset,
  input  [3:0] io_fdi_lp_state_req,
  input        io_fdi_lp_linkerror,
  input        io_fdi_lp_rx_active_sts,
  output [3:0] io_fdi_pl_state_sts,
  output       io_fdi_pl_rx_active_req,
  output       io_fdi_pl_inband_pres,
  output       io_rdi_lp_linkerror,
  output [3:0] io_rdi_lp_state_req,
  input  [3:0] io_rdi_pl_state_sts,
  input        io_rdi_pl_inband_pres,
  output [5:0] io_sb_snd,
  input  [5:0] io_sb_rcv,
  input        io_sb_rdy,
  output       io_linkmgmt_stallreq,
  input        io_linkmgmt_stalldone,
  output       io_parity_rx_enable,
  output       io_parity_tx_enable
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  wire  disabled_submodule_clock;
  wire  disabled_submodule_reset;
  wire [3:0] disabled_submodule_io_fdi_lp_state_req;
  wire [3:0] disabled_submodule_io_fdi_lp_state_req_prev;
  wire [3:0] disabled_submodule_io_link_state;
  wire  disabled_submodule_io_disabled_entry;
  wire [5:0] disabled_submodule_io_disabled_sb_snd;
  wire [5:0] disabled_submodule_io_disabled_sb_rcv;
  wire  disabled_submodule_io_disabled_sb_rdy;
  wire  linkreset_submodule_clock;
  wire  linkreset_submodule_reset;
  wire [3:0] linkreset_submodule_io_fdi_lp_state_req;
  wire [3:0] linkreset_submodule_io_fdi_lp_state_req_prev;
  wire [3:0] linkreset_submodule_io_link_state;
  wire  linkreset_submodule_io_linkreset_entry;
  wire [5:0] linkreset_submodule_io_linkreset_sb_snd;
  wire [5:0] linkreset_submodule_io_linkreset_sb_rcv;
  wire  linkreset_submodule_io_linkreset_sb_rdy;
  wire  linkinit_submodule_clock;
  wire  linkinit_submodule_reset;
  wire [3:0] linkinit_submodule_io_fdi_lp_state_req;
  wire [3:0] linkinit_submodule_io_fdi_lp_state_req_prev;
  wire  linkinit_submodule_io_fdi_lp_rxactive_sts;
  wire  linkinit_submodule_io_linkinit_fdi_pl_inband_pres;
  wire  linkinit_submodule_io_linkinit_fdi_pl_rxactive_req;
  wire [3:0] linkinit_submodule_io_rdi_pl_state_sts;
  wire  linkinit_submodule_io_rdi_pl_inband_pres;
  wire [3:0] linkinit_submodule_io_linkinit_rdi_lp_state_req;
  wire [3:0] linkinit_submodule_io_link_state;
  wire  linkinit_submodule_io_active_entry;
  wire [5:0] linkinit_submodule_io_linkinit_sb_snd;
  wire [5:0] linkinit_submodule_io_linkinit_sb_rcv;
  wire  linkinit_submodule_io_linkinit_sb_rdy;
  wire  parity_negotiation_submodule_clock;
  wire  parity_negotiation_submodule_reset;
  wire  parity_negotiation_submodule_io_start_negotiation;
  wire [5:0] parity_negotiation_submodule_io_parity_sb_rcv;
  wire [5:0] parity_negotiation_submodule_io_parity_sb_snd;
  wire  parity_negotiation_submodule_io_parity_sb_rdy;
  wire  parity_negotiation_submodule_io_parity_rx_enable;
  wire  parity_negotiation_submodule_io_parity_tx_enable;
  reg  rdi_lp_linkerror_reg;
  reg [3:0] rdi_lp_state_req_reg;
  reg  fdi_pl_rxactive_req_reg;
  reg  fdi_pl_inband_pres_reg;
  reg  linkmgmt_stallreq_reg;
  reg [3:0] fdi_lp_state_req_prev_reg;
  reg [3:0] link_state_reg;
  wire  _parity_negotiation_submodule_io_start_negotiation_T = link_state_reg == 4'hb;
  wire  linkerror_phy_sts = io_rdi_pl_state_sts == 4'ha;
  wire  stallhandler_handshake_done = linkmgmt_stallreq_reg & io_linkmgmt_stalldone;
  wire  rx_deactive = ~io_fdi_lp_rx_active_sts & ~io_fdi_pl_rx_active_req;
  wire  retrain_phy_sts = io_rdi_pl_state_sts == 4'hb;
  wire  _T = link_state_reg == 4'h1;
  wire  _linkmgmt_stallreq_reg_T = linkreset_submodule_io_linkreset_entry | disabled_submodule_io_disabled_entry;
  wire  _linkmgmt_stallreq_reg_T_1 = linkreset_submodule_io_linkreset_entry | disabled_submodule_io_disabled_entry |
    retrain_phy_sts;
  wire  _GEN_0 = link_state_reg == 4'h1 & (linkreset_submodule_io_linkreset_entry | disabled_submodule_io_disabled_entry
     | retrain_phy_sts);
  wire  _T_7 = link_state_reg == 4'h0;
  wire  _T_8 = link_state_reg == 4'ha;
  wire  _T_9 = link_state_reg == 4'hc;
  wire  _T_10 = link_state_reg == 4'ha | _T_9;
  wire  _T_11 = link_state_reg == 4'h9;
  wire  _T_12 = _T_10 | _T_11;
  wire  _T_14 = disabled_submodule_io_disabled_sb_snd != 6'h0;
  wire  _T_15 = linkreset_submodule_io_linkreset_sb_snd != 6'h0;
  wire [5:0] _GEN_8 = linkinit_submodule_io_linkinit_sb_snd != 6'h0 ? linkinit_submodule_io_linkinit_sb_snd : 6'h0;
  wire  _GEN_9 = linkinit_submodule_io_linkinit_sb_snd != 6'h0 & io_sb_rdy;
  wire [5:0] _GEN_10 = linkreset_submodule_io_linkreset_sb_snd != 6'h0 ? linkreset_submodule_io_linkreset_sb_snd :
    _GEN_8;
  wire  _GEN_11 = linkreset_submodule_io_linkreset_sb_snd != 6'h0 & io_sb_rdy;
  wire  _GEN_12 = linkreset_submodule_io_linkreset_sb_snd != 6'h0 ? 1'h0 : _GEN_9;
  wire [5:0] _GEN_13 = disabled_submodule_io_disabled_sb_snd != 6'h0 ? disabled_submodule_io_disabled_sb_snd : _GEN_10;
  wire  _GEN_14 = disabled_submodule_io_disabled_sb_snd != 6'h0 & io_sb_rdy;
  wire  _GEN_15 = disabled_submodule_io_disabled_sb_snd != 6'h0 ? 1'h0 : _GEN_11;
  wire  _GEN_16 = disabled_submodule_io_disabled_sb_snd != 6'h0 ? 1'h0 : _GEN_12;
  wire [5:0] _GEN_17 = _T_15 ? linkreset_submodule_io_linkreset_sb_snd : 6'h0;
  wire [5:0] _GEN_19 = _T_14 ? disabled_submodule_io_disabled_sb_snd : _GEN_17;
  wire [5:0] _GEN_22 = parity_negotiation_submodule_io_parity_sb_snd != 6'h0 ?
    parity_negotiation_submodule_io_parity_sb_snd : 6'h0;
  wire  _GEN_23 = parity_negotiation_submodule_io_parity_sb_snd != 6'h0 & io_sb_rdy;
  wire [5:0] _GEN_24 = _T_15 ? linkreset_submodule_io_linkreset_sb_snd : _GEN_22;
  wire  _GEN_26 = _T_15 ? 1'h0 : _GEN_23;
  wire [5:0] _GEN_27 = _T_14 ? disabled_submodule_io_disabled_sb_snd : _GEN_24;
  wire  _GEN_30 = _T_14 ? 1'h0 : _GEN_26;
  wire [5:0] _GEN_31 = _T_14 ? disabled_submodule_io_disabled_sb_snd : 6'h0;
  wire [5:0] _GEN_34 = _T_11 ? _GEN_31 : 6'h0;
  wire  _GEN_35 = _T_11 & _GEN_14;
  wire [5:0] _GEN_36 = _parity_negotiation_submodule_io_start_negotiation_T ? _GEN_27 : _GEN_34;
  wire  _GEN_37 = _parity_negotiation_submodule_io_start_negotiation_T ? _GEN_14 : _GEN_35;
  wire  _GEN_38 = _parity_negotiation_submodule_io_start_negotiation_T & _GEN_15;
  wire  _GEN_39 = _parity_negotiation_submodule_io_start_negotiation_T & _GEN_30;
  wire [5:0] _GEN_40 = _T ? _GEN_19 : _GEN_36;
  wire  _GEN_41 = _T ? _GEN_14 : _GEN_37;
  wire  _GEN_42 = _T ? _GEN_15 : _GEN_38;
  wire  _GEN_43 = _T ? 1'h0 : _GEN_39;
  wire  _T_33 = io_fdi_lp_state_req == 4'h1;
  wire  _T_35 = io_fdi_lp_state_req == 4'h1 & linkerror_phy_sts;
  wire [3:0] _GEN_51 = _T_33 ? 4'h1 : 4'hc;
  wire [3:0] _GEN_52 = _T_33 ? 4'h1 : 4'h9;
  wire [3:0] _GEN_53 = _T_11 ? _GEN_52 : rdi_lp_state_req_reg;
  wire [3:0] _GEN_54 = _T_9 ? _GEN_51 : _GEN_53;
  wire [3:0] _GEN_55 = _T_8 ? {{3'd0}, _T_35} : _GEN_54;
  wire  _T_43 = disabled_submodule_io_disabled_entry & rx_deactive;
  wire  _T_44 = linkreset_submodule_io_linkreset_entry & rx_deactive;
  wire [3:0] _GEN_59 = linkinit_submodule_io_active_entry ? 4'h1 : link_state_reg;
  wire [3:0] _GEN_60 = linkreset_submodule_io_linkreset_entry & rx_deactive ? 4'h9 : _GEN_59;
  wire [3:0] _GEN_63 = retrain_phy_sts & rx_deactive & stallhandler_handshake_done ? 4'hb : link_state_reg;
  wire [3:0] _GEN_64 = _T_44 & stallhandler_handshake_done ? 4'h9 : _GEN_63;
  wire [3:0] _GEN_65 = _T_43 & stallhandler_handshake_done ? 4'hc : _GEN_64;
  wire [3:0] _GEN_67 = linkreset_submodule_io_linkreset_entry ? 4'h9 : link_state_reg;
  wire [3:0] _GEN_68 = disabled_submodule_io_disabled_entry ? 4'hc : _GEN_67;
  wire [3:0] _GEN_69 = linkerror_phy_sts ? 4'ha : _GEN_68;
  wire  _T_62 = _T_33 | linkerror_phy_sts;
  wire [3:0] _GEN_70 = _T_62 & rx_deactive ? 4'h0 : link_state_reg;
  wire  _T_68 = io_rdi_pl_state_sts == 4'h0;
  wire  _T_69 = _T_33 | _T_68;
  wire [3:0] _GEN_71 = _T_69 ? 4'h0 : link_state_reg;
  wire [3:0] _GEN_72 = linkerror_phy_sts ? 4'ha : _GEN_71;
  wire [3:0] _GEN_74 = _T_43 ? 4'hc : _GEN_71;
  wire [3:0] _GEN_75 = linkerror_phy_sts ? 4'ha : _GEN_74;
  wire [3:0] _GEN_76 = 4'h9 == link_state_reg ? _GEN_75 : link_state_reg;
  wire [3:0] _GEN_77 = 4'hc == link_state_reg ? _GEN_72 : _GEN_76;
  wire [3:0] _GEN_78 = 4'ha == link_state_reg ? _GEN_70 : _GEN_77;
  lnk_dis disabled_submodule (
    .clock(disabled_submodule_clock),
    .reset(disabled_submodule_reset),
    .io_fdi_lp_state_req(disabled_submodule_io_fdi_lp_state_req),
    .io_fdi_lp_state_req_prev(disabled_submodule_io_fdi_lp_state_req_prev),
    .io_link_state(disabled_submodule_io_link_state),
    .io_disabled_entry(disabled_submodule_io_disabled_entry),
    .io_disabled_sb_snd(disabled_submodule_io_disabled_sb_snd),
    .io_disabled_sb_rcv(disabled_submodule_io_disabled_sb_rcv),
    .io_disabled_sb_rdy(disabled_submodule_io_disabled_sb_rdy)
  );
  lnk_rst linkreset_submodule (
    .clock(linkreset_submodule_clock),
    .reset(linkreset_submodule_reset),
    .io_fdi_lp_state_req(linkreset_submodule_io_fdi_lp_state_req),
    .io_fdi_lp_state_req_prev(linkreset_submodule_io_fdi_lp_state_req_prev),
    .io_link_state(linkreset_submodule_io_link_state),
    .io_linkreset_entry(linkreset_submodule_io_linkreset_entry),
    .io_linkreset_sb_snd(linkreset_submodule_io_linkreset_sb_snd),
    .io_linkreset_sb_rcv(linkreset_submodule_io_linkreset_sb_rcv),
    .io_linkreset_sb_rdy(linkreset_submodule_io_linkreset_sb_rdy)
  );
  lnk_init linkinit_submodule (
    .clock(linkinit_submodule_clock),
    .reset(linkinit_submodule_reset),
    .io_fdi_lp_state_req(linkinit_submodule_io_fdi_lp_state_req),
    .io_fdi_lp_state_req_prev(linkinit_submodule_io_fdi_lp_state_req_prev),
    .io_fdi_lp_rxactive_sts(linkinit_submodule_io_fdi_lp_rxactive_sts),
    .io_linkinit_fdi_pl_inband_pres(linkinit_submodule_io_linkinit_fdi_pl_inband_pres),
    .io_linkinit_fdi_pl_rxactive_req(linkinit_submodule_io_linkinit_fdi_pl_rxactive_req),
    .io_rdi_pl_state_sts(linkinit_submodule_io_rdi_pl_state_sts),
    .io_rdi_pl_inband_pres(linkinit_submodule_io_rdi_pl_inband_pres),
    .io_linkinit_rdi_lp_state_req(linkinit_submodule_io_linkinit_rdi_lp_state_req),
    .io_link_state(linkinit_submodule_io_link_state),
    .io_active_entry(linkinit_submodule_io_active_entry),
    .io_linkinit_sb_snd(linkinit_submodule_io_linkinit_sb_snd),
    .io_linkinit_sb_rcv(linkinit_submodule_io_linkinit_sb_rcv),
    .io_linkinit_sb_rdy(linkinit_submodule_io_linkinit_sb_rdy)
  );
  par_neg parity_negotiation_submodule (
    .clock(parity_negotiation_submodule_clock),
    .reset(parity_negotiation_submodule_reset),
    .io_start_negotiation(parity_negotiation_submodule_io_start_negotiation),
    .io_parity_sb_rcv(parity_negotiation_submodule_io_parity_sb_rcv),
    .io_parity_sb_snd(parity_negotiation_submodule_io_parity_sb_snd),
    .io_parity_sb_rdy(parity_negotiation_submodule_io_parity_sb_rdy),
    .io_parity_rx_enable(parity_negotiation_submodule_io_parity_rx_enable),
    .io_parity_tx_enable(parity_negotiation_submodule_io_parity_tx_enable)
  );
  assign io_fdi_pl_state_sts = link_state_reg;
  assign io_fdi_pl_rx_active_req = fdi_pl_rxactive_req_reg;
  assign io_fdi_pl_inband_pres = fdi_pl_inband_pres_reg;
  assign io_rdi_lp_linkerror = rdi_lp_linkerror_reg;
  assign io_rdi_lp_state_req = rdi_lp_state_req_reg;
  assign io_sb_snd = _T_7 ? _GEN_13 : _GEN_40;
  assign io_linkmgmt_stallreq = linkmgmt_stallreq_reg;
  assign io_parity_rx_enable = parity_negotiation_submodule_io_parity_rx_enable;
  assign io_parity_tx_enable = parity_negotiation_submodule_io_parity_tx_enable;
  assign disabled_submodule_clock = clock;
  assign disabled_submodule_reset = reset;
  assign disabled_submodule_io_fdi_lp_state_req = io_fdi_lp_state_req;
  assign disabled_submodule_io_fdi_lp_state_req_prev = fdi_lp_state_req_prev_reg;
  assign disabled_submodule_io_link_state = link_state_reg;
  assign disabled_submodule_io_disabled_sb_rcv = io_sb_rcv;
  assign disabled_submodule_io_disabled_sb_rdy = _T_7 ? _GEN_14 : _GEN_41;
  assign linkreset_submodule_clock = clock;
  assign linkreset_submodule_reset = reset;
  assign linkreset_submodule_io_fdi_lp_state_req = io_fdi_lp_state_req;
  assign linkreset_submodule_io_fdi_lp_state_req_prev = fdi_lp_state_req_prev_reg;
  assign linkreset_submodule_io_link_state = link_state_reg;
  assign linkreset_submodule_io_linkreset_sb_rcv = io_sb_rcv;
  assign linkreset_submodule_io_linkreset_sb_rdy = _T_7 ? _GEN_15 : _GEN_42;
  assign linkinit_submodule_clock = clock;
  assign linkinit_submodule_reset = reset;
  assign linkinit_submodule_io_fdi_lp_state_req = io_fdi_lp_state_req;
  assign linkinit_submodule_io_fdi_lp_state_req_prev = fdi_lp_state_req_prev_reg;
  assign linkinit_submodule_io_fdi_lp_rxactive_sts = io_fdi_lp_rx_active_sts;
  assign linkinit_submodule_io_rdi_pl_state_sts = io_rdi_pl_state_sts;
  assign linkinit_submodule_io_rdi_pl_inband_pres = io_rdi_pl_inband_pres;
  assign linkinit_submodule_io_link_state = link_state_reg;
  assign linkinit_submodule_io_linkinit_sb_rcv = io_sb_rcv;
  assign linkinit_submodule_io_linkinit_sb_rdy = _T_7 & _GEN_16;
  assign parity_negotiation_submodule_clock = clock;
  assign parity_negotiation_submodule_reset = reset;
  assign parity_negotiation_submodule_io_start_negotiation = link_state_reg == 4'hb;
  assign parity_negotiation_submodule_io_parity_sb_rcv = io_sb_rcv;
  assign parity_negotiation_submodule_io_parity_sb_rdy = _T_7 ? 1'h0 : _GEN_43;
  always @(posedge clock) begin
    if (reset) begin
      rdi_lp_linkerror_reg <= 1'h0;
    end else begin
      rdi_lp_linkerror_reg <= io_fdi_lp_linkerror;
    end
    if (reset) begin
      rdi_lp_state_req_reg <= 4'h0;
    end else if (_T_7) begin
      rdi_lp_state_req_reg <= linkinit_submodule_io_linkinit_rdi_lp_state_req;
    end else if (_T) begin
      if (retrain_phy_sts) begin
        rdi_lp_state_req_reg <= 4'hb;
      end
    end else if (_parity_negotiation_submodule_io_start_negotiation_T) begin
      rdi_lp_state_req_reg <= 4'h0;
    end else begin
      rdi_lp_state_req_reg <= _GEN_55;
    end
    if (reset) begin
      fdi_pl_rxactive_req_reg <= 1'h0;
    end else if (_T) begin
      if (_linkmgmt_stallreq_reg_T_1 | linkerror_phy_sts) begin
        fdi_pl_rxactive_req_reg <= 1'h0;
      end else begin
        fdi_pl_rxactive_req_reg <= 1'h1;
      end
    end else if (_linkmgmt_stallreq_reg_T | linkerror_phy_sts) begin
      fdi_pl_rxactive_req_reg <= 1'h0;
    end else begin
      fdi_pl_rxactive_req_reg <= linkinit_submodule_io_linkinit_fdi_pl_rxactive_req;
    end
    if (reset) begin
      fdi_pl_inband_pres_reg <= 1'h0;
    end else if (link_state_reg == 4'h0) begin
      if (linkerror_phy_sts) begin
        fdi_pl_inband_pres_reg <= 1'h0;
      end else begin
        fdi_pl_inband_pres_reg <= linkinit_submodule_io_linkinit_fdi_pl_inband_pres;
      end
    end else if (_T_12) begin
      fdi_pl_inband_pres_reg <= 1'h0;
    end else if (linkerror_phy_sts) begin
      fdi_pl_inband_pres_reg <= 1'h0;
    end else begin
      fdi_pl_inband_pres_reg <= 1'h1;
    end
    if (reset) begin
      linkmgmt_stallreq_reg <= 1'h0;
    end else begin
      linkmgmt_stallreq_reg <= _GEN_0;
    end
    fdi_lp_state_req_prev_reg <= io_fdi_lp_state_req;
    if (reset) begin
      link_state_reg <= 4'h0;
    end else if (4'h0 == link_state_reg) begin
      if (linkerror_phy_sts) begin
        link_state_reg <= 4'ha;
      end else if (disabled_submodule_io_disabled_entry & rx_deactive) begin
        link_state_reg <= 4'hc;
      end else begin
        link_state_reg <= _GEN_60;
      end
    end else if (4'h1 == link_state_reg) begin
      if (linkerror_phy_sts) begin
        link_state_reg <= 4'ha;
      end else begin
        link_state_reg <= _GEN_65;
      end
    end else if (4'hb == link_state_reg) begin
      link_state_reg <= _GEN_69;
    end else begin
      link_state_reg <= _GEN_78;
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
  rdi_lp_linkerror_reg = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  rdi_lp_state_req_reg = _RAND_1[3:0];
  _RAND_2 = {1{`RANDOM}};
  fdi_pl_rxactive_req_reg = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  fdi_pl_inband_pres_reg = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  linkmgmt_stallreq_reg = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  fdi_lp_state_req_prev_reg = _RAND_5[3:0];
  _RAND_6 = {1{`RANDOM}};
  link_state_reg = _RAND_6[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
