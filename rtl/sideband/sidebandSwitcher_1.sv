module sidebandSwitcher_1(
  input          io_inner_node_to_layer_below_ready,
  output         io_inner_node_to_layer_below_valid,
  output [127:0] io_inner_node_to_layer_below_bits,
  output         io_inner_layer_to_node_below_ready,
  input          io_inner_layer_to_node_below_valid,
  input  [127:0] io_inner_layer_to_node_below_bits,
  output         io_outer_node_to_layer_above_ready,
  input          io_outer_node_to_layer_above_valid,
  input  [127:0] io_outer_node_to_layer_above_bits,
  input          io_outer_layer_to_node_above_ready,
  output         io_outer_layer_to_node_above_valid,
  output [127:0] io_outer_layer_to_node_above_bits,
  output         io_outer_node_to_layer_below_ready,
  input          io_outer_node_to_layer_below_valid,
  input  [127:0] io_outer_node_to_layer_below_bits,
  input          io_outer_layer_to_node_below_ready,
  output         io_outer_layer_to_node_below_valid,
  output [127:0] io_outer_layer_to_node_below_bits
);
  wire  outer_node_to_layer_below_subswitch_io_outer_node_to_layer_ready;
  wire  outer_node_to_layer_below_subswitch_io_outer_node_to_layer_valid;
  wire [127:0] outer_node_to_layer_below_subswitch_io_outer_node_to_layer_bits;
  wire  outer_node_to_layer_below_subswitch_io_inner_node_to_layer_ready;
  wire  outer_node_to_layer_below_subswitch_io_inner_node_to_layer_valid;
  wire [127:0] outer_node_to_layer_below_subswitch_io_inner_node_to_layer_bits;
  wire  outer_node_to_layer_below_subswitch_io_node_to_node_ready;
  wire  outer_node_to_layer_below_subswitch_io_node_to_node_valid;
  wire [127:0] outer_node_to_layer_below_subswitch_io_node_to_node_bits;
  wire  outer_node_to_layer_above_subswitch_io_outer_node_to_layer_ready;
  wire  outer_node_to_layer_above_subswitch_io_outer_node_to_layer_valid;
  wire [127:0] outer_node_to_layer_above_subswitch_io_outer_node_to_layer_bits;
  wire  outer_node_to_layer_above_subswitch_io_inner_node_to_layer_ready;
  wire  outer_node_to_layer_above_subswitch_io_inner_node_to_layer_valid;
  wire [127:0] outer_node_to_layer_above_subswitch_io_inner_node_to_layer_bits;
  wire  outer_node_to_layer_above_subswitch_io_node_to_node_ready;
  wire  outer_node_to_layer_above_subswitch_io_node_to_node_valid;
  wire [127:0] outer_node_to_layer_above_subswitch_io_node_to_node_bits;
  wire  outer_layer_to_node_above_subswitch_io_outer_layer_to_node_ready;
  wire  outer_layer_to_node_above_subswitch_io_outer_layer_to_node_valid;
  wire [127:0] outer_layer_to_node_above_subswitch_io_outer_layer_to_node_bits;
  wire  outer_layer_to_node_above_subswitch_io_inner_layer_to_node_ready;
  wire  outer_layer_to_node_above_subswitch_io_inner_layer_to_node_valid;
  wire [127:0] outer_layer_to_node_above_subswitch_io_inner_layer_to_node_bits;
  wire  outer_layer_to_node_above_subswitch_io_node_to_node_ready;
  wire  outer_layer_to_node_above_subswitch_io_node_to_node_valid;
  wire [127:0] outer_layer_to_node_above_subswitch_io_node_to_node_bits;
  wire  outer_layer_to_node_below_subswitch_io_outer_layer_to_node_ready;
  wire  outer_layer_to_node_below_subswitch_io_outer_layer_to_node_valid;
  wire [127:0] outer_layer_to_node_below_subswitch_io_outer_layer_to_node_bits;
  wire  outer_layer_to_node_below_subswitch_io_inner_layer_to_node_ready;
  wire  outer_layer_to_node_below_subswitch_io_inner_layer_to_node_valid;
  wire [127:0] outer_layer_to_node_below_subswitch_io_inner_layer_to_node_bits;
  wire  outer_layer_to_node_below_subswitch_io_node_to_node_ready;
  wire  outer_layer_to_node_below_subswitch_io_node_to_node_valid;
  wire [127:0] outer_layer_to_node_below_subswitch_io_node_to_node_bits;
  sidebandOneInTwoOutSwitch_2 #(.ROUTE_TRAIN(1)) outer_node_to_layer_below_subswitch (
    .io_outer_node_to_layer_ready(outer_node_to_layer_below_subswitch_io_outer_node_to_layer_ready),
    .io_outer_node_to_layer_valid(outer_node_to_layer_below_subswitch_io_outer_node_to_layer_valid),
    .io_outer_node_to_layer_bits(outer_node_to_layer_below_subswitch_io_outer_node_to_layer_bits),
    .io_inner_node_to_layer_ready(outer_node_to_layer_below_subswitch_io_inner_node_to_layer_ready),
    .io_inner_node_to_layer_valid(outer_node_to_layer_below_subswitch_io_inner_node_to_layer_valid),
    .io_inner_node_to_layer_bits(outer_node_to_layer_below_subswitch_io_inner_node_to_layer_bits),
    .io_node_to_node_ready(outer_node_to_layer_below_subswitch_io_node_to_node_ready),
    .io_node_to_node_valid(outer_node_to_layer_below_subswitch_io_node_to_node_valid),
    .io_node_to_node_bits(outer_node_to_layer_below_subswitch_io_node_to_node_bits)
  );
  sidebandOneInTwoOutSwitch_2 #(.ROUTE_TRAIN(1)) outer_node_to_layer_above_subswitch (
    .io_outer_node_to_layer_ready(outer_node_to_layer_above_subswitch_io_outer_node_to_layer_ready),
    .io_outer_node_to_layer_valid(outer_node_to_layer_above_subswitch_io_outer_node_to_layer_valid),
    .io_outer_node_to_layer_bits(outer_node_to_layer_above_subswitch_io_outer_node_to_layer_bits),
    .io_inner_node_to_layer_ready(outer_node_to_layer_above_subswitch_io_inner_node_to_layer_ready),
    .io_inner_node_to_layer_valid(outer_node_to_layer_above_subswitch_io_inner_node_to_layer_valid),
    .io_inner_node_to_layer_bits(outer_node_to_layer_above_subswitch_io_inner_node_to_layer_bits),
    .io_node_to_node_ready(outer_node_to_layer_above_subswitch_io_node_to_node_ready),
    .io_node_to_node_valid(outer_node_to_layer_above_subswitch_io_node_to_node_valid),
    .io_node_to_node_bits(outer_node_to_layer_above_subswitch_io_node_to_node_bits)
  );
  sidebandTwoInOneOutSwitch outer_layer_to_node_above_subswitch (
    .io_outer_layer_to_node_ready(outer_layer_to_node_above_subswitch_io_outer_layer_to_node_ready),
    .io_outer_layer_to_node_valid(outer_layer_to_node_above_subswitch_io_outer_layer_to_node_valid),
    .io_outer_layer_to_node_bits(outer_layer_to_node_above_subswitch_io_outer_layer_to_node_bits),
    .io_inner_layer_to_node_ready(outer_layer_to_node_above_subswitch_io_inner_layer_to_node_ready),
    .io_inner_layer_to_node_valid(outer_layer_to_node_above_subswitch_io_inner_layer_to_node_valid),
    .io_inner_layer_to_node_bits(outer_layer_to_node_above_subswitch_io_inner_layer_to_node_bits),
    .io_node_to_node_ready(outer_layer_to_node_above_subswitch_io_node_to_node_ready),
    .io_node_to_node_valid(outer_layer_to_node_above_subswitch_io_node_to_node_valid),
    .io_node_to_node_bits(outer_layer_to_node_above_subswitch_io_node_to_node_bits)
  );
  sidebandTwoInOneOutSwitch outer_layer_to_node_below_subswitch (
    .io_outer_layer_to_node_ready(outer_layer_to_node_below_subswitch_io_outer_layer_to_node_ready),
    .io_outer_layer_to_node_valid(outer_layer_to_node_below_subswitch_io_outer_layer_to_node_valid),
    .io_outer_layer_to_node_bits(outer_layer_to_node_below_subswitch_io_outer_layer_to_node_bits),
    .io_inner_layer_to_node_ready(outer_layer_to_node_below_subswitch_io_inner_layer_to_node_ready),
    .io_inner_layer_to_node_valid(outer_layer_to_node_below_subswitch_io_inner_layer_to_node_valid),
    .io_inner_layer_to_node_bits(outer_layer_to_node_below_subswitch_io_inner_layer_to_node_bits),
    .io_node_to_node_ready(outer_layer_to_node_below_subswitch_io_node_to_node_ready),
    .io_node_to_node_valid(outer_layer_to_node_below_subswitch_io_node_to_node_valid),
    .io_node_to_node_bits(outer_layer_to_node_below_subswitch_io_node_to_node_bits)
  );
  assign io_inner_node_to_layer_below_valid = outer_node_to_layer_below_subswitch_io_inner_node_to_layer_valid;
  assign io_inner_node_to_layer_below_bits = outer_node_to_layer_below_subswitch_io_inner_node_to_layer_bits;
  assign io_inner_layer_to_node_below_ready = outer_layer_to_node_below_subswitch_io_inner_layer_to_node_ready;
  assign io_outer_node_to_layer_above_ready = outer_node_to_layer_above_subswitch_io_outer_node_to_layer_ready;
  assign io_outer_layer_to_node_above_valid = outer_layer_to_node_above_subswitch_io_outer_layer_to_node_valid;
  assign io_outer_layer_to_node_above_bits = outer_layer_to_node_above_subswitch_io_outer_layer_to_node_bits;
  assign io_outer_node_to_layer_below_ready = outer_node_to_layer_below_subswitch_io_outer_node_to_layer_ready;
  assign io_outer_layer_to_node_below_valid = outer_layer_to_node_below_subswitch_io_outer_layer_to_node_valid;
  assign io_outer_layer_to_node_below_bits = outer_layer_to_node_below_subswitch_io_outer_layer_to_node_bits;
  assign outer_node_to_layer_below_subswitch_io_outer_node_to_layer_valid = io_outer_node_to_layer_below_valid;
  assign outer_node_to_layer_below_subswitch_io_outer_node_to_layer_bits = io_outer_node_to_layer_below_bits;
  assign outer_node_to_layer_below_subswitch_io_inner_node_to_layer_ready = io_inner_node_to_layer_below_ready;
  assign outer_node_to_layer_below_subswitch_io_node_to_node_ready =
    outer_layer_to_node_above_subswitch_io_node_to_node_ready;
  assign outer_node_to_layer_above_subswitch_io_outer_node_to_layer_valid = io_outer_node_to_layer_above_valid;
  assign outer_node_to_layer_above_subswitch_io_outer_node_to_layer_bits = io_outer_node_to_layer_above_bits;
  assign outer_node_to_layer_above_subswitch_io_inner_node_to_layer_ready = 1'h0;
  assign outer_node_to_layer_above_subswitch_io_node_to_node_ready =
    outer_layer_to_node_below_subswitch_io_node_to_node_ready;
  assign outer_layer_to_node_above_subswitch_io_outer_layer_to_node_ready = io_outer_layer_to_node_above_ready;
  assign outer_layer_to_node_above_subswitch_io_inner_layer_to_node_valid = 1'h0;
  assign outer_layer_to_node_above_subswitch_io_inner_layer_to_node_bits = 128'h0;
  assign outer_layer_to_node_above_subswitch_io_node_to_node_valid =
    outer_node_to_layer_below_subswitch_io_node_to_node_valid;
  assign outer_layer_to_node_above_subswitch_io_node_to_node_bits =
    outer_node_to_layer_below_subswitch_io_node_to_node_bits;
  assign outer_layer_to_node_below_subswitch_io_outer_layer_to_node_ready = io_outer_layer_to_node_below_ready;
  assign outer_layer_to_node_below_subswitch_io_inner_layer_to_node_valid = io_inner_layer_to_node_below_valid;
  assign outer_layer_to_node_below_subswitch_io_inner_layer_to_node_bits = io_inner_layer_to_node_below_bits;
  assign outer_layer_to_node_below_subswitch_io_node_to_node_valid =
    outer_node_to_layer_above_subswitch_io_node_to_node_valid;
  assign outer_layer_to_node_below_subswitch_io_node_to_node_bits =
    outer_node_to_layer_above_subswitch_io_node_to_node_bits;
endmodule
