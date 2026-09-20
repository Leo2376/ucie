module d2d_mb(
  input         clock,
  input         reset,
  input         io_fdi_lp_irdy,
  input         io_fdi_lp_valid,
  input  [63:0] io_fdi_lp_data,
  output        io_fdi_pl_trdy,
  output        io_fdi_pl_valid,
  output [63:0] io_fdi_pl_data,
  output        io_rdi_lp_irdy,
  output        io_rdi_lp_valid,
  output [63:0] io_rdi_lp_data,
  input         io_rdi_pl_trdy,
  input         io_rdi_pl_valid,
  input  [63:0] io_rdi_pl_data,
  input  [3:0]  io_d2d_state,
  input         io_mainband_stallreq,
  output        io_mainband_stalldone,
  output [63:0] io_snd_data,
  output        io_snd_data_vld,
  output        io_rcv_data_vld,
  input         io_parity_insert,
  input  [63:0] io_parity_data,
  output        io_parity_rdy,
  input         io_parity_check
);
`ifdef RANDOMIZE_REG_INIT
  reg [63:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [63:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [63:0] data_buff_snt_reg;
  reg  data_buff_snt_fill_reg;
  reg [63:0] data_buff_rcv_reg;
  reg  data_buff_rcv_fill_reg;
  reg  stall_reg;
  wire  _GEN_0 = io_d2d_state != 4'h1 ? 1'h0 : stall_reg;
  wire  _GEN_1 = io_mainband_stallreq | _GEN_0;
  wire  snd_success_rdi = io_rdi_lp_irdy & io_rdi_lp_valid & io_rdi_pl_trdy;
  wire  _T_1 = ~io_parity_insert;
  wire  _T_3 = ~stall_reg;
  wire  _T_6 = io_parity_insert & _T_3;
  wire  _T_9 = io_fdi_lp_irdy & io_fdi_lp_valid;
  wire  _T_11 = _T_1 & snd_success_rdi;
  wire  _T_14 = io_rdi_pl_valid & ~io_parity_check;
  assign io_fdi_pl_trdy = ~data_buff_snt_fill_reg | _T_11;
  assign io_fdi_pl_valid = data_buff_rcv_fill_reg;
  assign io_fdi_pl_data = data_buff_rcv_reg;
  assign io_rdi_lp_irdy = ~io_parity_insert & data_buff_snt_fill_reg & ~stall_reg | _T_6;
  assign io_rdi_lp_valid = ~io_parity_insert & data_buff_snt_fill_reg & ~stall_reg | _T_6;
  assign io_rdi_lp_data = io_parity_insert ? io_parity_data : data_buff_snt_reg;
  assign io_mainband_stalldone = stall_reg;
  assign io_snd_data = io_fdi_lp_data;
  assign io_snd_data_vld = io_fdi_pl_trdy & io_fdi_lp_valid & io_fdi_lp_irdy;
  assign io_rcv_data_vld = io_rdi_pl_valid;
  assign io_parity_rdy = io_parity_insert & snd_success_rdi;
  always @(posedge clock) begin
    if (~data_buff_snt_fill_reg) begin
      data_buff_snt_reg <= io_fdi_lp_data;
    end else if (_T_1 & snd_success_rdi) begin
      if (_T_9) begin
        data_buff_snt_reg <= io_fdi_lp_data;
      end
    end
    if (reset) begin
      data_buff_snt_fill_reg <= 1'h0;
    end else if (~data_buff_snt_fill_reg) begin
      data_buff_snt_fill_reg <= _T_9;
    end else if (_T_1 & snd_success_rdi) begin
      data_buff_snt_fill_reg <= _T_9;
    end
    if (io_rdi_pl_valid) begin
      data_buff_rcv_reg <= io_rdi_pl_data;
    end
    if (reset) begin
      data_buff_rcv_fill_reg <= 1'h0;
    end else begin
      data_buff_rcv_fill_reg <= _T_14;
    end
    if (reset) begin
      stall_reg <= 1'h0;
    end else begin
      stall_reg <= _GEN_1;
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
  _RAND_0 = {2{`RANDOM}};
  data_buff_snt_reg = _RAND_0[63:0];
  _RAND_1 = {1{`RANDOM}};
  data_buff_snt_fill_reg = _RAND_1[0:0];
  _RAND_2 = {2{`RANDOM}};
  data_buff_rcv_reg = _RAND_2[63:0];
  _RAND_3 = {1{`RANDOM}};
  data_buff_rcv_fill_reg = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  stall_reg = _RAND_4[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
