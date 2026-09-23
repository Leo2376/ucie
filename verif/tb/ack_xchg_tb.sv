// ack_xchg_tb: cross-die ACK/NACK exchange (docs/ack_spec.md).
//
// Two d2d_sb instances cross-connected at the RDI 32b config streams
// (A.lp -> B.pl and B.lp -> A.pl, credits crossed). No training gates
// exist in d2d_sb, so this is deterministic and fast.
// 1. A ACK seq -> B decodes seq; 2. B ACK seq -> A; 3. A NACK -> B;
// 4. mgmt (snt) priority over pending ACK; 5. decode quiet (rcv==0)
//    throughout (ACKs never leak to link-mgmt); 6. host tap copies the
//    RDI-ingress packet word-intact.
// Driving convention: TB inputs change on negedge.
`timescale 1ns / 1ps

module ack_xchg_tb;
  reg clock = 0;
  reg reset = 1;
  always #5 clock = ~clock;

  integer fails = 0;

  // ---- cross-connected RDI streams ----
  wire [31:0] A2B_bits, B2A_bits;
  wire        A2B_vld, B2A_vld, A2B_crd, B2A_crd;

  // ---- A side ----
  reg        A_ack_v = 0;
  reg [7:0]  A_ack_s = 0;
  reg        A_nack = 0;
  wire       A_ack_rxv;
  wire [7:0] A_ack_rxs;
  wire       A_nack_rx;
  wire [5:0] A_rcv;
  reg [5:0]  A_snt = 0;
  wire       A_rdy;
  wire [31:0] A_tap;
  wire        A_tapv;
  reg        rcv_quiet = 1;

  d2d_sb dut_a (
    .clock(clock), .reset(reset),
    .io_rdi_pl_cfg(B2A_bits), .io_rdi_pl_cfg_vld(B2A_vld),
    .io_rdi_pl_cfg_crd(B2A_crd),
    .io_rdi_lp_cfg(A2B_bits), .io_rdi_lp_cfg_vld(A2B_vld),
    .io_rdi_lp_cfg_crd(A2B_crd),
    .io_fdi_pl_cfg(32'h0), .io_fdi_pl_cfg_vld(1'b0),
    .io_fdi_pl_cfg_crd(),
    .io_fdi_lp_cfg(A_tap), .io_fdi_lp_cfg_vld(A_tapv),
    .io_fdi_lp_cfg_crd(1'b1),
    .io_sideband_rcv(A_rcv), .io_sideband_snt(A_snt), .io_sideband_rdy(A_rdy),
    .io_ack_tx_valid(A_ack_v), .io_ack_tx_seq(A_ack_s), .io_nack_tx(A_nack),
    .io_ack_rx_valid(A_ack_rxv), .io_ack_rx_seq(A_ack_rxs),
    .io_nack_rx(A_nack_rx)
  );

  // ---- B side ----
  reg        B_ack_v = 0;
  reg [7:0]  B_ack_s = 0;
  reg        B_nack = 0;
  wire       B_ack_rxv;
  wire [7:0] B_ack_rxs;
  wire       B_nack_rx;
  wire [5:0] B_rcv;
  wire       B_rdy;
  wire [31:0] B_tap;
  wire        B_tapv;

  d2d_sb dut_b (
    .clock(clock), .reset(reset),
    .io_rdi_pl_cfg(A2B_bits), .io_rdi_pl_cfg_vld(A2B_vld),
    .io_rdi_pl_cfg_crd(A2B_crd),
    .io_rdi_lp_cfg(B2A_bits), .io_rdi_lp_cfg_vld(B2A_vld),
    .io_rdi_lp_cfg_crd(B2A_crd),
    .io_fdi_pl_cfg(32'h0), .io_fdi_pl_cfg_vld(1'b0),
    .io_fdi_pl_cfg_crd(),
    .io_fdi_lp_cfg(B_tap), .io_fdi_lp_cfg_vld(B_tapv),
    .io_fdi_lp_cfg_crd(1'b1),
    .io_sideband_rcv(B_rcv), .io_sideband_snt(6'h0), .io_sideband_rdy(B_rdy),
    .io_ack_tx_valid(B_ack_v), .io_ack_tx_seq(B_ack_s), .io_nack_tx(B_nack),
    .io_ack_rx_valid(B_ack_rxv), .io_ack_rx_seq(B_ack_rxs),
    .io_nack_rx(B_nack_rx)
  );

  // Decode-quiet monitor (ACKs must never reach link-mgmt; gated off
  // while part 4 deliberately drives mgmt).
  reg check_quiet = 1;
  always @(posedge clock) begin
    #1;
    if (!reset && check_quiet && (A_rcv !== 6'h0 || B_rcv !== 6'h0)) rcv_quiet <= 1'b0;
  end

  // Tap collectors (host copies of RDI-ingress, LSB first).
  reg [31:0] Atap_q [0:15];
  integer Atap_n = 0;
  always @(posedge clock) begin
    #1;
    if (!reset && A_tapv === 1'b1 && Atap_n < 16) begin
      Atap_q[Atap_n] = A_tap; Atap_n = Atap_n + 1;
    end
  end

  task automatic pulse_ack_a(input [7:0] seq);
    begin
      @(negedge clock);
      A_ack_v = 1; A_ack_s = seq;
      @(posedge clock);
      @(negedge clock);
      A_ack_v = 0;
    end
  endtask

  // Wait for B-side ack with seq; returns 1 on success.
  task automatic wait_back(input [7:0] seq, output bit ok);
    integer k;
    begin
      ok = 0;
      for (k = 0; k < 600 && !ok; k = k + 1) begin
        @(posedge clock); #1;
        if (B_ack_rxv === 1'b1) begin
          if (B_ack_rxs !== seq) begin
            $display("FAIL: B ack seq exp=%h got=%h", seq, B_ack_rxs); fails++;
          end
          ok = 1;
        end
      end
      if (!ok) begin $display("FAIL: B ack seq=%h timeout", seq); fails++; end
    end
  endtask

  bit ok;
  integer k;

  initial begin
    repeat (4) @(posedge clock);
    reset = 0;
    repeat (2) @(posedge clock);

    // 1. A ACK 0xA5 -> B.
    pulse_ack_a(8'hA5);
    wait_back(8'hA5, ok);
    if (ok) $display("PASS: A->B ACK seq intact");

    // 2. B ACK 0x3C -> A.
    @(negedge clock);
    B_ack_v = 1; B_ack_s = 8'h3C;
    @(posedge clock);
    @(negedge clock);
    B_ack_v = 0;
    ok = 0;
    for (k = 0; k < 600 && !ok; k = k + 1) begin
      @(posedge clock); #1;
      if (A_ack_rxv === 1'b1) begin
        if (A_ack_rxs !== 8'h3C) begin
          $display("FAIL: A ack seq exp=3c got=%h", A_ack_rxs); fails++;
        end
        ok = 1;
      end
    end
    if (!ok) $display("FAIL: A ack timeout");
    else $display("PASS: B->A ACK seq intact");

    // 3. A NACK -> B nack pulse.
    @(negedge clock);
    A_nack = 1;
    @(posedge clock);
    @(negedge clock);
    A_nack = 0;
    ok = 0;
    for (k = 0; k < 600 && !ok; k = k + 1) begin
      @(posedge clock); #1;
      if (B_nack_rx === 1'b1) ok = 1;
    end
    if (!ok) $display("FAIL: B nack timeout");
    else $display("PASS: A->B NACK pulse");

    // 4. Mgmt priority: hold snt=0x01, pulse ACK, expect mgmt first.
    @(negedge clock);
    check_quiet = 0;
    A_snt = 6'h01;
    A_ack_v = 1; A_ack_s = 8'h77;
    @(posedge clock);
    @(negedge clock);
    A_ack_v = 0;
    // While snt held, B must NOT see the ACK yet (mgmt template wins).
    repeat (30) @(posedge clock); #1;
    if (B_ack_rxv === 1'b1) begin
      $display("FAIL: ACK leaked during mgmt"); fails++;
    end else $display("PASS: mgmt holds off ACK");
    if (B_rcv !== 6'h01) begin
      $display("FAIL: B mgmt decode exp=01 got=%h", B_rcv); fails++;
    end else $display("PASS: mgmt ACTIVE-req decoded at B");
    @(negedge clock);
    A_snt = 6'h0;
    wait_back(8'h77, ok);
    if (ok) $display("PASS: ACK follows mgmt");
    repeat (10) @(posedge clock);
    check_quiet = 1;

    // 5. Decode quiet across data-ACK traffic.
    repeat (10) @(posedge clock);
    if (!rcv_quiet) begin $display("FAIL: mgmt decode saw ACKs"); fails++; end
    else $display("PASS: decode quiet on ACK traffic");

    // 6. Host tap: A's tap copies A-ingress (from B). Last B->A packet
    // is the 0x3C ACK: {64'h0, 8'h3C, 8'h00, 8'h00, 8'h2A, 10'h080,
    // 8'h04, 9'h0, 1, 2}, LSB first: w0=20010012, w1=3C00002A, w2=0, w3=0.
    if (Atap_n < 4) begin
      $display("FAIL: A tap only %0d words", Atap_n);
      fails++;
    end else begin
      // Last group of 4 = most recent packet.
      if (Atap_q[Atap_n-4] !== 32'h20010012) begin
        $display("FAIL: tap w0 exp=20010012 got=%h", Atap_q[Atap_n-4]); fails++;
      end
      if (Atap_q[Atap_n-3] !== 32'h3C00002A) begin
        $display("FAIL: tap w1 exp=3C00002A got=%h", Atap_q[Atap_n-3]); fails++;
      end
      if (Atap_q[Atap_n-2] !== 32'h00000000) begin
        $display("FAIL: tap w2 exp=0 got=%h", Atap_q[Atap_n-2]); fails++;
      end
      if (Atap_q[Atap_n-1] !== 32'h00000000) begin
        $display("FAIL: tap w3 exp=0 got=%h", Atap_q[Atap_n-1]); fails++;
      end
      if (fails == 0) $display("PASS: host tap word-intact (seq+code)");
    end

    if (fails == 0) $display("ACKXCHG PASS");
    else $display("ACKXCHG FAIL fails=%0d", fails);
    $finish;
  end

  initial begin
    repeat (100000) @(posedge clock);
    $display("ACKXCHG FAIL: watchdog");
    $finish;
  end
endmodule
