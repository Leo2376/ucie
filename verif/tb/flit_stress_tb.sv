// flit_stress_tb: flit-mode MB loopback stress with scoreboard.
//
// ucie_top #(USE_FLIT=1), MB AFE looped back. Sends NFLITS flits of
// xorshift-pseudorandom words through the AHB streaming port, collects
// the FDI Rx words, and scoreboards them in order. Mid-run it flips one
// bit of one 16b MB beat (flit IDX_CORRUPT): the RX CRC must catch it
// (unpack err_cnt=1, no words emitted for the bad copy), the packer
// must retry, and the final stream must still match exactly with no
// link_error.
// Driving convention: TB inputs change on negedge.
`timescale 1ns / 1ps

module flit_stress_tb;
  parameter int NFLITS = 8;
  parameter int IDX_CORRUPT = 3;
  parameter int DO_INJECT = 1;

  reg        HCLK = 1'b0;
  reg        HRESETn = 1'b0;
  reg        HSEL = 1'b0;
  reg [31:0] HADDR = 32'h0;
  reg [63:0] HWDATA = 64'h0;
  reg        HWRITE = 1'b0;
  reg [2:0]  HSIZE = 3'b011;
  reg [2:0]  HBURST = 3'h0;
  reg [1:0]  HTRANS = 2'b00;
  wire [63:0] HRDATA;
  wire        HREADYOUT;
  wire        HRESP;

  reg        tb_irdy = 1'b1;
  reg        tb_rdy2rcv = 1'b1;
  reg        tb_fault = 1'b0;
  reg        tb_soft_rst = 1'b0;
  wire [3:0] tb_state;
  wire [63:0] tb_pldata;
  wire        tb_plvalid;

  reg sb_rx = 1'b0;
  reg sb_rxc = 1'b0;
  wire tb_stallAck;
  wire tb_mbTxValid, tb_mbRxRdy, tb_mbRxEn, tb_sbTx, tb_sbTxClk, tb_sbRxEn;
  wire [15:0] tb_mbTxBits;
  wire [2:0] tb_mbFreq;

  wire        mb_rx_valid;
  wire [15:0] mb_rx_bits;

  ucie_top #(.USE_FLIT(1)) dut (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HSEL(HSEL),
    .HADDR(HADDR),
    .HWDATA(HWDATA),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HBURST(HBURST),
    .HTRANS(HTRANS),
    .HREADY(1'b1),
    .HRDATA(HRDATA),
    .HREADYOUT(HREADYOUT),
    .HRESP(HRESP),
    .io_TLlpData_irdy(tb_irdy),
    .io_TLplStateStatus(tb_state),
    .io_TLplData_bits(tb_pldata),
    .io_TLplData_valid(tb_plvalid),
    .io_TLready_to_rcv(tb_rdy2rcv),
    .io_fault(tb_fault),
    .io_soft_reset(tb_soft_rst),
    .io_fdi_lpStallAck(tb_stallAck),
    .io_mbAfe_fifoParams_clk(HCLK),
    .io_mbAfe_fifoParams_reset(~HRESETn),
    .io_mbAfe_txData_ready(1'b1),
    .io_mbAfe_txData_valid(tb_mbTxValid),
    .io_mbAfe_txData_bits_0(tb_mbTxBits),
    .io_mbAfe_rxData_ready(tb_mbRxRdy),
    .io_mbAfe_rxData_valid(mb_rx_valid),
    .io_mbAfe_rxData_bits_0(mb_rx_bits),
    .io_mbAfe_txFreqSel(tb_mbFreq),
    .io_mbAfe_rxEn(tb_mbRxEn),
    .io_mbAfe_pllLock(1'b1),
    .io_sbAfe_fifoParams_clk(HCLK),
    .io_sbAfe_fifoParams_reset(~HRESETn),
    .io_sbAfe_txData(tb_sbTx),
    .io_sbAfe_txClock(tb_sbTxClk),
    .io_sbAfe_rxData(sb_rx),
    .io_sbAfe_rxClock(sb_rxc),
    .io_sbAfe_rxEn(tb_sbRxEn),
    .io_sbAfe_pllLock(1'b1),
    .o_flit_link_error(),
    .o_flit_overflow()
  );

  // MB loopback with single-beat error injection (registered, so the
  // corrupted 16b beat stays aligned with its valid).
  reg lb_valid = 1'b0;
  reg [15:0] lb_bits = 16'h0;
  reg inject_arm = 1'b0;   // set by test to corrupt the next beat once
  reg inject_done = 1'b0;
  always @(posedge HCLK) begin
    lb_valid <= tb_mbTxValid;
    if (inject_arm && !inject_done && tb_mbTxValid) begin
      lb_bits <= tb_mbTxBits ^ 16'h0001; // flip one bit of this beat
      inject_done <= 1'b1;
    end else begin
      lb_bits <= tb_mbTxBits;
    end
  end
  assign mb_rx_valid = lb_valid;
  assign mb_rx_bits = lb_bits;

  always #5 HCLK = ~HCLK;

  // Pre-update accept counter: samples the exact values the DUT's
  // capture edge uses (no #1), so the total is ground truth.
  reg [63:0] cnt_accept = 0;
  always @(posedge HCLK) begin
    if (HRESETn && dut.d2dadapter.gen_flit.u_mb_flit.u_pack.in_valid &&
        dut.d2dadapter.gen_flit.u_mb_flit.u_pack.in_ready)
      cnt_accept <= cnt_accept + 1;
  end
  // Sequence event trace (pack/unpack handshakes, #1-settled view).
  always @(posedge HCLK) begin
    #1;
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_pack.in_valid &&
        dut.d2dadapter.gen_flit.u_mb_flit.u_pack.in_ready)
      $display("EV t=%0t PACK-IN wcnt=%0d data=%h", $time,
               dut.d2dadapter.gen_flit.u_mb_flit.u_pack.wcnt,
               dut.d2dadapter.gen_flit.u_mb_flit.u_pack.in_bits);
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.ack_valid)
      $display("EV t=%0t UNPACK-ACK seq=%0d err=%0d", $time,
               dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.ack_seq,
               dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt);
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.in_valid &&
        dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.in_ready)
      $display("EV t=%0t UNPACK-ACCEPT seq=%h", $time,
               dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.in_bits[511:504]);
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.nack)
      $display("EV t=%0t UNPACK-NACK err=%0d", $time,
               dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt);
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_pack.out_valid &&
        dut.d2dadapter.gen_flit.u_mb_flit.u_pack.out_ready)
      $display("EV t=%0t PACK-OUT seq=%h retry=%b oldest=%h pend=%b timer=%0d",
               $time,
               dut.d2dadapter.gen_flit.u_mb_flit.u_pack.out_bits[511:504],
               dut.d2dadapter.gen_flit.u_mb_flit.u_pack.out_retry,
               dut.d2dadapter.gen_flit.u_mb_flit.u_pack.oldest_seq,
               dut.d2dadapter.gen_flit.u_mb_flit.u_pack.pending_unacked,
               dut.d2dadapter.gen_flit.u_mb_flit.u_pack.timer);
  end

  // ---- 256B datapath DUT (WORDS_PER_FLIT=32, NLANES=16, 256b RDI) ----
  // Same loopback stress at the wide width: 32-word flits over 9x256b
  // beats, 9 lane cycles/flit at NLANES=16.
  localparam int NFLITS2 = 4;
  localparam int W2 = 32;
  reg        HSEL2 = 1'b0;
  reg [31:0] HADDR2 = 32'h0;
  reg [63:0] HWDATA2 = 64'h0;
  reg        HWRITE2 = 1'b0;
  reg [1:0]  HTRANS2 = 2'b00;
  wire [63:0] HRDATA2;
  wire        HREADYOUT2;
  wire        HRESP2;
  reg        tb2_irdy = 1'b1;
  reg        tb2_rdy2rcv = 1'b1;
  wire [3:0] tb2_state;
  wire [63:0] tb2_pldata;
  wire        tb2_plvalid;
  wire tb2_stallAck;
  wire tb2_mbTxValid, tb2_mbRxRdy, tb2_mbRxEn, tb2_sbTx, tb2_sbTxClk, tb2_sbRxEn;
  wire [255:0] tb2_mbTxBits;
  wire [2:0] tb2_mbFreq;
  reg sb2_rx = 1'b0;
  reg sb2_rxc = 1'b0;
  wire        mb2_rx_valid;
  wire [255:0] mb2_rx_bits;

  ucie_top #(.USE_FLIT(1), .WORDS_PER_FLIT(W2), .NLANES(16)) dut256 (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HSEL(HSEL2),
    .HADDR(HADDR2),
    .HWDATA(HWDATA2),
    .HWRITE(HWRITE2),
    .HSIZE(HSIZE),
    .HBURST(HBURST),
    .HTRANS(HTRANS2),
    .HREADY(1'b1),
    .HRDATA(HRDATA2),
    .HREADYOUT(HREADYOUT2),
    .HRESP(HRESP2),
    .io_TLlpData_irdy(tb2_irdy),
    .io_TLplStateStatus(tb2_state),
    .io_TLplData_bits(tb2_pldata),
    .io_TLplData_valid(tb2_plvalid),
    .io_TLready_to_rcv(tb2_rdy2rcv),
    .io_fault(tb_fault),
    .io_soft_reset(tb_soft_rst),
    .io_fdi_lpStallAck(tb2_stallAck),
    .io_mbAfe_fifoParams_clk(HCLK),
    .io_mbAfe_fifoParams_reset(~HRESETn),
    .io_mbAfe_txData_ready(1'b1),
    .io_mbAfe_txData_valid(tb2_mbTxValid),
    .io_mbAfe_txData_bits_0(tb2_mbTxBits),
    .io_mbAfe_rxData_ready(tb2_mbRxRdy),
    .io_mbAfe_rxData_valid(mb2_rx_valid),
    .io_mbAfe_rxData_bits_0(mb2_rx_bits),
    .io_mbAfe_txFreqSel(tb2_mbFreq),
    .io_mbAfe_rxEn(tb2_mbRxEn),
    .io_mbAfe_pllLock(1'b1),
    .io_sbAfe_fifoParams_clk(HCLK),
    .io_sbAfe_fifoParams_reset(~HRESETn),
    .io_sbAfe_txData(tb2_sbTx),
    .io_sbAfe_txClock(tb2_sbTxClk),
    .io_sbAfe_rxData(sb2_rx),
    .io_sbAfe_rxClock(sb2_rxc),
    .io_sbAfe_rxEn(tb2_sbRxEn),
    .io_sbAfe_pllLock(1'b1),
    .o_flit_link_error(),
    .o_flit_overflow()
  );

  // 256b loopback with single-beat error injection (flip LSB once).
  reg lb2_valid = 1'b0;
  reg [255:0] lb2_bits = 256'h0;
  reg inject2_arm = 1'b0;
  reg inject2_done = 1'b0;
  always @(posedge HCLK) begin
    lb2_valid <= tb2_mbTxValid;
    if (inject2_arm && !inject2_done && tb2_mbTxValid) begin
      lb2_bits <= tb2_mbTxBits ^ 256'h1;
      inject2_done <= 1'b1;
    end else begin
      lb2_bits <= tb2_mbTxBits;
    end
  end
  assign mb2_rx_valid = lb2_valid;
  assign mb2_rx_bits = lb2_bits;

  reg [63:0] exp2_q [0:NFLITS2*32-1];
  reg [63:0] got2_q [0:NFLITS2*32-1];
  integer exp2_n = 0;
  integer got2_n = 0;
  reg collect2_done = 1'b0;
  reg prev2_v = 1'b0;
  reg [63:0] prev2_d = 64'h0;
  always @(posedge HCLK) begin
    #1;
    if (HRESETn && !collect2_done &&
        tb2_plvalid === 1'b1 && (prev2_v !== 1'b1 || tb2_pldata !== prev2_d)) begin
      if (got2_n < NFLITS2*32) begin
        got2_q[got2_n] = tb2_pldata;
        got2_n = got2_n + 1;
      end
    end
    prev2_v <= tb2_plvalid;
    prev2_d <= tb2_pldata;
  end

  task automatic ahb_push2(input [63:0] word);
    begin
      @(negedge HCLK);
      HSEL2 = 1'b1; HWRITE2 = 1'b1; HTRANS2 = 2'b10; HWDATA2 = word;
      #1;
      while (HREADYOUT2 !== 1'b1) @(negedge HCLK);
      @(posedge HCLK);
      @(negedge HCLK);
      HSEL2 = 1'b0; HWRITE2 = 1'b0; HTRANS2 = 2'b00;
      exp2_q[exp2_n] = word;
      exp2_n = exp2_n + 1;
    end
  endtask

  integer fails = 0;
  reg [63:0] exp_q [0:NFLITS*7-1];
  reg [63:0] got_q [0:NFLITS*7-1];
  integer exp_n = 0;
  integer got_n = 0;
  integer i, f, w;
  reg [63:0] lfsr;
  reg collect_done = 1'b0;

  // Concurrent collector: FDI Rx valid is sticky (fill-reg semantics),
  // so sample on rise-or-change; each real word presents one cycle.
  reg prev_v = 1'b0;
  reg [63:0] prev_d = 64'h0;
  initial begin
    $dumpfile("/tmp/flitstress.vcd");
    $dumpvars(0, flit_stress_tb);
  end
  always @(posedge HCLK) begin
    #1;
    if (HRESETn && !collect_done &&
        tb_plvalid === 1'b1 && (prev_v !== 1'b1 || tb_pldata !== prev_d)) begin
      if (got_n < NFLITS*7) begin
        got_q[got_n] = tb_pldata;
        got_n = got_n + 1;
      end
    end
    prev_v <= tb_plvalid;
    prev_d <= tb_pldata;
  end

  // Race-free AHB pushes. HREADYOUT is combinational from settled regs,
  // so sampling it gives the exact pre-values the next posedge will
  // use -- INCLUDING the #1 settle-sample right after driving, which
  // observes the transfer condition for the immediately following
  // posedge (a plain negedge-only loop misses a transfer on that first
  // edge and double-captures). Transfer occurs at the first posedge
  // with ready==1; the phase is held through that posedge and dropped
  // at the following negedge: exactly one capture per push.
  task automatic ahb_push(input [63:0] word);
    begin
      @(negedge HCLK);
      HSEL = 1'b1; HWRITE = 1'b1; HTRANS = 2'b10; HWDATA = word;
      #1; // settle: pre-values for the upcoming posedge (no edge passes)
      while (HREADYOUT !== 1'b1) @(negedge HCLK);
      @(posedge HCLK); // transfer happens here
      @(negedge HCLK);
      HSEL = 1'b0; HWRITE = 1'b0; HTRANS = 2'b00;
      exp_q[exp_n] = word;
      exp_n = exp_n + 1;
    end
  endtask

  initial begin
    lfsr = 64'h1234_5678_9ABC_DEF1;
    HRESETn = 1'b0;
    repeat (6) @(posedge HCLK);
    HRESETn = 1'b1;
    repeat (4) @(posedge HCLK);

    for (f = 0; f < NFLITS; f = f + 1) begin
      if (f == IDX_CORRUPT && DO_INJECT != 0) begin
        inject_arm = 1'b1;
        inject_done = 1'b0;
      end
      for (w = 0; w < 7; w = w + 1) begin
        // xorshift64star-ish step (deterministic, TB-side only).
        lfsr = lfsr ^ (lfsr >> 12);
        lfsr = lfsr ^ (lfsr << 25);
        lfsr = lfsr ^ (lfsr >> 27);
        ahb_push(lfsr);
      end
      if (f == IDX_CORRUPT) begin
        // Let the corrupted flit traverse + retry before next flit.
        repeat (400) @(posedge HCLK);
        inject_arm = 1'b0;
        if (!inject_done) begin
          $display("FAIL: injection never fired (no MB traffic?)");
          fails = fails + 1;
        end else $display("PASS: error injected on flit %0d", IDX_CORRUPT);
      end
    end

    // Wait for the full stream (retry adds latency, not words).
    for (i = 0; i < 20000 && got_n < NFLITS*7; i = i + 1) begin
      @(posedge HCLK);
    end
    collect_done = 1'b1;
    if (got_n !== NFLITS*7) begin
      $display("FAIL: got %0d/%0d words", got_n, NFLITS*7);
      fails = fails + 1;
    end else begin
      for (i = 0; i < NFLITS*7; i = i + 1)
        if (got_q[i] !== exp_q[i]) begin
          $display("FAIL: word%0d exp=%h got=%h", i, exp_q[i], got_q[i]);
          fails = fails + 1;
        end
      if (fails == 0) $display("PASS: scoreboard match (%0d words)", got_n);
    end

    for (i = 0; i < got_n; i = i + 1)
      $display("GOT[%0d] = %h (exp %h)", i, got_q[i], exp_q[i]);
    // CRC must have caught exactly the injected corruption; no link drop.
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt !== 32'd1) begin
      $display("FAIL: unpack err_cnt exp=1 got=%0d",
               dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt);
      fails = fails + 1;
    end else $display("PASS: corruption detected once (err_cnt=1)");
    if (dut.d2dadapter.gen_flit.u_mb_flit.io_link_error) begin
      $display("FAIL: link_error set (retry exhausted)");
      fails = fails + 1;
    end else $display("PASS: no link_error (retry recovered)");
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_reasm.overflow) begin
      $display("FAIL: reasm overflow");
      fails = fails + 1;
    end else $display("PASS: no reasm overflow (7-word)");

    // ---- 256B run: 4 flits x 32 words over NLANES=16 loopback ----
    begin
      reg [63:0] lfsr2;
      integer f2, w2, ii;
      lfsr2 = 64'h9E37_79B9_7F4A_7C15;
      for (f2 = 0; f2 < NFLITS2; f2 = f2 + 1) begin
        if (f2 == 2) begin
          inject2_arm = 1'b1;
          inject2_done = 1'b0;
        end
        for (w2 = 0; w2 < 32; w2 = w2 + 1) begin
          lfsr2 = lfsr2 ^ (lfsr2 >> 12);
          lfsr2 = lfsr2 ^ (lfsr2 << 25);
          lfsr2 = lfsr2 ^ (lfsr2 >> 27);
          ahb_push2(lfsr2);
        end
        if (f2 == 2) begin
          repeat (800) @(posedge HCLK);
          inject2_arm = 1'b0;
          if (!inject2_done) begin
            $display("FAIL: 256B injection never fired");
            fails = fails + 1;
          end else $display("PASS: 256B error injected on flit 2");
        end
      end
      for (ii = 0; ii < 40000 && got2_n < NFLITS2*32; ii = ii + 1) begin
        @(posedge HCLK);
      end
      collect2_done = 1'b1;
      if (got2_n !== NFLITS2*32) begin
        $display("FAIL: 256B got %0d/%0d words", got2_n, NFLITS2*32);
        fails = fails + 1;
      end else begin
        for (ii = 0; ii < NFLITS2*32; ii = ii + 1)
          if (got2_q[ii] !== exp2_q[ii]) begin
            $display("FAIL: 256B word%0d exp=%h got=%h", ii, exp2_q[ii], got2_q[ii]);
            fails = fails + 1;
          end
        if (fails == 0) $display("PASS: 256B scoreboard match (%0d words)", got2_n);
      end
      if (dut256.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt !== 32'd1) begin
        $display("FAIL: 256B unpack err_cnt exp=1 got=%0d",
                 dut256.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt);
        fails = fails + 1;
      end else $display("PASS: 256B corruption detected once (err_cnt=1)");
      if (dut256.d2dadapter.gen_flit.u_mb_flit.io_link_error) begin
        $display("FAIL: 256B link_error set");
        fails = fails + 1;
      end else $display("PASS: 256B no link_error (retry recovered)");
      if (dut256.d2dadapter.gen_flit.u_mb_flit.u_reasm.overflow) begin
        $display("FAIL: 256B reasm overflow");
        fails = fails + 1;
      end else $display("PASS: 256B no reasm overflow");
    end

    if (fails == 0) $display("FLITSTRESS PASS");
    else $display("FLITSTRESS FAIL fails=%0d", fails);
    $display("ENDSTATE exp_n=%0d got_n=%0d accepts=%0d seq=%0d oldest=%0d wcnt=%0d retry=%0d err=%0d linkerr=%b",
             exp_n, got_n, cnt_accept,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.seq_reg,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.oldest_seq,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.wcnt,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.retry_cnt,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt,
             dut.d2dadapter.gen_flit.u_mb_flit.io_link_error);
    $display("ENDSTATE2 pend=%b timer=%0d outv=%b outrdy=%b retrdue=%b retryav=%b invld=%b inrdy=%b upackv=%b",
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.pending_unacked,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.timer,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.out_valid,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.out_ready,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.retransmit_due,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.retry_avail,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.in_valid,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.in_ready,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.out_valid);
    $display("ENDSTATE5 caps=%0d newouts=%0d retouts=%0d",
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.dbg_caps,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.dbg_newouts,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.dbg_retouts);
    $display("ENDSTATE4 tx_enqrdy=%b tx_enqvld=%b tx_deqvld=%b tx_deqrdy=%b txvld=%b rxvld=%b rx_enqrdy=%b rx_deqvld=%b",
             dut.logPhy.lanes.gen_lane[0].txMBFifo.io_enq_ready,
             dut.logPhy.lanes.gen_lane[0].txMBFifo.io_enq_valid,
             dut.logPhy.lanes.gen_lane[0].txMBFifo.io_deq_valid,
             dut.logPhy.lanes.gen_lane[0].txMBFifo.io_deq_ready,
             tb_mbTxValid, mb_rx_valid,
             dut.logPhy.lanes.gen_lane[0].rxMBFifo.io_enq_ready,
             dut.logPhy.lanes.gen_lane[0].rxMBFifo.io_deq_valid);
    $display("ENDSTATE3 slice_bl=%0d slice_idx=%0d rmap_txhave=%b rmap_txout=%0d rmap_rxcnt=%0d rmap_rxleft=%0d reasm_beats=%0d reasm_pv=%b up_drain=%b up_rcnt=%0d up_ackv=%b up_nack=%b",
             dut.d2dadapter.gen_flit.u_mb_flit.u_slice.beats_left,
             dut.d2dadapter.gen_flit.u_mb_flit.u_slice.idx,
              dut.logPhy.rdiDataMapper.gen_flit.tx_have,
              dut.logPhy.rdiDataMapper.gen_flit.tx_out,
              dut.logPhy.rdiDataMapper.gen_flit.rx_cnt,
              dut.logPhy.rdiDataMapper.gen_flit.rx_left,
             dut.d2dadapter.gen_flit.u_mb_flit.u_reasm.beats,
             dut.d2dadapter.gen_flit.u_mb_flit.u_reasm.pending_vld,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.draining,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.rcnt,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.ack_valid,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.nack);
    $finish;
  end

  initial begin
    repeat (200000) @(posedge HCLK);
    $display("FAIL: watchdog timeout");
    $finish;
  end
endmodule
