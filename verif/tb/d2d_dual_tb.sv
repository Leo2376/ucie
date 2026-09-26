// d2d_dual_tb: two d2d_adapt (USE_FLIT=1, REMOTE_ACK=1) cross-connected
// at RDI (data + config + credits), no training/PHY/AFE. FDI driven by
// TB with ahb_fdi-like oscillating state requests. Proves D2D PARAM +
// ACTIVE converges peer-to-peer AND flits flow via cross-die ACK/NACK.
// Fast isolation for dual-top D2D bring-up (no 21M-cycle training wait).
// Params: WPF words/flit (7=512b, 32=256B), RDIW RDI beat width.
// Production phase (8 flits each way + faults) runs at both widths.
`timescale 1ns / 1ps
module d2d_dual_tb #(parameter int WPF = 7, parameter int RDIW = 128);
  reg clock = 0;
  reg reset = 1;
  always #5 clock = ~clock;
  integer fails = 0;

  // ---- FDI stimulus/observe, die A ----
  reg        A_fdi_vld = 0;
  reg        A_fdi_irdy = 1;
  reg [63:0] A_fdi_bits = 0;
  wire       A_fdi_rdy;
  wire       A_fdi_pvld;
  wire [63:0] A_fdi_pdata;
  reg [3:0]  A_fdi_req = 0;
  wire [3:0] A_fdi_sts;
  wire       A_fdi_inband, A_fdi_rxreq, A_fdi_plstall, A_fliterr, A_ovf;
  // ---- FDI stimulus/observe, die B ----
  reg        B_fdi_vld = 0;
  reg        B_fdi_irdy = 1;
  reg [63:0] B_fdi_bits = 0;
  wire       B_fdi_rdy;
  wire       B_fdi_pvld;
  wire [63:0] B_fdi_pdata;
  reg [3:0]  B_fdi_req = 0;
  wire [3:0] B_fdi_sts;
  wire       B_fdi_inband, B_fdi_rxreq, B_fdi_plstall, B_fliterr, B_ovf;
  // ---- RDI cross: A.lp -> B.pl, B.lp -> A.pl ----
  // Data path direct (combinational). Config path (PARAM/ACKs) through
  // 300-cycle delay pipes to mimic dual-top gearbox+PHY latency. If the
  // protocol needs lockstep, this stalls; retry-until-complete sails.
  wire        A_lp_vld, A_lp_irdy;
  wire [RDIW-1:0] A_lp_bits;
  wire        B_lp_vld, B_lp_irdy;
  wire [RDIW-1:0] B_lp_bits;
  // Production-traffic fault injection (post-ACTIVE only):
  // corruptA/B_arm flips one bit of the next RDI beat (one-shot -> CRC
  // error -> NACK -> retry); drop_a2b/drop_b2a gates the config pipes
  // (dropped ACKs -> timeout retry). Both must recover without
  // link_error (MAX_RETRY=3).
  reg corruptA_arm = 0, corruptA_done = 0;
  reg corruptB_arm = 0, corruptB_done = 0;
  reg drop_a2b = 0, drop_b2a = 0;
  wire corruptA_fire = corruptA_arm && !corruptA_done && A_lp_vld;
  wire corruptB_fire = corruptB_arm && !corruptB_done && B_lp_vld;
  wire A2B_vld = A_lp_vld;
  wire [RDIW-1:0] A2B_bits = corruptA_fire ? (A_lp_bits ^ {{(RDIW-1){1'b0}}, 1'b1}) : A_lp_bits;
  wire B2A_vld = B_lp_vld;
  wire [RDIW-1:0] B2A_bits = corruptB_fire ? (B_lp_bits ^ {{(RDIW-1){1'b0}}, 1'b1}) : B_lp_bits;
  always @(posedge clock) begin
    if (reset) begin
      corruptA_done <= 1'b0;
      corruptB_done <= 1'b0;
    end else begin
      if (corruptA_fire) corruptA_done <= 1'b1;
      if (corruptB_fire) corruptB_done <= 1'b1;
    end
  end
  localparam int DLAT = 300;
  reg        A_cfg_vld_pipe [0:DLAT];
  reg [31:0] A_cfg_bits_pipe [0:DLAT];
  reg        B_cfg_vld_pipe [0:DLAT];
  reg [31:0] B_cfg_bits_pipe [0:DLAT];
  integer dp;
  // A.lpConfig -> pipe -> B.plConfig; B.lpConfig -> pipe -> A.plConfig.
  wire [31:0] A_rdi_lpcfg;
  wire        A_rdi_lpcfgv;
  wire [31:0] B_rdi_lpcfg;
  wire        B_rdi_lpcfgv;
  always @(posedge clock) begin
    if (reset) begin
      for (dp = 0; dp <= DLAT; dp = dp + 1) begin
        A_cfg_vld_pipe[dp] = 1'b0;
        A_cfg_bits_pipe[dp] = 32'h0;
        B_cfg_vld_pipe[dp] = 1'b0;
        B_cfg_bits_pipe[dp] = 32'h0;
      end
    end else begin
      // Blocking high-to-low: correct shift semantics (Verilator forbids
      // nonblocking array assigns in for loops).
      for (dp = DLAT; dp >= 1; dp = dp - 1) begin
        A_cfg_vld_pipe[dp] = A_cfg_vld_pipe[dp-1];
        A_cfg_bits_pipe[dp] = A_cfg_bits_pipe[dp-1];
        B_cfg_vld_pipe[dp] = B_cfg_vld_pipe[dp-1];
        B_cfg_bits_pipe[dp] = B_cfg_bits_pipe[dp-1];
      end
      A_cfg_vld_pipe[0] = drop_a2b ? 1'b0 : A_rdi_lpcfgv;
      A_cfg_bits_pipe[0] = A_rdi_lpcfg;
      B_cfg_vld_pipe[0] = drop_b2a ? 1'b0 : B_rdi_lpcfgv;
      B_cfg_bits_pipe[0] = B_rdi_lpcfg;
    end
  end
  wire [31:0] A_rdi_lpcfg_d = A_cfg_bits_pipe[DLAT];
  wire        A_rdi_lpcfgv_d = A_cfg_vld_pipe[DLAT];
  wire [31:0] B_rdi_lpcfg_d = B_cfg_bits_pipe[DLAT];
  wire        B_rdi_lpcfgv_d = B_cfg_vld_pipe[DLAT];
  wire [3:0]  A_rdi_lpreq, B_rdi_lpreq;
  wire        A_rdi_linkerr, B_rdi_linkerr, A_rdi_lpack, B_rdi_lpack;
  wire        A_pl_crd_dummy, B_pl_crd_dummy;
  wire [31:0] A_fdi_lp_cfg_bits, B_fdi_lp_cfg_bits;
  wire        A_fdi_lp_cfg_vld, B_fdi_lp_cfg_vld, A_fdi_pl_cfg_crd, B_fdi_pl_cfg_crd;
  wire _unused_dual;
  assign _unused_dual = &{A_lp_irdy, B_lp_irdy,
    A_rdi_lpreq, B_rdi_lpreq, A_rdi_linkerr, B_rdi_linkerr,
    A_rdi_lpack, B_rdi_lpack,
    A_fdi_lp_cfg_bits, B_fdi_lp_cfg_bits, A_fdi_lp_cfg_vld, B_fdi_lp_cfg_vld,
    A_fdi_pl_cfg_crd, B_fdi_pl_cfg_crd, A_pl_crd_dummy, B_pl_crd_dummy, 1'b0};

  d2d_adapt #(.USE_FLIT(1), .RDI_W(RDIW), .REMOTE_ACK(1), .WORDS_PER_FLIT(WPF)) dut_a (
    .clock(clock), .reset(reset),
    .io_fdi_lpData_ready(A_fdi_rdy),
    .io_fdi_lpData_valid(A_fdi_vld),
    .io_fdi_lpData_irdy(A_fdi_irdy),
    .io_fdi_lpData_bits(A_fdi_bits),
    .io_fdi_plData_valid(A_fdi_pvld),
    .io_fdi_plData_bits(A_fdi_pdata),
    .io_fdi_lpStateReq(A_fdi_req),
    .io_fdi_lpLinkError(1'b0),
    .io_fdi_plStateStatus(A_fdi_sts),
    .io_fdi_plInbandPres(A_fdi_inband),
    .io_fdi_plRxActiveReq(A_fdi_rxreq),
    .io_fdi_lpRxActiveStatus(1'b1),
    .io_fdi_plStallReq(A_fdi_plstall),
    .io_fdi_lpStallAck(1'b0),
    .io_rdi_lpData_ready(1'b1),
    .io_rdi_lpData_valid(A_lp_vld),
    .io_rdi_lpData_irdy(A_lp_irdy),
    .io_rdi_lpData_bits(A_lp_bits),
    .io_rdi_plData_valid(B2A_vld),
    .io_rdi_plData_bits(B2A_bits),
    .io_rdi_lpStateReq(A_rdi_lpreq),
    .io_rdi_lpLinkError(A_rdi_linkerr),
    .io_rdi_plStateStatus(4'h1),
    .io_rdi_plInbandPres(1'b1),
    .io_rdi_plStallReq(1'b0),
    .io_rdi_lpStallAck(A_rdi_lpack),
    .io_fdi_plConfig_valid(1'b0),
    .io_fdi_plConfig_bits(32'h0),
    .io_fdi_plConfigCredit(A_fdi_pl_cfg_crd),
    .io_fdi_lpConfig_valid(A_fdi_lp_cfg_vld),
    .io_fdi_lpConfig_bits(A_fdi_lp_cfg_bits),
    .io_fdi_lpConfigCredit(1'b1),
    .io_rdi_plConfig_valid(B_rdi_lpcfgv_d),
    .io_rdi_plConfig_bits(B_rdi_lpcfg_d),
    .io_rdi_plConfigCredit(A_pl_crd_dummy),
    .io_rdi_lpConfig_valid(A_rdi_lpcfgv),
    .io_rdi_lpConfig_bits(A_rdi_lpcfg),
    .io_rdi_lpConfigCredit(1'b1),
    .io_flit_link_error(A_fliterr),
    .io_flit_overflow(A_ovf)
  );

  d2d_adapt #(.USE_FLIT(1), .RDI_W(RDIW), .REMOTE_ACK(1), .WORDS_PER_FLIT(WPF)) dut_b (
    .clock(clock), .reset(reset),
    .io_fdi_lpData_ready(B_fdi_rdy),
    .io_fdi_lpData_valid(B_fdi_vld),
    .io_fdi_lpData_irdy(B_fdi_irdy),
    .io_fdi_lpData_bits(B_fdi_bits),
    .io_fdi_plData_valid(B_fdi_pvld),
    .io_fdi_plData_bits(B_fdi_pdata),
    .io_fdi_lpStateReq(B_fdi_req),
    .io_fdi_lpLinkError(1'b0),
    .io_fdi_plStateStatus(B_fdi_sts),
    .io_fdi_plInbandPres(B_fdi_inband),
    .io_fdi_plRxActiveReq(B_fdi_rxreq),
    .io_fdi_lpRxActiveStatus(1'b1),
    .io_fdi_plStallReq(B_fdi_plstall),
    .io_fdi_lpStallAck(1'b0),
    .io_rdi_lpData_ready(1'b1),
    .io_rdi_lpData_valid(B_lp_vld),
    .io_rdi_lpData_irdy(B_lp_irdy),
    .io_rdi_lpData_bits(B_lp_bits),
    .io_rdi_plData_valid(A2B_vld),
    .io_rdi_plData_bits(A2B_bits),
    .io_rdi_lpStateReq(B_rdi_lpreq),
    .io_rdi_lpLinkError(B_rdi_linkerr),
    .io_rdi_plStateStatus(4'h1),
    .io_rdi_plInbandPres(1'b1),
    .io_rdi_plStallReq(1'b0),
    .io_rdi_lpStallAck(B_rdi_lpack),
    .io_fdi_plConfig_valid(1'b0),
    .io_fdi_plConfig_bits(32'h0),
    .io_fdi_plConfigCredit(B_fdi_pl_cfg_crd),
    .io_fdi_lpConfig_valid(B_fdi_lp_cfg_vld),
    .io_fdi_lpConfig_bits(B_fdi_lp_cfg_bits),
    .io_fdi_lpConfigCredit(1'b1),
    .io_rdi_plConfig_valid(A_rdi_lpcfgv_d),
    .io_rdi_plConfig_bits(A_rdi_lpcfg_d),
    .io_rdi_plConfigCredit(B_pl_crd_dummy),
    .io_rdi_lpConfig_valid(B_rdi_lpcfgv),
    .io_rdi_lpConfig_bits(B_rdi_lpcfg),
    .io_rdi_lpConfigCredit(1'b1),
    .io_flit_link_error(B_fliterr),
    .io_flit_overflow(B_ovf)
  );

  // FDI push helpers (negedge drive).
  task automatic a_push(input [63:0] w);
    begin
      @(negedge clock);
      A_fdi_bits = w; A_fdi_vld = 1;
      @(posedge clock);
      @(negedge clock);
      A_fdi_vld = 0;
    end
  endtask
  task automatic b_push(input [63:0] w);
    begin
      @(negedge clock);
      B_fdi_bits = w; B_fdi_vld = 1;
      @(posedge clock);
      @(negedge clock);
      B_fdi_vld = 0;
    end
  endtask
  // Paced pushes for production traffic: wait for pack ready so no word
  // is dropped while a previous flit awaits its cross-die ACK (stop and
  // wait gates emission, not collection; retransmit windows gate ready).
  task automatic a_push_w(input [63:0] w);
    begin
      while (dut_a.gen_flit.u_mb_flit.u_pack.in_ready !== 1'b1) @(posedge clock);
      @(negedge clock);
      A_fdi_bits = w; A_fdi_vld = 1;
      @(posedge clock);
      @(negedge clock);
      A_fdi_vld = 0;
    end
  endtask
  task automatic b_push_w(input [63:0] w);
    begin
      while (dut_b.gen_flit.u_mb_flit.u_pack.in_ready !== 1'b1) @(posedge clock);
      @(negedge clock);
      B_fdi_bits = w; B_fdi_vld = 1;
      @(posedge clock);
      @(negedge clock);
      B_fdi_vld = 0;
    end
  endtask

  localparam int NPF = 8; // production flits per direction
  reg [63:0] a2b_exp [0:31];
  reg [63:0] a2b_got [0:31];
  reg [63:0] b2a_exp [0:31];
  reg [63:0] b2a_got [0:31];
  integer i, k, n;

  initial begin
    repeat (4) @(posedge clock);
    reset = 0;
    repeat (2) @(posedge clock);
    // Oscillate state requests like ahb_fdi until ACTIVE.
    k = 0;
    while (k < 50000 && (A_fdi_sts !== 4'h1 || B_fdi_sts !== 4'h1)) begin
      @(posedge clock); #1;
      if (A_fdi_sts !== 4'h1) A_fdi_req = (A_fdi_req == 4'h0) ? 4'h1 : 4'h0;
      else A_fdi_req = 4'h0;
      if (B_fdi_sts !== 4'h1) B_fdi_req = (B_fdi_req == 4'h0) ? 4'h1 : 4'h0;
      else B_fdi_req = 4'h0;
      k = k + 1;
      if (k % 5000 == 0)
        $display("D2D-WAIT t=%0t Ast=%h Bst=%h Asnd=%h Bsnd=%h Arcv=%h Brcv=%h",
                 $time, A_fdi_sts, B_fdi_sts,
                 dut_a.link_manager.io_sb_snd, dut_b.link_manager.io_sb_snd,
                 dut_a.link_manager.io_sb_rcv, dut_b.link_manager.io_sb_rcv);
    end
    if (A_fdi_sts !== 4'h1 || B_fdi_sts !== 4'h1) begin
      $display("D2DDUAL FAIL: link timeout A=%h B=%h", A_fdi_sts, B_fdi_sts);
      $finish;
    end
    $display("D2D ACTIVE t=%0t", $time);

    // A->B one flit.
    for (i = 0; i < WPF; i = i + 1)
      a2b_exp[i] = 64'hA000_0000_0000_0000 + 64'(i);
    for (i = 0; i < WPF; i = i + 1) a_push(a2b_exp[i]);
    n = 0;
    begin
      reg pv = 1'b0;
      reg [63:0] pd = 64'h0;
      for (k = 0; k < 50000 && n < WPF; k = k + 1) begin
        @(posedge clock); #1;
        if (B_fdi_pvld === 1'b1 && (pv !== 1'b1 || B_fdi_pdata !== pd)) begin
          a2b_got[n] = B_fdi_pdata; n = n + 1;
        end
        pv = B_fdi_pvld; pd = B_fdi_pdata;
      end
    end
    if (n !== WPF) begin $display("FAIL: A->B got %0d/%0d", n, WPF); fails++; end
    else begin
      for (i = 0; i < WPF; i = i + 1)
        if (a2b_got[i] !== a2b_exp[i]) begin
          $display("FAIL: A->B w%0d exp=%h got=%h", i, a2b_exp[i], a2b_got[i]);
          fails++;
        end
      if (fails == 0) $display("PASS: A->B flit via remote ACK");
    end

    // B->A one flit.
    for (i = 0; i < WPF; i = i + 1)
      b2a_exp[i] = 64'hB000_0000_0000_0000 + 64'(i);
    for (i = 0; i < WPF; i = i + 1) b_push(b2a_exp[i]);
    n = 0;
    begin
      reg pv = 1'b0;
      reg [63:0] pd = 64'h0;
      for (k = 0; k < 50000 && n < WPF; k = k + 1) begin
        @(posedge clock); #1;
        if (A_fdi_pvld === 1'b1 && (pv !== 1'b1 || A_fdi_pdata !== pd)) begin
          b2a_got[n] = A_fdi_pdata; n = n + 1;
        end
        pv = A_fdi_pvld; pd = A_fdi_pdata;
      end
    end
    if (n !== WPF) begin $display("FAIL: B->A got %0d/%0d", n, WPF); fails++; end
    else begin
      for (i = 0; i < WPF; i = i + 1)
        if (b2a_got[i] !== b2a_exp[i]) begin
          $display("FAIL: B->A w%0d exp=%h got=%h", i, b2a_exp[i], b2a_got[i]);
          fails++;
        end
      if (fails == 0) $display("PASS: B->A flit via remote ACK");
    end

    // ---- Production traffic: NPF flits each way, back-to-back ----
    // Sustained stop-and-wait over the 300-cycle sideband: corrupt flits
    // 2 and 5 per direction (RDI one-shot -> CRC error -> NACK -> retry)
    // and drop the receiver's sideband for 800 cycles during flit 4 each
    // way (A->B drops B's ACKs via drop_b2a and vice versa: lost ACKs ->
    // timeout retry). Push and collect run concurrently (fork/join);
    // each flit retires on its word count (link fully idle: no RDI valid
    // in flight) so every fault window contains exactly its target flit.
    // All must recover with exact data and no link_error (budget 3).
    begin
      integer f, w2, k2;
      reg [63:0] p2_exp [0:NPF*32-1];
      reg [63:0] p2_got [0:NPF*32-1];
      // A->B production.
      for (f = 0; f < NPF; f = f + 1)
        for (w2 = 0; w2 < WPF; w2 = w2 + 1)
          p2_exp[f*WPF+w2] = 64'hA200_0000_0000_0000 + 64'(f)*64'(WPF) + 64'(w2);
      n = 0;
      fork
        begin // push thread: paced words + fault windows + per-flit barrier
          for (f = 0; f < NPF; f = f + 1) begin
            if (f == 2 || f == 5) begin
              @(negedge clock);
              corruptA_arm = 1; corruptA_done = 0;
            end
            for (w2 = 0; w2 < WPF; w2 = w2 + 1) a_push_w(p2_exp[f*WPF+w2]);
            if (f == 4) begin
              // Drop window covers the ACK flight (~700cyc incl. pipes).
              @(negedge clock);
              drop_b2a = 1;
              repeat (800) @(posedge clock);
              @(negedge clock);
              drop_b2a = 0;
            end
            k2 = 0;
            while (n < WPF*(f+1) && k2 < 100000) begin
              @(posedge clock); k2 = k2 + 1;
            end
            if (n < WPF*(f+1)) begin
              $display("FAIL: PROD A->B flit%0d timeout", f); fails++;
            end
            if (f == 2 || f == 5) begin
              if (!corruptA_done) begin
                $display("FAIL: PROD A->B corrupt missed flit%0d", f); fails++;
              end
              @(negedge clock);
              corruptA_arm = 0;
            end
          end
        end
        begin // collect thread: baseline-sync, then change-detect hold-reg
          reg pv;
          reg [63:0] pd;
          @(posedge clock); #1;
          pv = B_fdi_pvld; pd = B_fdi_pdata;
          for (k = 0; k < 300000 && n < NPF*WPF; k = k + 1) begin
            @(posedge clock); #1;
            if (B_fdi_pvld === 1'b1 && (pv !== 1'b1 || B_fdi_pdata !== pd)) begin
              p2_got[n] = B_fdi_pdata; n = n + 1;
            end
            pv = B_fdi_pvld; pd = B_fdi_pdata;
          end
        end
      join
      if (n !== NPF*WPF) begin $display("FAIL: PROD A->B got %0d words", n); fails++; end
      else begin
        for (i = 0; i < NPF*WPF; i = i + 1)
          if (p2_got[i] !== p2_exp[i]) begin
            $display("FAIL: PROD A->B w%0d exp=%h got=%h", i, p2_exp[i], p2_got[i]);
            fails++;
          end
        if (fails == 0) $display("PASS: PROD A->B 8 flits (NACK+timeout retry)");
      end
      // B->A production.
      for (f = 0; f < NPF; f = f + 1)
        for (w2 = 0; w2 < WPF; w2 = w2 + 1)
          p2_exp[f*WPF+w2] = 64'hB200_0000_0000_0000 + 64'(f)*64'(WPF) + 64'(w2);
      n = 0;
      fork
        begin // push thread
          for (f = 0; f < NPF; f = f + 1) begin
            if (f == 2 || f == 5) begin
              @(negedge clock);
              corruptB_arm = 1; corruptB_done = 0;
            end
            for (w2 = 0; w2 < WPF; w2 = w2 + 1) b_push_w(p2_exp[f*WPF+w2]);
            if (f == 4) begin
              // Drop window covers the ACK flight (~700cyc incl. pipes).
              @(negedge clock);
              drop_a2b = 1;
              repeat (800) @(posedge clock);
              @(negedge clock);
              drop_a2b = 0;
            end
            k2 = 0;
            while (n < WPF*(f+1) && k2 < 100000) begin
              @(posedge clock); k2 = k2 + 1;
            end
            if (n < WPF*(f+1)) begin
              $display("FAIL: PROD B->A flit%0d timeout", f); fails++;
            end
            if (f == 2 || f == 5) begin
              if (!corruptB_done) begin
                $display("FAIL: PROD B->A corrupt missed flit%0d", f); fails++;
              end
              @(negedge clock);
              corruptB_arm = 0;
            end
          end
        end
        begin // collect thread
          reg pv;
          reg [63:0] pd;
          @(posedge clock); #1;
          pv = A_fdi_pvld; pd = A_fdi_pdata;
          for (k = 0; k < 300000 && n < NPF*WPF; k = k + 1) begin
            @(posedge clock); #1;
            if (A_fdi_pvld === 1'b1 && (pv !== 1'b1 || A_fdi_pdata !== pd)) begin
              p2_got[n] = A_fdi_pdata; n = n + 1;
            end
            pv = A_fdi_pvld; pd = A_fdi_pdata;
          end
        end
      join
      if (n !== NPF*WPF) begin $display("FAIL: PROD B->A got %0d words", n); fails++; end
      else begin
        for (i = 0; i < NPF*WPF; i = i + 1)
          if (p2_got[i] !== p2_exp[i]) begin
            $display("FAIL: PROD B->A w%0d exp=%h got=%h", i, p2_exp[i], p2_got[i]);
            fails++;
          end
        if (fails == 0) $display("PASS: PROD B->A 8 flits (NACK+timeout retry)");
      end
      if (dut_a.gen_flit.u_mb_flit.u_unpack.err_cnt == 0 ||
          dut_b.gen_flit.u_mb_flit.u_unpack.err_cnt == 0) begin
        $display("FAIL: PROD no CRC errors seen A=%0d B=%0d",
                 dut_a.gen_flit.u_mb_flit.u_unpack.err_cnt,
                 dut_b.gen_flit.u_mb_flit.u_unpack.err_cnt);
        fails++;
      end else $display("PASS: PROD CRC errors recovered A=%0d B=%0d",
                 dut_a.gen_flit.u_mb_flit.u_unpack.err_cnt,
                 dut_b.gen_flit.u_mb_flit.u_unpack.err_cnt);
      if (dut_a.gen_flit.u_mb_flit.u_pack.dbg_retouts == 0 ||
          dut_b.gen_flit.u_mb_flit.u_pack.dbg_retouts == 0) begin
        $display("FAIL: PROD no retries seen"); fails++;
      end else $display("PASS: PROD retries fired");
    end

    if (!A_fliterr && !B_fliterr) $display("PASS: no link_error");
    else begin $display("FAIL: link_error A=%b B=%b", A_fliterr, B_fliterr); fails++; end
    if (fails == 0) $display("D2DDUAL PASS WPF=%0d", WPF);
    else $display("D2DDUAL FAIL fails=%0d", fails);
    $finish;
  end
  initial begin
    repeat (500000) @(posedge clock);
    $display("D2DDUAL FAIL: watchdog");
    $finish;
  end
endmodule
