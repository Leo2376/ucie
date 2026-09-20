module sidebandTwoInOneOutSwitch(
  input          io_outer_layer_to_node_ready,
  output         io_outer_layer_to_node_valid,
  output [127:0] io_outer_layer_to_node_bits,
  output         io_inner_layer_to_node_ready,
  input          io_inner_layer_to_node_valid,
  input  [127:0] io_inner_layer_to_node_bits,
  output         io_node_to_node_ready,
  input          io_node_to_node_valid,
  input  [127:0] io_node_to_node_bits
);
  wire [127:0] _priority_node_to_node_T = io_node_to_node_bits & 128'h1f;
  wire  _priority_node_to_node_T_7 = 128'h10 == _priority_node_to_node_T | 128'h11 == _priority_node_to_node_T | 128'h19
     == _priority_node_to_node_T;
  wire  _priority_node_to_node_T_12 = 128'h12 == _priority_node_to_node_T | 128'h1b == _priority_node_to_node_T;
  wire [1:0] _priority_node_to_node_T_13 = _priority_node_to_node_T_12 ? 2'h1 : 2'h2;
  wire [1:0] priority_node_to_node = _priority_node_to_node_T_7 ? 2'h0 : _priority_node_to_node_T_13;
  wire [127:0] _priority_inner_layer_to_node_T = io_inner_layer_to_node_bits & 128'h1f;
  wire  _priority_inner_layer_to_node_T_7 = 128'h10 == _priority_inner_layer_to_node_T | 128'h11 ==
    _priority_inner_layer_to_node_T | 128'h19 == _priority_inner_layer_to_node_T;
  wire  _priority_inner_layer_to_node_T_12 = 128'h12 == _priority_inner_layer_to_node_T | 128'h1b ==
    _priority_inner_layer_to_node_T;
  wire [1:0] _priority_inner_layer_to_node_T_13 = _priority_inner_layer_to_node_T_12 ? 2'h1 : 2'h2;
  wire [1:0] priority_inner_layer_to_node = _priority_inner_layer_to_node_T_7 ? 2'h0 :
    _priority_inner_layer_to_node_T_13;
  wire  _flag_T = io_node_to_node_valid & io_inner_layer_to_node_valid;
  wire  _flag_T_1 = priority_inner_layer_to_node > priority_node_to_node;
  wire  flag = _flag_T ? _flag_T_1 : io_node_to_node_valid;
  assign io_outer_layer_to_node_valid = io_node_to_node_valid | io_inner_layer_to_node_valid;
  assign io_outer_layer_to_node_bits = flag ? io_node_to_node_bits : io_inner_layer_to_node_bits;
  assign io_inner_layer_to_node_ready = flag ? 1'h0 : io_outer_layer_to_node_ready;
  assign io_node_to_node_ready = flag & io_outer_layer_to_node_ready;
endmodule
