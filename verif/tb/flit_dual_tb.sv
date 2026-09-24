// flit_dual_tb: two-die UCIe link test (docs/ack_spec.md).
//
// Two ucie_top (USE_FLIT=1, REMOTE_ACK=1, GATE_ACTIVE=1) with crossed
// AFEs: MB tx->rx (registered, 1-cycle) and SB tx->rx (negedge-registered
// to mimic wire delay and kill same-edge races). Both sides train for
// real; then A->B (2 flits, one with a 1-shot MB bit error) and B->A
// (1 flit) must match exactly via cross-die ACK/NACK + retry.
// Driving convention: TB inputs change on negedge.
`timescale 1ns / 1ps

module flit_dual_tb;
  reg HCLK = 0;
  reg HRESETn = 0;
  always #5 HCLK = ~HCLK;

  integer fails = 0;

  // ================= Die A =================
  reg        A_HSEL = 0;
  reg [31:0] A_HADDR = 0;
  reg [63:0] A_HWDATA = 0;
  reg        A_HWRITE = 0;
  reg [2:0]  A_HSIZE = 3'b011;
  reg [2:0]  A_HBURST = 0;
  reg [1:0]  A_HTRANS = 0;
  wire [63:0] A_HRDATA;
  wire        A_HREADYOUT;
  wire        A_HRESP;
  reg  A_irdy = 1, A_rdy2rcv = 1, A_fault = 0, A_soft_rst = 0;
  wire [3:0] A_state;
  wire [63:0] A_pldata;
  wire        A_plvalid;
  wire A_stallAck, A_flit_err, A_flit_ovf;
  wire A_mbTxValid, A_mbRxRdy, A_mbRxEn, A_sbTx, A_sbTxClk, A_sbRxEn;
  wire [15:0] A_mbTxBits;
  wire [2:0] A_mbFreq;
  wire A_sbRx;
  wire A_sbRxc;
  wire B2A_mb_valid;
  wire [15:0] B2A_mb_bits;

  ucie_top #(.USE_FLIT(1), .REMOTE_ACK(1), .GATE_ACTIVE(1)) dut_a (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .HSEL(A_HSEL), .HADDR(A_HADDR), .HWDATA(A_HWDATA), .HWRITE(A_HWRITE),
    .HSIZE(A_HSIZE), .HBURST(A_HBURST), .HTRANS(A_HTRANS), .HREADY(1'b1),
    .HRDATA(A_HRDATA), .HREADYOUT(A_HREADYOUT), .HRESP(A_HRESP),
    .io_TLlpData_irdy(A_irdy), .io_TLplStateStatus(A_state),
    .io_TLplData_bits(A_pldata), .io_TLplData_valid(A_plvalid),
    .io_TLready_to_rcv(A_rdy2rcv), .io_fault(A_fault),
    .io_soft_reset(A_soft_rst),
    .io_fdi_lpStallAck(A_stallAck),
    .io_mbAfe_fifoParams_clk(HCLK), .io_mbAfe_fifoParams_reset(~HRESETn),
    .io_mbAfe_txData_ready(1'b1), .io_mbAfe_txData_valid(A_mbTxValid),
    .io_mbAfe_txData_bits_0(A_mbTxBits), .io_mbAfe_rxData_ready(A_mbRxRdy),
    .io_mbAfe_rxData_valid(B2A_mb_valid), .io_mbAfe_rxData_bits_0(B2A_mb_bits),
    .io_mbAfe_txFreqSel(A_mbFreq), .io_mbAfe_rxEn(A_mbRxEn),
    .io_mbAfe_pllLock(1'b1),
    .io_sbAfe_fifoParams_clk(HCLK), .io_sbAfe_fifoParams_reset(~HRESETn),
    .io_sbAfe_txData(A_sbTx), .io_sbAfe_txClock(A_sbTxClk),
    .io_sbAfe_rxData(A_sbRx), .io_sbAfe_rxClock(A_sbRxc),
    .io_sbAfe_rxEn(A_sbRxEn), .io_sbAfe_pllLock(1'b1),
    .o_flit_link_error(A_flit_err), .o_flit_overflow(A_flit_ovf)
  );

  // ================= Die B =================
  reg        B_HSEL = 0;
  reg [31:0] B_HADDR = 0;
  reg [63:0] B_HWDATA = 0;
  reg        B_HWRITE = 0;
  reg [2:0]  B_HSIZE = 3'b011;
  reg [2:0]  B_HBURST = 0;
  reg [1:0]  B_HTRANS = 0;
  wire [63:0] B_HRDATA;
  wire        B_HREADYOUT;
  wire        B_HRESP;
  reg  B_irdy = 1, B_rdy2rcv = 1, B_fault = 0, B_soft_rst = 0;
  wire [3:0] B_state;
  wire [63:0] B_pldata;
  wire        B_plvalid;
  wire B_stallAck, B_flit_err, B_flit_ovf;
  wire B_mbTxValid, B_mbRxRdy, B_mbRxEn, B_sbTx, B_sbTxClk, B_sbRxEn;
  wire [15:0] B_mbTxBits;
  wire [2:0] B_mbFreq;
  wire B_sbRx;
  wire B_sbRxc;
  wire A2B_mb_valid;
  wire [15:0] A2B_mb_bits;

  ucie_top #(.USE_FLIT(1), .REMOTE_ACK(1), .GATE_ACTIVE(1)) dut_b (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .HSEL(B_HSEL), .HADDR(B_HADDR), .HWDATA(B_HWDATA), .HWRITE(B_HWRITE),
    .HSIZE(B_HSIZE), .HBURST(B_HBURST), .HTRANS(B_HTRANS), .HREADY(1'b1),
    .HRDATA(B_HRDATA), .HREADYOUT(B_HREADYOUT), .HRESP(B_HRESP),
    .io_TLlpData_irdy(B_irdy), .io_TLplStateStatus(B_state),
    .io_TLplData_bits(B_pldata), .io_TLplData_valid(B_plvalid),
    .io_TLready_to_rcv(B_rdy2rcv), .io_fault(B_fault),
    .io_soft_reset(B_soft_rst),
    .io_fdi_lpStallAck(B_stallAck),
    .io_mbAfe_fifoParams_clk(HCLK), .io_mbAfe_fifoParams_reset(~HRESETn),
    .io_mbAfe_txData_ready(1'b1), .io_mbAfe_txData_valid(B_mbTxValid),
    .io_mbAfe_txData_bits_0(B_mbTxBits), .io_mbAfe_rxData_ready(B_mbRxRdy),
    .io_mbAfe_rxData_valid(A2B_mb_valid), .io_mbAfe_rxData_bits_0(A2B_mb_bits),
    .io_mbAfe_txFreqSel(B_mbFreq), .io_mbAfe_rxEn(B_mbRxEn),
    .io_mbAfe_pllLock(1'b1),
    .io_sbAfe_fifoParams_clk(HCLK), .io_sbAfe_fifoParams_reset(~HRESETn),
    .io_sbAfe_txData(B_sbTx), .io_sbAfe_txClock(B_sbTxClk),
    .io_sbAfe_rxData(B_sbRx), .io_sbAfe_rxClock(B_sbRxc),
    .io_sbAfe_rxEn(B_sbRxEn), .io_sbAfe_pllLock(1'b1),
    .o_flit_link_error(B_flit_err), .o_flit_overflow(B_flit_ovf)
  );

  // ---- MB cross (registered 1-cycle; 1-shot corrupt A->B) ----
  reg lbA_valid = 0, lbB_valid = 0;
  reg [15:0] lbA_bits = 0, lbB_bits = 0;
  reg corrupt_arm = 0, corrupt_done = 0;
  always @(posedge HCLK) begin
    lbA_valid <= A_mbTxValid;
    if (corrupt_arm && !corrupt_done && A_mbTxValid) begin
      lbA_bits <= A_mbTxBits ^ 16'h0001;
      corrupt_done <= 1'b1;
    end else begin
      lbA_bits <= A_mbTxBits;
    end
    lbB_valid <= B_mbTxValid;
    lbB_bits <= B_mbTxBits;
  end
  assign A2B_mb_valid = lbA_valid;
  assign A2B_mb_bits = lbA_bits;
  assign B2A_mb_valid = lbB_valid;
  assign B2A_mb_bits = lbB_bits;

  // ---- SB cross: TB gearbox per direction (BFM timing) ----
  // See common/sb_gear.sv: capture burst bits while sending, re-emit
  // BFM-exact pulses. Direct 1:1 forwarding breaks the des (its
  // synchronizer + delayed-count pipeline needs edges away from local
  // posedges); sampling the gated clock sticks. Gearbox adds ~2cyc/bit.
  sb_gear gear_a2b (
    .clock(HCLK), .reset(~HRESETn),
    .in_bit(A_sbTx),
    .in_sending(dut_a.logPhy.sidebandChannel.lower_node.tx_ser.sending),
    .out_bit(B_sbRx), .out_clk(B_sbRxc)
  );
  sb_gear gear_b2a (
    .clock(HCLK), .reset(~HRESETn),
    .in_bit(B_sbTx),
    .in_sending(dut_b.logPhy.sidebandChannel.lower_node.tx_ser.sending),
    .out_bit(A_sbRx), .out_clk(A_sbRxc)
  );

  // ---- AHB push/collect per side ----
  task automatic a_push(input [63:0] w);
    begin
      @(negedge HCLK);
      A_HSEL = 1; A_HWRITE = 1; A_HTRANS = 2'b10; A_HADDR = 0; A_HWDATA = w;
      @(posedge HCLK);
      @(negedge HCLK);
      A_HSEL = 0; A_HWRITE = 0; A_HTRANS = 0;
    end
  endtask
  task automatic b_push(input [63:0] w);
    begin
      @(negedge HCLK);
      B_HSEL = 1; B_HWRITE = 1; B_HTRANS = 2'b10; B_HADDR = 0; B_HWDATA = w;
      @(posedge HCLK);
      @(negedge HCLK);
      B_HSEL = 0; B_HWRITE = 0; B_HTRANS = 0;
    end
  endtask

  reg [63:0] a2b_exp [0:13];
  reg [63:0] a2b_got [0:13];
  reg [63:0] b2a_exp [0:6];
  reg [63:0] b2a_got [0:6];
  integer i, k, n;
  // Sticky counters: single-shot pulses are invisible to 1M polling.
  // Localize the PARAM path stage by stage (RDI ser out, upper des out,
  // lower burst starts).
  reg [31:0] A_lsw_cnt = 0, B_lsw_cnt = 0;
  reg A_lsw_prev = 0, B_lsw_prev = 0;
  // Stage counters (rise-edge counts, never reset): RDI ser out,
  // upper des out, lower burst starts. Deltas localize the stuck hop.
  reg [31:0] A_rser_cnt = 0, B_rser_cnt = 0;
  reg A_rser_prev = 0, B_rser_prev = 0;
  reg [31:0] A_udes_cnt = 0, B_udes_cnt = 0;
  reg A_udes_prev = 0, B_udes_prev = 0;
  always @(posedge HCLK) begin
    // Count lower-burst starts (sending rises).
    if (dut_a.logPhy.sidebandChannel.lower_node.tx_ser.sending &&
        !A_lsw_prev) A_lsw_cnt <= A_lsw_cnt + 1;
    if (dut_b.logPhy.sidebandChannel.lower_node.tx_ser.sending &&
        !B_lsw_prev) B_lsw_cnt <= B_lsw_cnt + 1;
    A_lsw_prev <= dut_a.logPhy.sidebandChannel.lower_node.tx_ser.sending;
    B_lsw_prev <= dut_b.logPhy.sidebandChannel.lower_node.tx_ser.sending;
    // Count RDI ser out-valid rises (32b word groups, 4 per packet).
    if (dut_a.d2dadapter.d2d_sideband.rdi_sideband_node.io_outer_tx_valid &&
        !A_rser_prev) A_rser_cnt <= A_rser_cnt + 1;
    if (dut_b.d2dadapter.d2d_sideband.rdi_sideband_node.io_outer_tx_valid &&
        !B_rser_prev) B_rser_cnt <= B_rser_cnt + 1;
    A_rser_prev <= dut_a.d2dadapter.d2d_sideband.rdi_sideband_node.io_outer_tx_valid;
    B_rser_prev <= dut_b.d2dadapter.d2d_sideband.rdi_sideband_node.io_outer_tx_valid;
    // Count upper des out pulses (assembled packets).
    if (dut_a.logPhy.sidebandChannel.upper_node.rx_des.io_out_valid &&
        !A_udes_prev) A_udes_cnt <= A_udes_cnt + 1;
    if (dut_b.logPhy.sidebandChannel.upper_node.rx_des.io_out_valid &&
        !B_udes_prev) B_udes_cnt <= B_udes_cnt + 1;
    A_udes_prev <= dut_a.logPhy.sidebandChannel.upper_node.rx_des.io_out_valid;
    B_udes_prev <= dut_b.logPhy.sidebandChannel.upper_node.rx_des.io_out_valid;
  end

  // Wire sniffer: sample A->B AFE bits on negedge HCLK while sending
  // (reg, stable mid-cycle; immune to txclk burst-end glitches).
  // Arms at train-4 entry: first 3 post-train bursts (PARAM + tail).
  reg [127:0] snif_pkt = 0;
  integer snif_n = 0;
  integer snif_npkt = 0;
  reg [127:0] snif_first3 [0:2];
  wire snif_armed = (dut_a.logPhy.trainingModule.currentState === 3'h4);
  always @(negedge HCLK) begin
    if (!HRESETn || !snif_armed) begin
      snif_n = 0;
      // keep npkt (don't reset after armed)
    end else if (dut_a.logPhy.sidebandChannel.lower_node.tx_ser.sending === 1'b0) begin
      // Inter-burst gap: drop any partial (mid-burst arming) so each
      // stored packet is one full 128b burst, correctly framed.
      snif_n = 0;
    end else if (snif_npkt < 3) begin
      snif_pkt[snif_n] = A_sbTx;
      snif_n = snif_n + 1;
      if (snif_n == 128) begin
        snif_first3[snif_npkt] = snif_pkt;
        snif_npkt = snif_npkt + 1;
        snif_n = 0;
        $display("SNIFF pkt%0d=%h", snif_npkt, snif_pkt);
      end
    end
  end

  integer wait_train, wait_link;

  initial begin
    $display("FLITDUAL BUILD MARKER v5-counters-gear64k-desfix");
    HRESETn = 0;
    repeat (6) @(posedge HCLK);
    HRESETn = 1;

    // ---- Bring-up: both sides train, then ACTIVE ----
    // NOTE: MBINIT messages route UP (away from training) on both sides,
    // so MBINIT always burns 2x6.4M-cycle timeouts here (single-DUT is
    // fast only because the BFM echoes). Budget accordingly.
    wait_train = 0;
    while ((dut_a.logPhy.trainingModule.currentState !== 3'h4 ||
            dut_b.logPhy.trainingModule.currentState !== 3'h4) &&
           wait_train < 30000000) begin
      @(posedge HCLK);
      wait_train = wait_train + 1;
      if (wait_train % 2000000 == 0)
        $display("DUAL-TRAIN t=%0t A=%d/%d B=%d/%d",
                 $time, dut_a.logPhy.trainingModule.currentState,
                 dut_a.logPhy.trainingModule.sbInitSubState,
                 dut_b.logPhy.trainingModule.currentState,
                 dut_b.logPhy.trainingModule.sbInitSubState);
    end
    if (dut_a.logPhy.trainingModule.currentState !== 3'h4 ||
        dut_b.logPhy.trainingModule.currentState !== 3'h4) begin
      $display("DUAL FAIL: train timeout A=%d B=%d",
               dut_a.logPhy.trainingModule.currentState,
               dut_b.logPhy.trainingModule.currentState);
      fails++;
    end else begin
    $display("DUAL TRAINED t=%0t", $time);
    // Fine-grained D2D-startup trace (first 50k cycles post-train):
    // catches the single-shot PARAM emission (or its absence).
    begin
      integer q;
      for (q = 0; q < 50000; q = q + 1) begin
        @(posedge HCLK);
        if (q % 200 == 0)
          $display("DUAL-EARLY t=%0t Asnd=%h Bsnd=%h Apst=%0d Bpst=%0d Aps=%b Apr=%b Bps=%b Bpr=%b Arserc=%0d Brserc=%0d Audesc=%0d Budesc=%0d Alswc=%0d Blswc=%0d Agtw=%0d Bgtw=%0d",
                   $time,
                   dut_a.d2dadapter.link_manager.io_sb_snd,
                   dut_b.d2dadapter.link_manager.io_sb_snd,
                   dut_a.d2dadapter.link_manager.linkinit_submodule.linkinit_state_reg,
                   dut_b.d2dadapter.link_manager.linkinit_submodule.linkinit_state_reg,
                   dut_a.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_snt_flag,
                   dut_a.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_rcv_flag,
                   dut_b.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_snt_flag,
                   dut_b.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_rcv_flag,
                   A_rser_cnt, B_rser_cnt, A_udes_cnt, B_udes_cnt,
                   A_lsw_cnt, B_lsw_cnt,
                   gear_a2b.total_fwd, gear_b2a.total_fwd);
        if (A_state === 4'h1 && B_state === 4'h1) begin
          $display("DUAL-EARLY: ACTIVE reached, skipping trace");
          q = 50000;
        end
      end
    end
    wait_link = 0;
    while ((A_state !== 4'h1 || B_state !== 4'h1) && wait_link < 20000000) begin
      @(posedge HCLK);
      wait_link = wait_link + 1;
      if (wait_link % 1000000 == 0)
        $display("DUAL-LINK t=%0t Ast=%h Bst=%h At=%d Bt=%d Asnd=%h Bsnd=%h Arcv=%h Brcv=%h Alink=%0d Blink=%0d Apst=%0d Bpst=%0d Aps=%b Apr=%b Bps=%b Bpr=%b Agtw=%0d Bgtw=%0d Ades=%0d Bdes=%0d Arserc=%0d Brserc=%0d Audesc=%0d Budesc=%0d Alswc=%0d Blswc=%0d",
                 $time, A_state, B_state,
                 dut_a.logPhy.trainingModule.currentState,
                 dut_b.logPhy.trainingModule.currentState,
                 dut_a.d2dadapter.link_manager.io_sb_snd,
                 dut_b.d2dadapter.link_manager.io_sb_snd,
                 dut_a.d2dadapter.link_manager.io_sb_rcv,
                 dut_b.d2dadapter.link_manager.io_sb_rcv,
                 dut_a.d2dadapter.link_manager.link_state_reg,
                 dut_b.d2dadapter.link_manager.link_state_reg,
                 dut_a.d2dadapter.link_manager.linkinit_submodule.linkinit_state_reg,
                 dut_b.d2dadapter.link_manager.linkinit_submodule.linkinit_state_reg,
                 dut_a.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_snt_flag,
                 dut_a.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_rcv_flag,
                 dut_b.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_snt_flag,
                 dut_b.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_rcv_flag,
                 gear_a2b.total_fwd, gear_b2a.total_fwd,
                 dut_a.logPhy.sidebandChannel.lower_node.rx_des.recvCount,
                 dut_b.logPhy.sidebandChannel.lower_node.rx_des.recvCount,
                 A_rser_cnt, B_rser_cnt, A_udes_cnt, B_udes_cnt,
                 A_lsw_cnt, B_lsw_cnt);
    end
    if (A_state !== 4'h1 || B_state !== 4'h1) begin
      $display("DUAL FAIL: link timeout A=%h B=%h", A_state, B_state);
      fails++;
    end else begin
    $display("DUAL ACTIVE t=%0t", $time);

    // ---- A->B: 2 flits (14 words), 1-shot corrupt on first ----
    a2b_exp[0] = 64'h0123_4567_89AB_CDEF;
    a2b_exp[1] = 64'hFEDC_BA98_7654_3210;
    a2b_exp[2] = 64'hA5A5_5A5A_DEAD_BEEF;
    a2b_exp[3] = 64'h0000_0000_0000_0001;
    a2b_exp[4] = 64'hFFFF_FFFF_FFFF_FFFF;
    a2b_exp[5] = 64'h1111_2222_3333_4444;
    a2b_exp[6] = 64'h5555_6666_7777_8888;
    a2b_exp[7] = 64'h9999_AAAA_BBBB_CCCC;
    a2b_exp[8] = 64'h1357_9BDF_2468_ACE0;
    a2b_exp[9] = 64'h0F0F_F0F0_00FF_FF00;
    a2b_exp[10] = 64'hDEAD_DEAD_DEAD_DEAD;
    a2b_exp[11] = 64'hBEEF_BEEF_BEEF_BEEF;
    a2b_exp[12] = 64'hCAFE_F00D_CAFE_F00D;
    a2b_exp[13] = 64'h8BAD_F00D_8BAD_F00D;
    corrupt_arm = 1; corrupt_done = 0;
    for (i = 0; i < 14; i = i + 1) a_push(a2b_exp[i]);
    // Change-detect collector: the FDI hold-reg keeps valid/data sticky
    // across the inter-flit ACK gap, so sample on rise-or-change
    // (test vectors are consecutive-distinct).
    n = 0;
    begin
      reg pv = 1'b0;
      reg [63:0] pd = 64'h0;
      for (k = 0; k < 200000 && n < 14; k = k + 1) begin
        @(posedge HCLK); #1;
        if (B_plvalid === 1'b1 && (pv !== 1'b1 || B_pldata !== pd)) begin
          a2b_got[n] = B_pldata; n = n + 1;
        end
        pv = B_plvalid; pd = B_pldata;
      end
    end
    if (n !== 14) begin
      $display("FAIL: A->B got %0d/14 words", n); fails++;
    end else begin
      for (i = 0; i < 14; i = i + 1)
        if (a2b_got[i] !== a2b_exp[i]) begin
          $display("FAIL: A->B word%0d exp=%h got=%h", i, a2b_exp[i], a2b_got[i]);
          fails++;
        end
      if (fails == 0) $display("PASS: A->B 2 flits incl. corrupted retry");
    end
    if (!corrupt_done) begin
      $display("FAIL: corruption never fired (no MB traffic?)"); fails++;
    end else $display("PASS: 1-shot corruption fired");
    if (dut_b.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt == 0) begin
      $display("FAIL: B saw no CRC error"); fails++;
    end else $display("PASS: B err_cnt=%0d (retry happened)",
                      dut_b.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt);

    // ---- B->A: 1 flit ----
    for (i = 0; i < 7; i = i + 1) b2a_exp[i] = 64'hB000_0000_0000_0000 + 64'(i);
    for (i = 0; i < 7; i = i + 1) b_push(b2a_exp[i]);
    n = 0;
    begin
      reg pv = 1'b0;
      reg [63:0] pd = 64'h0;
      for (k = 0; k < 200000 && n < 7; k = k + 1) begin
        @(posedge HCLK); #1;
        if (A_plvalid === 1'b1 && (pv !== 1'b1 || A_pldata !== pd)) begin
          b2a_got[n] = A_pldata; n = n + 1;
        end
        pv = A_plvalid; pd = A_pldata;
      end
    end
    if (n !== 7) begin
      $display("FAIL: B->A got %0d/7 words", n); fails++;
    end else begin
      for (i = 0; i < 7; i = i + 1)
        if (b2a_got[i] !== b2a_exp[i]) begin
          $display("FAIL: B->A word%0d exp=%h got=%h", i, b2a_exp[i], b2a_got[i]);
          fails++;
        end
      if (fails == 0) $display("PASS: B->A 1 flit");
    end

    // ---- Link health ----
    if (A_flit_err || B_flit_err) begin
      $display("FAIL: link_error A=%b B=%b", A_flit_err, B_flit_err); fails++;
    end else $display("PASS: no link_error either side");
    if (A_flit_ovf || B_flit_ovf) begin
      $display("FAIL: overflow A=%b B=%b", A_flit_ovf, B_flit_ovf); fails++;
    end else $display("PASS: no overflow either side");
    $display("DUAL-END Aseq=%0d Aack=%0d Back=%0d Back=%0d",
             dut_a.d2dadapter.gen_flit.u_mb_flit.u_pack.seq_reg,
             dut_a.d2dadapter.gen_flit.u_mb_flit.u_pack.oldest_seq,
             dut_b.d2dadapter.gen_flit.u_mb_flit.u_pack.seq_reg,
             dut_b.d2dadapter.gen_flit.u_mb_flit.u_pack.oldest_seq);
    end // link-ok
    end // train-ok

    if (fails == 0) $display("FLITDUAL PASS");
    else $display("FLITDUAL FAIL fails=%0d", fails);
    $finish;
  end

  initial begin
    repeat (70000000) @(posedge HCLK);
    $display("FLITDUAL FAIL: watchdog");
    $finish;
  end
endmodule
