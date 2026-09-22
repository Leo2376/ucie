// sb_link_tb: link bring-up test with a sideband partner BFM.
//
// Partner rules (see docs/sb_link.md):
// - sample our txData on posedge txClock, assemble 128b LSB-first;
// - pattern-class packets  -> reply 128'hAAAA...A (what pat_gen matches);
// - message-class packets  -> echo the exact packet (satisfies the
//   sb_wrap [4:0]/[21:14]/[39:32] match; D2D templates refined later);
// - shift replies on rxData with 128 rxClock pulses, LSB-first, all on
//   negedge HCLK so no races with DUT posedge logic.
// PASS when the FDI link state reaches ACTIVE (tb_state == 1).
`timescale 1ns / 1ps

module sb_link_tb;
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
  // No LINKRESET during initial bring-up: the training FSM treats RDI
  // state 9 as fatal (TRAIN=5), and D2D reset traffic would contend
  // with training on the shared serial sideband. The protocol side
  // requests ACTIVE by itself once inbandPres asserts (train==4).
  reg        tb_soft_rst = 1'b0;
  wire [3:0] tb_state;
  wire [63:0] tb_pldata;
  wire        tb_plvalid;

  // Partner-driven serial RX.
  reg sb_rx = 1'b0;
  reg sb_rxc = 1'b0;
  wire tb_stallAck;
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

  // RX sampler: assemble our TX packets. Message-class packets latch
  // separately (never dropped: the DUT sends one and waits); pattern
  // packets use a 1-deep box (drops OK, they stream).
  reg [127:0] rx_pkt = 128'h0;
  integer rx_n = 0;
  reg pkt_avail = 1'b0;
  reg [127:0] pkt_mbox = 128'h0;
  reg msg_avail = 1'b0;
  reg [127:0] msg_mbox = 128'h0;
  integer npkts = 0;

  // Packet classification. NOTE: the RDI-config (chunked) path rewrites
  // [63:48] on D2D packets (0500->0100 observed), so D2D matching masks
  // the domain; only direct-path training packets keep theirs.
  // Returns: 0 pattern, 1 train-echo, 2 D2D-req, 3 param-req, 4 ignore.
  localparam [127:0] DOMM = ~(128'hffff << 48);
  function automatic [2:0] pkt_class(input [127:0] p);
    begin
      if ((p & DOMM) == (PARAM_REQ & DOMM)) return 3'd3;
      if (p[63:48] == 16'h0600 || p[63:48] == 16'h0200) return 3'd1;
      if (p[127:64] == 64'h0 && p[47:40] == 8'h0 && p[31:22] == 10'h080 &&
          p[13:5] == 9'h0 && p[4] == 1'b1 && p[3:0] == 4'h2 &&
          (p[21:14] == 8'h03 || p[21:14] == 8'h07) &&
          (p[39:32] == 8'h01 || p[39:32] == 8'h04 || p[39:32] == 8'h08 ||
           p[39:32] == 8'h09 || p[39:32] == 8'h0c)) return 3'd2;
      if (p[4:0] == 5'h1b) return 3'd2; // param-shaped backstop
      // Our own RSPs and IDLEs: never answer.
      if (p[127:64] == 64'h0 && p[47:40] == 8'h0 && p[31:22] == 10'h080 &&
          p[13:5] == 9'h0 && p[4] == 1'b1 && p[3:0] == 4'h2) return 3'd4;
      return 3'd0;
    end
  endfunction
  function automatic bit is_msg(input [127:0] p);
    begin
      is_msg = (pkt_class(p) == 3'd1) || (pkt_class(p) == 3'd2) ||
               (pkt_class(p) == 3'd3);
    end
  endfunction

  wire tx_sending = dut.logPhy.sidebandChannel.lower_node.tx_ser.sending;
  reg tx_sending_prev = 1'b0;
  reg [127:0] full_pkt;
  always @(posedge HCLK) begin
    tx_sending_prev <= tx_sending;
    if (!tx_sending) begin
      rx_n <= 0;
    end else begin
      // Blocking temp: the completed packet must include THIS cycle's
      // sample (reading rx_pkt[127] here would return the stale value
      // and shift the whole packet by one bit).
      full_pkt = {tb_sbTx, rx_pkt[126:0]};
      rx_pkt[rx_n] <= tb_sbTx;
      if (rx_n == 127) begin
        npkts <= npkts + 1;
        $display("SNIF t=%0t pkt=%h", $time, full_pkt);
        if (is_msg(full_pkt)) begin
          msg_mbox <= full_pkt;
          msg_avail <= 1'b1;
        end else if (!pkt_avail) begin
          pkt_mbox <= full_pkt;
          pkt_avail <= 1'b1;
        end
        rx_n <= 0;
      end else begin
        rx_n <= rx_n + 1;
      end
    end
    if (tx_sending && !tx_sending_prev) begin
      $display("TXSTART t=%0t bits=%h", $time,
               dut.logPhy.sidebandChannel.lower_node.tx_ser.io_in_bits);
    end
  end

  // Responder: negedge-driven serial TX, 2 HCLK per bit.
  // Messages preempt everything (DUT sends one and waits); pattern
  // packets are rate-limited by cooldown.
  integer nresp_pat = 0;
  integer nresp_msg = 0;
  integer cooldown = 0;
  reg [127:0] tx_pkt;
  reg send_req = 1'b0;
  // D2D packet builder: {0, 0500, 00, code, 080, dir, 00.., 1, 2}.
  function automatic [127:0] d2d_pkt(input [7:0] code, input [7:0] dir);
    return {64'h0, 16'h0500, 8'h00, code, 10'h080, dir, 9'h0, 1'b1, 4'h2};
  endfunction
  localparam [127:0] PARAM_REQ = 128'h488000050000002000401b;
  reg active_req_sent = 1'b0;
  reg [127:0] rsp_q [0:7];
  integer rsp_w = 0;
  integer rsp_r = 0;
  integer rsp_n = 0;
  // Duplicate suppression: the DUT retransmits while waiting (tx
  // re-arms between bursts), so repeats of the same packet are normal.
  // Answer each distinct packet ONCE: late duplicates would otherwise
  // accumulate as stale packets in the DUT's RX queues and head-of-line
  // block later traffic (the queues have no flush on state change).
  reg [127:0] last_msg = 128'h0;
  integer dup_cnt = 0;

  task automatic enqueue(input [127:0] p);
    begin
      if (rsp_n < 8) begin
        rsp_q[rsp_w] = p;
        rsp_w = (rsp_w + 1) % 8;
        rsp_n = rsp_n + 1;
      end
    end
  endtask

  task automatic handle_msg(input [127:0] p);
    begin
      case (pkt_class(p))
        3'd1: begin
          enqueue(p); // training echo: satisfies sb_wrap match fields
          $display("PARTNER t=%0t echo train pkt=%h", $time, p);
        end
        3'd3: begin
          enqueue(PARAM_REQ); // partner's own PARAM req (rcv flag)
          $display("PARTNER t=%0t param req", $time);
        end
        3'd2: begin // our D2D REQ -> RSP (+req where the dance needs it)
          case (p[39:32])
            8'h09: enqueue(d2d_pkt(8'h09, 8'h04));
            8'h0c: enqueue(d2d_pkt(8'h0c, 8'h04));
            8'h01: begin
              enqueue(d2d_pkt(8'h01, 8'h04));
              if (!active_req_sent) begin
                enqueue(d2d_pkt(8'h01, 8'h03));
                active_req_sent = 1'b1;
              end
            end
            8'h00: begin // parity REQ (dir 07) or unknown code
              if (p[21:14] == 8'h07) enqueue(d2d_pkt(8'h00, 8'h08));
              else enqueue(p);
            end
            default: enqueue(p);
          endcase
          $display("PARTNER t=%0t rsp to %h", $time, p);
        end
        default: ; // patterns handled separately; ignore the rest
      endcase
    end
  endtask

  task automatic send_pkt(input [127:0] p);
    begin
      for (integer i = 0; i < 128; i = i + 1) begin
        @(negedge HCLK);
        sb_rx = p[i];
        sb_rxc = 1'b1;
        @(negedge HCLK);
        sb_rxc = 1'b0;
      end
      $display("PARTNER t=%0t reply sent", $time);
    end
  endtask

  initial begin
    sb_rx = 1'b0;
    sb_rxc = 1'b0;
    @(posedge HRESETn);
    forever begin
      @(negedge HCLK);
      if (cooldown > 0) cooldown = cooldown - 1;
      if (!send_req) begin
        if (msg_avail) begin
          msg_avail = 1'b0;
          if (msg_mbox == last_msg) dup_cnt = dup_cnt + 1;
          else begin last_msg = msg_mbox; dup_cnt = 1; end
          if (dup_cnt <= 1) handle_msg(msg_mbox);
          else $display("PARTNER t=%0t drop dup %h", $time, msg_mbox);
        end
        if (rsp_n > 0) begin
          tx_pkt = rsp_q[rsp_r];
          rsp_r = (rsp_r + 1) % 8;
          rsp_n = rsp_n - 1;
          nresp_msg = nresp_msg + 1;
          send_req = 1'b1;
        end else if (pkt_avail && cooldown == 0) begin
          pkt_avail = 1'b0;
          tx_pkt = 128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
          nresp_pat = nresp_pat + 1;
          cooldown = 100; // don't flood the pattern detector
          $display("PARTNER t=%0t send pattern #%0d for %h", $time, nresp_pat, pkt_mbox);
          send_req = 1'b1;
        end
      end
      if (send_req) begin
        send_req = 1'b0;
        send_pkt(tx_pkt);
      end
    end
  end

  // Progress probes.
  reg [5:0] last_snd = 6'hx;
  reg [5:0] last_rcv = 6'hx;
  always @(posedge HCLK) begin
    if (dut.d2dadapter.link_manager.io_sb_snd !== last_snd) begin
      last_snd <= dut.d2dadapter.link_manager.io_sb_snd;
      $display("D2DSND t=%0t op=%h", $time,
               dut.d2dadapter.link_manager.io_sb_snd);
    end
    if (dut.d2dadapter.link_manager.io_sb_rcv !== last_rcv) begin
      last_rcv <= dut.d2dadapter.link_manager.io_sb_rcv;
      $display("D2DRCV t=%0t op=%h", $time,
               dut.d2dadapter.link_manager.io_sb_rcv);
    end
  end
  reg [2:0] last_train = 3'hx;
  reg [2:0] last_sub = 3'hx;
  reg [3:0] last_rdi = 4'hx;
  reg [3:0] last_fdi = 4'hx;
  reg [3:0] last_link = 4'hx;
  reg last_desv = 1'bx;
  reg pup_v = 1'b0, rdi_v = 1'b0, rnode_v = 1'b0;
  reg swb_v = 1'b0, swa_v = 1'b0;
  integer hb = 0;
  always @(posedge HCLK) begin
    if (dut.logPhy.trainingModule.sbInitSubState !== last_sub) begin
      last_sub <= dut.logPhy.trainingModule.sbInitSubState;
      $display("SUB t=%0t sub=%d", $time,
               dut.logPhy.trainingModule.sbInitSubState);
    end
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
    if (tb_state !== last_fdi && ^tb_state !== 1'bx) begin
      last_fdi <= tb_state;
      $display("FDI-STATE t=%0t state=%h", $time, tb_state);
    end
    if (dut.d2dadapter.link_manager.link_state_reg !== last_link) begin
      last_link <= dut.d2dadapter.link_manager.link_state_reg;
      $display("LINK t=%0t state=%h fdi_req=%h", $time,
               dut.d2dadapter.link_manager.link_state_reg,
               dut.d2dadapter.link_manager.io_fdi_lp_state_req);
    end
    if (dut.logPhy.sidebandChannel.lower_node.rx_des_io_out_valid !== last_desv) begin
      last_desv <= dut.logPhy.sidebandChannel.lower_node.rx_des_io_out_valid;
      $display("DES t=%0t valid=%b bits=%h detects=%h rd=%b rxv=%b wip=%b rxmode=%b",
               $time,
               dut.logPhy.sidebandChannel.lower_node.rx_des_io_out_valid,
               dut.logPhy.sidebandChannel.lower_node.rx_des_io_out_bits,
               dut.logPhy.trainingModule.patternGenerator.patternDetectedCount,
               dut.logPhy.trainingModule.patternGenerator.readInProgress,
               dut.logPhy.trainingModule.patternGenerator.io_sidebandLaneIO_rxData_valid,
               dut.logPhy.trainingModule.io_sidebandFSMIO_rxMode,
               dut.logPhy.trainingModule.patternGenerator.writeInProgress,
               dut.logPhy.trainingModule.io_sidebandFSMIO_rxMode);
    end
    if (dut.logPhy.sidebandChannel.upper_node.io_outer_tx_valid !== pup_v) begin
      pup_v <= dut.logPhy.sidebandChannel.upper_node.io_outer_tx_valid;
      $display("UP32 t=%0t v=%b bits=%h", $time, pup_v,
               dut.logPhy.sidebandChannel.upper_node.io_outer_tx_bits);
    end
    if (dut.d2dadapter.io_rdi_plConfig_valid !== rdi_v) begin
      rdi_v <= dut.d2dadapter.io_rdi_plConfig_valid;
      $display("RDI32 t=%0t v=%b bits=%h", $time, rdi_v,
               dut.d2dadapter.io_rdi_plConfig_bits);
    end
    if (dut.d2dadapter.d2d_sideband.rdi_sideband_node.io_inner_node_to_layer_valid !== rnode_v) begin
      rnode_v <= dut.d2dadapter.d2d_sideband.rdi_sideband_node.io_inner_node_to_layer_valid;
      $display("RNODE t=%0t v=%b bits=%h", $time, rnode_v,
               dut.d2dadapter.d2d_sideband.rdi_sideband_node.io_inner_node_to_layer_bits);
    end
    if (dut.d2dadapter.d2d_sideband.sideband_switch.io_inner_node_to_layer_above_valid !== swa_v) begin
      swa_v <= dut.d2dadapter.d2d_sideband.sideband_switch.io_inner_node_to_layer_above_valid;
      $display("DECIN t=%0t v=%b bits=%h", $time, swa_v,
               dut.d2dadapter.d2d_sideband.sideband_switch.io_inner_node_to_layer_above_bits);
    end
    if (dut.d2dadapter.d2d_sideband.io_sideband_rcv !== 6'h0) begin
      $display("DEC t=%0t op=%h", $time, dut.d2dadapter.d2d_sideband.io_sideband_rcv);
    end
    hb <= hb + 1;
    if (hb % 20000 == 0) begin
      $display("HB t=%0t npkts=%0d train=%d sub=%d wip=%b detects=%h",
               $time, npkts,
               dut.logPhy.trainingModule.currentState,
               dut.logPhy.trainingModule.sbInitSubState,
               dut.logPhy.trainingModule.patternGenerator.writeInProgress,
               dut.logPhy.trainingModule.patternGenerator.patternDetectedCount);
      $display("HB2 t=%0t link=%h fdi_req=%h lp_plstate=%h rdi_st=%h",
               $time, dut.d2dadapter.link_manager.link_state_reg,
               dut.d2dadapter.link_manager.io_fdi_lp_state_req,
               dut.d2dadapter.io_fdi_plStateStatus,
               dut.logPhy.trainingModule.rdiBringup.state);
      $display("HB2b t=%0t linit=%d rdi_inband=%b snt=%h s_snt=%h s_rcv=%h prm_s=%b prm_r=%b",
               $time,
               dut.d2dadapter.link_manager.linkinit_submodule.linkinit_state_reg,
               dut.d2dadapter.link_manager.linkinit_submodule.io_rdi_pl_inband_pres,
               dut.d2dadapter.link_manager.linkinit_submodule.io_linkinit_sb_snd,
               dut.d2dadapter.link_manager.io_sb_snd,
               dut.d2dadapter.link_manager.io_sb_rcv,
               dut.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_snt_flag,
               dut.d2dadapter.link_manager.linkinit_submodule.param_exch_sbmsg_rcv_flag);
      $display("HB3 t=%0t rdi_sub=%d rdi_req=%h ahb_req=%h sb_rsp_vld=%b",
               $time, dut.logPhy.trainingModule.rdiBringup.resetSubstate,
               dut.logPhy.trainingModule.rdiBringup.io_sbTrainIO_msgReq_valid,
               dut.d2dadapter.link_manager.linkinit_submodule.io_fdi_lp_state_req,
               dut.logPhy.trainingModule.sbMsgWrapper.io_laneIO_rxData_valid);
      $display("HB4 t=%0t sb6=%h rst_req=%b rst_rsp=%b rst_ext=%b rst_fdi=%b entry=%b",
               $time, dut.d2dadapter.d2d_sideband.io_sideband_rcv,
               dut.d2dadapter.link_manager.linkreset_submodule.linkreset_sbmsg_req_rcv_flag,
               dut.d2dadapter.link_manager.linkreset_submodule.linkreset_sbmsg_rsp_rcv_flag,
               dut.d2dadapter.link_manager.linkreset_submodule.linkreset_sbmsg_ext_rsp_reg,
               dut.d2dadapter.link_manager.linkreset_submodule.linkreset_fdi_req_reg,
               dut.d2dadapter.link_manager.linkreset_submodule.io_linkreset_entry);
    end
    if (hb % 2000 == 0) begin
      $display("WRAP t=%0t st=%d sent=%b recvd=%b txv=%b txr=%b inmode=%b rxm=%b req=%h",
               $time,
               dut.logPhy.trainingModule.sbMsgWrapper.currentState,
               dut.logPhy.trainingModule.sbMsgWrapper.sentMsg,
               dut.logPhy.trainingModule.sbMsgWrapper.receivedMsg,
               dut.logPhy.trainingModule.sbMsgWrapper.io_laneIO_txData_valid,
               dut.logPhy.trainingModule.sbMsgWrapper.io_laneIO_txData_ready,
               dut.logPhy.sidebandChannel.io_inner_inputMode,
               dut.logPhy.trainingModule.io_sidebandFSMIO_rxMode,
               dut.logPhy.trainingModule.sbMsgWrapper.currentReq);
    end
    if (hb % 2000 == 0) begin
      $display("ARB t=%0t sbv=%b n2nv=%b n2nb=%h flag=%b SerV=%b SerR=%b sending=%b SerBits=%h",
               $time,
               dut.logPhy.sidebandChannel.switcher.outer_layer_to_node_below_subswitch.io_inner_layer_to_node_valid,
               dut.logPhy.sidebandChannel.switcher.outer_layer_to_node_below_subswitch.io_node_to_node_valid,
               dut.logPhy.sidebandChannel.switcher.outer_layer_to_node_below_subswitch.io_node_to_node_bits,
               dut.logPhy.sidebandChannel.switcher.outer_layer_to_node_below_subswitch.flag,
               dut.logPhy.sidebandChannel.lower_node.tx_ser.io_in_valid,
               dut.logPhy.sidebandChannel.lower_node.tx_ser.io_in_ready,
               dut.logPhy.sidebandChannel.lower_node.tx_ser.sending,
               dut.logPhy.sidebandChannel.lower_node.tx_ser.io_in_bits);
    end
  end

  integer wait_train = 0;
  integer wait_link = 0;

  initial begin
    HRESETn = 1'b0;
    repeat (6) @(posedge HCLK);
    HRESETn = 1'b1;
    // Wait for PHY training to complete (train==4, inbandPres up);
    // the protocol side then walks RESET->ACTIVE on its own.
    // Separate budgets: training carries multi-M-cycle protocol
    // timeouts, and D2D PARAM/ACTIVE needs its own window after.
    while (dut.logPhy.trainingModule.currentState !== 3'h4 && wait_train < 30000000) begin
      @(posedge HCLK);
      wait_train = wait_train + 1;
    end
    if (dut.logPhy.trainingModule.currentState !== 3'h4)
      $display("TRAIN TIMEOUT t=%0t train=%d", $time,
               dut.logPhy.trainingModule.currentState);
    else
      $display("TRAINED t=%0t train=%d", $time,
               dut.logPhy.trainingModule.currentState);
    // Wait for ACTIVE with its own budget (D2D PARAM/ACTIVE dance).
    while (tb_state !== 4'h1 && wait_link < 20000000) begin
      @(posedge HCLK);
      wait_link = wait_link + 1;
    end
    if (tb_state == 4'h1) begin
      $display("LINK ACTIVE t=%0t npkts=%0d pat=%0d msg=%0d", $time,
               npkts, nresp_pat, nresp_msg);
      $display("LINKBRINGUP PASS");
    end else begin
      $display("LINKBRINGUP FAIL: timeout npkts=%0d pat=%0d msg=%0d state=%h train=%d",
               npkts, nresp_pat, nresp_msg, tb_state,
               dut.logPhy.trainingModule.currentState);
    end
    $finish;
  end
endmodule
