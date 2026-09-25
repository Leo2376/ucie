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

  // ---- 256B datapath (WORDS_PER_FLIT=32, 256b RDI beats) ----
  // Same checks at the wide width: loopback, corrupt->nack, retry.
  localparam int W32 = 32;
  localparam int RAW32 = W32 * 64 + 64;
  localparam int FLIT32 = ((RAW32 + 256 - 1) / 256) * 256;
  reg        p32_in_valid = 0;
  reg [63:0] p32_in_bits = 0;
  wire       p32_in_ready;
  reg        p32_out_ready = 0;
  wire       p32_out_valid;
  wire [FLIT32-1:0] p32_out_bits;
  wire       p32_out_retry;
  reg        ack32_valid = 0;
  reg [7:0]  ack32_seq = 0;
  reg        nack32_in = 0;
  wire       link32_error;

  flit_pack #(.WORDS_PER_FLIT(W32), .RDI_BEAT_W(256)) dut_pack32 (
    .clock(clock), .reset(reset),
    .in_ready(p32_in_ready), .in_valid(p32_in_valid), .in_bits(p32_in_bits),
    .idle_req(1'b0),
    .out_ready(p32_out_ready), .out_valid(p32_out_valid), .out_bits(p32_out_bits),
    .out_retry(p32_out_retry),
    .ack_valid(ack32_valid), .ack_seq(ack32_seq), .nack(nack32_in),
    .link_error(link32_error), .cur_seq()
  );

  reg        u32_out_ready = 1;
  wire       u32_out_valid;
  wire [63:0] u32_out_bits;
  wire       u32_out_last;
  wire       u32_ack_valid;
  wire [7:0] u32_ack_seq;
  wire       u32_nack;
  wire [31:0] u32_err_cnt;
  reg [FLIT32-1:0] u32_in_bits = 0;
  reg        u32_in_valid = 0;
  wire       u32_in_ready;
  flit_unpack #(.WORDS_PER_FLIT(W32), .RDI_BEAT_W(256)) dut_unpack32 (
    .clock(clock), .reset(reset),
    .in_ready(u32_in_ready), .in_valid(u32_in_valid), .in_bits(u32_in_bits),
    .out_ready(u32_out_ready), .out_valid(u32_out_valid), .out_bits(u32_out_bits),
    .out_last(u32_out_last),
    .ack_valid(u32_ack_valid), .ack_seq(u32_ack_seq), .nack(u32_nack),
    .err_cnt(u32_err_cnt), .exp_seq()
  );

  // Slicer/reasm round-trip at 256B width (2304b/9x256b).
  reg        s32_in_valid = 0;
  reg [FLIT32-1:0] s32_in_bits = 0;
  wire       s32_in_ready;
  wire       s32_out_valid;
  wire [255:0] s32_out_bits;
  wire       s32_out_last;
  reg        s32_out_ready = 0;
  flit_slicer #(.FLIT_W(FLIT32), .BEAT_W(256)) u_slice32 (
    .clock(clock), .reset(reset),
    .in_ready(s32_in_ready), .in_valid(s32_in_valid), .in_bits(s32_in_bits),
    .out_ready(s32_out_ready), .out_valid(s32_out_valid), .out_bits(s32_out_bits),
    .out_last(s32_out_last)
  );
  reg        r32_in_valid = 0;
  reg [255:0] r32_in_bits = 0;
  wire       r32_in_ready;
  wire       r32_out_valid;
  wire [FLIT32-1:0] r32_out_bits;
  wire       r32_overflow;
  reg        r32_out_ready = 0;
  flit_reasm #(.FLIT_W(FLIT32), .BEAT_W(256)) u_reasm32 (
    .clock(clock), .reset(reset),
    .in_ready(r32_in_ready), .in_valid(r32_in_valid), .in_bits(r32_in_bits),
    .out_ready(r32_out_ready), .out_valid(r32_out_valid), .out_bits(r32_out_bits),
    .overflow(r32_overflow)
  );

  integer fails = 0;
  reg [63:0] wdata [0:6];
  reg [63:0] rdata [0:6];
  reg [511:0] saved_flit;
  reg [511:0] first_tx;
  integer i;

  // Spare CRC for building idle/poison test flits with valid CRC.
  reg [479:0] crc_in;
  wire [31:0] crc_out;
  ucie_crc32 u_crc_tb (.data(crc_in), .crc(crc_out));

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

    // 4. MAX_RETRY: 4 nacks (MAX_RETRY=3) -> link_error latches, quiesce.
    for (i = 0; i < 4; i = i + 1) begin
      @(negedge clock);
      nack_in = 1'b1;
      @(posedge clock);
      @(negedge clock);
      nack_in = 1'b0;
      p_out_ready = 1'b1;
      @(posedge clock); #1;
      p_out_ready = 1'b0;
      repeat (2) @(posedge clock);
    end
    #1;
    if (!link_error) begin $display("FAIL: link_error not latched after MAX_RETRY"); fails++; end
    else $display("PASS: link_error latched after MAX_RETRY");
    if (p_out_valid) begin $display("FAIL: out_valid not quiesced on link_error"); fails++; end
    else $display("PASS: quiesced on link_error");

    // 5. fmt decode via unpack (fresh state after reset pulse).
    reset = 1'b1;
    repeat (2) @(posedge clock);
    reset = 1'b0;
    repeat (2) @(posedge clock);
    begin
      reg [31:0] ih, ph;
      reg [511:0] idle_f, poison_f;
      integer k;
      // Idle: fmt=1, len=0, zero payload, valid CRC -> ack, no words.
      // (seq must equal expected seq: 0 after reset.)
      ih = {8'h00, 4'h1, 6'd0, 14'h0};
      crc_in = {ih, 448'h0}; #1;
      idle_f = {ih, 448'h0, crc_out};
      present_flit(idle_f);
      repeat (3) @(posedge clock); #1;
      if (u_err_cnt !== 0) begin
        $display("FAIL: idle flit counted err=%0d", u_err_cnt); fails++;
      end else $display("PASS: idle acked without error");
      if (u_out_valid) begin
        $display("FAIL: idle emitted words"); fails++;
      end else $display("PASS: idle emits no words");
      // Poison: fmt=F with valid CRC -> nack + err, no words.
      // (seq=1 = next expected after the idle above; poison nacks anyway.)
      ph = {8'h01, 4'hF, 6'd7, 14'h0};
      crc_in = {ph, saved_flit[479:32]}; #1;
      poison_f = {ph, saved_flit[479:32], crc_out};
      present_flit(poison_f);
      repeat (3) @(posedge clock); #1;
      if (u_err_cnt !== 32'd1) begin
        $display("FAIL: poison err_cnt exp=1 got=%0d", u_err_cnt); fails++;
      end else $display("PASS: poison detected (err_cnt=1)");
      if (u_out_valid) begin
        $display("FAIL: poison emitted words"); fails++;
      end else $display("PASS: poison emits no words");
      // Duplicate data: re-present saved_flit (data, seq 0, valid CRC).
      // exp is 1 (idle seq 0 accepted above), so seq 0 == exp-1: must
      // re-ack WITHOUT re-streaming and WITHOUT counting an error.
      present_flit(saved_flit);
      repeat (3) @(posedge clock); #1;
      if (u_err_cnt !== 32'd1) begin
        $display("FAIL: duplicate changed err_cnt to %0d", u_err_cnt); fails++;
      end else $display("PASS: duplicate re-acked without error");
      if (u_out_valid) begin
        $display("FAIL: duplicate re-streamed words"); fails++;
      end else $display("PASS: duplicate emits no words");
    end

    // 6. 256B width: pack 32 words -> unpack -> match, seq/len, retry.
    begin
      reg [63:0] w32 [0:31];
      reg [63:0] r32 [0:31];
      reg [FLIT32-1:0] f32, f32_retry;
      integer j;
      for (j = 0; j < 32; j = j + 1)
        w32[j] = 64'hA000_0000_0000_0000 + 64'(j * 3 + 1);
      p32_out_ready = 1'b0;
      for (j = 0; j < 32; j = j + 1) begin
        @(negedge clock);
        p32_in_bits = w32[j];
        p32_in_valid = 1'b1;
        @(posedge clock);
        #1;
        @(negedge clock);
        p32_in_valid = 1'b0;
      end
      wait (p32_out_valid);
      #1;
      f32 = p32_out_bits;
      if (f32[RAW32-1:RAW32-8] !== 8'h00) begin
        $display("FAIL: 256B seq exp=00 got=%h", f32[RAW32-1:RAW32-8]); fails++;
      end else $display("PASS: 256B seq 0");
      if (f32[RAW32-9:RAW32-12] !== 4'h0) begin
        $display("FAIL: 256B fmt exp=0 got=%h", f32[RAW32-9:RAW32-12]); fails++;
      end else $display("PASS: 256B fmt data");
      if (f32[RAW32-13:RAW32-18] !== 6'd32) begin
        $display("FAIL: 256B len exp=32 got=%0d", f32[RAW32-13:RAW32-18]); fails++;
      end else $display("PASS: 256B len 32");
      if (f32[FLIT32-1:RAW32] !== {(FLIT32-RAW32){1'b0}}) begin
        $display("FAIL: 256B reserved pad nonzero"); fails++;
      end else $display("PASS: 256B reserved pad zero");
      if (p32_out_retry) begin
        $display("FAIL: 256B retry on first flit"); fails++;
      end
      @(posedge clock); #1;
      p32_out_ready = 1'b1;
      @(posedge clock); #1;
      p32_out_ready = 1'b0;
      // unpack loopback
      @(negedge clock);
      u32_in_bits = f32; u32_in_valid = 1'b1;
      @(posedge clock);
      @(negedge clock);
      u32_in_valid = 1'b0;
      for (j = 0; j < 32; j = j + 1) begin
        wait (u32_out_valid);
        r32[j] = u32_out_bits;
        if (j == 31 && !u32_out_last) begin
          $display("FAIL: 256B out_last missing"); fails++;
        end
        @(posedge clock); #1;
      end
      repeat (2) @(posedge clock);
      for (j = 0; j < 32; j = j + 1)
        if (r32[j] !== w32[j]) begin
          $display("FAIL: 256B word%0d exp=%h got=%h", j, w32[j], r32[j]); fails++;
        end
      if (fails == 0) $display("PASS: 256B loopback payload match");
      if (u32_err_cnt !== 0) begin
        $display("FAIL: 256B err_cnt exp=0 got=%0d", u32_err_cnt); fails++;
      end else $display("PASS: 256B err_cnt 0");
      // corrupt -> nack
      @(negedge clock);
      u32_in_bits = f32 ^ 1; u32_in_valid = 1'b1;
      @(posedge clock);
      @(negedge clock);
      u32_in_valid = 1'b0;
      repeat (3) @(posedge clock); #1;
      if (u32_err_cnt !== 32'd1) begin
        $display("FAIL: 256B corrupt err exp=1 got=%0d", u32_err_cnt); fails++;
      end else $display("PASS: 256B corrupt detected (err_cnt=1)");
      if (u32_out_valid) begin
        $display("FAIL: 256B words on bad CRC"); fails++;
      end else $display("PASS: 256B no words on bad CRC");
      // slicer/reasm round-trip: 9x256b beats, last flag, identical flit.
      // Step the slicer one beat per iteration (ready low except the
      // transfer posedge) so no beat is missed between loop iterations.
      @(negedge clock);
      s32_in_bits = f32; s32_in_valid = 1'b1;
      @(posedge clock);
      @(negedge clock);
      s32_in_valid = 1'b0;
      for (j = 0; j < 9; j = j + 1) begin
        wait (s32_out_valid);
        @(negedge clock);
        r32_in_bits = s32_out_bits; r32_in_valid = 1'b1;
        s32_out_ready = 1'b1;
        if (j == 8 && !s32_out_last) begin
          $display("FAIL: 256B slice last missing"); fails++;
        end
        @(posedge clock);
        @(negedge clock);
        r32_in_valid = 1'b0;
        s32_out_ready = 1'b0;
      end
      repeat (2) @(posedge clock); #1;
      if (!r32_out_valid) begin
        $display("FAIL: 256B reasm no flit"); fails++;
      end else if (r32_out_bits !== f32) begin
        $display("FAIL: 256B slicer/reasm mismatch"); fails++;
      end else $display("PASS: 256B slicer/reasm 9x256b round-trip");
      if (r32_overflow) begin
        $display("FAIL: 256B reasm overflow"); fails++;
      end
      // retry identical + link_error latch on 32-word packer
      f32_retry = f32;
      @(negedge clock);
      nack32_in = 1'b1;
      @(posedge clock);
      @(negedge clock);
      nack32_in = 1'b0;
      wait (p32_out_valid && p32_out_retry);
      #1;
      if (p32_out_bits !== f32_retry) begin
        $display("FAIL: 256B retry bits differ"); fails++;
      end else $display("PASS: 256B retry retransmits identical flit");
      @(posedge clock); #1;
      p32_out_ready = 1'b1;
      @(posedge clock); #1;
      p32_out_ready = 1'b0;
      if (link32_error) begin
        $display("FAIL: 256B unexpected link_error"); fails++;
      end else $display("PASS: 256B no link_error");
    end

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
