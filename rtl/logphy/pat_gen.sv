module pat_gen(
  input          clock,
  input          reset,
  output         io_patternGeneratorIO_transmitReq_ready,
  input          io_patternGeneratorIO_transmitReq_valid,
  input  [31:0]  io_patternGeneratorIO_transmitReq_bits_timeoutCycles,
  input          io_patternGeneratorIO_transmitPatternStatus_ready,
  output         io_patternGeneratorIO_transmitPatternStatus_valid,
  output         io_patternGeneratorIO_transmitPatternStatus_bits,
  input          io_sidebandLaneIO_txData_ready,
  output         io_sidebandLaneIO_txData_valid,
  output [127:0] io_sidebandLaneIO_txData_bits,
  output         io_sidebandLaneIO_rxData_ready,
  input          io_sidebandLaneIO_rxData_valid,
  input  [127:0] io_sidebandLaneIO_rxData_bits
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  reg  writeInProgress;
  reg  readInProgress;
  wire  inProgress = writeInProgress | readInProgress;
  reg [31:0] timeoutCycles;
  reg  status;
  reg  statusValid;
  wire  _T = io_patternGeneratorIO_transmitReq_ready & io_patternGeneratorIO_transmitReq_valid;
  wire  _GEN_0 = _T | writeInProgress;
  wire  _GEN_1 = _T | readInProgress;
  wire  _GEN_5 = _T ? 1'h0 : statusValid;
  reg [8:0] patternDetectedCount;
  reg [1:0] patternWrittenCount;
  wire  _T_1 = io_patternGeneratorIO_transmitPatternStatus_ready & io_patternGeneratorIO_transmitPatternStatus_valid;
  wire  _GEN_6 = _T_1 ? 1'h0 : _GEN_5;
  wire [31:0] _timeoutCycles_T_1 = timeoutCycles - 32'h1;
  wire  _T_7 = patternWrittenCount >= 2'h2;
  wire  _T_13 = _T_7 & patternDetectedCount >= 9'h80;
  wire  _GEN_7 = _T_13 | _GEN_6;
  wire  _GEN_8 = _T_13 ? 1'h0 : status;
  wire [1:0] _GEN_11 = _T_13 ? 2'h0 : patternWrittenCount;
  wire [8:0] _GEN_12 = _T_13 ? 9'h0 : patternDetectedCount;
  wire  _GEN_13 = timeoutCycles == 32'h0 | _GEN_8;
  wire  _GEN_14 = timeoutCycles == 32'h0 | _GEN_7;
  wire [1:0] _GEN_17 = timeoutCycles == 32'h0 ? 2'h0 : _GEN_11;
  wire [8:0] _GEN_18 = timeoutCycles == 32'h0 ? 9'h0 : _GEN_12;
  wire [1:0] _GEN_24 = inProgress ? _GEN_17 : patternWrittenCount;
  wire [8:0] _GEN_25 = inProgress ? _GEN_18 : patternDetectedCount;
  wire  _T_17 = io_sidebandLaneIO_txData_ready & io_sidebandLaneIO_txData_valid;
  wire [1:0] _patternWrittenCount_T_1 = patternWrittenCount + 2'h1;
  wire  _T_23 = io_sidebandLaneIO_rxData_ready & io_sidebandLaneIO_rxData_valid;
  wire [8:0] _patternDetectedCount_T_1 = patternDetectedCount + 9'h80;
  assign io_patternGeneratorIO_transmitReq_ready = ~inProgress;
  assign io_patternGeneratorIO_transmitPatternStatus_valid = statusValid;
  assign io_patternGeneratorIO_transmitPatternStatus_bits = status;
  assign io_sidebandLaneIO_txData_valid = writeInProgress;
  assign io_sidebandLaneIO_txData_bits = writeInProgress ? 128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa : 128'h0;
  assign io_sidebandLaneIO_rxData_ready = readInProgress;
  always @(posedge clock) begin
    if (reset) begin
      writeInProgress <= 1'h0;
    end else if (inProgress) begin
      if (timeoutCycles == 32'h0) begin
        writeInProgress <= 1'h0;
      end else if (_T_13) begin
        writeInProgress <= 1'h0;
      end else begin
        writeInProgress <= _GEN_0;
      end
    end else begin
      writeInProgress <= _GEN_0;
    end
    if (reset) begin
      readInProgress <= 1'h0;
    end else if (inProgress) begin
      if (timeoutCycles == 32'h0) begin
        readInProgress <= 1'h0;
      end else if (_T_13) begin
        readInProgress <= 1'h0;
      end else begin
        readInProgress <= _GEN_1;
      end
    end else begin
      readInProgress <= _GEN_1;
    end
    if (reset) begin
      timeoutCycles <= 32'h0;
    end else if (inProgress) begin
      timeoutCycles <= _timeoutCycles_T_1;
    end else if (_T) begin
      timeoutCycles <= io_patternGeneratorIO_transmitReq_bits_timeoutCycles;
    end
    if (reset) begin
      status <= 1'h0;
    end else if (inProgress) begin
      status <= _GEN_13;
    end
    if (reset) begin
      statusValid <= 1'h0;
    end else if (inProgress) begin
      statusValid <= _GEN_14;
    end else if (_T_1) begin
      statusValid <= 1'h0;
    end else if (_T) begin
      statusValid <= 1'h0;
    end
    if (reset) begin
      patternDetectedCount <= 9'h0;
    end else if (readInProgress) begin
      if (_T_23) begin
        if (io_sidebandLaneIO_rxData_bits == 128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa) begin
          patternDetectedCount <= _patternDetectedCount_T_1;
        end else begin
          patternDetectedCount <= _GEN_25;
        end
      end else begin
        patternDetectedCount <= _GEN_25;
      end
    end else begin
      patternDetectedCount <= _GEN_25;
    end
    if (reset) begin
      patternWrittenCount <= 2'h0;
    end else if (writeInProgress) begin
      if (_T_17) begin
        patternWrittenCount <= _patternWrittenCount_T_1;
      end else begin
        patternWrittenCount <= _GEN_24;
      end
    end else begin
      patternWrittenCount <= _GEN_24;
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (writeInProgress & _T_17 & ~reset) begin
          $fwrite(32'h80000002,"pattern written count: %d\n",patternWrittenCount);
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
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
  writeInProgress = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  readInProgress = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  timeoutCycles = _RAND_2[31:0];
  _RAND_3 = {1{`RANDOM}};
  status = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  statusValid = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  patternDetectedCount = _RAND_5[8:0];
  _RAND_6 = {1{`RANDOM}};
  patternWrittenCount = _RAND_6[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
