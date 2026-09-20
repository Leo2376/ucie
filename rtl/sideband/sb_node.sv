module sb_node(
  input          clock,
  input          reset,
  output         io_inner_layer_to_node_ready,
  input          io_inner_layer_to_node_valid,
  input  [127:0] io_inner_layer_to_node_bits,
  input          io_inner_node_to_layer_ready,
  output         io_inner_node_to_layer_valid,
  output [127:0] io_inner_node_to_layer_bits,
  output [31:0]  io_outer_tx_bits,
  output         io_outer_tx_valid,
  input          io_outer_tx_credit,
  input  [31:0]  io_outer_rx_bits,
  input          io_outer_rx_valid,
  output         io_outer_rx_credit
);
  wire  tx_ser_clock;
  wire  tx_ser_reset;
  wire  tx_ser_io_in_ready;
  wire  tx_ser_io_in_valid;
  wire [127:0] tx_ser_io_in_bits;
  wire [31:0] tx_ser_io_out_bits;
  wire  tx_ser_io_out_valid;
  wire  tx_ser_io_out_credit;
  wire  rx_queue_clock;
  wire  rx_queue_reset;
  wire  rx_queue_io_enq_valid;
  wire [127:0] rx_queue_io_enq_bits;
  wire  rx_queue_io_deq_ready;
  wire  rx_queue_io_deq_valid;
  wire [127:0] rx_queue_io_deq_bits;
  wire  rx_des_clock;
  wire  rx_des_reset;
  wire [31:0] rx_des_io_in_bits;
  wire  rx_des_io_in_valid;
  wire  rx_des_io_out_valid;
  wire [127:0] rx_des_io_out_bits;
  wire  _io_outer_rx_credit_T = rx_queue_io_deq_ready & rx_queue_io_deq_valid;
  wire [127:0] _io_outer_rx_credit_T_1 = rx_queue_io_deq_bits & 128'h1f;
  wire  _io_outer_rx_credit_T_8 = 128'h10 == _io_outer_rx_credit_T_1 | 128'h11 == _io_outer_rx_credit_T_1 | 128'h19 ==
    _io_outer_rx_credit_T_1;
  sb_ser tx_ser (
    .clock(tx_ser_clock),
    .reset(tx_ser_reset),
    .io_in_ready(tx_ser_io_in_ready),
    .io_in_valid(tx_ser_io_in_valid),
    .io_in_bits(tx_ser_io_in_bits),
    .io_out_bits(tx_ser_io_out_bits),
    .io_out_valid(tx_ser_io_out_valid),
    .io_out_credit(tx_ser_io_out_credit)
  );
  sb_prioq rx_queue (
    .clock(rx_queue_clock),
    .reset(rx_queue_reset),
    .io_enq_valid(rx_queue_io_enq_valid),
    .io_enq_bits(rx_queue_io_enq_bits),
    .io_deq_ready(rx_queue_io_deq_ready),
    .io_deq_valid(rx_queue_io_deq_valid),
    .io_deq_bits(rx_queue_io_deq_bits)
  );
  sb_des rx_des (
    .clock(rx_des_clock),
    .reset(rx_des_reset),
    .io_in_bits(rx_des_io_in_bits),
    .io_in_valid(rx_des_io_in_valid),
    .io_out_valid(rx_des_io_out_valid),
    .io_out_bits(rx_des_io_out_bits)
  );
  assign io_inner_layer_to_node_ready = tx_ser_io_in_ready;
  assign io_inner_node_to_layer_valid = rx_queue_io_deq_valid;
  assign io_inner_node_to_layer_bits = rx_queue_io_deq_bits;
  assign io_outer_tx_bits = tx_ser_io_out_bits;
  assign io_outer_tx_valid = tx_ser_io_out_valid;
  assign io_outer_rx_credit = _io_outer_rx_credit_T & ~_io_outer_rx_credit_T_8;
  assign tx_ser_clock = clock;
  assign tx_ser_reset = reset;
  assign tx_ser_io_in_valid = io_inner_layer_to_node_valid;
  assign tx_ser_io_in_bits = io_inner_layer_to_node_bits;
  assign tx_ser_io_out_credit = io_outer_tx_credit;
  assign rx_queue_clock = clock;
  assign rx_queue_reset = reset;
  assign rx_queue_io_enq_valid = rx_des_io_out_valid;
  assign rx_queue_io_enq_bits = rx_des_io_out_bits;
  assign rx_queue_io_deq_ready = io_inner_node_to_layer_ready;
  assign rx_des_clock = clock;
  assign rx_des_reset = reset;
  assign rx_des_io_in_bits = io_outer_rx_bits;
  assign rx_des_io_in_valid = io_outer_rx_valid;
endmodule
