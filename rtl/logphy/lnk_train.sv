module lnk_train(
  input          clock,
  input          reset,
  output         io_mainbandFSMIO_rxEn,
  input          io_mainbandFSMIO_pllLock,
  output         io_sidebandFSMIO_rxData_ready,
  input          io_sidebandFSMIO_rxData_valid,
  input  [127:0] io_sidebandFSMIO_rxData_bits,
  input          io_sidebandFSMIO_patternTxData_ready,
  output         io_sidebandFSMIO_patternTxData_valid,
  output [127:0] io_sidebandFSMIO_patternTxData_bits,
  input          io_sidebandFSMIO_packetTxData_ready,
  output         io_sidebandFSMIO_packetTxData_valid,
  output [127:0] io_sidebandFSMIO_packetTxData_bits,
  output         io_sidebandFSMIO_rxMode,
  output         io_sidebandFSMIO_txMode,
  input          io_sidebandFSMIO_pllLock,
  input  [3:0]   io_rdi_rdiBringupIO_lpStateReq,
  output [3:0]   io_rdi_rdiBringupIO_plStateStatus,
  output         io_rdi_rdiBringupIO_plStallReq,
  input          io_rdi_rdiBringupIO_lpStallAck,
  input          io_rdi_rdiBringupIO_lpLinkError,
  output [2:0]   io_currentState
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  wire  patternGenerator_clock;
  wire  patternGenerator_reset;
  wire  patternGenerator_io_patternGeneratorIO_transmitReq_ready;
  wire  patternGenerator_io_patternGeneratorIO_transmitReq_valid;
  wire [31:0] patternGenerator_io_patternGeneratorIO_transmitReq_bits_timeoutCycles;
  wire  patternGenerator_io_patternGeneratorIO_transmitPatternStatus_ready;
  wire  patternGenerator_io_patternGeneratorIO_transmitPatternStatus_valid;
  wire  patternGenerator_io_patternGeneratorIO_transmitPatternStatus_bits;
  wire  patternGenerator_io_sidebandLaneIO_txData_ready;
  wire  patternGenerator_io_sidebandLaneIO_txData_valid;
  wire [127:0] patternGenerator_io_sidebandLaneIO_txData_bits;
  wire  patternGenerator_io_sidebandLaneIO_rxData_ready;
  wire  patternGenerator_io_sidebandLaneIO_rxData_valid;
  wire [127:0] patternGenerator_io_sidebandLaneIO_rxData_bits;
  wire  sbMsgWrapper_clock;
  wire  sbMsgWrapper_reset;
  wire  sbMsgWrapper_io_trainIO_msgReq_ready;
  wire  sbMsgWrapper_io_trainIO_msgReq_valid;
  wire [127:0] sbMsgWrapper_io_trainIO_msgReq_bits_msg;
  wire [63:0] sbMsgWrapper_io_trainIO_msgReq_bits_timeoutCycles;
  wire  sbMsgWrapper_io_trainIO_msgReqStatus_ready;
  wire  sbMsgWrapper_io_trainIO_msgReqStatus_valid;
  wire  sbMsgWrapper_io_laneIO_txData_ready;
  wire  sbMsgWrapper_io_laneIO_txData_valid;
  wire [127:0] sbMsgWrapper_io_laneIO_txData_bits;
  wire  sbMsgWrapper_io_laneIO_rxData_ready;
  wire  sbMsgWrapper_io_laneIO_rxData_valid;
  wire [127:0] sbMsgWrapper_io_laneIO_rxData_bits;
  wire  mbInit_clock;
  wire  mbInit_reset;
  wire  mbInit_io_sbTrainIO_msgReq_ready;
  wire  mbInit_io_sbTrainIO_msgReq_valid;
  wire [127:0] mbInit_io_sbTrainIO_msgReq_bits_msg;
  wire  mbInit_io_sbTrainIO_msgReqStatus_ready;
  wire  mbInit_io_sbTrainIO_msgReqStatus_valid;
  wire  mbInit_io_transition;
  wire  mbInit_io_error;
  wire  rdiBringup_clock;
  wire  rdiBringup_reset;
  wire [3:0] rdiBringup_io_rdiIO_lpStateReq;
  wire [3:0] rdiBringup_io_rdiIO_plStateStatus;
  wire  rdiBringup_io_rdiIO_plStallReq;
  wire  rdiBringup_io_rdiIO_lpStallAck;
  wire  rdiBringup_io_rdiIO_lpLinkError;
  wire  rdiBringup_io_sbTrainIO_msgReq_ready;
  wire  rdiBringup_io_sbTrainIO_msgReq_valid;
  wire [127:0] rdiBringup_io_sbTrainIO_msgReq_bits_msg;
  wire  rdiBringup_io_sbTrainIO_msgReqStatus_ready;
  wire  rdiBringup_io_sbTrainIO_msgReqStatus_valid;
  wire  rdiBringup_io_active;
  wire  rdiBringup_io_internalError;
  reg [2:0] currentState;
  reg [2:0] sbInitSubState;
  wire  _T_30 = 3'h0 == sbInitSubState;
  wire  _GEN_51 = 3'h6 == sbInitSubState | 3'h7 == sbInitSubState;
  wire  _GEN_57 = 3'h5 == sbInitSubState | _GEN_51;
  wire  _GEN_66 = 3'h4 == sbInitSubState | _GEN_57;
  wire  _GEN_71 = 3'h3 == sbInitSubState | _GEN_66;
  wire  _GEN_80 = 3'h2 == sbInitSubState | _GEN_71;
  wire  _GEN_85 = 3'h1 == sbInitSubState ? 1'h0 : _GEN_80;
  wire  _GEN_96 = 3'h0 == sbInitSubState ? 1'h0 : _GEN_85;
  wire  _GEN_132 = 3'h2 == currentState | 3'h3 == currentState;
  wire  _GEN_142 = 3'h1 == currentState ? _GEN_96 : _GEN_132;
  wire  msgSource = 3'h0 == currentState ? 1'h0 : _GEN_142;
  reg [1:0] resetSubState;
  wire  _T_24 = io_mainbandFSMIO_pllLock & io_sidebandFSMIO_pllLock;
  wire [2:0] _GEN_17 = _T_24 ? 3'h1 : currentState;
  wire [2:0] _GEN_18 = 2'h2 == resetSubState ? _GEN_17 : currentState;
  wire [2:0] _GEN_20 = 2'h1 == resetSubState ? currentState : _GEN_18;
  wire [2:0] _GEN_24 = 2'h0 == resetSubState ? currentState : _GEN_20;
  wire  _T_35 = patternGenerator_io_patternGeneratorIO_transmitPatternStatus_ready &
    patternGenerator_io_patternGeneratorIO_transmitPatternStatus_valid;
  wire [2:0] _GEN_26 = patternGenerator_io_patternGeneratorIO_transmitPatternStatus_bits ? 3'h5 : currentState;
  wire [2:0] _GEN_28 = ~patternGenerator_io_patternGeneratorIO_transmitPatternStatus_bits ? currentState : _GEN_26;
  wire [2:0] _GEN_30 = _T_35 ? _GEN_28 : currentState;
  wire  _T_49 = sbMsgWrapper_io_trainIO_msgReqStatus_ready & sbMsgWrapper_io_trainIO_msgReqStatus_valid;
  wire [2:0] _GEN_46 = _T_49 ? 3'h2 : currentState;
  wire [2:0] _GEN_48 = 3'h7 == sbInitSubState ? _GEN_46 : currentState;
  wire [2:0] _GEN_55 = 3'h6 == sbInitSubState ? currentState : _GEN_48;
  wire [2:0] _GEN_59 = 3'h5 == sbInitSubState ? currentState : _GEN_55;
  wire [2:0] _GEN_69 = 3'h4 == sbInitSubState ? currentState : _GEN_59;
  wire [2:0] _GEN_73 = 3'h3 == sbInitSubState ? currentState : _GEN_69;
  wire [2:0] _GEN_83 = 3'h2 == sbInitSubState ? currentState : _GEN_73;
  wire [2:0] _GEN_87 = 3'h1 == sbInitSubState ? _GEN_30 : _GEN_83;
  wire [2:0] _GEN_99 = 3'h0 == sbInitSubState ? currentState : _GEN_87;
  wire [2:0] _nextState_T = mbInit_io_error ? 3'h5 : 3'h3;
  wire [2:0] _GEN_104 = mbInit_io_transition ? _nextState_T : currentState;
  wire [2:0] _GEN_105 = rdiBringup_io_active ? 3'h4 : currentState;
  wire [2:0] _GEN_115 = 3'h3 == currentState ? _GEN_105 : currentState;
  wire [2:0] _GEN_133 = 3'h2 == currentState ? _GEN_104 : _GEN_115;
  wire [2:0] _GEN_145 = 3'h1 == currentState ? _GEN_99 : _GEN_133;
  wire [2:0] nextState = 3'h0 == currentState ? _GEN_24 : _GEN_145;
  wire  _T_2 = currentState != 3'h0;
  wire  _T_3 = nextState == 3'h0 & currentState != 3'h0;
  wire [1:0] _GEN_5 = _T_3 ? 2'h0 : resetSubState;
  wire  _T_6 = nextState == 3'h1 & currentState != 3'h1;
  wire [2:0] _GEN_6 = _T_6 ? 3'h0 : sbInitSubState;
  wire  _currentState_T = rdiBringup_io_rdiIO_plStateStatus == 4'h0;
  wire  _currentState_T_1 = rdiBringup_io_rdiIO_plStateStatus == 4'h1;
  wire  _currentState_T_2 = rdiBringup_io_rdiIO_plStateStatus == 4'hb;
  wire  _io_sidebandFSMIO_rxMode_T_2 = sbInitSubState == 3'h1;
  wire  _io_sidebandFSMIO_rxMode_T_3 = sbInitSubState == 3'h0 | _io_sidebandFSMIO_rxMode_T_2;
  wire  _io_sidebandFSMIO_rxMode_T_4 = sbInitSubState == 3'h2;
  wire  _io_sidebandFSMIO_rxMode_T_5 = _io_sidebandFSMIO_rxMode_T_3 | _io_sidebandFSMIO_rxMode_T_4;
  wire  _io_sidebandFSMIO_rxMode_T_6 = sbInitSubState == 3'h3;
  wire  _io_sidebandFSMIO_rxMode_T_7 = _io_sidebandFSMIO_rxMode_T_5 | _io_sidebandFSMIO_rxMode_T_6;
  wire  _io_sidebandFSMIO_rxMode_T_8 = currentState == 3'h1 & _io_sidebandFSMIO_rxMode_T_7;
  reg [4:0] freqSelCtrValue;
  wire  freqSelCtrValue_wrap_wrap = freqSelCtrValue == 5'h13;
  wire [4:0] _freqSelCtrValue_wrap_value_T_1 = freqSelCtrValue + 5'h1;
  wire  _GEN_23 = 2'h0 == resetSubState & _T_24;
  wire  resetFreqCtrValue = 3'h0 == currentState & _GEN_23;
  wire [1:0] _GEN_16 = freqSelCtrValue_wrap_wrap ? 2'h2 : _GEN_5;
  wire  _T_31 = patternGenerator_io_patternGeneratorIO_transmitReq_ready &
    patternGenerator_io_patternGeneratorIO_transmitReq_valid;
  wire [2:0] _GEN_25 = _T_31 ? 3'h1 : _GEN_6;
  wire [2:0] _GEN_27 = ~patternGenerator_io_patternGeneratorIO_transmitPatternStatus_bits ? 3'h2 : _GEN_6;
  wire [2:0] _GEN_29 = _T_35 ? _GEN_27 : _GEN_6;
  wire  _T_45 = sbMsgWrapper_io_trainIO_msgReq_ready & sbMsgWrapper_io_trainIO_msgReq_valid;
  wire [2:0] _GEN_31 = _T_45 ? 3'h3 : _GEN_6;
  wire [2:0] _GEN_35 = _T_49 ? 3'h4 : _GEN_6;
  wire [2:0] _GEN_37 = _T_45 ? 3'h5 : _GEN_6;
  wire [2:0] _GEN_41 = _T_49 ? 3'h6 : _GEN_6;
  wire [2:0] _GEN_43 = _T_45 ? 3'h7 : _GEN_6;
  wire [2:0] _GEN_53 = 3'h6 == sbInitSubState ? _GEN_43 : _GEN_6;
  wire  _GEN_54 = 3'h6 == sbInitSubState ? 1'h0 : 3'h7 == sbInitSubState;
  wire  _GEN_56 = 3'h5 == sbInitSubState | _GEN_54;
  wire [2:0] _GEN_58 = 3'h5 == sbInitSubState ? _GEN_41 : _GEN_53;
  wire  _GEN_61 = 3'h5 == sbInitSubState ? 1'h0 : 3'h6 == sbInitSubState;
  wire [142:0] _GEN_63 = 3'h4 == sbInitSubState ? 143'h600000140254012 : 143'h600000140268012;
  wire  _GEN_64 = 3'h4 == sbInitSubState | _GEN_61;
  wire [2:0] _GEN_67 = 3'h4 == sbInitSubState ? _GEN_37 : _GEN_58;
  wire  _GEN_68 = 3'h4 == sbInitSubState ? 1'h0 : _GEN_56;
  wire  _GEN_70 = 3'h3 == sbInitSubState | _GEN_68;
  wire [2:0] _GEN_72 = 3'h3 == sbInitSubState ? _GEN_35 : _GEN_67;
  wire  _GEN_75 = 3'h3 == sbInitSubState ? 1'h0 : _GEN_64;
  wire [142:0] _GEN_77 = 3'h2 == sbInitSubState ? 143'h600000040244000 : _GEN_63;
  wire  _GEN_78 = 3'h2 == sbInitSubState | _GEN_75;
  wire [2:0] _GEN_81 = 3'h2 == sbInitSubState ? _GEN_31 : _GEN_72;
  wire  _GEN_82 = 3'h2 == sbInitSubState ? 1'h0 : _GEN_70;
  wire [2:0] _GEN_86 = 3'h1 == sbInitSubState ? _GEN_29 : _GEN_81;
  wire  _GEN_89 = 3'h1 == sbInitSubState ? 1'h0 : _GEN_78;
  wire  _GEN_91 = 3'h1 == sbInitSubState ? 1'h0 : _GEN_82;
  wire  _GEN_98 = 3'h0 == sbInitSubState ? 1'h0 : 3'h1 == sbInitSubState;
  wire  _GEN_101 = 3'h0 == sbInitSubState ? 1'h0 : _GEN_89;
  wire  _GEN_103 = 3'h0 == sbInitSubState ? 1'h0 : _GEN_91;
  wire  _GEN_106 = 3'h3 == currentState & sbMsgWrapper_io_trainIO_msgReq_ready;
  wire  _GEN_107 = 3'h3 == currentState & rdiBringup_io_sbTrainIO_msgReq_valid;
  wire [127:0] _GEN_108 = rdiBringup_io_sbTrainIO_msgReq_bits_msg;
  wire  _GEN_110 = 3'h3 == currentState & rdiBringup_io_sbTrainIO_msgReqStatus_ready;
  wire  _GEN_111 = 3'h3 == currentState & sbMsgWrapper_io_trainIO_msgReqStatus_valid;
  wire  _GEN_116 = 3'h2 == currentState & sbMsgWrapper_io_trainIO_msgReq_ready;
  wire  _GEN_117 = 3'h2 == currentState ? mbInit_io_sbTrainIO_msgReq_valid : _GEN_107;
  wire [127:0] _GEN_118 = 3'h2 == currentState ? mbInit_io_sbTrainIO_msgReq_bits_msg : _GEN_108;
  wire [63:0] _GEN_119 = 3'h2 == currentState ? 64'h61a800 : 64'hf4240;
  wire  _GEN_120 = 3'h2 == currentState ? mbInit_io_sbTrainIO_msgReqStatus_ready : _GEN_110;
  wire  _GEN_121 = 3'h2 == currentState & sbMsgWrapper_io_trainIO_msgReqStatus_valid;
  wire  _GEN_134 = 3'h2 == currentState ? 1'h0 : _GEN_106;
  wire  _GEN_135 = 3'h2 == currentState ? 1'h0 : _GEN_111;
  wire [142:0] _GEN_146 = 3'h1 == currentState ? _GEN_77 : {{15'd0}, _GEN_118};
  wire  _GEN_147 = 3'h1 == currentState ? _GEN_101 : _GEN_117;
  wire  _GEN_149 = 3'h1 == currentState ? _GEN_103 : _GEN_120;
  wire  _GEN_150 = 3'h1 == currentState ? 1'h0 : _GEN_116;
  wire  _GEN_151 = 3'h1 == currentState ? 1'h0 : _GEN_121;
  wire  _GEN_157 = 3'h1 == currentState ? 1'h0 : _GEN_134;
  wire  _GEN_158 = 3'h1 == currentState ? 1'h0 : _GEN_135;
  pat_gen patternGenerator (
    .clock(patternGenerator_clock),
    .reset(patternGenerator_reset),
    .io_patternGeneratorIO_transmitReq_ready(patternGenerator_io_patternGeneratorIO_transmitReq_ready),
    .io_patternGeneratorIO_transmitReq_valid(patternGenerator_io_patternGeneratorIO_transmitReq_valid),
    .io_patternGeneratorIO_transmitReq_bits_timeoutCycles(
      patternGenerator_io_patternGeneratorIO_transmitReq_bits_timeoutCycles),
    .io_patternGeneratorIO_transmitPatternStatus_ready(
      patternGenerator_io_patternGeneratorIO_transmitPatternStatus_ready),
    .io_patternGeneratorIO_transmitPatternStatus_valid(
      patternGenerator_io_patternGeneratorIO_transmitPatternStatus_valid),
    .io_patternGeneratorIO_transmitPatternStatus_bits(patternGenerator_io_patternGeneratorIO_transmitPatternStatus_bits)
      ,
    .io_sidebandLaneIO_txData_ready(patternGenerator_io_sidebandLaneIO_txData_ready),
    .io_sidebandLaneIO_txData_valid(patternGenerator_io_sidebandLaneIO_txData_valid),
    .io_sidebandLaneIO_txData_bits(patternGenerator_io_sidebandLaneIO_txData_bits),
    .io_sidebandLaneIO_rxData_ready(patternGenerator_io_sidebandLaneIO_rxData_ready),
    .io_sidebandLaneIO_rxData_valid(patternGenerator_io_sidebandLaneIO_rxData_valid),
    .io_sidebandLaneIO_rxData_bits(patternGenerator_io_sidebandLaneIO_rxData_bits)
  );
  sb_wrap sbMsgWrapper (
    .clock(sbMsgWrapper_clock),
    .reset(sbMsgWrapper_reset),
    .io_trainIO_msgReq_ready(sbMsgWrapper_io_trainIO_msgReq_ready),
    .io_trainIO_msgReq_valid(sbMsgWrapper_io_trainIO_msgReq_valid),
    .io_trainIO_msgReq_bits_msg(sbMsgWrapper_io_trainIO_msgReq_bits_msg),
    .io_trainIO_msgReq_bits_timeoutCycles(sbMsgWrapper_io_trainIO_msgReq_bits_timeoutCycles),
    .io_trainIO_msgReqStatus_ready(sbMsgWrapper_io_trainIO_msgReqStatus_ready),
    .io_trainIO_msgReqStatus_valid(sbMsgWrapper_io_trainIO_msgReqStatus_valid),
    .io_laneIO_txData_ready(sbMsgWrapper_io_laneIO_txData_ready),
    .io_laneIO_txData_valid(sbMsgWrapper_io_laneIO_txData_valid),
    .io_laneIO_txData_bits(sbMsgWrapper_io_laneIO_txData_bits),
    .io_laneIO_rxData_ready(sbMsgWrapper_io_laneIO_rxData_ready),
    .io_laneIO_rxData_valid(sbMsgWrapper_io_laneIO_rxData_valid),
    .io_laneIO_rxData_bits(sbMsgWrapper_io_laneIO_rxData_bits)
  );
  mb_init mbInit (
    .clock(mbInit_clock),
    .reset(mbInit_reset),
    .io_sbTrainIO_msgReq_ready(mbInit_io_sbTrainIO_msgReq_ready),
    .io_sbTrainIO_msgReq_valid(mbInit_io_sbTrainIO_msgReq_valid),
    .io_sbTrainIO_msgReq_bits_msg(mbInit_io_sbTrainIO_msgReq_bits_msg),
    .io_sbTrainIO_msgReqStatus_ready(mbInit_io_sbTrainIO_msgReqStatus_ready),
    .io_sbTrainIO_msgReqStatus_valid(mbInit_io_sbTrainIO_msgReqStatus_valid),
    .io_transition(mbInit_io_transition),
    .io_error(mbInit_io_error)
  );
  rdi_up rdiBringup (
    .clock(rdiBringup_clock),
    .reset(rdiBringup_reset),
    .io_rdiIO_lpStateReq(rdiBringup_io_rdiIO_lpStateReq),
    .io_rdiIO_plStateStatus(rdiBringup_io_rdiIO_plStateStatus),
    .io_rdiIO_plStallReq(rdiBringup_io_rdiIO_plStallReq),
    .io_rdiIO_lpStallAck(rdiBringup_io_rdiIO_lpStallAck),
    .io_rdiIO_lpLinkError(rdiBringup_io_rdiIO_lpLinkError),
    .io_sbTrainIO_msgReq_ready(rdiBringup_io_sbTrainIO_msgReq_ready),
    .io_sbTrainIO_msgReq_valid(rdiBringup_io_sbTrainIO_msgReq_valid),
    .io_sbTrainIO_msgReq_bits_msg(rdiBringup_io_sbTrainIO_msgReq_bits_msg),
    .io_sbTrainIO_msgReqStatus_ready(rdiBringup_io_sbTrainIO_msgReqStatus_ready),
    .io_sbTrainIO_msgReqStatus_valid(rdiBringup_io_sbTrainIO_msgReqStatus_valid),
    .io_active(rdiBringup_io_active),
    .io_internalError(rdiBringup_io_internalError)
  );
  assign io_mainbandFSMIO_rxEn = 3'h0 == currentState ? 1'h0 : _T_2;
  assign io_sidebandFSMIO_rxData_ready = ~msgSource ? patternGenerator_io_sidebandLaneIO_rxData_ready :
    sbMsgWrapper_io_laneIO_rxData_ready;
  assign io_sidebandFSMIO_patternTxData_valid = patternGenerator_io_sidebandLaneIO_txData_valid;
  assign io_sidebandFSMIO_patternTxData_bits = patternGenerator_io_sidebandLaneIO_txData_bits;
  assign io_sidebandFSMIO_packetTxData_valid = sbMsgWrapper_io_laneIO_txData_valid;
  assign io_sidebandFSMIO_packetTxData_bits = sbMsgWrapper_io_laneIO_txData_bits;
  assign io_sidebandFSMIO_rxMode = _io_sidebandFSMIO_rxMode_T_8 ? 1'h0 : 1'h1;
  // TX source: raw pattern path only during pattern substates; the
  // packet (switcher) path everywhere else. The old txMode=rxMode left
  // message-substate packets (SBINIT 2/3) with nowhere to go.
  wire _tx_raw_T = 3'h1 == currentState & (3'h0 == sbInitSubState | 3'h1 == sbInitSubState);
  assign io_sidebandFSMIO_txMode = _tx_raw_T ? 1'h0 : 1'h1;
  assign io_rdi_rdiBringupIO_plStateStatus = rdiBringup_io_rdiIO_plStateStatus;
  assign io_rdi_rdiBringupIO_plStallReq = rdiBringup_io_rdiIO_plStallReq;
  assign io_currentState = currentState;
  assign patternGenerator_clock = clock;
  assign patternGenerator_reset = reset;
  assign patternGenerator_io_patternGeneratorIO_transmitReq_valid = 3'h0 == currentState ? 1'h0 : 3'h1 == currentState
     & _T_30;
  assign patternGenerator_io_patternGeneratorIO_transmitReq_bits_timeoutCycles = 3'h1 == currentState ? 32'h61a800 : 32'h0
    ;
  assign patternGenerator_io_patternGeneratorIO_transmitPatternStatus_ready = 3'h0 == currentState ? 1'h0 : 3'h1 ==
    currentState & _GEN_98;
  assign patternGenerator_io_sidebandLaneIO_txData_ready = io_sidebandFSMIO_patternTxData_ready;
  assign patternGenerator_io_sidebandLaneIO_rxData_valid = ~msgSource & io_sidebandFSMIO_rxData_valid;
  assign patternGenerator_io_sidebandLaneIO_rxData_bits = io_sidebandFSMIO_rxData_bits;
  assign sbMsgWrapper_clock = clock;
  assign sbMsgWrapper_reset = reset;
  assign sbMsgWrapper_io_trainIO_msgReq_valid = 3'h0 == currentState ? 1'h0 : _GEN_147;
  assign sbMsgWrapper_io_trainIO_msgReq_bits_msg = _GEN_146[127:0];
  assign sbMsgWrapper_io_trainIO_msgReq_bits_timeoutCycles = 3'h1 == currentState ? 64'h61a800 : _GEN_119;
  assign sbMsgWrapper_io_trainIO_msgReqStatus_ready = 3'h0 == currentState ? 1'h0 : _GEN_149;
  assign sbMsgWrapper_io_laneIO_txData_ready = io_sidebandFSMIO_packetTxData_ready;
  assign sbMsgWrapper_io_laneIO_rxData_valid = ~msgSource ? 1'h0 : io_sidebandFSMIO_rxData_valid;
  assign sbMsgWrapper_io_laneIO_rxData_bits = io_sidebandFSMIO_rxData_bits;
  assign mbInit_clock = clock;
  assign mbInit_reset = nextState == 3'h2 & currentState != 3'h2 | reset;
  assign mbInit_io_sbTrainIO_msgReq_ready = 3'h0 == currentState ? 1'h0 : _GEN_150;
  assign mbInit_io_sbTrainIO_msgReqStatus_valid = 3'h0 == currentState ? 1'h0 : _GEN_151;
  assign rdiBringup_clock = clock;
  assign rdiBringup_reset = reset;
  assign rdiBringup_io_rdiIO_lpStateReq = io_rdi_rdiBringupIO_lpStateReq;
  assign rdiBringup_io_rdiIO_lpStallAck = io_rdi_rdiBringupIO_lpStallAck;
  assign rdiBringup_io_rdiIO_lpLinkError = io_rdi_rdiBringupIO_lpLinkError;
  assign rdiBringup_io_sbTrainIO_msgReq_ready = 3'h0 == currentState ? 1'h0 : _GEN_157;
  assign rdiBringup_io_sbTrainIO_msgReqStatus_valid = 3'h0 == currentState ? 1'h0 : _GEN_158;
  assign rdiBringup_io_internalError = currentState == 3'h5;
  always @(posedge clock) begin
    if (reset) begin
      currentState <= 3'h0;
    end else if (_currentState_T) begin
      if (3'h0 == currentState) begin
        if (!(2'h0 == resetSubState)) begin
          currentState <= _GEN_20;
        end
      end else if (3'h1 == currentState) begin
        currentState <= _GEN_99;
      end else begin
        currentState <= _GEN_133;
      end
    end else if (_currentState_T_1) begin
      currentState <= 3'h4;
    end else if (_currentState_T_2) begin
      currentState <= 3'h6;
    end else begin
      currentState <= 3'h5;
    end
    if (reset) begin
      sbInitSubState <= 3'h0;
    end else if (3'h0 == currentState) begin
      sbInitSubState <= _GEN_6;
    end else if (3'h1 == currentState) begin
      if (3'h0 == sbInitSubState) begin
        sbInitSubState <= _GEN_25;
      end else begin
        sbInitSubState <= _GEN_86;
      end
    end else begin
      sbInitSubState <= _GEN_6;
    end
    if (reset) begin
      resetSubState <= 2'h0;
    end else if (3'h0 == currentState) begin
      if (2'h0 == resetSubState) begin
        if (_T_24) begin
          resetSubState <= 2'h1;
        end else begin
          resetSubState <= _GEN_5;
        end
      end else if (2'h1 == resetSubState) begin
        resetSubState <= _GEN_16;
      end else begin
        resetSubState <= _GEN_5;
      end
    end else begin
      resetSubState <= _GEN_5;
    end
    if (reset) begin
      freqSelCtrValue <= 5'h1;
    end else if (resetFreqCtrValue) begin
      freqSelCtrValue <= 5'h1;
    end else if (freqSelCtrValue_wrap_wrap) begin
      freqSelCtrValue <= 5'h1;
    end else begin
      freqSelCtrValue <= _freqSelCtrValue_wrap_value_T_1;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  currentState = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  sbInitSubState = _RAND_1[2:0];
  _RAND_2 = {1{`RANDOM}};
  resetSubState = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  freqSelCtrValue = _RAND_3[4:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
