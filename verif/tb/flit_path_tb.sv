// flit_path_tb: flit-mode datapath integration test.
//
// ucie_top #(USE_FLIT=1) with the MB AFE looped back (tx->rx).
// Pushes 7 known 64b words through the AHB streaming port and expects
// the identical 7 words back on the FDI Rx pins (tb_pldata/tb_plvalid):
// words -> flit_pack (CRC+seq) -> 128b RDI -> 16b MB -> loopback ->
// 128b RDI -> flit_unpack (CRC check) -> words.
// Link bring-up is NOT required (data plane has no ACTIVE gate).
// Driving convention: TB inputs change on negedge.
`timescale 1ns / 1ps

module flit_path_tb;
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
  wire tb_lpCfg_valid, tb_plCfgCredit, tb_stallAck;
  wire [31:0] tb_lpCfg_bits;
  wire tb_mbTxValid, tb_mbRxRdy, tb_mbRxEn, tb_sbTx, tb_sbTxClk, tb_sbRxEn;
  wire [15:0] tb_mbTxBits;
  wire [2:0] tb_mbFreq;
  wire tb_flit_err, tb_flit_ovf;

  // MB AFE loopback: tx straight into rx, same clock.
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
    .io_fdi_lpConfigCredit(1'b0),
    .io_fdi_plConfig_valid(1'b0),
    .io_fdi_plConfig_bits(32'h0),
    .io_fdi_lpConfig_valid(tb_lpCfg_valid),
    .io_fdi_lpConfig_bits(tb_lpCfg_bits),
    .io_fdi_plConfigCredit(tb_plCfgCredit),
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
    .o_flit_link_error(tb_flit_err),
    .o_flit_overflow(tb_flit_ovf)
  );

  // Loopback with 1-cycle delay (no combinational loop on valid/ready).
  reg lb_valid = 1'b0;
  reg [15:0] lb_bits = 16'h0;
  always @(posedge HCLK) begin
    lb_valid <= tb_mbTxValid;
    lb_bits <= tb_mbTxBits;
  end
  assign mb_rx_valid = lb_valid;
  assign mb_rx_bits = lb_bits;

  always #5 HCLK = ~HCLK;

  integer fails = 0;
  reg [63:0] wdata [0:6];
  reg [63:0] rdata [0:6];
  integer got;
  integer i;

  task automatic ahb_push(input [63:0] w);
    begin
      @(negedge HCLK);
      HSEL = 1'b1; HWRITE = 1'b1; HTRANS = 2'b10; HWDATA = w;
      @(posedge HCLK); // data phase: pack captures (ready known-high)
      @(negedge HCLK);
      HSEL = 1'b0; HWRITE = 1'b0; HTRANS = 2'b00;
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
    HRESETn = 1'b0;
    repeat (6) @(posedge HCLK);
    HRESETn = 1'b1;
    repeat (4) @(posedge HCLK);

    for (i = 0; i < 7; i = i + 1) ahb_push(wdata[i]);

    // Collect Rx words: unpack streams exactly 7 valid cycles.
    got = 0;
    for (i = 0; i < 3000 && got < 7; i = i + 1) begin
      @(posedge HCLK); #1;
      if (tb_plvalid === 1'b1) begin
        rdata[got] = tb_pldata;
        got = got + 1;
      end
    end
    if (got !== 7) begin
      $display("FAIL: got %0d/7 words (overflow=%b link_err=%b)", got,
        dut.d2dadapter.gen_flit.u_mb_flit.u_reasm.overflow,
        dut.d2dadapter.gen_flit.u_mb_flit.io_link_error);
      fails = fails + 1;
    end else begin
      for (i = 0; i < 7; i = i + 1)
        if (rdata[i] !== wdata[i]) begin
          $display("FAIL: word%0d exp=%h got=%h", i, wdata[i], rdata[i]);
          fails = fails + 1;
        end
      if (fails == 0) $display("PASS: flit path round trip (7 words)");
    end
    if (dut.d2dadapter.gen_flit.u_mb_flit.u_reasm.overflow) begin
      $display("FAIL: reasm overflow"); fails = fails + 1;
    end
    if (tb_flit_err) begin
      $display("FAIL: top link_error asserted"); fails = fails + 1;
    end else $display("PASS: top link_error clear");
    if (tb_flit_ovf) begin
      $display("FAIL: top overflow asserted"); fails = fails + 1;
    end else $display("PASS: top overflow clear");

    if (fails == 0) $display("FLITPATH PASS");
    else $display("FLITPATH FAIL fails=%0d", fails);
    $display("PATHSTATE wcnt=%0d seq=%0d oldest=%0d pend=%b slice_bl=%0d rmap_tx=%b/%0d rmap_rxleft=%0d reasm_pv=%b up_drain=%b up_err=%0d",
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.wcnt,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.seq_reg,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.oldest_seq,
             dut.d2dadapter.gen_flit.u_mb_flit.u_pack.pending_unacked,
             dut.d2dadapter.gen_flit.u_mb_flit.u_slice.beats_left,
             dut.logPhy.rdiDataMapper.gen_flit128.tx_have,
             dut.logPhy.rdiDataMapper.gen_flit128.tx_out,
             dut.logPhy.rdiDataMapper.gen_flit128.rx_left,
             dut.d2dadapter.gen_flit.u_mb_flit.u_reasm.pending_vld,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.draining,
             dut.d2dadapter.gen_flit.u_mb_flit.u_unpack.err_cnt);
    $finish;
  end

  initial begin
    repeat (60000) @(posedge HCLK);
    $display("FAIL: watchdog timeout");
    $finish;
  end
endmodule
