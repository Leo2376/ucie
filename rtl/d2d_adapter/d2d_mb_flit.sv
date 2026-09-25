// d2d_mb_flit: flit-mode mainband datapath (USE_FLIT=1 path).
//
// FDI side stays 64b streaming words (host unchanged). Internally:
//   TX: words -> flit_pack (512b + CRC + seq + replay) -> flit_slicer
//       -> 4 x 128b RDI beats.
//   RX: 128b RDI beats -> flit_reasm -> flit_unpack (CRC check)
//       -> 64b words.
// RX ack/nack feeds back locally to the packer (cross-die transport
// is bullet 5). Legacy parity path is bypassed (CRC authoritative).
// Stall mirrors d2d_mb: latch while ACTIVE, gate TX both directions.
// GATE_ACTIVE=0 (default): data flows unstalled without bring-up (test).
// GATE_ACTIVE=1: TX/RX gated on d2d_state==ACTIVE (production).
// REMOTE_ACK=0 (default): pack consumes the on-die unpack ack/nack
// (all existing TBs). =1: cross-die mode, pack consumes the decoded
// partner ack/nack from the sideband and the local unpack output goes
// to the sideband encoder (docs/ack_spec.md).
// WORDS_PER_FLIT=7 (default): 512b flits, 128b RDI beats.
// WORDS_PER_FLIT=32: 256B datapath — 32x64b payload + hdr/CRC padded to
// 2304b (9x256b RDI beats, 192b reserved zeros outside the CRC).
module d2d_mb_flit #(
  parameter GATE_ACTIVE = 0,
  parameter REMOTE_ACK = 0,
  parameter int WORDS_PER_FLIT = 7,
  parameter int RDI_W = 128
) (
  input         clock,
  input         reset,
  // FDI: 64b words (same 4-signal style as d2d_mb)
  input         io_fdi_lp_irdy,
  input         io_fdi_lp_valid,
  input  [63:0] io_fdi_lp_data,
  output        io_fdi_pl_trdy,
  output        io_fdi_pl_valid,
  output [63:0] io_fdi_pl_data,
  // RDI: beats of RDI_W (128b x4 for 512b flits, 256b x9 for 256B)
  output        io_rdi_lp_irdy,
  output        io_rdi_lp_valid,
  output [RDI_W-1:0] io_rdi_lp_data,
  input         io_rdi_pl_trdy,
  input         io_rdi_pl_valid,
  input  [RDI_W-1:0] io_rdi_pl_data,
  input  [3:0]  io_d2d_state,
  input         io_mainband_stallreq,
  output        io_mainband_stalldone,
  output        io_link_error,
  output        io_reasm_overflow,
  // Cross-die ACK/NACK (sideband codec in d2d_sb via d2d_adapt).
  output        io_ack_tx_valid,
  output [7:0]  io_ack_tx_seq,
  output        io_nack_tx,
  input         io_ack_rx_valid,
  input  [7:0]  io_ack_rx_seq,
  input         io_nack_rx
);
  logic stall_reg;
  wire stalled = stall_reg;
  wire active = (io_d2d_state == 4'h1);
  // Link gate: when enabled, block both directions until ACTIVE.
  wire link_gate = (GATE_ACTIVE != 0) && !active;
  // Padded flit width (multiple of the RDI beat).
  localparam int RAW_W = WORDS_PER_FLIT * 64 + 64;
  localparam int BEATS = (RAW_W + RDI_W - 1) / RDI_W;
  localparam int FLIT_W = BEATS * RDI_W;

  // ---- TX: FDI words -> pack -> slice -> RDI beats ----
  wire pack_in_ready, pack_out_valid, pack_out_retry, pack_link_error;
  wire [FLIT_W-1:0] pack_out_bits;
  wire slice_in_ready, slice_out_valid, slice_out_last;
  wire [RDI_W-1:0] slice_out_bits;
  // RX feedback: local loopback (REMOTE_ACK=0) or cross-die sideband.
  wire up_ack_valid, up_nack;
  wire [7:0] up_ack_seq;
  wire pack_ack_valid = (REMOTE_ACK != 0) ? io_ack_rx_valid : up_ack_valid;
  wire [7:0] pack_ack_seq = (REMOTE_ACK != 0) ? io_ack_rx_seq : up_ack_seq;
  wire pack_nack = (REMOTE_ACK != 0) ? io_nack_rx : up_nack;
  assign io_ack_tx_valid = up_ack_valid;
  assign io_ack_tx_seq = up_ack_seq;
  assign io_nack_tx = up_nack;

  flit_pack #(.WORDS_PER_FLIT(WORDS_PER_FLIT), .RDI_BEAT_W(RDI_W)) u_pack (
    .clock(clock), .reset(reset),
    .in_ready(pack_in_ready),
    .in_valid(io_fdi_lp_valid & io_fdi_lp_irdy & ~stalled & ~link_gate),
    .in_bits(io_fdi_lp_data),
    .idle_req(1'b0),
    .out_ready(slice_in_ready),
    .out_valid(pack_out_valid), .out_bits(pack_out_bits),
    .out_retry(pack_out_retry),
    .ack_valid(pack_ack_valid), .ack_seq(pack_ack_seq), .nack(pack_nack),
    .link_error(pack_link_error), .cur_seq()
  );

  flit_slicer #(.FLIT_W(FLIT_W), .BEAT_W(RDI_W)) u_slice (
    .clock(clock), .reset(reset),
    .in_ready(slice_in_ready),
    .in_valid(pack_out_valid),
    .in_bits(pack_out_bits),
    .out_ready(io_rdi_pl_trdy & ~stalled & ~link_gate),
    .out_valid(slice_out_valid), .out_bits(slice_out_bits),
    .out_last()
  );

  // ---- RX: RDI beats -> reasm -> unpack -> FDI words ----
  wire reasm_out_valid;
  wire [FLIT_W-1:0] reasm_out_bits;
  wire up_out_valid, up_out_last;
  wire [63:0] up_out_bits;
  wire [31:0] up_err_cnt;

  flit_reasm #(.FLIT_W(FLIT_W), .BEAT_W(RDI_W)) u_reasm (
    .clock(clock), .reset(reset),
    .in_ready(),
    .in_valid(io_rdi_pl_valid),
    .in_bits(io_rdi_pl_data),
    .out_ready(up_in_ready),
    .out_valid(reasm_out_valid), .out_bits(reasm_out_bits),
    .overflow(io_reasm_overflow)
  );

  // Unpack input handshake: reasm holds the flit until unpack accepts
  // (combinational valid/ready pair, no skid reg, no loss).
  wire up_in_ready;

  flit_unpack #(.WORDS_PER_FLIT(WORDS_PER_FLIT), .RDI_BEAT_W(RDI_W)) u_unpack (
    .clock(clock), .reset(reset),
    .in_ready(up_in_ready),
    .in_valid(reasm_out_valid),
    .in_bits(reasm_out_bits),
    .out_ready(1'b1),
    .out_valid(up_out_valid), .out_bits(up_out_bits),
    .out_last(up_out_last),
    .ack_valid(up_ack_valid), .ack_seq(up_ack_seq), .nack(up_nack),
    .err_cnt(up_err_cnt), .exp_seq()
  );

  // FDI RX: hold last word (legacy fill-reg semantics).
  logic [63:0] rx_word;
  logic rx_vld;
  always_ff @(posedge clock) begin
    if (reset) begin
      rx_word <= 64'h0;
      rx_vld <= 1'b0;
    end else if (up_out_valid) begin
      rx_word <= up_out_bits;
      rx_vld <= 1'b1;
    end
  end

  // Data flows whenever unstalled (GATE_ACTIVE=0 default, so the data
  // plane is testable without link bring-up; set GATE_ACTIVE=1 for
  // production link gating).
  assign io_fdi_pl_trdy = pack_in_ready & ~stalled & ~link_gate;
  assign io_fdi_pl_valid = rx_vld & ~link_gate;
  assign io_fdi_pl_data = rx_word;
  assign io_rdi_lp_irdy = slice_out_valid;
  assign io_rdi_lp_valid = slice_out_valid & ~stalled & ~link_gate;
  assign io_rdi_lp_data = slice_out_bits;
  // Link error ORs pack retry-exceeded; overflow is reported separately
  // via io_reasm_overflow (both surface at d2d_adapt/ucie_top).
  assign io_link_error = pack_link_error;
  assign io_mainband_stalldone = stall_reg;

  wire _unused = &{up_out_last, up_err_cnt[31:1], pack_out_retry, 1'b0};

  always_ff @(posedge clock) begin
    if (reset) stall_reg <= 1'b0;
    else stall_reg <= io_mainband_stallreq | (active & stall_reg);
  end
endmodule
