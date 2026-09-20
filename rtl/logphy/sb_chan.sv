module sb_chan(
  input          clock,
  input          reset,
  output [31:0]  io_to_upper_layer_tx_bits,
  output         io_to_upper_layer_tx_valid,
  input          io_to_upper_layer_tx_credit,
  input  [31:0]  io_to_upper_layer_rx_bits,
  input          io_to_upper_layer_rx_valid,
  output         io_to_upper_layer_rx_credit,
  output         io_to_lower_layer_tx_bits,
  output         io_to_lower_layer_tx_clock,
  input          io_to_lower_layer_rx_bits,
  input          io_to_lower_layer_rx_clock,
  input          io_inner_inputMode,
  input          io_inner_rxMode,
  output         io_inner_rawInput_ready,
  input          io_inner_rawInput_valid,
  input  [127:0] io_inner_rawInput_bits,
  input          io_inner_switcherBundle_node_to_layer_below_ready,
  output         io_inner_switcherBundle_node_to_layer_below_valid,
  output [127:0] io_inner_switcherBundle_node_to_layer_below_bits,
  output         io_inner_switcherBundle_layer_to_node_below_ready,
  input          io_inner_switcherBundle_layer_to_node_below_valid,
  input  [127:0] io_inner_switcherBundle_layer_to_node_below_bits
);
  wire  upper_node_clock;
  wire  upper_node_reset;
  wire  upper_node_io_inner_layer_to_node_ready;
  wire  upper_node_io_inner_layer_to_node_valid;
  wire [127:0] upper_node_io_inner_layer_to_node_bits;
  wire  upper_node_io_inner_node_to_layer_ready;
  wire  upper_node_io_inner_node_to_layer_valid;
  wire [127:0] upper_node_io_inner_node_to_layer_bits;
  wire [31:0] upper_node_io_outer_tx_bits;
  wire  upper_node_io_outer_tx_valid;
  wire  upper_node_io_outer_tx_credit;
  wire [31:0] upper_node_io_outer_rx_bits;
  wire  upper_node_io_outer_rx_valid;
  wire  upper_node_io_outer_rx_credit;
  wire  switcher_io_inner_node_to_layer_below_ready;
  wire  switcher_io_inner_node_to_layer_below_valid;
  wire [127:0] switcher_io_inner_node_to_layer_below_bits;
  wire  switcher_io_inner_layer_to_node_below_ready;
  wire  switcher_io_inner_layer_to_node_below_valid;
  wire [127:0] switcher_io_inner_layer_to_node_below_bits;
  wire  switcher_io_outer_node_to_layer_above_ready;
  wire  switcher_io_outer_node_to_layer_above_valid;
  wire [127:0] switcher_io_outer_node_to_layer_above_bits;
  wire  switcher_io_outer_layer_to_node_above_ready;
  wire  switcher_io_outer_layer_to_node_above_valid;
  wire [127:0] switcher_io_outer_layer_to_node_above_bits;
  wire  switcher_io_outer_node_to_layer_below_ready;
  wire  switcher_io_outer_node_to_layer_below_valid;
  wire [127:0] switcher_io_outer_node_to_layer_below_bits;
  wire  switcher_io_outer_layer_to_node_below_ready;
  wire  switcher_io_outer_layer_to_node_below_valid;
  wire [127:0] switcher_io_outer_layer_to_node_below_bits;
  wire  lower_node_clock;
  wire  lower_node_reset;
  wire  lower_node_io_rxMode;
  wire  lower_node_io_inner_layer_to_node_ready;
  wire  lower_node_io_inner_layer_to_node_valid;
  wire [127:0] lower_node_io_inner_layer_to_node_bits;
  wire  lower_node_io_inner_node_to_layer_ready;
  wire  lower_node_io_inner_node_to_layer_valid;
  wire [127:0] lower_node_io_inner_node_to_layer_bits;
  wire  lower_node_io_outer_tx_bits;
  wire  lower_node_io_outer_tx_clock;
  wire  lower_node_io_outer_rx_bits;
  wire  lower_node_io_outer_rx_clock;
  sb_node upper_node (
    .clock(upper_node_clock),
    .reset(upper_node_reset),
    .io_inner_layer_to_node_ready(upper_node_io_inner_layer_to_node_ready),
    .io_inner_layer_to_node_valid(upper_node_io_inner_layer_to_node_valid),
    .io_inner_layer_to_node_bits(upper_node_io_inner_layer_to_node_bits),
    .io_inner_node_to_layer_ready(upper_node_io_inner_node_to_layer_ready),
    .io_inner_node_to_layer_valid(upper_node_io_inner_node_to_layer_valid),
    .io_inner_node_to_layer_bits(upper_node_io_inner_node_to_layer_bits),
    .io_outer_tx_bits(upper_node_io_outer_tx_bits),
    .io_outer_tx_valid(upper_node_io_outer_tx_valid),
    .io_outer_tx_credit(upper_node_io_outer_tx_credit),
    .io_outer_rx_bits(upper_node_io_outer_rx_bits),
    .io_outer_rx_valid(upper_node_io_outer_rx_valid),
    .io_outer_rx_credit(upper_node_io_outer_rx_credit)
  );
  sidebandSwitcher_1 switcher (
    .io_inner_node_to_layer_below_ready(switcher_io_inner_node_to_layer_below_ready),
    .io_inner_node_to_layer_below_valid(switcher_io_inner_node_to_layer_below_valid),
    .io_inner_node_to_layer_below_bits(switcher_io_inner_node_to_layer_below_bits),
    .io_inner_layer_to_node_below_ready(switcher_io_inner_layer_to_node_below_ready),
    .io_inner_layer_to_node_below_valid(switcher_io_inner_layer_to_node_below_valid),
    .io_inner_layer_to_node_below_bits(switcher_io_inner_layer_to_node_below_bits),
    .io_outer_node_to_layer_above_ready(switcher_io_outer_node_to_layer_above_ready),
    .io_outer_node_to_layer_above_valid(switcher_io_outer_node_to_layer_above_valid),
    .io_outer_node_to_layer_above_bits(switcher_io_outer_node_to_layer_above_bits),
    .io_outer_layer_to_node_above_ready(switcher_io_outer_layer_to_node_above_ready),
    .io_outer_layer_to_node_above_valid(switcher_io_outer_layer_to_node_above_valid),
    .io_outer_layer_to_node_above_bits(switcher_io_outer_layer_to_node_above_bits),
    .io_outer_node_to_layer_below_ready(switcher_io_outer_node_to_layer_below_ready),
    .io_outer_node_to_layer_below_valid(switcher_io_outer_node_to_layer_below_valid),
    .io_outer_node_to_layer_below_bits(switcher_io_outer_node_to_layer_below_bits),
    .io_outer_layer_to_node_below_ready(switcher_io_outer_layer_to_node_below_ready),
    .io_outer_layer_to_node_below_valid(switcher_io_outer_layer_to_node_below_valid),
    .io_outer_layer_to_node_below_bits(switcher_io_outer_layer_to_node_below_bits)
  );
  sb_lnode lower_node (
    .clock(lower_node_clock),
    .reset(lower_node_reset),
    .io_rxMode(lower_node_io_rxMode),
    .io_inner_layer_to_node_ready(lower_node_io_inner_layer_to_node_ready),
    .io_inner_layer_to_node_valid(lower_node_io_inner_layer_to_node_valid),
    .io_inner_layer_to_node_bits(lower_node_io_inner_layer_to_node_bits),
    .io_inner_node_to_layer_ready(lower_node_io_inner_node_to_layer_ready),
    .io_inner_node_to_layer_valid(lower_node_io_inner_node_to_layer_valid),
    .io_inner_node_to_layer_bits(lower_node_io_inner_node_to_layer_bits),
    .io_outer_tx_bits(lower_node_io_outer_tx_bits),
    .io_outer_tx_clock(lower_node_io_outer_tx_clock),
    .io_outer_rx_bits(lower_node_io_outer_rx_bits),
    .io_outer_rx_clock(lower_node_io_outer_rx_clock)
  );
  assign io_to_upper_layer_tx_bits = upper_node_io_outer_tx_bits;
  assign io_to_upper_layer_tx_valid = upper_node_io_outer_tx_valid;
  assign io_to_upper_layer_rx_credit = upper_node_io_outer_rx_credit;
  assign io_to_lower_layer_tx_bits = lower_node_io_outer_tx_bits;
  assign io_to_lower_layer_tx_clock = lower_node_io_outer_tx_clock;
  assign io_inner_rawInput_ready = io_inner_inputMode ? 1'h0 : lower_node_io_inner_layer_to_node_ready;
  assign io_inner_switcherBundle_node_to_layer_below_valid = switcher_io_inner_node_to_layer_below_valid;
  assign io_inner_switcherBundle_node_to_layer_below_bits = switcher_io_inner_node_to_layer_below_bits;
  assign io_inner_switcherBundle_layer_to_node_below_ready = switcher_io_inner_layer_to_node_below_ready;
  assign upper_node_clock = clock;
  assign upper_node_reset = reset;
  assign upper_node_io_inner_layer_to_node_valid = switcher_io_outer_layer_to_node_above_valid;
  assign upper_node_io_inner_layer_to_node_bits = switcher_io_outer_layer_to_node_above_bits;
  assign upper_node_io_inner_node_to_layer_ready = switcher_io_outer_node_to_layer_above_ready;
  assign upper_node_io_outer_tx_credit = io_to_upper_layer_tx_credit;
  assign upper_node_io_outer_rx_bits = io_to_upper_layer_rx_bits;
  assign upper_node_io_outer_rx_valid = io_to_upper_layer_rx_valid;
  assign switcher_io_inner_node_to_layer_below_ready = io_inner_switcherBundle_node_to_layer_below_ready;
  assign switcher_io_inner_layer_to_node_below_valid = io_inner_switcherBundle_layer_to_node_below_valid;
  assign switcher_io_inner_layer_to_node_below_bits = io_inner_switcherBundle_layer_to_node_below_bits;
  assign switcher_io_outer_node_to_layer_above_valid = upper_node_io_inner_node_to_layer_valid;
  assign switcher_io_outer_node_to_layer_above_bits = upper_node_io_inner_node_to_layer_bits;
  assign switcher_io_outer_layer_to_node_above_ready = upper_node_io_inner_layer_to_node_ready;
  assign switcher_io_outer_node_to_layer_below_valid = lower_node_io_inner_node_to_layer_valid;
  assign switcher_io_outer_node_to_layer_below_bits = lower_node_io_inner_node_to_layer_bits;
  assign switcher_io_outer_layer_to_node_below_ready = io_inner_inputMode & lower_node_io_inner_layer_to_node_ready;
  assign lower_node_clock = clock;
  assign lower_node_reset = reset;
  assign lower_node_io_rxMode = io_inner_rxMode;
  assign lower_node_io_inner_layer_to_node_valid = io_inner_inputMode ? switcher_io_outer_layer_to_node_below_valid :
    io_inner_rawInput_valid;
  assign lower_node_io_inner_layer_to_node_bits = io_inner_inputMode ? switcher_io_outer_layer_to_node_below_bits :
    io_inner_rawInput_bits;
  assign lower_node_io_inner_node_to_layer_ready = switcher_io_outer_node_to_layer_below_ready;
  assign lower_node_io_outer_rx_bits = io_to_lower_layer_rx_bits;
  assign lower_node_io_outer_rx_clock = io_to_lower_layer_rx_clock;
endmodule
