// flit_pack_tb: unit test for ucie_crc32 + flit_pack + flit_unpack.
//
// 1. Pack 7 words -> unpack -> payload identical, ack seq 0.
// 2. Corrupt one bit -> nack + err_cnt=1, no words.
// 3. Retry: nack -> out_retry retransmits same flit.
//
// Driving convention (avoids posedge races under Verilator --timing):
// inputs change on negedge, DUT captures on posedge.
`timescale 1ns / 1ps
module flit_pack_tb;
  reg clock = 0;
  reg reset = 1;
  always #5 clock = ~clock;

  reg        p_in_valid = 0;
  reg [63:0] p_in_bits = 0;
  wire       p_in_ready;
  reg        p_out_ready = 0;
  wire       p_out_valid;
  wire [511:0] p_out_bits;
  wire       p_out_retry;
  reg        ack_valid = 0;
  reg [7:0]  ack_seq = 0;
  reg        nack_in = 0;
  wire       link_error;
  wire [7:0] cur_seq;

  flit_pack dut_pack (
    .clock(clock), .reset(reset),
    .in_ready(p_in_ready), .in_valid(p_in_valid), .in_bits(p_in_bits),
    .idle_req(1'b0),
    .out_ready(p_out_ready), .out_valid(p_out_valid), .out_bits(p_out_bits),
    .out_retry(p_out_retry),
    .ack_valid(ack_valid), .ack_seq(ack_seq), .nack(nack_in),
    .link_error(link_error), .cur_seq(cur_seq)
  );

  reg        u_out_ready = 1;
  wire       u_out_valid;
  wire [63:0] u_out_bits;
  wire       u_out_last;
  wire       u_ack_valid;
  wire [7:0] u_ack_seq;
  wire       u_nack;
  wire [31:0] u_err_cnt;

  reg [511:0] u_in_bits = 0;
  reg        u_in_valid = 0;
  wire       u_in_ready;
  flit_unpack dut_unpack (
    .clock(clock), .reset(reset),
    .in_ready(u_in_ready), .in_valid(u_in_valid), .in_bits(u_in_bits),
    .out_ready(u_out_ready), .out_valid(u_out_valid), .out_bits(u_out_bits),
    .out_last(u_out_last),
    .ack_valid(u_ack_valid), .ack_seq(u_ack_seq), .nack(u_nack),
    .err_cnt(u_err_cnt), .exp_seq()
  );

  integer fails = 0;
  reg [63:0] wdata [0:6];
  reg [63:0] rdata [0:6];
  reg [511:0] saved_flit;
  reg [511:0] first_tx;
  integer i;

  // Push one word: setup on negedge, captured on next posedge, drop after.
  task automatic push_word(input [63:0] w);
    begin
      @(negedge clock);
      p_in_bits = w;
      p_in_valid = 1'b1;
      @(posedge clock); // handshake (ready known-high in this test)
      #1;
      if (!p_in_ready && dut_pack.wcnt != 3'd7)
        $display("WARN: push without ready wcnt=%d", dut_pack.wcnt);
      @(negedge clock);
      p_in_valid = 1'b0;
    end
  endtask

  // Present a flit to unpack (same negedge convention).
  task automatic present_flit(input [511:0] f);
    begin
      @(negedge clock);
      u_in_bits = f;
      u_in_valid = 1'b1;
      @(posedge clock);
      @(negedge clock);
      u_in_valid = 1'b0;
    end
  endtask

  initial begin
    wdata[0] = 64'h0123_4567_89AB_CDEF;
    wdata[1] = 64'hFEDC_BA98_7654_3210;
    wdata[2] = 64'hA5A5_5A5A_DEAD_BEEF;
    wdata[3] = 64'h0000_0000_0000_0001;
    wdata[4] = 64'hFFFF_FFFF_FFFF_FFFF;
    wdata[5] = 64'h1111_2222_3333_4444;
    wdata[6] = 64'h5555_6666_7777_8888;
    repeat (4) @(posedge clock);
    reset = 0;
    repeat (2) @(posedge clock);

    // 1. pack 7 words, capture flit with out_ready held low
    p_out_ready = 1'b0;
    for (i = 0; i < 7; i = i + 1) push_word(wdata[i]);
    wait (p_out_valid);
    #1;
    saved_flit = p_out_bits;
    $display("FLIT=%h retry=%b", saved_flit, p_out_retry);
    if (saved_flit[511:504] !== 8'h00) begin
      $display("FAIL: seq exp=00 got=%h", saved_flit[511:504]); fails++;
    end else $display("PASS: seq 0");
    if (p_out_retry) begin
      $display("FAIL: retry on first flit"); fails++;
    end
    @(posedge clock); #1;
    p_out_ready = 1'b1;
    @(posedge clock); #1;
    p_out_ready = 1'b0;

    // unpack it
    present_flit(saved_flit);
    for (i = 0; i < 7; i = i + 1) begin
      wait (u_out_valid);
      rdata[i] = u_out_bits;
      if (i == 6 && !u_out_last) begin
        $display("FAIL: out_last missing"); fails++;
      end
      @(posedge clock); #1;
    end
    repeat (2) @(posedge clock);
    for (i = 0; i < 7; i = i + 1)
      if (rdata[i] !== wdata[i]) begin
        $display("FAIL: word%0d exp=%h got=%h", i, wdata[i], rdata[i]); fails++;
      end
    if (fails == 0) $display("PASS: loopback payload match");
    if (u_err_cnt !== 0) begin
      $display("FAIL: err_cnt exp=0 got=%0d", u_err_cnt); fails++;
    end else $display("PASS: err_cnt 0");

    // 2. corrupt CRC -> nack, err_cnt=1, no words
    repeat (2) @(posedge clock);
    present_flit(saved_flit ^ 512'h1);
    repeat (3) @(posedge clock);
    #1;
    if (u_err_cnt !== 32'd1) begin
      $display("FAIL: err_cnt exp=1 got=%0d", u_err_cnt); fails++;
    end else $display("PASS: corrupt flit detected (err_cnt=1)");
    if (u_out_valid) begin
      $display("FAIL: words emitted on bad CRC"); fails++;
    end else $display("PASS: no words on bad CRC");

    // 3. retry: ack flit0, send flit1, nack -> retransmit identical
    @(negedge clock);
    ack_valid = 1'b1; ack_seq = 8'h00;
    @(posedge clock);
    @(negedge clock);
    ack_valid = 1'b0;
    wdata[0] = 64'hDEAD_DEAD_DEAD_DEAD;
    for (i = 0; i < 7; i = i + 1) push_word(wdata[i]);
    wait (p_out_valid && !p_out_retry);
    #1;
    first_tx = p_out_bits;
    $display("FLIT1 seq=%h", first_tx[511:504]);
    if (first_tx[511:504] !== 8'h01) begin
      $display("FAIL: seq exp=01 got=%h", first_tx[511:504]); fails++;
    end else $display("PASS: seq 1");
    @(posedge clock); #1;
    p_out_ready = 1'b1;
    @(posedge clock); #1;
    p_out_ready = 1'b0;
    @(negedge clock);
    nack_in = 1'b1;
    @(posedge clock);
    @(negedge clock);
    nack_in = 1'b0;
    wait (p_out_valid && p_out_retry);
    #1;
    if (p_out_bits !== first_tx) begin
      $display("FAIL: retry bits differ"); fails++;
    end else $display("PASS: retry retransmits identical flit");
    @(posedge clock); #1;
    p_out_ready = 1'b1;
    @(posedge clock); #1;
    p_out_ready = 1'b0;

    if (link_error) begin $display("FAIL: unexpected link_error"); fails++; end
    else $display("PASS: no link_error");

    if (fails == 0) $display("FLIT PASS");
    else $display("FLIT FAIL fails=%0d", fails);
    $finish;
  end

  initial begin
    repeat (50000) @(posedge clock);
    $display("FAIL: watchdog");
    $finish;
  end
endmodule
