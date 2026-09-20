module sidebandOneInTwoOutSwitch(
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
  wire  _io_inner_node_to_layer_valid_T_1 = io_outer_node_to_layer_bits[58:56] == 3'h1;
  wire  _io_node_to_node_valid_T_1 = io_outer_node_to_layer_bits[58:56] != 3'h1;
  assign io_outer_node_to_layer_ready = _io_inner_node_to_layer_valid_T_1 ? io_inner_node_to_layer_ready :
    io_node_to_node_ready;
  assign io_inner_node_to_layer_valid = io_outer_node_to_layer_valid & _io_inner_node_to_layer_valid_T_1;
  assign io_inner_node_to_layer_bits = io_outer_node_to_layer_bits;
  assign io_node_to_node_valid = io_outer_node_to_layer_valid & _io_node_to_node_valid_T_1;
  assign io_node_to_node_bits = io_outer_node_to_layer_bits;
endmodule
