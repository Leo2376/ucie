module sb_lnode(
  input          clock,
  input          reset,
  input          io_rxMode,
  output         io_inner_layer_to_node_ready,
  input          io_inner_layer_to_node_valid,
  input  [127:0] io_inner_layer_to_node_bits,
  input          io_inner_node_to_layer_ready,
  output         io_inner_node_to_layer_valid,
  output [127:0] io_inner_node_to_layer_bits,
  output         io_outer_tx_bits,
  output         io_outer_tx_clock,
  input          io_outer_rx_bits,
  input          io_outer_rx_clock
);
  wire  tx_ser_clock;
  wire  tx_ser_reset;
  wire  tx_ser_io_in_ready;
  wire  tx_ser_io_in_valid;
  wire [127:0] tx_ser_io_in_bits;
  wire  tx_ser_io_out_bits;
  wire  tx_ser_io_out_clock;
  wire  rx_des_clock;
  wire  rx_des_reset;
  wire  rx_des_io_in_bits;
  wire  rx_des_io_in_remote_clock;
  wire  rx_des_io_out_ready;
  wire  rx_des_io_out_valid;
  wire [127:0] rx_des_io_out_bits;
  wire  rx_queue_clock;
  wire  rx_queue_reset;
  wire  rx_queue_io_enq_valid;
  wire [127:0] rx_queue_io_enq_bits;
  wire  rx_queue_io_deq_ready;
  wire  rx_queue_io_deq_valid;
  wire [127:0] rx_queue_io_deq_bits;
  wire [69:0] tx_ser_io_in_bits_hi = {io_inner_layer_to_node_bits[127:59],1'h0};
  sb_lser tx_ser (
    .clock(tx_ser_clock),
    .reset(tx_ser_reset),
    .io_in_ready(tx_ser_io_in_ready),
    .io_in_valid(tx_ser_io_in_valid),
    .io_in_bits(tx_ser_io_in_bits),
    .io_out_bits(tx_ser_io_out_bits),
    .io_out_clock(tx_ser_io_out_clock)
  );
  sb_ldes rx_des (
    .clock(rx_des_clock),
    .reset(rx_des_reset),
    .io_in_bits(rx_des_io_in_bits),
    .io_in_remote_clock(rx_des_io_in_remote_clock),
    .io_out_ready(rx_des_io_out_ready),
    .io_out_valid(rx_des_io_out_valid),
    .io_out_bits(rx_des_io_out_bits)
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
  assign io_inner_layer_to_node_ready = tx_ser_io_in_ready;
  assign io_inner_node_to_layer_valid = io_rxMode ? rx_queue_io_deq_valid : rx_des_io_out_valid;
  assign io_inner_node_to_layer_bits = io_rxMode ? rx_queue_io_deq_bits : rx_des_io_out_bits;
  assign io_outer_tx_bits = tx_ser_io_out_bits;
  assign io_outer_tx_clock = tx_ser_io_out_clock;
  assign tx_ser_clock = clock;
  assign tx_ser_reset = reset;
  assign tx_ser_io_in_valid = io_inner_layer_to_node_valid;
  assign tx_ser_io_in_bits = {tx_ser_io_in_bits_hi,io_inner_layer_to_node_bits[57:0]};
  assign rx_des_clock = clock;
  assign rx_des_reset = reset;
  assign rx_des_io_in_bits = io_outer_rx_bits;
  assign rx_des_io_in_remote_clock = io_outer_rx_clock;
  assign rx_des_io_out_ready = io_rxMode | io_inner_node_to_layer_ready;
  assign rx_queue_clock = clock;
  assign rx_queue_reset = reset;
  assign rx_queue_io_enq_valid = io_rxMode & rx_des_io_out_valid;
  assign rx_queue_io_enq_bits = rx_des_io_out_bits;
  assign rx_queue_io_deq_ready = io_rxMode & io_inner_node_to_layer_ready;
endmodule
