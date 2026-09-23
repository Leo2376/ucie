module d2d_sb(
  input         clock,
  input         reset,
  input  [31:0] io_rdi_pl_cfg,
  input         io_rdi_pl_cfg_vld,
  output        io_rdi_pl_cfg_crd,
  output [31:0] io_rdi_lp_cfg,
  output        io_rdi_lp_cfg_vld,
  input         io_rdi_lp_cfg_crd,
  // FDI config legs (host mailbox, docs/cfg_spec.md). Previously tied
  // off; now live: host TX flows to the RDI node (node_to_node chain),
  // RDI-ingress is tapped to the host RX (see sidebandSwitcher).
  input  [31:0] io_fdi_pl_cfg,
  input         io_fdi_pl_cfg_vld,
  output        io_fdi_pl_cfg_crd,
  output [31:0] io_fdi_lp_cfg,
  output        io_fdi_lp_cfg_vld,
  input         io_fdi_lp_cfg_crd,
  output [5:0]  io_sideband_rcv,
  input  [5:0]  io_sideband_snt,
  output        io_sideband_rdy,
  // Flit ACK/NACK codec (docs/ack_spec.md). TX: local unpack feedback
  // encoded into D2D-domain sideband packets toward the partner.
  // RX: partner packets decoded into the local pack feedback.
  input         io_ack_tx_valid,
  input  [7:0]  io_ack_tx_seq,
  input         io_nack_tx,
  output        io_ack_rx_valid,
  output [7:0]  io_ack_rx_seq,
  output        io_nack_rx
);
  wire  fdi_sideband_node_clock;
  wire  fdi_sideband_node_reset;
  wire  fdi_sideband_node_io_inner_layer_to_node_ready;
  wire  fdi_sideband_node_io_inner_layer_to_node_valid;
  wire [127:0] fdi_sideband_node_io_inner_layer_to_node_bits;
  wire  fdi_sideband_node_io_inner_node_to_layer_ready;
  wire  fdi_sideband_node_io_inner_node_to_layer_valid;
  wire [127:0] fdi_sideband_node_io_inner_node_to_layer_bits;
  wire [31:0] fdi_sideband_node_io_outer_tx_bits;
  wire  fdi_sideband_node_io_outer_tx_valid;
  wire  fdi_sideband_node_io_outer_tx_credit;
  wire [31:0] fdi_sideband_node_io_outer_rx_bits;
  wire  fdi_sideband_node_io_outer_rx_valid;
  wire  fdi_sideband_node_io_outer_rx_credit;
  wire  rdi_sideband_node_clock;
  wire  rdi_sideband_node_reset;
  wire  rdi_sideband_node_io_inner_layer_to_node_ready;
  wire  rdi_sideband_node_io_inner_layer_to_node_valid;
  wire [127:0] rdi_sideband_node_io_inner_layer_to_node_bits;
  wire  rdi_sideband_node_io_inner_node_to_layer_ready;
  wire  rdi_sideband_node_io_inner_node_to_layer_valid;
  wire [127:0] rdi_sideband_node_io_inner_node_to_layer_bits;
  wire [31:0] rdi_sideband_node_io_outer_tx_bits;
  wire  rdi_sideband_node_io_outer_tx_valid;
  wire  rdi_sideband_node_io_outer_tx_credit;
  wire [31:0] rdi_sideband_node_io_outer_rx_bits;
  wire  rdi_sideband_node_io_outer_rx_valid;
  wire  rdi_sideband_node_io_outer_rx_credit;
  wire  sideband_switch_io_inner_node_to_layer_above_ready;
  wire  sideband_switch_io_inner_node_to_layer_above_valid;
  wire [127:0] sideband_switch_io_inner_node_to_layer_above_bits;
  wire  sideband_switch_io_inner_layer_to_node_below_ready;
  wire  sideband_switch_io_inner_layer_to_node_below_valid;
  wire [127:0] sideband_switch_io_inner_layer_to_node_below_bits;
  wire  sideband_switch_io_outer_node_to_layer_above_ready;
  wire  sideband_switch_io_outer_node_to_layer_above_valid;
  wire [127:0] sideband_switch_io_outer_node_to_layer_above_bits;
  wire  sideband_switch_io_outer_layer_to_node_above_ready;
  wire  sideband_switch_io_outer_layer_to_node_above_valid;
  wire [127:0] sideband_switch_io_outer_layer_to_node_above_bits;
  wire  sideband_switch_io_outer_node_to_layer_below_ready;
  wire  sideband_switch_io_outer_node_to_layer_below_valid;
  wire [127:0] sideband_switch_io_outer_node_to_layer_below_bits;
  wire  sideband_switch_io_outer_layer_to_node_below_ready;
  wire  sideband_switch_io_outer_layer_to_node_below_valid;
  wire [127:0] sideband_switch_io_outer_layer_to_node_below_bits;
  wire [127:0] _T_1 = sideband_switch_io_inner_node_to_layer_above_bits & 128'hffffff003fc01f;
  wire [127:0] _T_3 = sideband_switch_io_inner_node_to_layer_above_bits & 128'hff003fc01f;
  wire [5:0] _GEN_0 = 128'h401b == _T_1 ? 6'h24 : 6'h0;
  wire [5:0] _GEN_1 = 128'h100020012 == _T_1 ? 6'h32 : _GEN_0;
  wire [5:0] _GEN_2 = 128'h20012 == _T_1 ? 6'h31 : _GEN_1;
  wire [5:0] _GEN_3 = 128'h1c012 == _T_1 ? 6'h21 : _GEN_2;
  wire [5:0] _GEN_4 = 128'hc00010012 == _T_1 ? 6'h1c : _GEN_3;
  wire [5:0] _GEN_5 = 128'h900010012 == _T_1 ? 6'h19 : _GEN_4;
  wire [5:0] _GEN_6 = 128'h800010012 == _T_1 ? 6'h18 : _GEN_5;
  wire [5:0] _GEN_7 = 128'h400010012 == _T_1 ? 6'h14 : _GEN_6;
  wire [5:0] _GEN_8 = 128'h200010012 == _T_1 ? 6'h13 : _GEN_7;
  wire [5:0] _GEN_9 = 128'h100010012 == _T_1 ? 6'h11 : _GEN_8;
  wire [5:0] _GEN_10 = 128'hc0000c012 == _T_3 ? 6'hc : _GEN_9;
  wire [5:0] _GEN_11 = 128'h90000c012 == _T_3 ? 6'h9 : _GEN_10;
  wire [5:0] _GEN_12 = 128'h80000c012 == _T_3 ? 6'h8 : _GEN_11;
  wire [5:0] _GEN_13 = 128'h40000c012 == _T_3 ? 6'h4 : _GEN_12;
  wire [5:0] _GEN_14 = 128'h10000c012 == _T_1 ? 6'h1 : _GEN_13;
  // Flit ACK/NACK decode (docs/ack_spec.md). seq rides in [63:56],
  // which the mask ignores, so one entry matches every seq value.
  // NOTE: the mask zeroes [31:22], so entries carry only dir+fmt below.
  wire [5:0] _GEN_32 = 128'h00002A00010012 == _T_1 ? 6'h2A : _GEN_14;
  wire [5:0] _GEN_33 = 128'h00002B00010012 == _T_1 ? 6'h2B : _GEN_32;
  wire [142:0] _GEN_16 = io_sideband_snt == 6'h24 ? 143'h488000050000002000401b : 143'h500000020000012;
  wire [142:0] _GEN_17 = io_sideband_snt == 6'h32 ? 143'h500000120020012 : _GEN_16;
  wire [142:0] _GEN_18 = io_sideband_snt == 6'h31 ? 143'h500000020020012 : _GEN_17;
  wire [142:0] _GEN_19 = io_sideband_snt == 6'h21 ? 143'h50000002001c012 : _GEN_18;
  wire [142:0] _GEN_20 = io_sideband_snt == 6'h1c ? 143'h500000c20010012 : _GEN_19;
  wire [142:0] _GEN_21 = io_sideband_snt == 6'h19 ? 143'h500000920010012 : _GEN_20;
  wire [142:0] _GEN_22 = io_sideband_snt == 6'h18 ? 143'h500000820010012 : _GEN_21;
  wire [142:0] _GEN_23 = io_sideband_snt == 6'h14 ? 143'h500000420010012 : _GEN_22;
  wire [142:0] _GEN_24 = io_sideband_snt == 6'h13 ? 143'h500000220010012 : _GEN_23;
  wire [142:0] _GEN_25 = io_sideband_snt == 6'h11 ? 143'h500000120010012 : _GEN_24;
  wire [142:0] _GEN_26 = io_sideband_snt == 6'hc ? 143'h500000c2000c012 : _GEN_25;
  wire [142:0] _GEN_27 = io_sideband_snt == 6'h9 ? 143'h50000092000c012 : _GEN_26;
  wire [142:0] _GEN_28 = io_sideband_snt == 6'h8 ? 143'h50000082000c012 : _GEN_27;
  wire [142:0] _GEN_29 = io_sideband_snt == 6'h4 ? 143'h50000042000c012 : _GEN_28;
  wire [142:0] _GEN_30 = io_sideband_snt == 6'h1 ? 143'h50000012000c012 : _GEN_29;
  wire [142:0] _GEN_31 = io_sideband_snt != 6'h0 ? _GEN_30 : 143'h500000020000012;
  sb_node fdi_sideband_node (
    .clock(fdi_sideband_node_clock),
    .reset(fdi_sideband_node_reset),
    .io_inner_layer_to_node_ready(fdi_sideband_node_io_inner_layer_to_node_ready),
    .io_inner_layer_to_node_valid(fdi_sideband_node_io_inner_layer_to_node_valid),
    .io_inner_layer_to_node_bits(fdi_sideband_node_io_inner_layer_to_node_bits),
    .io_inner_node_to_layer_ready(fdi_sideband_node_io_inner_node_to_layer_ready),
    .io_inner_node_to_layer_valid(fdi_sideband_node_io_inner_node_to_layer_valid),
    .io_inner_node_to_layer_bits(fdi_sideband_node_io_inner_node_to_layer_bits),
    .io_outer_tx_bits(fdi_sideband_node_io_outer_tx_bits),
    .io_outer_tx_valid(fdi_sideband_node_io_outer_tx_valid),
    .io_outer_tx_credit(fdi_sideband_node_io_outer_tx_credit),
    .io_outer_rx_bits(fdi_sideband_node_io_outer_rx_bits),
    .io_outer_rx_valid(fdi_sideband_node_io_outer_rx_valid),
    .io_outer_rx_credit(fdi_sideband_node_io_outer_rx_credit)
  );
  sb_node rdi_sideband_node (
    .clock(rdi_sideband_node_clock),
    .reset(rdi_sideband_node_reset),
    .io_inner_layer_to_node_ready(rdi_sideband_node_io_inner_layer_to_node_ready),
    .io_inner_layer_to_node_valid(rdi_sideband_node_io_inner_layer_to_node_valid),
    .io_inner_layer_to_node_bits(rdi_sideband_node_io_inner_layer_to_node_bits),
    .io_inner_node_to_layer_ready(rdi_sideband_node_io_inner_node_to_layer_ready),
    .io_inner_node_to_layer_valid(rdi_sideband_node_io_inner_node_to_layer_valid),
    .io_inner_node_to_layer_bits(rdi_sideband_node_io_inner_node_to_layer_bits),
    .io_outer_tx_bits(rdi_sideband_node_io_outer_tx_bits),
    .io_outer_tx_valid(rdi_sideband_node_io_outer_tx_valid),
    .io_outer_tx_credit(rdi_sideband_node_io_outer_tx_credit),
    .io_outer_rx_bits(rdi_sideband_node_io_outer_rx_bits),
    .io_outer_rx_valid(rdi_sideband_node_io_outer_rx_valid),
    .io_outer_rx_credit(rdi_sideband_node_io_outer_rx_credit)
  );
  sidebandSwitcher sideband_switch (
    .io_inner_node_to_layer_above_ready(sideband_switch_io_inner_node_to_layer_above_ready),
    .io_inner_node_to_layer_above_valid(sideband_switch_io_inner_node_to_layer_above_valid),
    .io_inner_node_to_layer_above_bits(sideband_switch_io_inner_node_to_layer_above_bits),
    .io_inner_layer_to_node_below_ready(sideband_switch_io_inner_layer_to_node_below_ready),
    .io_inner_layer_to_node_below_valid(sideband_switch_io_inner_layer_to_node_below_valid),
    .io_inner_layer_to_node_below_bits(sideband_switch_io_inner_layer_to_node_below_bits),
    .io_outer_node_to_layer_above_ready(sideband_switch_io_outer_node_to_layer_above_ready),
    .io_outer_node_to_layer_above_valid(sideband_switch_io_outer_node_to_layer_above_valid),
    .io_outer_node_to_layer_above_bits(sideband_switch_io_outer_node_to_layer_above_bits),
    .io_outer_layer_to_node_above_ready(sideband_switch_io_outer_layer_to_node_above_ready),
    .io_outer_layer_to_node_above_valid(sideband_switch_io_outer_layer_to_node_above_valid),
    .io_outer_layer_to_node_above_bits(sideband_switch_io_outer_layer_to_node_above_bits),
    .io_outer_node_to_layer_below_ready(sideband_switch_io_outer_node_to_layer_below_ready),
    .io_outer_node_to_layer_below_valid(sideband_switch_io_outer_node_to_layer_below_valid),
    .io_outer_node_to_layer_below_bits(sideband_switch_io_outer_node_to_layer_below_bits),
    .io_outer_layer_to_node_below_ready(sideband_switch_io_outer_layer_to_node_below_ready),
    .io_outer_layer_to_node_below_valid(sideband_switch_io_outer_layer_to_node_below_valid),
    .io_outer_layer_to_node_below_bits(sideband_switch_io_outer_layer_to_node_below_bits)
  );
  assign io_rdi_pl_cfg_crd = rdi_sideband_node_io_outer_rx_credit;
  assign io_rdi_lp_cfg = rdi_sideband_node_io_outer_tx_bits;
  assign io_rdi_lp_cfg_vld = rdi_sideband_node_io_outer_tx_valid;
  // Link-mgmt decode never sees ACK/NACK (masked to 0 here); they go to
  // the flit pack instead (edge-detected below).
  wire [5:0] decoded_op = _GEN_33;
  wire dec_strobe = sideband_switch_io_inner_node_to_layer_above_valid &
    sideband_switch_io_inner_node_to_layer_above_ready;
  wire dec_is_ack = dec_strobe && (decoded_op == 6'h2A);
  wire dec_is_nack = dec_strobe && (decoded_op == 6'h2B);
  assign io_sideband_rcv = dec_strobe ?
    ((decoded_op == 6'h2A || decoded_op == 6'h2B) ? 6'h0 : decoded_op) : 6'h0;
  assign io_ack_rx_valid = dec_is_ack && !dec_ack_prev;
  assign io_ack_rx_seq = sideband_switch_io_inner_node_to_layer_above_bits[63:56];
  assign io_nack_rx = dec_is_nack && !dec_nack_prev;
  reg dec_ack_prev;
  reg dec_nack_prev;
  // ACK/NACK TX pending (set by unpack pulses, cleared when taken).
  reg ack_pend;
  reg [7:0] ack_seq_r;
  reg nack_pend;
  wire use_mgmt = (io_sideband_snt != 6'h0);
  wire nack_send = !use_mgmt && nack_pend;
  wire ack_send = !use_mgmt && !nack_pend && ack_pend;
  wire [142:0] ack_tpl = {15'h0, 64'h0, ack_seq_r, 8'h00, 8'h00, 8'h2A,
    10'h080, 8'h04, 9'h0, 1'b1, 4'h2};
  wire [142:0] nack_tpl = {15'h0, 64'h0, 8'h00, 8'h00, 8'h00, 8'h2B,
    10'h080, 8'h04, 9'h0, 1'b1, 4'h2};
  wire below_inner_rdy = sideband_switch_io_inner_layer_to_node_below_ready;
  always @(posedge clock) begin
    if (reset) begin
      dec_ack_prev <= 1'b0;
      dec_nack_prev <= 1'b0;
      ack_pend <= 1'b0;
      ack_seq_r <= 8'h0;
      nack_pend <= 1'b0;
    end else begin
      dec_ack_prev <= dec_is_ack;
      dec_nack_prev <= dec_is_nack;
      if (io_ack_tx_valid) begin
        ack_pend <= 1'b1;
        ack_seq_r <= io_ack_tx_seq;
      end else if (ack_send && below_inner_rdy) begin
        ack_pend <= 1'b0;
      end
      if (io_nack_tx) begin
        nack_pend <= 1'b1;
      end else if (nack_send && below_inner_rdy) begin
        nack_pend <= 1'b0;
      end
    end
  end
  assign io_sideband_rdy = io_sideband_snt != 6'h0 & (sideband_switch_io_inner_layer_to_node_below_valid &
    sideband_switch_io_inner_layer_to_node_below_ready);
  assign fdi_sideband_node_clock = clock;
  assign fdi_sideband_node_reset = reset;
  assign fdi_sideband_node_io_inner_layer_to_node_valid = sideband_switch_io_outer_layer_to_node_above_valid;
  assign fdi_sideband_node_io_inner_layer_to_node_bits = sideband_switch_io_outer_layer_to_node_above_bits;
  assign fdi_sideband_node_io_inner_node_to_layer_ready = sideband_switch_io_outer_node_to_layer_above_ready;
  assign io_fdi_lp_cfg = fdi_sideband_node_io_outer_tx_bits;
  assign io_fdi_lp_cfg_vld = fdi_sideband_node_io_outer_tx_valid;
  assign fdi_sideband_node_io_outer_tx_credit = io_fdi_lp_cfg_crd;
  assign io_fdi_pl_cfg_crd = fdi_sideband_node_io_outer_rx_credit;
  assign fdi_sideband_node_io_outer_rx_bits = io_fdi_pl_cfg;
  assign fdi_sideband_node_io_outer_rx_valid = io_fdi_pl_cfg_vld;
  assign rdi_sideband_node_clock = clock;
  assign rdi_sideband_node_reset = reset;
  assign rdi_sideband_node_io_inner_layer_to_node_valid = sideband_switch_io_outer_layer_to_node_below_valid;
  assign rdi_sideband_node_io_inner_layer_to_node_bits = sideband_switch_io_outer_layer_to_node_below_bits;
  assign rdi_sideband_node_io_inner_node_to_layer_ready = sideband_switch_io_outer_node_to_layer_below_ready;
  assign rdi_sideband_node_io_outer_tx_credit = io_rdi_lp_cfg_crd;
  assign rdi_sideband_node_io_outer_rx_bits = io_rdi_pl_cfg;
  assign rdi_sideband_node_io_outer_rx_valid = io_rdi_pl_cfg_vld;
  assign sideband_switch_io_inner_node_to_layer_above_ready = 1'h1;
  // TX source: link-mgmt template, else pending NACK, else pending ACK.
  assign sideband_switch_io_inner_layer_to_node_below_valid =
    use_mgmt || nack_send || ack_send;
  assign sideband_switch_io_inner_layer_to_node_below_bits = use_mgmt ? _GEN_31[127:0]
    : nack_send ? nack_tpl[127:0] : ack_tpl[127:0];
  assign sideband_switch_io_outer_node_to_layer_above_valid = fdi_sideband_node_io_inner_node_to_layer_valid;
  assign sideband_switch_io_outer_node_to_layer_above_bits = fdi_sideband_node_io_inner_node_to_layer_bits;
  assign sideband_switch_io_outer_layer_to_node_above_ready = fdi_sideband_node_io_inner_layer_to_node_ready;
  assign sideband_switch_io_outer_node_to_layer_below_valid = rdi_sideband_node_io_inner_node_to_layer_valid;
  assign sideband_switch_io_outer_node_to_layer_below_bits = rdi_sideband_node_io_inner_node_to_layer_bits;
  assign sideband_switch_io_outer_layer_to_node_below_ready = rdi_sideband_node_io_inner_layer_to_node_ready;
endmodule
