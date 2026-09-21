module sidebandOneInTwoOutSwitch_2 #(
  parameter ROUTE_TRAIN = 0
)(
  output         io_outer_node_to_layer_ready,
  input          io_outer_node_to_layer_valid,
  input  [127:0] io_outer_node_to_layer_bits,
  input          io_inner_node_to_layer_ready,
  output         io_inner_node_to_layer_valid,
  output [127:0] io_inner_node_to_layer_bits,
  input          io_node_to_node_ready,
  output         io_node_to_node_valid,
  output [127:0] io_node_to_node_bits
);
  // Legacy rule (ROUTE_TRAIN=0): inner iff bits[58:56]==0. No defined
  // packet satisfies that, so the training RX path is unreachable.
  // Fixed rule (ROUTE_TRAIN=1, serial-RX instance only): training-domain
  // messages (0600 SBINIT, 0200 bringup, 0002 MBINIT) and non-message
  // packets (patterns, [4:0] not 12/1b) go inner; D2D-domain messages
  // (0500 mgmt, PARAM shape) go up. In train state 4+ the training
  // consumers gate RX off, so stray inner-routed packets are dropped.
  wire is_msg = (io_outer_node_to_layer_bits[4:0] == 5'h12) |
                (io_outer_node_to_layer_bits[4:0] == 5'h1b);
  wire train_domain = (io_outer_node_to_layer_bits[63:48] == 16'h0600) |
                      (io_outer_node_to_layer_bits[63:48] == 16'h0200) |
                      (io_outer_node_to_layer_bits[63:48] == 16'h0002);
  wire route_inner = ROUTE_TRAIN ? (train_domain | ~is_msg) :
    (io_outer_node_to_layer_bits[58:56] == 3'h0);
  wire  _io_inner_node_to_layer_valid_T_1 = route_inner;
  wire  _io_node_to_node_valid_T_1 = ~route_inner;
  assign io_outer_node_to_layer_ready = _io_inner_node_to_layer_valid_T_1 ? io_inner_node_to_layer_ready :
    io_node_to_node_ready;
  assign io_inner_node_to_layer_valid = io_outer_node_to_layer_valid & _io_inner_node_to_layer_valid_T_1;
  assign io_inner_node_to_layer_bits = io_outer_node_to_layer_bits;
  assign io_node_to_node_valid = io_outer_node_to_layer_valid & _io_node_to_node_valid_T_1;
  assign io_node_to_node_bits = io_outer_node_to_layer_bits;
endmodule
