// lane_pll_tb: Phase 3 PHY/AFE tests.
//
// A. Lanes NLANES=4 with a truly async AFE clock (different period):
//    lane TX -> AFE TX -> loopback -> AFE RX -> lane RX, per-lane data.
// B. ucie_top with pllLock=0: training must NOT reach state 4 / ACTIVE.
// C. rdi_map legacy RX-overwrite sticky flag stays clear under burst.
// PASS when all three hold (LANEPLL PASS).
`timescale 1ns / 1ps

module lane_pll_tb;
  reg clock = 0;      // core 100MHz
  reg fclk = 0;       // AFE ~166MHz (async)
  reg reset = 1;
  always #5 clock = ~clock;
  always #3 fclk = ~fclk;

  integer fails = 0;

  // ---- A. 4-lane loopback ----
  reg lane_tx_vld = 0;
  reg [63:0] lane_tx_bits = 64'h0;
  wire lane_tx_rdy;
  wire afe_tx_vld;
  wire [63:0] afe_tx_bits;
  reg afe_rx_vld = 0;
  reg [63:0] afe_rx_bits = 64'h0;
  wire afe_rx_rdy;
  wire lane_rx_vld;
  wire [63:0] lane_rx_bits;

  Lanes #(.NLANES(4)) dut_lanes (
    .clock(clock), .reset(reset),
    .io_mainbandIo_fifoParams_clk(fclk),
    .io_mainbandIo_fifoParams_reset(reset),
    .io_mainbandIo_txData_ready(1'b1),
    .io_mainbandIo_txData_valid(afe_tx_vld),
    .io_mainbandIo_txData_bits_0(afe_tx_bits),
    .io_mainbandIo_rxData_ready(afe_rx_rdy),
    .io_mainbandIo_rxData_valid(afe_rx_vld),
    .io_mainbandIo_rxData_bits_0(afe_rx_bits),
    .io_mainbandLaneIO_txData_ready(lane_tx_rdy),
    .io_mainbandLaneIO_txData_valid(lane_tx_vld),
    .io_mainbandLaneIO_txData_bits(lane_tx_bits),
    .io_mainbandLaneIO_rxData_valid(lane_rx_vld),
    .io_mainbandLaneIO_rxData_bits(lane_rx_bits)
  );

  // ---- B. top with pllLock=0 (no training partner needed: negative) ----
  reg HCLK = 0; reg HRESETn = 0;
  always #5 HCLK = ~HCLK;
  wire [63:0] b_hrdata; wire b_hr, b_resp;
  wire [3:0] b_state; wire [63:0] b_pldata; wire b_plvld;
  wire b_stall, b_mbTxV, b_mbRxR, b_mbRxEn, b_sbTx, b_sbClk, b_sbEn;
  wire [15:0] b_mbTxB; wire [2:0] b_mbFreq;
  ucie_top dut_top (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .HSEL(1'b0), .HADDR(32'h0), .HWDATA(64'h0), .HWRITE(1'b0),
    .HSIZE(3'b011), .HBURST(3'h0), .HTRANS(2'b00), .HREADY(1'b1),
    .HRDATA(b_hrdata), .HREADYOUT(b_hr), .HRESP(b_resp),
    .io_TLlpData_irdy(1'b1), .io_TLplStateStatus(b_state),
    .io_TLplData_bits(b_pldata), .io_TLplData_valid(b_plvld),
    .io_TLready_to_rcv(1'b1), .io_fault(1'b0), .io_soft_reset(1'b0),
    .io_fdi_lpStallAck(b_stall),
    .io_mbAfe_fifoParams_clk(HCLK), .io_mbAfe_fifoParams_reset(~HRESETn),
    .io_mbAfe_txData_ready(1'b1), .io_mbAfe_txData_valid(b_mbTxV),
    .io_mbAfe_txData_bits_0(b_mbTxB), .io_mbAfe_rxData_ready(b_mbRxR),
    .io_mbAfe_rxData_valid(1'b0), .io_mbAfe_rxData_bits_0(16'h0),
    .io_mbAfe_txFreqSel(b_mbFreq), .io_mbAfe_rxEn(b_mbRxEn),
    .io_mbAfe_pllLock(1'b0), // held out of lock
    .io_sbAfe_fifoParams_clk(HCLK), .io_sbAfe_fifoParams_reset(~HRESETn),
    .io_sbAfe_txData(b_sbTx), .io_sbAfe_txClock(b_sbClk),
    .io_sbAfe_rxData(1'b0), .io_sbAfe_rxClock(1'b0),
    .io_sbAfe_rxEn(b_sbEn), .io_sbAfe_pllLock(1'b0),
    .o_flit_link_error(), .o_flit_overflow()
  );

  // ---- C. rdi_map legacy standalone for overwrite flag ----
  reg c_tx_rdy = 1'b1;
  wire c_lp_rdy, c_pl_vld;
  wire [63:0] c_pl_bits;
  reg c_lp_vld = 1'b0, c_irdy = 1'b0;
  reg [63:0] c_lp_bits = 64'h0;
  reg c_lane_vld = 1'b0;
  reg [15:0] c_lane_bits = 16'h0;
  rdi_map #(.RDI_W(64)) dut_rmap (
    .clock(clock), .reset(reset),
    .io_rdi_lpData_ready(c_lp_rdy), .io_rdi_lpData_valid(c_lp_vld),
    .io_rdi_lpData_irdy(c_irdy), .io_rdi_lpData_bits(c_lp_bits),
    .io_rdi_plData_valid(c_pl_vld), .io_rdi_plData_bits(c_pl_bits),
    .io_mainbandLaneIO_txData_ready(c_tx_rdy),
    .io_mainbandLaneIO_txData_valid(), .io_mainbandLaneIO_txData_bits(),
    .io_mainbandLaneIO_rxData_valid(c_lane_vld),
    .io_mainbandLaneIO_rxData_bits(c_lane_bits)
  );

  // AFE loopback for lanes (fclk domain regs).
  reg [63:0] lb_bits = 0; reg lb_vld = 0;
  always @(posedge fclk) begin
    lb_vld <= afe_tx_vld;
    lb_bits <= afe_tx_bits;
  end
  always @(negedge fclk) begin
    afe_rx_vld = lb_vld;
    afe_rx_bits = lb_bits;
  end

  initial begin
    reset = 1; HRESETn = 0;
    repeat (6) @(posedge clock);
    repeat (4) @(posedge HCLK);
    reset = 0; HRESETn = 1;
    // Let async-FIFO reset synchronizers settle in both domains before
    // the first word (else the first lockstep vector can be dropped).
    repeat (40) @(posedge fclk);
    repeat (4) @(posedge clock);

    // A. push 8 lockstep vectors across 4 lanes, expect identical return.
    begin
      reg [63:0] vec [0:7];
      reg [63:0] got;
      integer i, k, n;
      vec[0] = 64'h1111_2222_3333_4444;
      vec[1] = 64'h5555_6666_7777_8888;
      vec[2] = 64'hDEAD_BEEF_CAFE_F00D;
      vec[3] = 64'h0123_4567_89AB_CDEF;
      vec[4] = 64'hFFFF_0000_FFFF_0000;
      vec[5] = 64'h0000_FFFF_0000_FFFF;
      vec[6] = 64'hA5A5_A5A5_5A5A_5A5A;
      vec[7] = 64'h1357_9BDF_2468_ACE0;
      for (i = 0; i < 8; i = i + 1) begin
        @(negedge clock);
        lane_tx_bits = vec[i]; lane_tx_vld = 1'b1;
        @(posedge clock); @(negedge clock); lane_tx_vld = 1'b0;
        // Collect one lane-side word (all 4 lanes lockstep => same 64b).
        n = 0; got = 64'hx;
        for (k = 0; k < 4000 && n < 1; k = k + 1) begin
          @(posedge clock); #1;
          if (lane_rx_vld === 1'b1) begin got = lane_rx_bits; n = 1; end
        end
        if (n !== 1) begin
          $display("FAIL: lane %0d no return", i); fails++;
        end else if (got !== vec[i]) begin
          $display("FAIL: lane %0d exp=%h got=%h", i, vec[i], got); fails++;
        end else $display("PASS: lane word %0d loopback %h", i, got);
        repeat (10) @(posedge clock);
      end
    end

    // B. pllLock=0 must block training/ACTIVE.
    repeat (2000) @(posedge HCLK);
    if (dut_top.logPhy.trainingModule.currentState === 3'h4) begin
      $display("FAIL: trained with pllLock=0"); fails++;
    end else $display("PASS: no training without pllLock (train=%0d)",
                      dut_top.logPhy.trainingModule.currentState);
    if (b_state === 4'h1) begin
      $display("FAIL: ACTIVE with pllLock=0"); fails++;
    end else $display("PASS: no ACTIVE without pllLock (fdi=%h)", b_state);

    // C. burst 4 words into legacy rdi_map RX, overwrite flag must be clear.
    begin
      integer i, words;
      reg [15:0] beats [0:15];
      words = 0;
      for (i = 0; i < 16; i = i + 1) beats[i] = 16'h1000 + 16'(i);
      for (i = 0; i < 16; i = i + 1) begin
        @(negedge clock);
        c_lane_bits = beats[i]; c_lane_vld = 1'b1;
        @(posedge clock); #1;
        if (c_pl_vld === 1'b1) words = words + 1;
      end
      @(negedge clock); c_lane_vld = 1'b0;
      repeat (6) @(posedge clock); #1;
      if (c_pl_vld === 1'b1) words = words + 1;
      if (dut_rmap.gen_legacy.rx_overwrite !== 1'b0) begin
        $display("FAIL: rdi overwrite flagged"); fails++;
      end else $display("PASS: rdi no overwrite on burst");
      if (words < 4) begin
        $display("FAIL: only %0d/4 words completed", words); fails++;
      end else $display("PASS: rdi 4 words completed last=%h", c_pl_bits);
    end

    if (fails == 0) $display("LANEPLL PASS");
    else $display("LANEPLL FAIL fails=%0d", fails);
    $finish;
  end

  initial begin
    repeat (200000) @(posedge clock);
    $display("LANEPLL FAIL: watchdog");
    $finish;
  end
endmodule
