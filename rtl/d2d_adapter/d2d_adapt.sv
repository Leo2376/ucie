module d2d_adapt(
  input         clock,
  input         reset,
  output        io_fdi_lpData_ready,
  input         io_fdi_lpData_valid,
  input         io_fdi_lpData_irdy,
  input  [63:0] io_fdi_lpData_bits,
  output        io_fdi_plData_valid,
  output [63:0] io_fdi_plData_bits,
  input  [3:0]  io_fdi_lpStateReq,
  input         io_fdi_lpLinkError,
  output [3:0]  io_fdi_plStateStatus,
  output        io_fdi_plInbandPres,
  output        io_fdi_plRxActiveReq,
  input         io_fdi_lpRxActiveStatus,
  output        io_fdi_plStallReq,
  input         io_fdi_lpStallAck,
  input         io_rdi_lpData_ready,
  output        io_rdi_lpData_valid,
  output        io_rdi_lpData_irdy,
  output [63:0] io_rdi_lpData_bits,
  input         io_rdi_plData_valid,
  input  [63:0] io_rdi_plData_bits,
  output [3:0]  io_rdi_lpStateReq,
  output        io_rdi_lpLinkError,
  input  [3:0]  io_rdi_plStateStatus,
  input         io_rdi_plInbandPres,
  input         io_rdi_plStallReq,
  output        io_rdi_lpStallAck,
  input         io_rdi_plConfig_valid,
  input  [31:0] io_rdi_plConfig_bits,
  output        io_rdi_plConfigCredit,
  output        io_rdi_lpConfig_valid,
  output [31:0] io_rdi_lpConfig_bits,
  input         io_rdi_lpConfigCredit
);
  wire  link_manager_clock;
  wire  link_manager_reset;
  wire [3:0] link_manager_io_fdi_lp_state_req;
  wire  link_manager_io_fdi_lp_linkerror;
  wire  link_manager_io_fdi_lp_rx_active_sts;
  wire [3:0] link_manager_io_fdi_pl_state_sts;
  wire  link_manager_io_fdi_pl_rx_active_req;
  wire  link_manager_io_fdi_pl_inband_pres;
  wire  link_manager_io_rdi_lp_linkerror;
  wire [3:0] link_manager_io_rdi_lp_state_req;
  wire [3:0] link_manager_io_rdi_pl_state_sts;
  wire  link_manager_io_rdi_pl_inband_pres;
  wire [5:0] link_manager_io_sb_snd;
  wire [5:0] link_manager_io_sb_rcv;
  wire  link_manager_io_sb_rdy;
  wire  link_manager_io_linkmgmt_stallreq;
  wire  link_manager_io_linkmgmt_stalldone;
  wire  link_manager_io_parity_rx_enable;
  wire  link_manager_io_parity_tx_enable;
  wire  fdi_stall_handler_clock;
  wire  fdi_stall_handler_reset;
  wire  fdi_stall_handler_io_linkmgmt_stallreq;
  wire  fdi_stall_handler_io_linkmgmt_stalldone;
  wire  fdi_stall_handler_io_fdi_pl_stallreq;
  wire  fdi_stall_handler_io_fdi_lp_stallack;
  wire  rdi_stall_handler_clock;
  wire  rdi_stall_handler_reset;
  wire  rdi_stall_handler_io_mainband_stallreq;
  wire  rdi_stall_handler_io_mainband_stalldone;
  wire  rdi_stall_handler_io_rdi_pl_stallreq;
  wire  rdi_stall_handler_io_rdi_lp_stallack;
  wire  d2d_sideband_clock;
  wire  d2d_sideband_reset;
  wire [31:0] d2d_sideband_io_rdi_pl_cfg;
  wire  d2d_sideband_io_rdi_pl_cfg_vld;
  wire  d2d_sideband_io_rdi_pl_cfg_crd;
  wire [31:0] d2d_sideband_io_rdi_lp_cfg;
  wire  d2d_sideband_io_rdi_lp_cfg_vld;
  wire  d2d_sideband_io_rdi_lp_cfg_crd;
  wire [5:0] d2d_sideband_io_sideband_rcv;
  wire [5:0] d2d_sideband_io_sideband_snt;
  wire  d2d_sideband_io_sideband_rdy;
  wire  d2d_mainband_clock;
  wire  d2d_mainband_reset;
  wire  d2d_mainband_io_fdi_lp_irdy;
  wire  d2d_mainband_io_fdi_lp_valid;
  wire [63:0] d2d_mainband_io_fdi_lp_data;
  wire  d2d_mainband_io_fdi_pl_trdy;
  wire  d2d_mainband_io_fdi_pl_valid;
  wire [63:0] d2d_mainband_io_fdi_pl_data;
  wire  d2d_mainband_io_rdi_lp_irdy;
  wire  d2d_mainband_io_rdi_lp_valid;
  wire [63:0] d2d_mainband_io_rdi_lp_data;
  wire  d2d_mainband_io_rdi_pl_trdy;
  wire  d2d_mainband_io_rdi_pl_valid;
  wire [63:0] d2d_mainband_io_rdi_pl_data;
  wire [3:0] d2d_mainband_io_d2d_state;
  wire  d2d_mainband_io_mainband_stallreq;
  wire  d2d_mainband_io_mainband_stalldone;
  wire [63:0] d2d_mainband_io_snd_data;
  wire  d2d_mainband_io_snd_data_vld;
  wire  d2d_mainband_io_rcv_data_vld;
  wire  d2d_mainband_io_parity_insert;
  wire [63:0] d2d_mainband_io_parity_data;
  wire  d2d_mainband_io_parity_rdy;
  wire  d2d_mainband_io_parity_check;
  wire  parity_generator_clock;
  wire  parity_generator_reset;
  wire [7:0] parity_generator_io_snd_data_0;
  wire [7:0] parity_generator_io_snd_data_1;
  wire [7:0] parity_generator_io_snd_data_2;
  wire [7:0] parity_generator_io_snd_data_3;
  wire [7:0] parity_generator_io_snd_data_4;
  wire [7:0] parity_generator_io_snd_data_5;
  wire [7:0] parity_generator_io_snd_data_6;
  wire [7:0] parity_generator_io_snd_data_7;
  wire  parity_generator_io_snd_data_vld;
  wire  parity_generator_io_rcv_data_vld;
  wire [7:0] parity_generator_io_parity_data_0;
  wire [7:0] parity_generator_io_parity_data_1;
  wire [7:0] parity_generator_io_parity_data_2;
  wire [7:0] parity_generator_io_parity_data_3;
  wire [7:0] parity_generator_io_parity_data_4;
  wire [7:0] parity_generator_io_parity_data_5;
  wire [7:0] parity_generator_io_parity_data_6;
  wire [7:0] parity_generator_io_parity_data_7;
  wire  parity_generator_io_parity_insert;
  wire  parity_generator_io_parity_check;
  wire  parity_generator_io_parity_rdy;
  wire [3:0] parity_generator_io_rdi_state;
  wire  parity_generator_io_parity_rx_enable;
  wire  parity_generator_io_parity_tx_enable;
  wire [63:0] _WIRE_1 = d2d_mainband_io_snd_data;
  wire [31:0] d2d_mainband_io_parity_data_lo = {parity_generator_io_parity_data_3,parity_generator_io_parity_data_2,
    parity_generator_io_parity_data_1,parity_generator_io_parity_data_0};
  wire [31:0] d2d_mainband_io_parity_data_hi = {parity_generator_io_parity_data_7,parity_generator_io_parity_data_6,
    parity_generator_io_parity_data_5,parity_generator_io_parity_data_4};
  lnk_mgmt link_manager (
    .clock(link_manager_clock),
    .reset(link_manager_reset),
    .io_fdi_lp_state_req(link_manager_io_fdi_lp_state_req),
    .io_fdi_lp_linkerror(link_manager_io_fdi_lp_linkerror),
    .io_fdi_lp_rx_active_sts(link_manager_io_fdi_lp_rx_active_sts),
    .io_fdi_pl_state_sts(link_manager_io_fdi_pl_state_sts),
    .io_fdi_pl_rx_active_req(link_manager_io_fdi_pl_rx_active_req),
    .io_fdi_pl_inband_pres(link_manager_io_fdi_pl_inband_pres),
    .io_rdi_lp_linkerror(link_manager_io_rdi_lp_linkerror),
    .io_rdi_lp_state_req(link_manager_io_rdi_lp_state_req),
    .io_rdi_pl_state_sts(link_manager_io_rdi_pl_state_sts),
    .io_rdi_pl_inband_pres(link_manager_io_rdi_pl_inband_pres),
    .io_sb_snd(link_manager_io_sb_snd),
    .io_sb_rcv(link_manager_io_sb_rcv),
    .io_sb_rdy(link_manager_io_sb_rdy),
    .io_linkmgmt_stallreq(link_manager_io_linkmgmt_stallreq),
    .io_linkmgmt_stalldone(link_manager_io_linkmgmt_stalldone),
    .io_parity_rx_enable(link_manager_io_parity_rx_enable),
    .io_parity_tx_enable(link_manager_io_parity_tx_enable)
  );
  fdi_stall fdi_stall_handler (
    .clock(fdi_stall_handler_clock),
    .reset(fdi_stall_handler_reset),
    .io_linkmgmt_stallreq(fdi_stall_handler_io_linkmgmt_stallreq),
    .io_linkmgmt_stalldone(fdi_stall_handler_io_linkmgmt_stalldone),
    .io_fdi_pl_stallreq(fdi_stall_handler_io_fdi_pl_stallreq),
    .io_fdi_lp_stallack(fdi_stall_handler_io_fdi_lp_stallack)
  );
  rdi_stall rdi_stall_handler (
    .clock(rdi_stall_handler_clock),
    .reset(rdi_stall_handler_reset),
    .io_mainband_stallreq(rdi_stall_handler_io_mainband_stallreq),
    .io_mainband_stalldone(rdi_stall_handler_io_mainband_stalldone),
    .io_rdi_pl_stallreq(rdi_stall_handler_io_rdi_pl_stallreq),
    .io_rdi_lp_stallack(rdi_stall_handler_io_rdi_lp_stallack)
  );
  d2d_sb d2d_sideband (
    .clock(d2d_sideband_clock),
    .reset(d2d_sideband_reset),
    .io_rdi_pl_cfg(d2d_sideband_io_rdi_pl_cfg),
    .io_rdi_pl_cfg_vld(d2d_sideband_io_rdi_pl_cfg_vld),
    .io_rdi_pl_cfg_crd(d2d_sideband_io_rdi_pl_cfg_crd),
    .io_rdi_lp_cfg(d2d_sideband_io_rdi_lp_cfg),
    .io_rdi_lp_cfg_vld(d2d_sideband_io_rdi_lp_cfg_vld),
    .io_rdi_lp_cfg_crd(d2d_sideband_io_rdi_lp_cfg_crd),
    .io_sideband_rcv(d2d_sideband_io_sideband_rcv),
    .io_sideband_snt(d2d_sideband_io_sideband_snt),
    .io_sideband_rdy(d2d_sideband_io_sideband_rdy)
  );
  d2d_mb d2d_mainband (
    .clock(d2d_mainband_clock),
    .reset(d2d_mainband_reset),
    .io_fdi_lp_irdy(d2d_mainband_io_fdi_lp_irdy),
    .io_fdi_lp_valid(d2d_mainband_io_fdi_lp_valid),
    .io_fdi_lp_data(d2d_mainband_io_fdi_lp_data),
    .io_fdi_pl_trdy(d2d_mainband_io_fdi_pl_trdy),
    .io_fdi_pl_valid(d2d_mainband_io_fdi_pl_valid),
    .io_fdi_pl_data(d2d_mainband_io_fdi_pl_data),
    .io_rdi_lp_irdy(d2d_mainband_io_rdi_lp_irdy),
    .io_rdi_lp_valid(d2d_mainband_io_rdi_lp_valid),
    .io_rdi_lp_data(d2d_mainband_io_rdi_lp_data),
    .io_rdi_pl_trdy(d2d_mainband_io_rdi_pl_trdy),
    .io_rdi_pl_valid(d2d_mainband_io_rdi_pl_valid),
    .io_rdi_pl_data(d2d_mainband_io_rdi_pl_data),
    .io_d2d_state(d2d_mainband_io_d2d_state),
    .io_mainband_stallreq(d2d_mainband_io_mainband_stallreq),
    .io_mainband_stalldone(d2d_mainband_io_mainband_stalldone),
    .io_snd_data(d2d_mainband_io_snd_data),
    .io_snd_data_vld(d2d_mainband_io_snd_data_vld),
    .io_rcv_data_vld(d2d_mainband_io_rcv_data_vld),
    .io_parity_insert(d2d_mainband_io_parity_insert),
    .io_parity_data(d2d_mainband_io_parity_data),
    .io_parity_rdy(d2d_mainband_io_parity_rdy),
    .io_parity_check(d2d_mainband_io_parity_check)
  );
  par_gen parity_generator (
    .clock(parity_generator_clock),
    .reset(parity_generator_reset),
    .io_snd_data_0(parity_generator_io_snd_data_0),
    .io_snd_data_1(parity_generator_io_snd_data_1),
    .io_snd_data_2(parity_generator_io_snd_data_2),
    .io_snd_data_3(parity_generator_io_snd_data_3),
    .io_snd_data_4(parity_generator_io_snd_data_4),
    .io_snd_data_5(parity_generator_io_snd_data_5),
    .io_snd_data_6(parity_generator_io_snd_data_6),
    .io_snd_data_7(parity_generator_io_snd_data_7),
    .io_snd_data_vld(parity_generator_io_snd_data_vld),
    .io_rcv_data_vld(parity_generator_io_rcv_data_vld),
    .io_parity_data_0(parity_generator_io_parity_data_0),
    .io_parity_data_1(parity_generator_io_parity_data_1),
    .io_parity_data_2(parity_generator_io_parity_data_2),
    .io_parity_data_3(parity_generator_io_parity_data_3),
    .io_parity_data_4(parity_generator_io_parity_data_4),
    .io_parity_data_5(parity_generator_io_parity_data_5),
    .io_parity_data_6(parity_generator_io_parity_data_6),
    .io_parity_data_7(parity_generator_io_parity_data_7),
    .io_parity_insert(parity_generator_io_parity_insert),
    .io_parity_check(parity_generator_io_parity_check),
    .io_parity_rdy(parity_generator_io_parity_rdy),
    .io_rdi_state(parity_generator_io_rdi_state),
    .io_parity_rx_enable(parity_generator_io_parity_rx_enable),
    .io_parity_tx_enable(parity_generator_io_parity_tx_enable)
  );
  assign io_fdi_lpData_ready = d2d_mainband_io_fdi_pl_trdy;
  assign io_fdi_plData_valid = d2d_mainband_io_fdi_pl_valid;
  assign io_fdi_plData_bits = d2d_mainband_io_fdi_pl_data;
  assign io_fdi_plStateStatus = link_manager_io_fdi_pl_state_sts;
  assign io_fdi_plInbandPres = link_manager_io_fdi_pl_inband_pres;
  assign io_fdi_plRxActiveReq = link_manager_io_fdi_pl_rx_active_req;
  assign io_fdi_plStallReq = fdi_stall_handler_io_fdi_pl_stallreq;
  assign io_rdi_lpData_valid = d2d_mainband_io_rdi_lp_valid;
  assign io_rdi_lpData_irdy = d2d_mainband_io_rdi_lp_irdy;
  assign io_rdi_lpData_bits = d2d_mainband_io_rdi_lp_data;
  assign io_rdi_lpStateReq = link_manager_io_rdi_lp_state_req;
  assign io_rdi_lpLinkError = link_manager_io_rdi_lp_linkerror;
  assign io_rdi_lpStallAck = rdi_stall_handler_io_rdi_lp_stallack;
  assign io_rdi_plConfigCredit = d2d_sideband_io_rdi_pl_cfg_crd;
  assign io_rdi_lpConfig_valid = d2d_sideband_io_rdi_lp_cfg_vld;
  assign io_rdi_lpConfig_bits = d2d_sideband_io_rdi_lp_cfg;
  assign link_manager_clock = clock;
  assign link_manager_reset = reset;
  assign link_manager_io_fdi_lp_state_req = io_fdi_lpStateReq;
  assign link_manager_io_fdi_lp_linkerror = io_fdi_lpLinkError;
  assign link_manager_io_fdi_lp_rx_active_sts = io_fdi_lpRxActiveStatus;
  assign link_manager_io_rdi_pl_state_sts = io_rdi_plStateStatus;
  assign link_manager_io_rdi_pl_inband_pres = io_rdi_plInbandPres;
  assign link_manager_io_sb_rcv = d2d_sideband_io_sideband_rcv;
  assign link_manager_io_sb_rdy = d2d_sideband_io_sideband_rdy;
  assign link_manager_io_linkmgmt_stalldone = fdi_stall_handler_io_linkmgmt_stalldone;
  assign fdi_stall_handler_clock = clock;
  assign fdi_stall_handler_reset = reset;
  assign fdi_stall_handler_io_linkmgmt_stallreq = link_manager_io_linkmgmt_stallreq;
  assign fdi_stall_handler_io_fdi_lp_stallack = io_fdi_lpStallAck;
  assign rdi_stall_handler_clock = clock;
  assign rdi_stall_handler_reset = reset;
  assign rdi_stall_handler_io_mainband_stalldone = d2d_mainband_io_mainband_stalldone;
  assign rdi_stall_handler_io_rdi_pl_stallreq = io_rdi_plStallReq;
  assign d2d_sideband_clock = clock;
  assign d2d_sideband_reset = reset;
  assign d2d_sideband_io_rdi_pl_cfg = io_rdi_plConfig_bits;
  assign d2d_sideband_io_rdi_pl_cfg_vld = io_rdi_plConfig_valid;
  assign d2d_sideband_io_rdi_lp_cfg_crd = io_rdi_lpConfigCredit;
  assign d2d_sideband_io_sideband_snt = link_manager_io_sb_snd;
  assign d2d_mainband_clock = clock;
  assign d2d_mainband_reset = reset;
  assign d2d_mainband_io_fdi_lp_irdy = io_fdi_lpData_irdy;
  assign d2d_mainband_io_fdi_lp_valid = io_fdi_lpData_valid;
  assign d2d_mainband_io_fdi_lp_data = io_fdi_lpData_bits;
  assign d2d_mainband_io_rdi_pl_trdy = io_rdi_lpData_ready;
  assign d2d_mainband_io_rdi_pl_valid = io_rdi_plData_valid;
  assign d2d_mainband_io_rdi_pl_data = io_rdi_plData_bits;
  assign d2d_mainband_io_d2d_state = link_manager_io_fdi_pl_state_sts;
  assign d2d_mainband_io_mainband_stallreq = rdi_stall_handler_io_mainband_stallreq;
  assign d2d_mainband_io_parity_insert = parity_generator_io_parity_insert;
  assign d2d_mainband_io_parity_data = {d2d_mainband_io_parity_data_hi,d2d_mainband_io_parity_data_lo};
  assign d2d_mainband_io_parity_check = parity_generator_io_parity_check;
  assign parity_generator_clock = clock;
  assign parity_generator_reset = reset;
  assign parity_generator_io_snd_data_0 = _WIRE_1[7:0];
  assign parity_generator_io_snd_data_1 = _WIRE_1[15:8];
  assign parity_generator_io_snd_data_2 = _WIRE_1[23:16];
  assign parity_generator_io_snd_data_3 = _WIRE_1[31:24];
  assign parity_generator_io_snd_data_4 = _WIRE_1[39:32];
  assign parity_generator_io_snd_data_5 = _WIRE_1[47:40];
  assign parity_generator_io_snd_data_6 = _WIRE_1[55:48];
  assign parity_generator_io_snd_data_7 = _WIRE_1[63:56];
  assign parity_generator_io_snd_data_vld = d2d_mainband_io_snd_data_vld;
  assign parity_generator_io_rcv_data_vld = d2d_mainband_io_rcv_data_vld;
  assign parity_generator_io_parity_rdy = d2d_mainband_io_parity_rdy;
  assign parity_generator_io_rdi_state = io_rdi_plStateStatus;
  assign parity_generator_io_parity_rx_enable = link_manager_io_parity_rx_enable;
  assign parity_generator_io_parity_tx_enable = link_manager_io_parity_tx_enable;
endmodule
