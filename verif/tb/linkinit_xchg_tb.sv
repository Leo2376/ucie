// linkinit_xchg_tb: two lnk_init cross-connected at the 6b sideband
// (sb_snd->sb_rcv, rdy=1), both requesting ACTIVE. Proves the PARAM +
// ACTIVE handshake converges peer-to-peer (no BFM): active_entry on
// both sides. Fast protocol check for dual-DUT D2D bring-up.
`timescale 1ns / 1ps
module linkinit_xchg_tb;
  reg clock = 0;
  reg reset = 1;
  always #5 clock = ~clock;
  integer fails = 0;

  reg [3:0] A_req = 0;
  reg [3:0] A_prev = 0;
  wire A_inband, A_rxreq, A_active;
  wire [3:0] A_rdi_req;
  wire [5:0] A_snd;
  reg [5:0] A_rcv = 0;
  always @(posedge clock) begin
    A_prev <= A_req;
    A_rcv <= B_snd;
  end

  lnk_init dut_a (
    .clock(clock), .reset(reset),
    .io_fdi_lp_state_req(A_req),
    .io_fdi_lp_state_req_prev(A_prev),
    .io_fdi_lp_rxactive_sts(1'b1),
    .io_linkinit_fdi_pl_inband_pres(A_inband),
    .io_linkinit_fdi_pl_rxactive_req(A_rxreq),
    .io_rdi_pl_state_sts(4'h1),
    .io_rdi_pl_inband_pres(1'b1),
    .io_linkinit_rdi_lp_state_req(A_rdi_req),
    .io_link_state(4'h0),
    .io_active_entry(A_active),
    .io_linkinit_sb_snd(A_snd),
    .io_linkinit_sb_rcv(A_rcv),
    .io_linkinit_sb_rdy(1'b1)
  );

  reg [3:0] B_req = 0;
  reg [3:0] B_prev = 0;
  wire B_inband, B_rxreq, B_active;
  wire [3:0] B_rdi_req;
  wire [5:0] B_snd;
  reg [5:0] B_rcv = 0;
  always @(posedge clock) begin
    B_prev <= B_req;
    B_rcv <= A_snd;
  end

  lnk_init dut_b (
    .clock(clock), .reset(reset),
    .io_fdi_lp_state_req(B_req),
    .io_fdi_lp_state_req_prev(B_prev),
    .io_fdi_lp_rxactive_sts(1'b1),
    .io_linkinit_fdi_pl_inband_pres(B_inband),
    .io_linkinit_fdi_pl_rxactive_req(B_rxreq),
    .io_rdi_pl_state_sts(4'h1),
    .io_rdi_pl_inband_pres(1'b1),
    .io_linkinit_rdi_lp_state_req(B_rdi_req),
    .io_link_state(4'h0),
    .io_active_entry(B_active),
    .io_linkinit_sb_snd(B_snd),
    .io_linkinit_sb_rcv(B_rcv),
    .io_linkinit_sb_rdy(1'b1)
  );

  integer k;
  integer dbg = 0;
  always @(posedge clock) begin
    #1;
    if (!reset && dbg < 60) begin
      dbg <= dbg + 1;
      $display("LI t=%0t Asnd=%h Bsnd=%h Ast=%0d Bst=%0d Ape=%b Apr=%b Atreq=%b Atrsp=%b Areqq=%b Arspq=%b | Bpe=%b Bpr=%b Btreq=%b Btrsp=%b Breqq=%b Brspq=%b",
        $time, A_snd, B_snd,
        dut_a.linkinit_state_reg, dut_b.linkinit_state_reg,
        dut_a.param_exch_sbmsg_snt_flag, dut_a.param_exch_sbmsg_rcv_flag,
        dut_a.transition_to_active_reg, dut_a.active_sbmsg_ext_rsp_reg,
        dut_a.active_sbmsg_req_rcv_flag, dut_a.active_sbmsg_rsp_rcv_flag,
        dut_b.param_exch_sbmsg_snt_flag, dut_b.param_exch_sbmsg_rcv_flag,
        dut_b.transition_to_active_reg, dut_b.active_sbmsg_ext_rsp_reg,
        dut_b.active_sbmsg_req_rcv_flag, dut_b.active_sbmsg_rsp_rcv_flag);
    end
  end
  initial begin
    repeat (4) @(posedge clock);
    reset = 0;
    repeat (2) @(posedge clock);
    @(negedge clock);
    A_req = 4'h1; B_req = 4'h1;
    k = 0;
    while (k < 2000 && (!A_active || !B_active)) begin
      @(posedge clock); #1;
      // Mimic ahb_fdi's request oscillator: req_next = (req==0) while
      // bringing up (plState==0, inband==1, no soft reset). A steady
      // req=1 gives no edges, and lnk_init's transition_to_active needs
      // a fresh 0->1 edge in state 3 (see _T_31/_T_32).
      A_req = (A_req == 4'h0) ? 4'h1 : 4'h0;
      B_req = (B_req == 4'h0) ? 4'h1 : 4'h0;
      k = k + 1;
    end
    if (!A_active) begin $display("FAIL: A no active_entry"); fails++; end
    else $display("PASS: A active_entry (inband=%b rxreq=%b)", A_inband, A_rxreq);
    if (!B_active) begin $display("FAIL: B no active_entry"); fails++; end
    else $display("PASS: B active_entry (inband=%b rxreq=%b)", B_inband, B_rxreq);
    if (fails == 0) $display("LINKINITXCHG PASS");
    else $display("LINKINITXCHG FAIL fails=%0d", fails);
    $finish;
  end
  initial begin
    repeat (50000) @(posedge clock);
    $display("LINKINITXCHG FAIL: watchdog");
    $finish;
  end
endmodule
