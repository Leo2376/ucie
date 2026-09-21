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
module d2d_mb_flit (
  input         clock,
  input         reset,
  // FDI: 64b words (same 4-signal style as d2d_mb)
  input         io_fdi_lp_irdy,
  input         io_fdi_lp_valid,
  input  [63:0] io_fdi_lp_data,
  output        io_fdi_pl_trdy,
  output        io_fdi_pl_valid,
  output [63:0] io_fdi_pl_data,
  // RDI: 128b beats
  output        io_rdi_lp_irdy,
  output        io_rdi_lp_valid,
  output [127:0] io_rdi_lp_data,
  input         io_rdi_pl_trdy,
  input         io_rdi_pl_valid,
  input  [127:0] io_rdi_pl_data,
  input  [3:0]  io_d2d_state,
  input         io_mainband_stallreq,
  output        io_mainband_stalldone,
  output        io_link_error,
  output        io_reasm_overflow
);
  reg stall_reg;
  wire stalled = stall_reg;
  wire active = (io_d2d_state == 4'h1);

  // ---- TX: FDI words -> pack -> slice -> RDI beats ----
  wire pack_in_ready, pack_out_valid, pack_out_retry, pack_link_error;
  wire [511:0] pack_out_bits;
  wire slice_in_ready, slice_out_valid, slice_out_last;
  wire [127:0] slice_out_bits;
  // RX feedback (local loopback until bullet 5 sideband ACK).
  wire up_ack_valid, up_nack;
  wire [7:0] up_ack_seq;

  flit_pack u_pack (
    .clock(clock), .reset(reset),
    .in_ready(pack_in_ready),
    .in_valid(io_fdi_lp_valid & io_fdi_lp_irdy & ~stalled),
    .in_bits(io_fdi_lp_data),
    .idle_req(1'b0),
    .out_ready(slice_in_ready),
    .out_valid(pack_out_valid), .out_bits(pack_out_bits),
    .out_retry(pack_out_retry),
    .ack_valid(up_ack_valid), .ack_seq(up_ack_seq), .nack(up_nack),
    .link_error(pack_link_error), .cur_seq()
  );

  flit_slicer u_slice (
    .clock(clock), .reset(reset),
    .in_ready(slice_in_ready),
    .in_valid(pack_out_valid),
    .in_bits(pack_out_bits),
    .out_ready(io_rdi_pl_trdy & ~stalled),
    .out_valid(slice_out_valid), .out_bits(slice_out_bits),
    .out_last()
  );

  // ---- RX: RDI beats -> reasm -> unpack -> FDI words ----
  wire reasm_out_valid;
  wire [511:0] reasm_out_bits;
  wire up_out_valid, up_out_last;
  wire [63:0] up_out_bits;
  wire [31:0] up_err_cnt;

  flit_reasm u_reasm (
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

  flit_unpack u_unpack (
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
  reg [63:0] rx_word;
  reg rx_vld;
  always @(posedge clock) begin
    if (reset) begin
      rx_word <= 64'h0;
      rx_vld <= 1'b0;
    end else if (up_out_valid) begin
      rx_word <= up_out_bits;
      rx_vld <= 1'b1;
    end
  end

  // Data flows whenever unstalled (no ACTIVE gate, so the data plane
  // is testable without link bring-up; link gating is bullet 3+).
  assign io_fdi_pl_trdy = pack_in_ready & ~stalled;
  assign io_fdi_pl_valid = rx_vld;
  assign io_fdi_pl_data = rx_word;
  assign io_rdi_lp_irdy = slice_out_valid;
  assign io_rdi_lp_valid = slice_out_valid & ~stalled;
  assign io_rdi_lp_data = slice_out_bits;
  assign io_link_error = pack_link_error;
  assign io_mainband_stalldone = stall_reg;

  wire _unused = &{up_out_last, up_err_cnt, pack_out_retry, 1'b0};

  always @(posedge clock) begin
    if (reset) stall_reg <= 1'b0;
    else stall_reg <= io_mainband_stallreq | (active & stall_reg);
  end
endmodule
