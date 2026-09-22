// ahb_cfg_tb: Phase 4 host config path + HRESP tests (docs/cfg_spec.md).
//
// Map: HADDR[31]=0 streaming (untouched here), HADDR[31]=1 config space
// (offset 0 = data, 4 = status {ovf, err, txrdy, rxvld}).
// Part 1 (top, USE_FLIT=1): AHB cfg writes x4 -> sideband packet emerges
//   at the RDI ser (hierarchical), fabric credit returns (status poll).
// Part 2 (unit ahb_fdi): TX backpressure (5th write stalls, credit drains),
//   RX mailbox (4 words in -> poll -> read match, 1 credit), mgmt packet
//   (no credit), overrun sticky + status-write clear.
// Part 3 (unit d2d_sb): RDI outer words in -> host tap -> FDI outer words
//   out, link-mgmt decode stays 0.
// Part 4 (top): corrupt-every-beat MB loopback -> link_error latches ->
//   HRESP=1 + status err; reset clears.
// Driving convention: TB inputs change on negedge; HREADYOUT is sampled
// #1 after a negedge (pre-edge values for the upcoming posedge), so
// wait-states complete exactly once.
`timescale 1ns / 1ps

module ahb_cfg_tb;
  reg HCLK = 0;
  reg HRESETn = 0;
  always #5 HCLK = ~HCLK;

  integer fails = 0;

  localparam [31:0] CFG_DATA = 32'h8000_0000;
  localparam [31:0] CFG_STS  = 32'h8000_0004;

  // ================= Top DUT (USE_FLIT=1, corrupt MB loopback) =================
  reg        HSEL = 0;
  reg [31:0] HADDR = 0;
  reg [63:0] HWDATA = 0;
  reg        HWRITE = 0;
  reg [2:0]  HSIZE = 3'b011;
  reg [2:0]  HBURST = 0;
  reg [1:0]  HTRANS = 0;
  wire [63:0] HRDATA;
  wire        HREADYOUT;
  wire        HRESP;
  reg        tb_irdy = 1, tb_rdy2rcv = 1, tb_fault = 0, tb_soft_rst = 0;
  wire [3:0] tb_state;
  wire [63:0] tb_pldata;
  wire        tb_plvalid;
  wire tb_stallAck, tb_flit_err, tb_flit_ovf;
  reg sb_rx = 0, sb_rxc = 0;
  wire tb_mbTxValid, tb_sbTx, tb_sbTxClk, tb_sbRxEn, tb_mbRxEn;
  wire [15:0] tb_mbTxBits;
  wire [2:0] tb_mbFreq;
  wire tb_mbRxRdy;

  ucie_top #(.USE_FLIT(1)) dut_top (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .HSEL(HSEL), .HADDR(HADDR), .HWDATA(HWDATA), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HBURST(HBURST), .HTRANS(HTRANS), .HREADY(1'b1),
    .HRDATA(HRDATA), .HREADYOUT(HREADYOUT), .HRESP(HRESP),
    .io_TLlpData_irdy(tb_irdy), .io_TLplStateStatus(tb_state),
    .io_TLplData_bits(tb_pldata), .io_TLplData_valid(tb_plvalid),
    .io_TLready_to_rcv(tb_rdy2rcv), .io_fault(tb_fault),
    .io_soft_reset(tb_soft_rst),
    .io_fdi_lpStallAck(tb_stallAck),
    .io_mbAfe_fifoParams_clk(HCLK), .io_mbAfe_fifoParams_reset(~HRESETn),
    .io_mbAfe_txData_ready(1'b1), .io_mbAfe_txData_valid(tb_mbTxValid),
    .io_mbAfe_txData_bits_0(tb_mbTxBits), .io_mbAfe_rxData_ready(tb_mbRxRdy),
    .io_mbAfe_rxData_valid(mb_rx_valid), .io_mbAfe_rxData_bits_0(mb_rx_bits),
    .io_mbAfe_txFreqSel(tb_mbFreq), .io_mbAfe_rxEn(tb_mbRxEn),
    .io_mbAfe_pllLock(1'b1),
    .io_sbAfe_fifoParams_clk(HCLK), .io_sbAfe_fifoParams_reset(~HRESETn),
    .io_sbAfe_txData(tb_sbTx), .io_sbAfe_txClock(tb_sbTxClk),
    .io_sbAfe_rxData(sb_rx), .io_sbAfe_rxClock(sb_rxc),
    .io_sbAfe_rxEn(tb_sbRxEn), .io_sbAfe_pllLock(1'b1),
    .o_flit_link_error(tb_flit_err), .o_flit_overflow(tb_flit_ovf)
  );

  // Corrupt-every-beat loopback (Part 4 needs repeated CRC failures).
  reg lb_valid = 0;
  reg [15:0] lb_bits = 0;
  always @(posedge HCLK) begin
    lb_valid <= tb_mbTxValid;
    lb_bits <= tb_mbTxBits ^ 16'h0001;
  end
  wire mb_rx_valid = lb_valid;
  wire [15:0] mb_rx_bits = lb_bits;

  // ================= Unit ahb_fdi (mailbox flow control) =================
  reg        u_HSEL = 0;
  reg [31:0] u_HADDR = 0;
  reg [63:0] u_HWDATA = 0;
  reg        u_HWRITE = 0;
  reg [1:0]  u_HTRANS = 0;
  wire [63:0] u_HRDATA;
  wire        u_HREADYOUT;
  wire        u_HRESP;
  reg        u_plCrd = 0;
  wire       u_plVld;
  wire [31:0] u_plBits;
  reg        u_lpVld = 0;
  reg [31:0] u_lpBits = 0;
  wire       u_lpCrd;
  integer    u_cred_cnt = 0;
  always @(posedge HCLK) if (u_lpCrd) u_cred_cnt <= u_cred_cnt + 1;

  ahb_fdi dut_mb (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .HSEL(u_HSEL), .HADDR(u_HADDR), .HWDATA(u_HWDATA), .HWRITE(u_HWRITE),
    .HSIZE(3'b011), .HBURST(3'b0), .HTRANS(u_HTRANS), .HREADY(1'b1),
    .HRDATA(u_HRDATA), .HREADYOUT(u_HREADYOUT), .HRESP(u_HRESP),
    .io_lpData_irdy(1'b1), .io_plStateStatus(), .io_plData_bits(),
    .io_plData_valid(), .io_ready_to_rcv(1'b1), .io_fault(1'b0),
    .io_soft_reset(1'b0), .io_fdi_lpData_ready(1'b1),
    .io_fdi_lpData_valid(), .io_fdi_lpData_irdy(), .io_fdi_lpData_bits(),
    .io_fdi_plData_valid(1'b0), .io_fdi_plData_bits(64'h0),
    .io_fdi_lpStateReq(), .io_fdi_lpLinkError(),
    .io_fdi_plStateStatus(4'h0), .io_fdi_plInbandPres(1'b0),
    .io_fdi_plRxActiveReq(1'b0), .io_fdi_lpRxActiveStatus(),
    .io_fdi_plStallReq(1'b0), .io_fdi_lpStallAck(),
    .io_link_error(1'b0),
    .io_fdi_plConfig_valid(u_plVld), .io_fdi_plConfig_bits(u_plBits),
    .io_fdi_plConfigCredit(u_plCrd),
    .io_fdi_lpConfig_valid(u_lpVld), .io_fdi_lpConfig_bits(u_lpBits),
    .io_fdi_lpConfigCredit(u_lpCrd)
  );

  // ================= Unit d2d_sb (host tap) =================
  reg [31:0] s_rdi_bits = 0;
  reg        s_rdi_vld = 0;
  wire       s_rdi_crd;
  wire [31:0] s_rdi_tx;
  wire       s_rdi_txv;
  reg        s_fdi_crd = 1;
  wire [31:0] s_fdi_tx;
  wire       s_fdi_txv;
  wire [5:0] s_rcv;

  d2d_sb dut_sb (
    .clock(HCLK), .reset(~HRESETn),
    .io_rdi_pl_cfg(s_rdi_bits), .io_rdi_pl_cfg_vld(s_rdi_vld),
    .io_rdi_pl_cfg_crd(s_rdi_crd),
    .io_rdi_lp_cfg(s_rdi_tx), .io_rdi_lp_cfg_vld(s_rdi_txv),
    .io_rdi_lp_cfg_crd(1'b1),
    .io_fdi_pl_cfg(32'h0), .io_fdi_pl_cfg_vld(1'b0),
    .io_fdi_pl_cfg_crd(),
    .io_fdi_lp_cfg(s_fdi_tx), .io_fdi_lp_cfg_vld(s_fdi_txv),
    .io_fdi_lp_cfg_crd(s_fdi_crd),
    .io_sideband_rcv(s_rcv), .io_sideband_snt(6'h0), .io_sideband_rdy()
  );

  // ---- AHB drivers with wait-state support (top) ----
  task automatic ahb_write(input [31:0] addr, input [63:0] data);
    begin
      @(negedge HCLK);
      HSEL = 1; HWRITE = 1; HTRANS = 2'b10; HADDR = addr; HWDATA = data;
      #1;
      while (HREADYOUT !== 1'b1) begin @(negedge HCLK); #1; end
      @(posedge HCLK);
      @(negedge HCLK);
      HSEL = 0; HWRITE = 0; HTRANS = 2'b00;
    end
  endtask
  task automatic ahb_read(input [31:0] addr, output [63:0] data);
    begin
      @(negedge HCLK);
      HSEL = 1; HWRITE = 0; HTRANS = 2'b10; HADDR = addr;
      #1;
      // Sample pre-transfer: this slave pops/reacts AT the posedge, so
      // post-edge sampling sees post-pop state (off-by-one). AHB masters
      // sample HRDATA setup to the completing edge = these values.
      data = HRDATA;
      while (HREADYOUT !== 1'b1) begin @(negedge HCLK); #1; data = HRDATA; end
      @(posedge HCLK);
      @(negedge HCLK);
      HSEL = 0; HTRANS = 2'b00;
    end
  endtask
  // ---- AHB drivers (unit) ----
  task automatic u_write(input [31:0] addr, input [63:0] data);
    begin
      @(negedge HCLK);
      u_HSEL = 1; u_HWRITE = 1; u_HTRANS = 2'b10; u_HADDR = addr; u_HWDATA = data;
      #1;
      while (u_HREADYOUT !== 1'b1) begin @(negedge HCLK); #1; end
      @(posedge HCLK);
      @(negedge HCLK);
      u_HSEL = 0; u_HWRITE = 0; u_HTRANS = 2'b00;
    end
  endtask
  task automatic u_read(input [31:0] addr, output [63:0] data);
    begin
      @(negedge HCLK);
      u_HSEL = 1; u_HWRITE = 0; u_HTRANS = 2'b10; u_HADDR = addr;
      #1;
      // Pre-transfer sample (see ahb_read: pop happens AT the posedge).
      data = u_HRDATA;
      while (u_HREADYOUT !== 1'b1) begin @(negedge HCLK); #1; data = u_HRDATA; end
      @(posedge HCLK);
      @(negedge HCLK);
      u_HSEL = 0; u_HTRANS = 2'b00;
    end
  endtask

  reg [63:0] rdata;
  reg [31:0] w [0:3];
  reg [31:0] got [0:3];
  integer i, k;

  // Always-on collectors (start before stimulus so bursty ser words
  // can't be missed by poll-then-collect races).
  reg [31:0] rdi_cap [0:15];
  integer rdi_n = 0;
  always @(posedge HCLK) begin
    #1;
    if (dut_top.d2dadapter.d2d_sideband.io_rdi_lp_cfg_vld === 1'b1 && rdi_n < 16) begin
      rdi_cap[rdi_n] = dut_top.d2dadapter.d2d_sideband.io_rdi_lp_cfg;
      rdi_n = rdi_n + 1;
    end
  end
  reg [31:0] tap_cap [0:15];
  integer tap_n = 0;
  always @(posedge HCLK) begin
    #1;
    if (s_fdi_txv === 1'b1 && tap_n < 16) begin
      tap_cap[tap_n] = s_fdi_tx;
      tap_n = tap_n + 1;
    end
  end

  initial begin
    HRESETn = 0;
    repeat (6) @(posedge HCLK);
    HRESETn = 1;
    repeat (4) @(posedge HCLK);

    // ---------- Part 1: top TX e2e ----------
    // Packet: low5=0x02 (credit back), word1[26:24]=0 (FDI->RDI route).
    w[0] = 32'h0000_0002; w[1] = 32'h0000_0000;
    w[2] = 32'hDEAD_BEEF; w[3] = 32'hC0FF_EE00;
    ahb_read(CFG_STS, rdata);
    if (rdata[3:0] !== 4'h2) begin
      $display("FAIL: status idle exp=2 got=%h", rdata[3:0]); fails++;
    end else $display("PASS: status idle (txrdy)");
    if (HRESP !== 1'b0) begin $display("FAIL: HRESP idle"); fails++; end
    else $display("PASS: HRESP idle 0");
    for (i = 0; i < 4; i = i + 1)
      ahb_write(CFG_DATA, {32'h0, w[i]});
    // Poll for fabric credit (tx_ready back).
    k = 0;
    while (k < 500) begin
      ahb_read(CFG_STS, rdata);
      if (rdata[1] === 1'b1) k = 500; else k = k + 1;
    end
    ahb_read(CFG_STS, rdata);
    if (rdata[1] !== 1'b1) begin
      $display("FAIL: tx credit never returned sts=%h", rdata[3:0]); fails++;
    end else $display("PASS: fabric credit returned");
    // Emission was captured by the always-on collector (no poll race).
    if (rdi_n < 4) begin
      $display("FAIL: RDI ser emitted %0d/4 words", rdi_n); fails++;
    end else begin
      for (i = 0; i < 4; i = i + 1) got[i] = rdi_cap[i];
      for (i = 0; i < 4; i = i + 1)
        if (got[i] !== w[i]) begin
          $display("FAIL: rdi word%0d exp=%h got=%h", i, w[i], got[i]); fails++;
        end
      if (fails == 0) $display("PASS: host packet reaches RDI ser intact");
    end

    // ---------- Part 2: unit mailbox flow control + RX ----------
    // TX backpressure: credit held 0, 4 writes fill, 5th stalls.
    u_read(CFG_STS, rdata);
    if (rdata[1] !== 1'b1) begin $display("FAIL: unit tx not ready"); fails++; end
    for (i = 0; i < 4; i = i + 1)
      u_write(CFG_DATA, {32'h0, w[i]});
    // 5th write must stall (HREADYOUT==0 pre-edge).
    @(negedge HCLK);
    u_HSEL = 1; u_HWRITE = 1; u_HTRANS = 2'b10; u_HADDR = CFG_DATA;
    u_HWDATA = 64'h1234_5678;
    #1;
    if (u_HREADYOUT !== 1'b0) begin
      $display("FAIL: no backpressure on full TX"); fails++;
    end else $display("PASS: TX backpressure (HREADYOUT=0)");
    // Drain: wait until the presenter is actually waiting for credit
    // (else a blind 1-cycle pulse can land mid-presentation and miss),
    // then pulse credit; the held word completes at the next posedge.
    k = 0;
    while (k < 200 && dut_mb.tx_wait !== 1'b1) begin @(posedge HCLK); k = k + 1; end
    if (dut_mb.tx_wait !== 1'b1) begin
      $display("FAIL: tx never reached wait state"); fails++;
    end
    @(negedge HCLK); u_plCrd = 1;
    @(posedge HCLK);
    @(negedge HCLK); u_plCrd = 0;
    @(posedge HCLK);
    @(negedge HCLK);
    u_HSEL = 0; u_HWRITE = 0; u_HTRANS = 2'b00;
    u_read(CFG_STS, rdata);
    if (rdata[1] !== 1'b1) begin
      $display("FAIL: unit tx not ready after credit sts=%h", rdata[3:0]); fails++;
    end else $display("PASS: credit drains TX");
    // RX: 4 words in (non-mgmt: exactly 1 credit), poll, read back.
    u_cred_cnt = 0;
    for (i = 0; i < 4; i = i + 1) begin
      @(negedge HCLK);
      u_lpVld = 1; u_lpBits = w[i];
      @(posedge HCLK);
    end
    @(negedge HCLK); u_lpVld = 0;
    repeat (2) @(posedge HCLK);
    u_read(CFG_STS, rdata);
    if (rdata[0] !== 1'b1) begin
      $display("FAIL: rx_valid not set sts=%h", rdata[3:0]); fails++;
    end else $display("PASS: rx packet ready");
    if (u_cred_cnt !== 1) begin
      $display("FAIL: credit count exp=1 got=%0d", u_cred_cnt); fails++;
    end else $display("PASS: one credit per packet");
    for (i = 0; i < 4; i = i + 1) begin
      u_read(CFG_DATA, rdata);
      if (rdata[31:0] !== w[i]) begin
        $display("FAIL: rx word%0d exp=%h got=%h", i, w[i], rdata[31:0]); fails++;
      end
    end
    u_read(CFG_STS, rdata);
    if (rdata[0] !== 1'b0) begin $display("FAIL: rx not drained"); fails++; end
    else $display("PASS: rx round trip match");
    // MGMT packet (word0 low5=0x10): readable, but NO credit.
    u_cred_cnt = 0;
    @(negedge HCLK); u_lpVld = 1; u_lpBits = 32'h0000_0010;
    @(posedge HCLK);
    for (i = 1; i < 4; i = i + 1) begin
      @(negedge HCLK); u_lpBits = 32'hAAAA_0000 + i;
      @(posedge HCLK);
    end
    @(negedge HCLK); u_lpVld = 0;
    repeat (2) @(posedge HCLK);
    if (u_cred_cnt !== 0) begin
      $display("FAIL: mgmt returned credit (%0d)", u_cred_cnt); fails++;
    end else $display("PASS: mgmt packet takes no credit");
    for (i = 0; i < 4; i = i + 1) u_read(CFG_DATA, rdata);
    // Overrun: 8 words, no reads -> sticky ovf; status-write clears.
    for (i = 0; i < 8; i = i + 1) begin
      @(negedge HCLK);
      u_lpVld = 1; u_lpBits = 32'hBEEF_0000 + i;
      @(posedge HCLK);
    end
    @(negedge HCLK); u_lpVld = 0;
    repeat (2) @(posedge HCLK);
    u_read(CFG_STS, rdata);
    if (rdata[3] !== 1'b1) begin
      $display("FAIL: overrun not flagged sts=%h", rdata[3:0]); fails++;
    end else $display("PASS: overrun sticky");
    u_write(CFG_STS, 64'h0);
    u_read(CFG_STS, rdata);
    if (rdata[3] !== 1'b0) begin $display("FAIL: ovf not cleared"); fails++; end
    else $display("PASS: ovf cleared by status write");
    for (i = 0; i < 4; i = i + 1) u_read(CFG_DATA, rdata);

    // ---------- Part 3: unit d2d_sb host tap ----------
    for (i = 0; i < 4; i = i + 1) begin
      @(negedge HCLK);
      s_rdi_bits = w[i]; s_rdi_vld = 1;
      @(posedge HCLK);
    end
    @(negedge HCLK); s_rdi_vld = 0;
    k = 0;
    while (k < 200 && tap_n < 4) begin @(posedge HCLK); k = k + 1; end
    if (tap_n < 4) begin $display("FAIL: tap silent (%0d/4)", tap_n); fails++; end
    else begin
      for (i = 0; i < 4; i = i + 1) got[i] = tap_cap[i];
      for (i = 0; i < 4; i = i + 1)
        if (got[i] !== w[i]) begin
          $display("FAIL: tap word%0d exp=%h got=%h", i, w[i], got[i]); fails++;
        end else if (i == 0) $display("PASS: host tap word order intact");
      if (s_rcv !== 6'h0) begin
        $display("FAIL: mgmt decode spuriously %h", s_rcv); fails++;
      end else $display("PASS: mgmt decode quiet on data packet");
    end

    // ---------- Part 4: HRESP on link_error (top, corrupt MB) ----------
    // Push one 7-word flit through streaming space; every MB beat is
    // corrupted so retries exhaust and link_error latches.
    for (i = 0; i < 7; i = i + 1) begin
      @(negedge HCLK);
      HSEL = 1; HWRITE = 1; HTRANS = 2'b10; HADDR = 32'h0;
      HWDATA = 64'hA5A5_0000_0000_0000 + 64'(i);
      @(posedge HCLK);
      @(negedge HCLK);
      HSEL = 0; HWRITE = 0; HTRANS = 2'b00;
    end
    k = 0;
    while (k < 20000 && tb_flit_err !== 1'b1) begin @(posedge HCLK); k = k + 1; end
    if (tb_flit_err !== 1'b1) begin
      $display("FAIL: link_error never latched"); fails++;
    end else $display("PASS: link_error latched on retry exhaustion");
    ahb_read(CFG_STS, rdata);
    if (HRESP !== 1'b1) begin $display("FAIL: HRESP not asserted"); fails++; end
    else $display("PASS: HRESP=1 on link_error");
    if (rdata[2] !== 1'b1) begin
      $display("FAIL: status err bit sts=%h", rdata[3:0]); fails++;
    end else $display("PASS: status err bit set");
    // Reset clears the latch and HRESP.
    HRESETn = 0;
    repeat (4) @(posedge HCLK);
    HRESETn = 1;
    repeat (4) @(posedge HCLK);
    ahb_read(CFG_STS, rdata);
    if (HRESP !== 1'b0) begin $display("FAIL: HRESP stuck"); fails++; end
    else $display("PASS: HRESP clear after reset");
    if (rdata[2] !== 1'b0) begin $display("FAIL: err stuck"); fails++; end
    else $display("PASS: err clear after reset");

    if (fails == 0) $display("AHBCFG PASS");
    else $display("AHBCFG FAIL fails=%0d", fails);
    $finish;
  end

  initial begin
    repeat (300000) @(posedge HCLK);
    $display("AHBCFG FAIL: watchdog");
    $finish;
  end
endmodule
