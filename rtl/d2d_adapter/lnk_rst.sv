module lnk_rst(
  input        clock,
  input        reset,
  input  [3:0] io_fdi_lp_state_req,
  input  [3:0] io_fdi_lp_state_req_prev,
  input  [3:0] io_link_state,
  output       io_linkreset_entry,
  output [5:0] io_linkreset_sb_snd,
  input  [5:0] io_linkreset_sb_rcv,
  input        io_linkreset_sb_rdy
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg  linkreset_fdi_req_reg;
  reg  linkreset_sbmsg_req_rcv_flag;
  reg  linkreset_sbmsg_rsp_rcv_flag;
  reg  linkreset_sbmsg_ext_rsp_reg;
  reg  linkreset_sbmsg_ext_req_reg;
  wire  _T = io_link_state == 4'h0;
  wire  _T_1 = io_link_state == 4'h1;
  wire  _T_2 = io_link_state == 4'h0 | _T_1;
  wire  _T_3 = io_link_state == 4'hb;
  wire  _T_4 = _T_2 | _T_3;
  wire  _T_6 = io_fdi_lp_state_req == 4'h9;
  wire  _T_7 = _T & _T_6;
  wire  _T_8 = io_fdi_lp_state_req_prev == 4'h0;
  wire  _T_9 = _T_7 & _T_8;
  wire  _T_11 = io_link_state != 4'h0;
  wire  _T_12 = _T_6 & _T_11;
  wire  _GEN_0 = _T_12 | linkreset_fdi_req_reg;
  wire  _GEN_1 = _T_9 | _GEN_0;
  wire  _GEN_2 = io_linkreset_sb_snd == 6'h9 & io_linkreset_sb_rdy | linkreset_sbmsg_ext_req_reg;
  wire  _GEN_3 = io_linkreset_sb_snd == 6'h19 & io_linkreset_sb_rdy | linkreset_sbmsg_ext_rsp_reg;
  wire  _GEN_4 = io_linkreset_sb_rcv == 6'h9 | linkreset_sbmsg_req_rcv_flag;
  wire  _GEN_5 = io_linkreset_sb_rcv == 6'h19 | linkreset_sbmsg_rsp_rcv_flag;
  wire  _T_21 = ~linkreset_sbmsg_ext_req_reg;
  wire  _T_22 = linkreset_fdi_req_reg & ~linkreset_sbmsg_req_rcv_flag & _T_21;
  wire [5:0] _GEN_6 = linkreset_sbmsg_req_rcv_flag & ~linkreset_sbmsg_ext_rsp_reg ? 6'h19 : 6'h0;
  wire [5:0] _GEN_7 = _T_22 ? 6'h9 : _GEN_6;
  wire  _GEN_9 = _T_4 & _GEN_1;
  wire  _GEN_10 = _T_4 & _GEN_2;
  wire  _GEN_11 = _T_4 & _GEN_3;
  wire  _GEN_12 = _T_4 & _GEN_4;
  wire  _GEN_13 = _T_4 & _GEN_5;
  assign io_linkreset_entry = _T_4 & (linkreset_sbmsg_ext_rsp_reg | linkreset_sbmsg_rsp_rcv_flag);
  assign io_linkreset_sb_snd = _T_4 ? _GEN_7 : 6'h0;
  always @(posedge clock) begin
    if (reset) begin
      linkreset_fdi_req_reg <= 1'h0;
    end else begin
      linkreset_fdi_req_reg <= _GEN_9;
    end
    if (reset) begin
      linkreset_sbmsg_req_rcv_flag <= 1'h0;
    end else begin
      linkreset_sbmsg_req_rcv_flag <= _GEN_12;
    end
    if (reset) begin
      linkreset_sbmsg_rsp_rcv_flag <= 1'h0;
    end else begin
      linkreset_sbmsg_rsp_rcv_flag <= _GEN_13;
    end
    if (reset) begin
      linkreset_sbmsg_ext_rsp_reg <= 1'h0;
    end else begin
      linkreset_sbmsg_ext_rsp_reg <= _GEN_11;
    end
    if (reset) begin
      linkreset_sbmsg_ext_req_reg <= 1'h0;
    end else begin
      linkreset_sbmsg_ext_req_reg <= _GEN_10;
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
  linkreset_fdi_req_reg = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  linkreset_sbmsg_req_rcv_flag = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  linkreset_sbmsg_rsp_rcv_flag = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  linkreset_sbmsg_ext_rsp_reg = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  linkreset_sbmsg_ext_req_reg = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
