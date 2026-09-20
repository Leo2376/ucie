module Lanes(
  input         clock,
  input         reset,
  input         io_mainbandIo_fifoParams_clk,
  input         io_mainbandIo_fifoParams_reset,
  input         io_mainbandIo_txData_ready,
  output        io_mainbandIo_txData_valid,
  output [15:0] io_mainbandIo_txData_bits_0,
  output        io_mainbandIo_rxData_ready,
  input         io_mainbandIo_rxData_valid,
  input  [15:0] io_mainbandIo_rxData_bits_0,
  output        io_mainbandLaneIO_txData_ready,
  input         io_mainbandLaneIO_txData_valid,
  input  [15:0] io_mainbandLaneIO_txData_bits,
  output        io_mainbandLaneIO_rxData_valid,
  output [15:0] io_mainbandLaneIO_rxData_bits
);
  wire  txMBFifo_io_enq_clock;
  wire  txMBFifo_io_enq_reset;
  wire  txMBFifo_io_enq_ready;
  wire  txMBFifo_io_enq_valid;
  wire [15:0] txMBFifo_io_enq_bits_0;
  wire  txMBFifo_io_deq_clock;
  wire  txMBFifo_io_deq_reset;
  wire  txMBFifo_io_deq_ready;
  wire  txMBFifo_io_deq_valid;
  wire [15:0] txMBFifo_io_deq_bits_0;
  wire  rxMBFifo_io_enq_clock;
  wire  rxMBFifo_io_enq_reset;
  wire  rxMBFifo_io_enq_ready;
  wire  rxMBFifo_io_enq_valid;
  wire [15:0] rxMBFifo_io_enq_bits_0;
  wire  rxMBFifo_io_deq_clock;
  wire  rxMBFifo_io_deq_reset;
  wire  rxMBFifo_io_deq_valid;
  wire [15:0] rxMBFifo_io_deq_bits_0;
  wire [7:0] txDataVec_0_0 = io_mainbandLaneIO_txData_bits[7:0];
  wire [7:0] rxDataVec_0_0 = rxMBFifo_io_deq_bits_0[7:0];
  wire [7:0] txDataVec_0_1 = io_mainbandLaneIO_txData_bits[15:8];
  wire [7:0] rxDataVec_1_0 = rxMBFifo_io_deq_bits_0[15:8];
  async_q txMBFifo (
    .io_enq_clock(txMBFifo_io_enq_clock),
    .io_enq_reset(txMBFifo_io_enq_reset),
    .io_enq_ready(txMBFifo_io_enq_ready),
    .io_enq_valid(txMBFifo_io_enq_valid),
    .io_enq_bits_0(txMBFifo_io_enq_bits_0),
    .io_deq_clock(txMBFifo_io_deq_clock),
    .io_deq_reset(txMBFifo_io_deq_reset),
    .io_deq_ready(txMBFifo_io_deq_ready),
    .io_deq_valid(txMBFifo_io_deq_valid),
    .io_deq_bits_0(txMBFifo_io_deq_bits_0)
  );
  async_q1 rxMBFifo (
    .io_enq_clock(rxMBFifo_io_enq_clock),
    .io_enq_reset(rxMBFifo_io_enq_reset),
    .io_enq_ready(rxMBFifo_io_enq_ready),
    .io_enq_valid(rxMBFifo_io_enq_valid),
    .io_enq_bits_0(rxMBFifo_io_enq_bits_0),
    .io_deq_clock(rxMBFifo_io_deq_clock),
    .io_deq_reset(rxMBFifo_io_deq_reset),
    .io_deq_valid(rxMBFifo_io_deq_valid),
    .io_deq_bits_0(rxMBFifo_io_deq_bits_0)
  );
  assign io_mainbandIo_txData_valid = txMBFifo_io_deq_valid;
  assign io_mainbandIo_txData_bits_0 = txMBFifo_io_deq_bits_0;
  assign io_mainbandIo_rxData_ready = rxMBFifo_io_enq_ready;
  assign io_mainbandLaneIO_txData_ready = txMBFifo_io_enq_ready;
  assign io_mainbandLaneIO_rxData_valid = rxMBFifo_io_deq_valid;
  assign io_mainbandLaneIO_rxData_bits = {rxDataVec_1_0,rxDataVec_0_0};
  assign txMBFifo_io_enq_clock = clock;
  assign txMBFifo_io_enq_reset = reset;
  assign txMBFifo_io_enq_valid = io_mainbandLaneIO_txData_valid;
  assign txMBFifo_io_enq_bits_0 = {txDataVec_0_1,txDataVec_0_0};
  assign txMBFifo_io_deq_clock = io_mainbandIo_fifoParams_clk;
  assign txMBFifo_io_deq_reset = io_mainbandIo_fifoParams_reset;
  assign txMBFifo_io_deq_ready = io_mainbandIo_txData_ready;
  assign rxMBFifo_io_enq_clock = io_mainbandIo_fifoParams_clk;
  assign rxMBFifo_io_enq_reset = io_mainbandIo_fifoParams_reset;
  assign rxMBFifo_io_enq_valid = io_mainbandIo_rxData_valid;
  assign rxMBFifo_io_enq_bits_0 = io_mainbandIo_rxData_bits_0;
  assign rxMBFifo_io_deq_clock = clock;
  assign rxMBFifo_io_deq_reset = reset;
endmodule
