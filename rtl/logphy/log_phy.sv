module log_phy #(
  parameter RDI_W = 64
) (
  input         clock,
  input         reset,
  output        io_rdi_lpData_ready,
  input         io_rdi_lpData_valid,
  input         io_rdi_lpData_irdy,
  input  [RDI_W-1:0] io_rdi_lpData_bits,
  output        io_rdi_plData_valid,
  output [RDI_W-1:0] io_rdi_plData_bits,
  input  [3:0]  io_rdi_lpStateReq,
  input         io_rdi_lpLinkError,
  output [3:0]  io_rdi_plStateStatus,
  output        io_rdi_plInbandPres,
  output        io_rdi_plStallReq,
  input         io_rdi_lpStallAck,
  output        io_rdi_plConfig_valid,
  output [31:0] io_rdi_plConfig_bits,
  input         io_rdi_plConfigCredit,
  input         io_rdi_lpConfig_valid,
  input  [31:0] io_rdi_lpConfig_bits,
  output        io_rdi_lpConfigCredit,
  input         io_mbAfe_fifoParams_clk,
  input         io_mbAfe_fifoParams_reset,
  input         io_mbAfe_txData_ready,
  output        io_mbAfe_txData_valid,
  output [15:0] io_mbAfe_txData_bits_0,
  output        io_mbAfe_rxData_ready,
  input         io_mbAfe_rxData_valid,
  input  [15:0] io_mbAfe_rxData_bits_0,
  output        io_mbAfe_rxEn,
  input         io_mbAfe_pllLock,
  output        io_sbAfe_txData,
  output        io_sbAfe_txClock,
  input         io_sbAfe_rxData,
  input         io_sbAfe_rxClock,
  input         io_sbAfe_pllLock
);
  wire  trainingModule_clock;
  wire  trainingModule_reset;
  wire  trainingModule_io_mainbandFSMIO_rxEn;
  wire  trainingModule_io_mainbandFSMIO_pllLock;
  wire  trainingModule_io_sidebandFSMIO_rxData_ready;
  wire  trainingModule_io_sidebandFSMIO_rxData_valid;
  wire [127:0] trainingModule_io_sidebandFSMIO_rxData_bits;
  wire  trainingModule_io_sidebandFSMIO_patternTxData_ready;
  wire  trainingModule_io_sidebandFSMIO_patternTxData_valid;
  wire [127:0] trainingModule_io_sidebandFSMIO_patternTxData_bits;
  wire  trainingModule_io_sidebandFSMIO_packetTxData_ready;
  wire  trainingModule_io_sidebandFSMIO_packetTxData_valid;
  wire [127:0] trainingModule_io_sidebandFSMIO_packetTxData_bits;
  wire  trainingModule_io_sidebandFSMIO_rxMode;
  wire  trainingModule_io_sidebandFSMIO_txMode;
  wire  trainingModule_io_sidebandFSMIO_pllLock;
  wire [3:0] trainingModule_io_rdi_rdiBringupIO_lpStateReq;
  wire [3:0] trainingModule_io_rdi_rdiBringupIO_plStateStatus;
  wire  trainingModule_io_rdi_rdiBringupIO_plStallReq;
  wire  trainingModule_io_rdi_rdiBringupIO_lpStallAck;
  wire  trainingModule_io_rdi_rdiBringupIO_lpLinkError;
  wire [2:0] trainingModule_io_currentState;
  wire  rdiDataMapper_clock;
  wire  rdiDataMapper_reset;
  wire  rdiDataMapper_io_rdi_lpData_ready;
  wire  rdiDataMapper_io_rdi_lpData_valid;
  wire  rdiDataMapper_io_rdi_lpData_irdy;
  wire [RDI_W-1:0] rdiDataMapper_io_rdi_lpData_bits;
  wire  rdiDataMapper_io_rdi_plData_valid;
  wire [RDI_W-1:0] rdiDataMapper_io_rdi_plData_bits;
  wire  rdiDataMapper_io_mainbandLaneIO_txData_ready;
  wire  rdiDataMapper_io_mainbandLaneIO_txData_valid;
  wire [15:0] rdiDataMapper_io_mainbandLaneIO_txData_bits;
  wire  rdiDataMapper_io_mainbandLaneIO_rxData_valid;
  wire [15:0] rdiDataMapper_io_mainbandLaneIO_rxData_bits;
  wire  lanes_clock;
  wire  lanes_reset;
  wire  lanes_io_mainbandIo_fifoParams_clk;
  wire  lanes_io_mainbandIo_fifoParams_reset;
  wire  lanes_io_mainbandIo_txData_ready;
  wire  lanes_io_mainbandIo_txData_valid;
  wire [15:0] lanes_io_mainbandIo_txData_bits_0;
  wire  lanes_io_mainbandIo_rxData_ready;
  wire  lanes_io_mainbandIo_rxData_valid;
  wire [15:0] lanes_io_mainbandIo_rxData_bits_0;
  wire  lanes_io_mainbandLaneIO_txData_ready;
  wire  lanes_io_mainbandLaneIO_txData_valid;
  wire [15:0] lanes_io_mainbandLaneIO_txData_bits;
  wire  lanes_io_mainbandLaneIO_rxData_valid;
  wire [15:0] lanes_io_mainbandLaneIO_rxData_bits;
  wire  sidebandChannel_clock;
  wire  sidebandChannel_reset;
  wire [31:0] sidebandChannel_io_to_upper_layer_tx_bits;
  wire  sidebandChannel_io_to_upper_layer_tx_valid;
  wire  sidebandChannel_io_to_upper_layer_tx_credit;
  wire [31:0] sidebandChannel_io_to_upper_layer_rx_bits;
  wire  sidebandChannel_io_to_upper_layer_rx_valid;
  wire  sidebandChannel_io_to_upper_layer_rx_credit;
  wire  sidebandChannel_io_to_lower_layer_tx_bits;
  wire  sidebandChannel_io_to_lower_layer_tx_clock;
  wire  sidebandChannel_io_to_lower_layer_rx_bits;
  wire  sidebandChannel_io_to_lower_layer_rx_clock;
  wire  sidebandChannel_io_inner_inputMode;
  wire  sidebandChannel_io_inner_rxMode;
  wire  sidebandChannel_io_inner_rawInput_ready;
  wire  sidebandChannel_io_inner_rawInput_valid;
  wire [127:0] sidebandChannel_io_inner_rawInput_bits;
  wire  sidebandChannel_io_inner_switcherBundle_node_to_layer_below_ready;
  wire  sidebandChannel_io_inner_switcherBundle_node_to_layer_below_valid;
  wire [127:0] sidebandChannel_io_inner_switcherBundle_node_to_layer_below_bits;
  wire  sidebandChannel_io_inner_switcherBundle_layer_to_node_below_ready;
  wire  sidebandChannel_io_inner_switcherBundle_layer_to_node_below_valid;
  wire [127:0] sidebandChannel_io_inner_switcherBundle_layer_to_node_below_bits;
  lnk_train trainingModule (
    .clock(trainingModule_clock),
    .reset(trainingModule_reset),
    .io_mainbandFSMIO_rxEn(trainingModule_io_mainbandFSMIO_rxEn),
    .io_mainbandFSMIO_pllLock(trainingModule_io_mainbandFSMIO_pllLock),
    .io_sidebandFSMIO_rxData_ready(trainingModule_io_sidebandFSMIO_rxData_ready),
    .io_sidebandFSMIO_rxData_valid(trainingModule_io_sidebandFSMIO_rxData_valid),
    .io_sidebandFSMIO_rxData_bits(trainingModule_io_sidebandFSMIO_rxData_bits),
    .io_sidebandFSMIO_patternTxData_ready(trainingModule_io_sidebandFSMIO_patternTxData_ready),
    .io_sidebandFSMIO_patternTxData_valid(trainingModule_io_sidebandFSMIO_patternTxData_valid),
    .io_sidebandFSMIO_patternTxData_bits(trainingModule_io_sidebandFSMIO_patternTxData_bits),
    .io_sidebandFSMIO_packetTxData_ready(trainingModule_io_sidebandFSMIO_packetTxData_ready),
    .io_sidebandFSMIO_packetTxData_valid(trainingModule_io_sidebandFSMIO_packetTxData_valid),
    .io_sidebandFSMIO_packetTxData_bits(trainingModule_io_sidebandFSMIO_packetTxData_bits),
    .io_sidebandFSMIO_rxMode(trainingModule_io_sidebandFSMIO_rxMode),
    .io_sidebandFSMIO_txMode(trainingModule_io_sidebandFSMIO_txMode),
    .io_sidebandFSMIO_pllLock(trainingModule_io_sidebandFSMIO_pllLock),
    .io_rdi_rdiBringupIO_lpStateReq(trainingModule_io_rdi_rdiBringupIO_lpStateReq),
    .io_rdi_rdiBringupIO_plStateStatus(trainingModule_io_rdi_rdiBringupIO_plStateStatus),
    .io_rdi_rdiBringupIO_plStallReq(trainingModule_io_rdi_rdiBringupIO_plStallReq),
    .io_rdi_rdiBringupIO_lpStallAck(trainingModule_io_rdi_rdiBringupIO_lpStallAck),
    .io_rdi_rdiBringupIO_lpLinkError(trainingModule_io_rdi_rdiBringupIO_lpLinkError),
    .io_currentState(trainingModule_io_currentState)
  );
  rdi_map #(.RDI_W(RDI_W)) rdiDataMapper (
    .clock(rdiDataMapper_clock),
    .reset(rdiDataMapper_reset),
    .io_rdi_lpData_ready(rdiDataMapper_io_rdi_lpData_ready),
    .io_rdi_lpData_valid(rdiDataMapper_io_rdi_lpData_valid),
    .io_rdi_lpData_irdy(rdiDataMapper_io_rdi_lpData_irdy),
    .io_rdi_lpData_bits(rdiDataMapper_io_rdi_lpData_bits),
    .io_rdi_plData_valid(rdiDataMapper_io_rdi_plData_valid),
    .io_rdi_plData_bits(rdiDataMapper_io_rdi_plData_bits),
    .io_mainbandLaneIO_txData_ready(rdiDataMapper_io_mainbandLaneIO_txData_ready),
    .io_mainbandLaneIO_txData_valid(rdiDataMapper_io_mainbandLaneIO_txData_valid),
    .io_mainbandLaneIO_txData_bits(rdiDataMapper_io_mainbandLaneIO_txData_bits),
    .io_mainbandLaneIO_rxData_valid(rdiDataMapper_io_mainbandLaneIO_rxData_valid),
    .io_mainbandLaneIO_rxData_bits(rdiDataMapper_io_mainbandLaneIO_rxData_bits)
  );
  Lanes lanes (
    .clock(lanes_clock),
    .reset(lanes_reset),
    .io_mainbandIo_fifoParams_clk(lanes_io_mainbandIo_fifoParams_clk),
    .io_mainbandIo_fifoParams_reset(lanes_io_mainbandIo_fifoParams_reset),
    .io_mainbandIo_txData_ready(lanes_io_mainbandIo_txData_ready),
    .io_mainbandIo_txData_valid(lanes_io_mainbandIo_txData_valid),
    .io_mainbandIo_txData_bits_0(lanes_io_mainbandIo_txData_bits_0),
    .io_mainbandIo_rxData_ready(lanes_io_mainbandIo_rxData_ready),
    .io_mainbandIo_rxData_valid(lanes_io_mainbandIo_rxData_valid),
    .io_mainbandIo_rxData_bits_0(lanes_io_mainbandIo_rxData_bits_0),
    .io_mainbandLaneIO_txData_ready(lanes_io_mainbandLaneIO_txData_ready),
    .io_mainbandLaneIO_txData_valid(lanes_io_mainbandLaneIO_txData_valid),
    .io_mainbandLaneIO_txData_bits(lanes_io_mainbandLaneIO_txData_bits),
    .io_mainbandLaneIO_rxData_valid(lanes_io_mainbandLaneIO_rxData_valid),
    .io_mainbandLaneIO_rxData_bits(lanes_io_mainbandLaneIO_rxData_bits)
  );
  sb_chan sidebandChannel (
    .clock(sidebandChannel_clock),
    .reset(sidebandChannel_reset),
    .io_to_upper_layer_tx_bits(sidebandChannel_io_to_upper_layer_tx_bits),
    .io_to_upper_layer_tx_valid(sidebandChannel_io_to_upper_layer_tx_valid),
    .io_to_upper_layer_tx_credit(sidebandChannel_io_to_upper_layer_tx_credit),
    .io_to_upper_layer_rx_bits(sidebandChannel_io_to_upper_layer_rx_bits),
    .io_to_upper_layer_rx_valid(sidebandChannel_io_to_upper_layer_rx_valid),
    .io_to_upper_layer_rx_credit(sidebandChannel_io_to_upper_layer_rx_credit),
    .io_to_lower_layer_tx_bits(sidebandChannel_io_to_lower_layer_tx_bits),
    .io_to_lower_layer_tx_clock(sidebandChannel_io_to_lower_layer_tx_clock),
    .io_to_lower_layer_rx_bits(sidebandChannel_io_to_lower_layer_rx_bits),
    .io_to_lower_layer_rx_clock(sidebandChannel_io_to_lower_layer_rx_clock),
    .io_inner_inputMode(sidebandChannel_io_inner_inputMode),
    .io_inner_rxMode(sidebandChannel_io_inner_rxMode),
    .io_inner_rawInput_ready(sidebandChannel_io_inner_rawInput_ready),
    .io_inner_rawInput_valid(sidebandChannel_io_inner_rawInput_valid),
    .io_inner_rawInput_bits(sidebandChannel_io_inner_rawInput_bits),
    .io_inner_switcherBundle_node_to_layer_below_ready(sidebandChannel_io_inner_switcherBundle_node_to_layer_below_ready
      ),
    .io_inner_switcherBundle_node_to_layer_below_valid(sidebandChannel_io_inner_switcherBundle_node_to_layer_below_valid
      ),
    .io_inner_switcherBundle_node_to_layer_below_bits(sidebandChannel_io_inner_switcherBundle_node_to_layer_below_bits),
    .io_inner_switcherBundle_layer_to_node_below_ready(sidebandChannel_io_inner_switcherBundle_layer_to_node_below_ready
      ),
    .io_inner_switcherBundle_layer_to_node_below_valid(sidebandChannel_io_inner_switcherBundle_layer_to_node_below_valid
      ),
    .io_inner_switcherBundle_layer_to_node_below_bits(sidebandChannel_io_inner_switcherBundle_layer_to_node_below_bits)
  );
  assign io_rdi_lpData_ready = rdiDataMapper_io_rdi_lpData_ready;
  assign io_rdi_plData_valid = rdiDataMapper_io_rdi_plData_valid;
  assign io_rdi_plData_bits = rdiDataMapper_io_rdi_plData_bits;
  assign io_rdi_plStateStatus = trainingModule_io_rdi_rdiBringupIO_plStateStatus;
  assign io_rdi_plInbandPres = trainingModule_io_currentState == 3'h4;
  assign io_rdi_plStallReq = trainingModule_io_rdi_rdiBringupIO_plStallReq;
  assign io_rdi_plConfig_valid = sidebandChannel_io_to_upper_layer_tx_valid;
  assign io_rdi_plConfig_bits = sidebandChannel_io_to_upper_layer_tx_bits;
  assign io_rdi_lpConfigCredit = sidebandChannel_io_to_upper_layer_rx_credit;
  assign io_mbAfe_txData_valid = lanes_io_mainbandIo_txData_valid;
  assign io_mbAfe_txData_bits_0 = lanes_io_mainbandIo_txData_bits_0;
  assign io_mbAfe_rxData_ready = lanes_io_mainbandIo_rxData_ready;
  assign io_mbAfe_rxEn = trainingModule_io_mainbandFSMIO_rxEn;
  assign io_sbAfe_txData = sidebandChannel_io_to_lower_layer_tx_bits;
  assign io_sbAfe_txClock = sidebandChannel_io_to_lower_layer_tx_clock;
  assign trainingModule_clock = clock;
  assign trainingModule_reset = reset;
  assign trainingModule_io_mainbandFSMIO_pllLock = io_mbAfe_pllLock;
  assign trainingModule_io_sidebandFSMIO_rxData_valid =
    sidebandChannel_io_inner_switcherBundle_node_to_layer_below_valid;
  assign trainingModule_io_sidebandFSMIO_rxData_bits = sidebandChannel_io_inner_switcherBundle_node_to_layer_below_bits;
  assign trainingModule_io_sidebandFSMIO_patternTxData_ready = sidebandChannel_io_inner_rawInput_ready;
  assign trainingModule_io_sidebandFSMIO_packetTxData_ready =
    sidebandChannel_io_inner_switcherBundle_layer_to_node_below_ready;
  assign trainingModule_io_sidebandFSMIO_pllLock = io_sbAfe_pllLock;
  assign trainingModule_io_rdi_rdiBringupIO_lpStateReq = io_rdi_lpStateReq;
  assign trainingModule_io_rdi_rdiBringupIO_lpStallAck = io_rdi_lpStallAck;
  assign trainingModule_io_rdi_rdiBringupIO_lpLinkError = io_rdi_lpLinkError;
  assign rdiDataMapper_clock = clock;
  assign rdiDataMapper_reset = reset;
  assign rdiDataMapper_io_rdi_lpData_valid = io_rdi_lpData_valid;
  assign rdiDataMapper_io_rdi_lpData_irdy = io_rdi_lpData_irdy;
  assign rdiDataMapper_io_rdi_lpData_bits = io_rdi_lpData_bits;
  assign rdiDataMapper_io_mainbandLaneIO_txData_ready = lanes_io_mainbandLaneIO_txData_ready;
  assign rdiDataMapper_io_mainbandLaneIO_rxData_valid = lanes_io_mainbandLaneIO_rxData_valid;
  assign rdiDataMapper_io_mainbandLaneIO_rxData_bits = lanes_io_mainbandLaneIO_rxData_bits;
  assign lanes_clock = clock;
  assign lanes_reset = reset;
  assign lanes_io_mainbandIo_fifoParams_clk = io_mbAfe_fifoParams_clk;
  assign lanes_io_mainbandIo_fifoParams_reset = io_mbAfe_fifoParams_reset;
  assign lanes_io_mainbandIo_txData_ready = io_mbAfe_txData_ready;
  assign lanes_io_mainbandIo_rxData_valid = io_mbAfe_rxData_valid;
  assign lanes_io_mainbandIo_rxData_bits_0 = io_mbAfe_rxData_bits_0;
  assign lanes_io_mainbandLaneIO_txData_valid = rdiDataMapper_io_mainbandLaneIO_txData_valid;
  assign lanes_io_mainbandLaneIO_txData_bits = rdiDataMapper_io_mainbandLaneIO_txData_bits;
  assign sidebandChannel_clock = clock;
  assign sidebandChannel_reset = reset;
  assign sidebandChannel_io_to_upper_layer_tx_credit = io_rdi_plConfigCredit;
  assign sidebandChannel_io_to_upper_layer_rx_bits = io_rdi_lpConfig_bits;
  assign sidebandChannel_io_to_upper_layer_rx_valid = io_rdi_lpConfig_valid;
  assign sidebandChannel_io_to_lower_layer_rx_bits = io_sbAfe_rxData;
  assign sidebandChannel_io_to_lower_layer_rx_clock = io_sbAfe_rxClock;
  assign sidebandChannel_io_inner_inputMode = trainingModule_io_sidebandFSMIO_txMode;
  assign sidebandChannel_io_inner_rxMode = trainingModule_io_sidebandFSMIO_rxMode;
  assign sidebandChannel_io_inner_rawInput_valid = trainingModule_io_sidebandFSMIO_patternTxData_valid;
  assign sidebandChannel_io_inner_rawInput_bits = trainingModule_io_sidebandFSMIO_patternTxData_bits;
  assign sidebandChannel_io_inner_switcherBundle_node_to_layer_below_ready =
    trainingModule_io_sidebandFSMIO_rxData_ready;
  assign sidebandChannel_io_inner_switcherBundle_layer_to_node_below_valid =
    trainingModule_io_sidebandFSMIO_packetTxData_valid;
  assign sidebandChannel_io_inner_switcherBundle_layer_to_node_below_bits =
    trainingModule_io_sidebandFSMIO_packetTxData_bits;
endmodule
