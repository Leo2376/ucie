module par_neg(
  input        clock,
  input        reset,
  input        io_start_negotiation,
  input  [5:0] io_parity_sb_rcv,
  output [5:0] io_parity_sb_snd,
  input        io_parity_sb_rdy,
  output       io_parity_rx_enable,
  output       io_parity_tx_enable
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_REG_INIT
  reg  parity_rsp_snt_flag_reg;
  reg  parity_req_rcv_flag_reg;
  reg  parity_rx_enable_reg;
  reg  parity_tx_enable_reg;
  wire  _T_3 = ~parity_rsp_snt_flag_reg;
  wire [5:0] _GEN_0 = parity_req_rcv_flag_reg & _T_3 ? 6'h32 : 6'h0;
  wire  _T_13 = io_parity_sb_snd == 6'h31;
  wire  _T_14 = io_parity_sb_snd == 6'h32;
  wire  _GEN_6 = (io_parity_sb_snd == 6'h31 | io_parity_sb_snd == 6'h32) & io_parity_sb_rdy | parity_rsp_snt_flag_reg;
  wire  _GEN_7 = io_parity_sb_rcv == 6'h21 | parity_req_rcv_flag_reg;
  wire  _T_18 = io_parity_sb_rcv == 6'h31;
  wire  _GEN_9 = _T_14 & io_parity_sb_rdy ? 1'h0 : parity_rx_enable_reg;
  wire  _GEN_10 = _T_14 & io_parity_sb_rdy ? _GEN_6 : parity_rsp_snt_flag_reg;
  wire  _GEN_11 = _T_13 & io_parity_sb_rdy | _GEN_9;
  wire  _GEN_12 = _T_13 & io_parity_sb_rdy ? _GEN_6 : _GEN_10;
  wire  _GEN_19 = io_start_negotiation & _GEN_12;
  wire  _GEN_20 = io_start_negotiation & _GEN_7;
  assign io_parity_sb_snd = io_start_negotiation ? _GEN_0 : 6'h0;
  assign io_parity_rx_enable = parity_rx_enable_reg;
  assign io_parity_tx_enable = parity_tx_enable_reg;
  always @(posedge clock) begin
    if (reset) begin
      parity_rsp_snt_flag_reg <= 1'h0;
    end else begin
      parity_rsp_snt_flag_reg <= _GEN_19;
    end
    if (reset) begin
      parity_req_rcv_flag_reg <= 1'h0;
    end else begin
      parity_req_rcv_flag_reg <= _GEN_20;
    end
    if (reset) begin
      parity_rx_enable_reg <= 1'h0;
    end else if (io_start_negotiation) begin
      parity_rx_enable_reg <= _GEN_11;
    end
    if (reset) begin
      parity_tx_enable_reg <= 1'h0;
    end else if (io_start_negotiation) begin
      parity_tx_enable_reg <= _T_18;
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
  parity_rsp_snt_flag_reg = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  parity_req_rcv_flag_reg = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  parity_rx_enable_reg = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  parity_tx_enable_reg = _RAND_3[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
