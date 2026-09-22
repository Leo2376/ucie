// sb_sniff_tb: sideband sniffer. No responses yet -- records every
// 128-bit packet our side transmits (LSB-first on txClock posedges)
// plus training/link state transitions, so the partner BFM can be
// built against observed traffic.
`timescale 1ns / 1ps

module sb_sniff_tb;
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
    .io_sbAfe_rxClock(sb_rxc),
    .io_sbAfe_rxEn(tb_sbRxEn),
    .io_sbAfe_pllLock(1'b1),
    .o_flit_link_error(),
    .o_flit_overflow()
  );

  always #5 HCLK = ~HCLK;

  // Packet sniffer: LSB-first assembly on txClock posedges.
  reg [127:0] pkt = 128'h0;
  integer nbits = 0;
  integer npkts = 0;
  always @(posedge tb_sbTxClk) begin
    pkt[nbits] <= tb_sbTx;
    if (nbits == 127) begin
      $display("SB-TX t=%0t pkt=%h", $time, {tb_sbTx, pkt[127:1]});
      npkts <= npkts + 1;
      nbits <= 0;
    end else begin
      nbits <= nbits + 1;
    end
  end

  // State probes.
  reg [2:0] last_train = 3'hx;
  reg [3:0] last_rdi = 4'hx;
  reg [3:0] last_fdi_state = 4'hx;
  always @(posedge HCLK) begin
    if (dut.logPhy.trainingModule.currentState !== last_train) begin
      last_train <= dut.logPhy.trainingModule.currentState;
      $display("TRAIN t=%0t state=%d sub=%d fdi_state=%h", $time,
               dut.logPhy.trainingModule.currentState,
               dut.logPhy.trainingModule.sbInitSubState, tb_state);
    end
    if (dut.logPhy.trainingModule.rdiBringup.state !== last_rdi) begin
      last_rdi <= dut.logPhy.trainingModule.rdiBringup.state;
      $display("RDI t=%0t state=%h sub=%d", $time,
               dut.logPhy.trainingModule.rdiBringup.state,
               dut.logPhy.trainingModule.rdiBringup.resetSubstate);
    end
    if (tb_state !== last_fdi_state) begin
      last_fdi_state <= tb_state;
      $display("FDI-STATE t=%0t state=%h", $time, tb_state);
    end
  end

  initial begin
    HRESETn = 1'b0;
    repeat (6) @(posedge HCLK);
    HRESETn = 1'b1;
    repeat (200000) @(posedge HCLK);
    $display("SNIFF DONE npkts=%0d", npkts);
    $finish;
  end
endmodule
