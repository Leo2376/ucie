// Lanes: NLANES x 16b mainband lanes, each with its own async-FIFO pair.
//
// NLANES=1 (default) is bit-identical to the legacy single lane.
// NLANES=16 is the standard-package target: the lane-side and AFE-side
// buses widen to NLANES*16b and each lane crosses into the (shared) AFE
// clock domain through its own FIFOs.
module Lanes #(
  parameter NLANES = 1
) (
  input         clock,
  input         reset,
  input         io_mainbandIo_fifoParams_clk,
  input         io_mainbandIo_fifoParams_reset,
  input         io_mainbandIo_txData_ready,
  output        io_mainbandIo_txData_valid,
  output [NLANES*16-1:0] io_mainbandIo_txData_bits_0,
  output        io_mainbandIo_rxData_ready,
  input         io_mainbandIo_rxData_valid,
  input  [NLANES*16-1:0] io_mainbandIo_rxData_bits_0,
  output        io_mainbandLaneIO_txData_ready,
  input         io_mainbandLaneIO_txData_valid,
  input  [NLANES*16-1:0] io_mainbandLaneIO_txData_bits,
  output        io_mainbandLaneIO_rxData_valid,
  output [NLANES*16-1:0] io_mainbandLaneIO_rxData_bits
);
  // Per-lane ready/valid: AFE side ANDs TX ready (all lanes must accept);
  // lane side requires all FIFOs non-empty for valid.
  wire [NLANES-1:0] tx_enq_ready, tx_deq_valid, rx_enq_ready, rx_deq_valid;

  assign io_mainbandLaneIO_txData_ready = &tx_enq_ready;
  assign io_mainbandIo_txData_valid = &tx_deq_valid;
  assign io_mainbandIo_rxData_ready = &rx_enq_ready;
  assign io_mainbandLaneIO_rxData_valid = &rx_deq_valid;

  genvar g;
  generate
    for (g = 0; g < NLANES; g = g + 1) begin : gen_lane
      async_q txMBFifo (
        .io_enq_clock(clock),
        .io_enq_reset(reset),
        .io_enq_ready(tx_enq_ready[g]),
        .io_enq_valid(io_mainbandLaneIO_txData_valid),
        .io_enq_bits_0(io_mainbandLaneIO_txData_bits[g*16+:16]),
        .io_deq_clock(io_mainbandIo_fifoParams_clk),
        .io_deq_reset(io_mainbandIo_fifoParams_reset),
        .io_deq_ready(io_mainbandIo_txData_ready),
        .io_deq_valid(tx_deq_valid[g]),
        .io_deq_bits_0(io_mainbandIo_txData_bits_0[g*16+:16])
      );
      async_q1 rxMBFifo (
        .io_enq_clock(io_mainbandIo_fifoParams_clk),
        .io_enq_reset(io_mainbandIo_fifoParams_reset),
        .io_enq_ready(rx_enq_ready[g]),
        .io_enq_valid(io_mainbandIo_rxData_valid),
        .io_enq_bits_0(io_mainbandIo_rxData_bits_0[g*16+:16]),
        .io_deq_clock(clock),
        .io_deq_reset(reset),
        .io_deq_valid(rx_deq_valid[g]),
        .io_deq_bits_0(io_mainbandLaneIO_rxData_bits[g*16+:16])
      );
    end
  endgenerate
endmodule
