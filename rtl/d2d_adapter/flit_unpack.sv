// flit_unpack: streaming flit -> 64b streaming words + CRC check.
//
// Inverse of flit_pack (docs/flit_spec.md). Accepts one padded flit
// (FLIT_W beats; raw hdr ++ payload ++ crc in the low RAW_W bits,
// reserved padding ignored), checks IEEE CRC-32 over {hdr,payload},
// then streams WORDS_PER_FLIT x 64b words.
// On CRC mismatch: drops flit, pulses `nack`, counts `err_cnt`, no words.
// On match: pulses `ack_valid/ack_seq` (hdr.seq) and streams payload.
// `in_ready` is high when idle; backpressure via out_ready during drain.
module flit_unpack #(
  parameter int WORDS_PER_FLIT = 7,
  parameter int RDI_BEAT_W      = 128
) (
  input  wire         clock,
  input  wire         reset,
  // padded flit in
  output wire         in_ready,
  input  wire         in_valid,
  input  wire [FLIT_W-1:0] in_bits,
  // 64b word out
  input  wire         out_ready,
  output wire         out_valid,
  output wire [63:0]  out_bits,
  output wire         out_last,
  // feedback to flit_pack
  output wire         ack_valid,
  output wire [7:0]   ack_seq,
  output wire         nack,
  output wire [31:0]  err_cnt,
  output wire [7:0]   exp_seq
);
  localparam int RAW_W = WORDS_PER_FLIT * 64 + 64;
  localparam int BEATS = (RAW_W + RDI_BEAT_W - 1) / RDI_BEAT_W;
  localparam int FLIT_W = BEATS * RDI_BEAT_W;
  localparam int PAY_W = WORDS_PER_FLIT * 64;
  localparam int RCNT_W = (WORDS_PER_FLIT <= 7) ? 3 : $clog2(WORDS_PER_FLIT + 1);
  localparam int IDX_W = $clog2(WORDS_PER_FLIT); // pbuf index bits
  initial begin
    if (WORDS_PER_FLIT < 1 || WORDS_PER_FLIT > 63) $error("flit_unpack: WORDS_PER_FLIT out of len range");
  end
  reg [63:0] pbuf [0:WORDS_PER_FLIT-1];
  reg [RCNT_W-1:0] rcnt;    // words remaining
  reg [RCNT_W-1:0] rptr;
  reg draining;
  reg ack_v;
  reg [7:0] ack_s;
  reg nack_r;
  reg [31:0] errs;
  reg [7:0] exp_s;

  wire [RAW_W-1:0] raw = in_bits[RAW_W-1:0];
  wire [31:0] hdr = raw[RAW_W-1:RAW_W-32];
  wire [PAY_W-1:0] payload = raw[RAW_W-33:32];
  wire [31:0] rx_crc = raw[31:0];
  wire [7:0] rx_seq = hdr[31:24];
  wire [3:0] rx_fmt = hdr[23:20];
  wire [5:0] rx_len = hdr[19:14];
  localparam [3:0] FMT_DATA = 4'h0;
  localparam [3:0] FMT_IDLE = 4'h1;
  localparam [3:0] FMT_POISON = 4'hF;
  wire [31:0] calc_crc;
  ucie_crc32 #(.DATA_W(PAY_W + 32)) u_crc (.data({hdr, payload}), .crc(calc_crc));
  wire crc_ok = (calc_crc == rx_crc);

  assign in_ready = !draining;
  assign out_valid = draining && (rcnt != RCNT_W'(0));
  assign out_bits = pbuf[rptr[IDX_W-1:0]];
  assign out_last = draining && (rcnt == RCNT_W'(1));
  assign ack_valid = ack_v;
  assign ack_seq = ack_s;
  assign nack = nack_r;
  assign err_cnt = errs;
  assign exp_seq = exp_s;

  integer i;
  always @(posedge clock) begin
    if (reset) begin
      draining <= 1'b0;
      rcnt <= RCNT_W'(0);
      rptr <= RCNT_W'(0);
      ack_v <= 1'b0;
      ack_s <= 8'h0;
      nack_r <= 1'b0;
      errs <= 32'h0;
      exp_s <= 8'h0;
      for (i = 0; i < WORDS_PER_FLIT; i = i + 1) pbuf[i] <= 64'h0;
    end else begin
      ack_v <= 1'b0;
      nack_r <= 1'b0;
      if (!draining && in_valid && in_ready) begin
        if (!crc_ok) begin
          nack_r <= 1'b1;
          errs <= errs + 32'd1;
        end else if (rx_fmt == FMT_IDLE) begin
          // Idle/skip: keep-alive only. Ack if it carries the expected
          // seq (duplicate idles re-ack without effect); no words.
          if (rx_seq == exp_s) begin
            ack_v <= 1'b1;
            ack_s <= rx_seq;
            exp_s <= rx_seq + 8'd1;
          end else if (rx_seq == exp_s - 8'd1) begin
            ack_v <= 1'b1;
            ack_s <= rx_seq;
          end else begin
            nack_r <= 1'b1;
            errs <= errs + 32'd1;
          end
        end else if (rx_fmt == FMT_POISON) begin
          // Poisoned/retry marker: drop, count, nack to force retransmit.
          nack_r <= 1'b1;
          errs <= errs + 32'd1;
        end else if (rx_fmt != FMT_DATA || rx_len != WORDS_PER_FLIT[5:0]) begin
          // Unknown fmt or bad len: drop, count, nack.
          nack_r <= 1'b1;
          errs <= errs + 32'd1;
        end else if (rx_seq == exp_s - 8'd1) begin
          // Stale retransmit (already acked before the retry raced it):
          // re-ack so TX can advance, but do NOT re-stream the payload
          // (otherwise duplicates shift the word stream).
          ack_v <= 1'b1;
          ack_s <= rx_seq;
        end else if (rx_seq != exp_s) begin
          // Out-of-window (gap/loss): nack, count, wait for retry.
          nack_r <= 1'b1;
          errs <= errs + 32'd1;
        end else begin
          for (i = 0; i < WORDS_PER_FLIT; i = i + 1)
            pbuf[i] <= payload[i*64+:64];
          draining <= 1'b1;
          rcnt <= RCNT_W'(WORDS_PER_FLIT);
          rptr <= RCNT_W'(0);
          ack_v <= 1'b1;
          ack_s <= rx_seq;
          exp_s <= rx_seq + 8'd1;
        end
      end else if (draining && out_ready && out_valid) begin
        rptr <= rptr + RCNT_W'(1);
        rcnt <= rcnt - RCNT_W'(1);
        if (rcnt == RCNT_W'(1)) draining <= 1'b0;
      end
    end
  end
endmodule
