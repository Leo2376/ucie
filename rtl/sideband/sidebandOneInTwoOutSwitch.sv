module sidebandOneInTwoOutSwitch #(
  parameter ROUTE_ALL_INNER = 0
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
  // Legacy rule (ROUTE_ALL_INNER=0): inner iff bits[58:56]==1. No defined
  // packet satisfies that, so the D2D receive-decode path is unreachable
  // (lnk submodules can send but never hear the partner).
  // Fixed rule (ROUTE_ALL_INNER=1, RDI-side instance in d2d_sb only):
  // everything from RDI goes to decode; the node_to_node leg is a dead
  // end there (FDI outer RX is tied off), and unknown packets decode
  // to opcode 0 = ignored.
  wire  _legacy_inner = io_outer_node_to_layer_bits[58:56] == 3'h1;
  wire  _io_inner_node_to_layer_valid_T_1 = ROUTE_ALL_INNER ? 1'h1 : _legacy_inner;
  wire  _io_node_to_node_valid_T_1 = ROUTE_ALL_INNER ? 1'h0 : ~_legacy_inner;
  assign io_outer_node_to_layer_ready = _io_inner_node_to_layer_valid_T_1 ? io_inner_node_to_layer_ready :
    io_node_to_node_ready;
  assign io_inner_node_to_layer_valid = io_outer_node_to_layer_valid & _io_inner_node_to_layer_valid_T_1;
  assign io_inner_node_to_layer_bits = io_outer_node_to_layer_bits;
  assign io_node_to_node_valid = io_outer_node_to_layer_valid & _io_node_to_node_valid_T_1;
  assign io_node_to_node_bits = io_outer_node_to_layer_bits;
endmodule
