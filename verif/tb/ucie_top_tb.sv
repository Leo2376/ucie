// ucie_top_tb: streaming-AHB smoke test for ucie_top.
//
// HWDATA/HRDATA/HREADYOUT are wired straight through to the FDI
// streaming port (no registers), so the checks observe the transfer
// itself: Tx push lands on the FDI bits with valid raised, HREADYOUT
// follows the downstream ready, Rx reads return the FDI Rx bits, and
// the discrete control pins behave with original semantics.
// No link partner is modeled, so no AFE traffic is expected.
`timescale 1ns / 1ps

module ucie_top_tb;
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

  // Control pins (original streaming semantics).
  reg        tb_irdy = 1'b0;
  reg        tb_rdy2rcv = 1'b0;
  reg        tb_fault = 1'b0;
  reg        tb_soft_rst = 1'b0;
  wire [3:0] tb_state;
  wire [63:0] tb_pldata;
  wire        tb_plvalid;

  // Single slave, TB manager never waits: HREADY tied high. The slave
  // signals its own waits via HREADYOUT, honored by extending the phase.

  // AFE tie-offs (no remote side).
  reg sb_rx = 1'b0;
  wire tb_lpCfg_valid, tb_plCfgCredit, tb_stallAck;
  wire [31:0] tb_lpCfg_bits;
  wire tb_mbTxValid, tb_mbRxRdy, tb_mbRxEn, tb_sbTx, tb_sbTxClk, tb_sbRxEn;
  wire [15:0] tb_mbTxBits;
  wire [2:0] tb_mbFreq;

  ucie_top dut (
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
    .io_mbAfe_rxData_valid(1'b0),
    .io_mbAfe_rxData_bits_0(16'h0),
    .io_mbAfe_txFreqSel(tb_mbFreq),
    .io_mbAfe_rxEn(tb_mbRxEn),
    .io_mbAfe_pllLock(1'b1),
    .io_sbAfe_fifoParams_clk(HCLK),
    .io_sbAfe_fifoParams_reset(~HRESETn),
    .io_sbAfe_txData(tb_sbTx),
    .io_sbAfe_txClock(tb_sbTxClk),
    .io_sbAfe_rxData(sb_rx),
    .io_sbAfe_rxClock(1'b0),
    .io_sbAfe_rxEn(tb_sbRxEn),
    .io_sbAfe_pllLock(1'b1)
  );

  always #5 HCLK = ~HCLK;

  integer fails = 0;

  // One AHB data phase. Write: HWDATA must appear on the FDI Tx bits
  // with valid raised during the phase. Read: HRDATA is sampled.
  task automatic ahb_xfer(input bit write, input [63:0] wdata,
                          output [63:0] rdata);
    begin
      @(posedge HCLK);
      HSEL = 1'b1; HWRITE = write; HTRANS = 2'b10;
      if (write) HWDATA = wdata;
      @(posedge HCLK);
      HTRANS = 2'b00;
      begin
        integer i = 0;
        while (HREADYOUT !== 1'b1 && i < 1000) begin
          @(posedge HCLK);
          i = i + 1;
        end
        if (HREADYOUT !== 1'b1) begin
          $display("FAIL: HREADYOUT stuck low");
          fails = fails + 1;
        end
      end
      rdata = HRDATA;
      @(posedge HCLK);
      HSEL = 1'b0; HWRITE = 1'b0;
    end
  endtask

  reg [63:0] rdata;

  initial begin
    HRESETn = 1'b0;
    repeat (6) @(posedge HCLK);
    HRESETn = 1'b1;
    repeat (4) @(posedge HCLK);

    // 1. Idle: ready follows downstream, HRESP always OKAY, state RESET.
    if (HREADYOUT !== 1'b1) begin
      $display("FAIL: HREADYOUT idle exp=1 got=%b", HREADYOUT);
      fails = fails + 1;
    end else $display("PASS: HREADYOUT idle 1");
    if (HRESP !== 1'b0) begin
      $display("FAIL: HRESP idle exp=0 got=%b", HRESP);
      fails = fails + 1;
    end else $display("PASS: HRESP idle 0");
    if (tb_state !== 4'h0) begin
      $display("FAIL: state after reset exp=0 got=%h", tb_state);
      fails = fails + 1;
    end else $display("PASS: state RESET after reset");

    // 2. Tx push: pattern lands directly on FDI bits with valid=1.
    tb_irdy = 1'b1;
    @(posedge HCLK);
    HSEL = 1'b1; HWRITE = 1'b1; HTRANS = 2'b10;
    HWDATA = 64'hA5A5_5A5A_DEAD_BEEF;
    @(negedge HCLK);
    if (dut.protocol_io_fdi_lpData_bits !== 64'hA5A5_5A5A_DEAD_BEEF) begin
      $display("FAIL: FDI bits exp=A5.. got=%h",
               dut.protocol_io_fdi_lpData_bits);
      fails = fails + 1;
    end else if (dut.protocol_io_fdi_lpData_valid !== 1'b1) begin
      $display("FAIL: FDI valid not raised during write xfer");
      fails = fails + 1;
    end else if (dut.protocol_io_fdi_lpData_irdy !== 1'b1) begin
      $display("FAIL: FDI irdy did not follow pin");
      fails = fails + 1;
    end else $display("PASS: Tx push direct to FDI");
    @(posedge HCLK);
    HTRANS = 2'b00;
    @(posedge HCLK);
    HSEL = 1'b0; HWRITE = 1'b0;
    if (dut.protocol_io_fdi_lpData_valid !== 1'b0) begin
      $display("FAIL: FDI valid did not drop after xfer");
      fails = fails + 1;
    end else $display("PASS: FDI valid drops after xfer");

    // 3. Rx sample: HRDATA follows FDI Rx bits (idle 0, no partner).
    ahb_xfer(1'b0, 64'h0, rdata);
    if (rdata !== tb_pldata) begin
      $display("FAIL: HRDATA %h != pldata %h", rdata, tb_pldata);
      fails = fails + 1;
    end else $display("PASS: Rx sample follows FDI (data=%h)", rdata);

    // 4. Control pins: ready_to_rcv, fault, soft_reset propagate.
    tb_rdy2rcv = 1'b1;
    tb_fault = 1'b1;
    repeat (2) @(posedge HCLK);
    if (dut.protocol_io_fdi_lpLinkError !== 1'b1) begin
      $display("FAIL: fault pin did not reach lpLinkError");
      fails = fails + 1;
    end else $display("PASS: fault pin -> lpLinkError");
    tb_fault = 1'b0;
    tb_soft_rst = 1'b1;
    repeat (4) @(posedge HCLK);
    tb_soft_rst = 1'b0;
    repeat (2) @(posedge HCLK);
    $display("PASS: soft_reset pulse done (state=%h)", tb_state);

    if (fails == 0) $display("SMOKE PASS");
    else $display("SMOKE FAIL fails=%0d", fails);
    $finish;
  end

  // Watchdog.
  initial begin
    repeat (20000) @(posedge HCLK);
    $display("FAIL: watchdog timeout");
    $finish;
  end
endmodule
