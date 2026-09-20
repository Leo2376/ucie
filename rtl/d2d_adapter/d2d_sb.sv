module d2d_sb(
  input         clock,
  input         reset,
  input  [31:0] io_rdi_pl_cfg,
  input         io_rdi_pl_cfg_vld,
  output        io_rdi_pl_cfg_crd,
  output [31:0] io_rdi_lp_cfg,
  output        io_rdi_lp_cfg_vld,
  input         io_rdi_lp_cfg_crd,
  output [5:0]  io_sideband_rcv,
  input  [5:0]  io_sideband_snt,
  output        io_sideband_rdy
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
  assign io_sideband_rcv = sideband_switch_io_inner_node_to_layer_above_valid &
    sideband_switch_io_inner_node_to_layer_above_ready ? _GEN_14 : 6'h0;
  assign io_sideband_rdy = io_sideband_snt != 6'h0 & (sideband_switch_io_inner_layer_to_node_below_valid &
    sideband_switch_io_inner_layer_to_node_below_ready);
  assign fdi_sideband_node_clock = clock;
  assign fdi_sideband_node_reset = reset;
  assign fdi_sideband_node_io_inner_layer_to_node_valid = sideband_switch_io_outer_layer_to_node_above_valid;
  assign fdi_sideband_node_io_inner_layer_to_node_bits = sideband_switch_io_outer_layer_to_node_above_bits;
  assign fdi_sideband_node_io_inner_node_to_layer_ready = sideband_switch_io_outer_node_to_layer_above_ready;
  assign fdi_sideband_node_io_outer_tx_credit = 1'h0;
  assign fdi_sideband_node_io_outer_rx_bits = 32'h0;
  assign fdi_sideband_node_io_outer_rx_valid = 1'h0;
  assign rdi_sideband_node_clock = clock;
  assign rdi_sideband_node_reset = reset;
  assign rdi_sideband_node_io_inner_layer_to_node_valid = sideband_switch_io_outer_layer_to_node_below_valid;
  assign rdi_sideband_node_io_inner_layer_to_node_bits = sideband_switch_io_outer_layer_to_node_below_bits;
  assign rdi_sideband_node_io_inner_node_to_layer_ready = sideband_switch_io_outer_node_to_layer_below_ready;
  assign rdi_sideband_node_io_outer_tx_credit = io_rdi_lp_cfg_crd;
  assign rdi_sideband_node_io_outer_rx_bits = io_rdi_pl_cfg;
  assign rdi_sideband_node_io_outer_rx_valid = io_rdi_pl_cfg_vld;
  assign sideband_switch_io_inner_node_to_layer_above_ready = 1'h1;
  assign sideband_switch_io_inner_layer_to_node_below_valid = io_sideband_snt != 6'h0;
  assign sideband_switch_io_inner_layer_to_node_below_bits = _GEN_31[127:0];
  assign sideband_switch_io_outer_node_to_layer_above_valid = fdi_sideband_node_io_inner_node_to_layer_valid;
  assign sideband_switch_io_outer_node_to_layer_above_bits = fdi_sideband_node_io_inner_node_to_layer_bits;
  assign sideband_switch_io_outer_layer_to_node_above_ready = fdi_sideband_node_io_inner_layer_to_node_ready;
  assign sideband_switch_io_outer_node_to_layer_below_valid = rdi_sideband_node_io_inner_node_to_layer_valid;
  assign sideband_switch_io_outer_node_to_layer_below_bits = rdi_sideband_node_io_inner_node_to_layer_bits;
  assign sideband_switch_io_outer_layer_to_node_below_ready = rdi_sideband_node_io_inner_layer_to_node_ready;
endmodule
