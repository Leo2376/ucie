// sbchan_fwd_tb: sb_chan forwarding in mission mode (inputMode=1,
// rxMode=1, i.e. train state 4), no training engine. Proves D2D-shaped
// packets traverse upper(RDI)<->lower(AFE) without training help.
// UP: 4x32b words in at upper outer RX -> 128b packet out lower tx_ser.
// DN: 128b packet in at lower (via direct 128b inject) -> 4x32b out upper.
// Fast isolation for dual-top D2D stall (sb_chan suspect).
`timescale 1ns / 1ps
module sbchan_fwd_tb;
  reg clock = 0;
  reg reset = 1;
  always #5 clock = ~clock;
  integer fails = 0;

  // Upper (RDI side) outer: RX in (TB drives), TX out (observed).
  reg [31:0] up_rx_bits = 0;
  reg        up_rx_vld = 0;
  wire       up_rx_crd;
  wire [31:0] up_tx_bits;
  wire        up_tx_vld;
  reg        up_tx_crd = 1;
  // Lower (AFE side): serial via lser/ldes models? Drive 128b directly
  // into lower inner? No: lower inner comes from switch only. Instead
  // observe lower tx_ser (sending + collect serial bits via AFE pins).
  wire       lo_txbit, lo_txclk;
  reg        lo_rxbit = 0, lo_rxclk = 0;
  // Inner bundle (training side): training NEVER accepts in this test
  // (mimics train state 4 gated-off consumers). This is the clog probe:
  // a stale training-shaped packet must not head-of-line-block D2D.
  wire       inner_raw_rdy;
  wire       inner_n2l_vld;
  wire [127:0] inner_n2l_bits;
  wire       inner_l2n_rdy;

  sb_chan dut (
    .clock(clock), .reset(reset),
    .io_to_upper_layer_tx_bits(up_tx_bits),
    .io_to_upper_layer_tx_valid(up_tx_vld),
    .io_to_upper_layer_tx_credit(up_tx_crd),
    .io_to_upper_layer_rx_bits(up_rx_bits),
    .io_to_upper_layer_rx_valid(up_rx_vld),
    .io_to_upper_layer_rx_credit(up_rx_crd),
    .io_to_lower_layer_tx_bits(lo_txbit),
    .io_to_lower_layer_tx_clock(lo_txclk),
    .io_to_lower_layer_rx_bits(lo_rxbit),
    .io_to_lower_layer_rx_clock(lo_rxclk),
    .io_inner_inputMode(1'b1),
    .io_inner_rxMode(1'b1),
    .io_inner_rawInput_ready(inner_raw_rdy),
    .io_inner_rawInput_valid(1'b0),
    .io_inner_rawInput_bits(128'h0),
    .io_inner_switcherBundle_node_to_layer_below_ready(1'b0),
    .io_inner_switcherBundle_node_to_layer_below_valid(inner_n2l_vld),
    .io_inner_switcherBundle_node_to_layer_below_bits(inner_n2l_bits),
    .io_inner_switcherBundle_layer_to_node_below_ready(inner_l2n_rdy),
    .io_inner_switcherBundle_layer_to_node_below_valid(1'b0),
    .io_inner_switcherBundle_layer_to_node_below_bits(128'h0)
  );

  // AFE serial sampler: sample DATA every negedge while the lser is
  // sending (reg, stable mid-cycle; immune to txclk combinational
  // glitches at burst boundaries, which inject spurious edges into
  // edge-counting samplers and shift everything after by one bit).
  reg [127:0] tx_pkt [0:1];
  integer tx_n = 0;
  integer tx_npkt = 0;
  reg tx_done = 0;
  always @(negedge clock) begin
    if (!reset && tx_npkt < 2 &&
        dut.lower_node.tx_ser.sending === 1'b1) begin
      tx_pkt[tx_npkt][tx_n] = lo_txbit;
      tx_n = tx_n + 1;
      if (tx_n == 128) begin tx_n = 0; tx_npkt = tx_npkt + 1; end
      if (tx_npkt == 2) tx_done = 1;
    end
  end

  // D2D PARAM template (exact d2d_sb encoder literal for code 0x24):
  // 128'h488000050000002000401b, words LSB-first. ([58:56]=5 routes
  // node_to_node in the legacy switch; a [58:56]==0 packet would take
  // the dead inner leg and stall -- that is expected, not a bug.)
  reg [31:0] w [0:3];
  integer i, k;
  // Path probes (hierarchical), first 2000 cycles.
  integer pcyc = 0;
  always @(posedge clock) begin
    #1;
    if (!reset) begin
      pcyc <= pcyc + 1;
      if (pcyc < 2000 && pcyc % 200 == 0) begin
        $display("SB cyc=%0d updes=%b upqev=%b upqdv=%b upin=%b swabo=%b swblo=%b lobits=%h losend=%b lordy=%b",
          pcyc,
          dut.upper_node.rx_des.io_out_valid,
          dut.upper_node.rx_queue.io_enq_valid,
          dut.upper_node.rx_queue.io_deq_valid,
          dut.upper_node.io_inner_node_to_layer_valid,
          dut.switcher.io_outer_node_to_layer_above_valid,
          dut.switcher.io_outer_layer_to_node_below_valid,
          dut.switcher.io_outer_layer_to_node_below_bits[7:0],
          dut.lower_node.tx_ser.sending,
          dut.lower_node.tx_ser.io_in_ready);
      end
    end
  end
  initial begin
    w[0] = 32'h2000401b;
    w[1] = 32'h05000000;
    w[2] = 32'h00488000;
    w[3] = 32'h00000000;
    repeat (4) @(posedge clock);
    reset = 0;
    repeat (4) @(posedge clock);
    // FIRST: a stale training-shaped packet (0200-domain LinkInit-like,
    // routes inner/training which never accepts here).
    @(negedge clock);
    up_rx_bits = 32'h00004012; up_rx_vld = 1;
    @(posedge clock);
    @(negedge clock);
    up_rx_bits = 32'h02000000;
    @(posedge clock);
    @(negedge clock);
    up_rx_bits = 32'h00000000;
    @(posedge clock);
    @(negedge clock);
    up_rx_bits = 32'h00000000;
    @(posedge clock);
    @(negedge clock);
    up_rx_vld = 0;
    repeat (20) @(posedge clock);
    // THEN: the D2D PARAM (must still get through, else clogged).
    // NOTE: only n2n-branch packets reach the AFE; the stale training
    // packet routes inner (training, gated off) and must NOT block this.
    for (i = 0; i < 4; i = i + 1) begin
      @(negedge clock);
      up_rx_bits = w[i]; up_rx_vld = 1;
      @(posedge clock);
    end
    @(negedge clock);
    up_rx_vld = 0;
    // Wait for BOTH serial emissions (stale + PARAM, FIFO order).
    k = 0;
    while (k < 8000 && !tx_done) begin @(posedge clock); k = k + 1; end
    if (!tx_done) begin $display("FAIL: missing AFE emission(s)"); fails++; end
    else begin
      // First out must be the stale training packet (proves no clog:
      // stale drains instead of head-of-line blocking).
      if (tx_pkt[0][31:0] !== 32'h00004012) begin
        $display("FAIL: stale w0 exp=00004012 got=%h", tx_pkt[0][31:0]); fails++;
      end
      if (tx_pkt[0][63:32] !== 32'h02000000) begin
        $display("FAIL: stale w1 exp=02000000 got=%h", tx_pkt[0][63:32]); fails++;
      end
      // Second out must be the PARAM, intact.
      if (tx_pkt[1][31:0] !== w[0]) begin
        $display("FAIL: w0 exp=%h got=%h", w[0], tx_pkt[1][31:0]); fails++;
      end
      if (tx_pkt[1][63:32] !== w[1]) begin
        $display("FAIL: w1 exp=%h got=%h", w[1], tx_pkt[1][63:32]); fails++;
      end
      if (tx_pkt[1][95:64] !== w[2]) begin
        $display("FAIL: w2 exp=%h got=%h", w[2], tx_pkt[1][95:64]); fails++;
      end
      if (tx_pkt[1][127:96] !== w[3]) begin
        $display("FAIL: w3 exp=%h got=%h", w[3], tx_pkt[1][127:96]); fails++;
      end
      if (fails == 0) $display("PASS: stale drains, PARAM intact (no clog)");
    end
    if (fails == 0) $display("SBCHANFWD PASS");
    else $display("SBCHANFWD FAIL fails=%0d", fails);
    $finish;
  end
  initial begin
    repeat (100000) @(posedge clock);
    $display("SBCHANFWD FAIL: watchdog");
    $finish;
  end
endmodule
