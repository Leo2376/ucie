// flit_unpack: 512b UCIe streaming flit -> 64b streaming words + CRC check.
//
// Inverse of flit_pack (docs/flit_spec.md). Accepts one 512b flit,
// checks IEEE CRC-32 over {hdr,payload}, then streams 7x64b words.
// On CRC mismatch: drops flit, pulses `nack`, counts `err_cnt`, no words.
// On match: pulses `ack_valid/ack_seq` (hdr.seq) and streams payload.
// `in_ready` is high when idle; backpressure via out_ready during drain.
module flit_unpack (
  input  wire         clock,
  input  wire         reset,
  // 512b flit in
  output wire         in_ready,
  input  wire         in_valid,
  input  wire [511:0] in_bits,
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
  reg [63:0] pbuf [0:6];
  reg [2:0] rcnt;    // words remaining
  reg [2:0] rptr;
  reg draining;
  reg ack_v;
  reg [7:0] ack_s;
  reg nack_r;
  reg [31:0] errs;
  reg [7:0] exp_s;

  wire [31:0] hdr = in_bits[511:480];
  wire [447:0] payload = in_bits[479:32];
  wire [31:0] rx_crc = in_bits[31:0];
  wire [7:0] rx_seq = hdr[31:24];
  wire [3:0] rx_fmt = hdr[23:20];
  wire [5:0] rx_len = hdr[19:14];
  localparam [3:0] FMT_DATA = 4'h0;
  localparam [3:0] FMT_IDLE = 4'h1;
  localparam [3:0] FMT_POISON = 4'hF;
  wire [31:0] calc_crc;
  ucie_crc32 u_crc (.data({hdr, payload}), .crc(calc_crc));
  wire crc_ok = (calc_crc == rx_crc);

  assign in_ready = !draining;
  assign out_valid = draining && (rcnt != 0);
  assign out_bits = pbuf[rptr];
  assign out_last = draining && (rcnt == 3'd1);
  assign ack_valid = ack_v;
  assign ack_seq = ack_s;
  assign nack = nack_r;
  assign err_cnt = errs;
  assign exp_seq = exp_s;

  integer i;
  always @(posedge clock) begin
    if (reset) begin
      draining <= 1'b0;
      rcnt <= 0;
      rptr <= 0;
      ack_v <= 1'b0;
      ack_s <= 8'h0;
      nack_r <= 1'b0;
      errs <= 32'h0;
      exp_s <= 8'h0;
      for (i = 0; i < 7; i = i + 1) pbuf[i] <= 64'h0;
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
        end else if (rx_fmt != FMT_DATA || rx_len != 6'd7) begin
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
          pbuf[0] <= payload[63:0];
          pbuf[1] <= payload[127:64];
          pbuf[2] <= payload[191:128];
          pbuf[3] <= payload[255:192];
          pbuf[4] <= payload[319:256];
          pbuf[5] <= payload[383:320];
          pbuf[6] <= payload[447:384];
          draining <= 1'b1;
          rcnt <= 3'd7;
          rptr <= 3'd0;
          ack_v <= 1'b1;
          ack_s <= rx_seq;
          exp_s <= rx_seq + 8'd1;
        end
      end else if (draining && out_ready && out_valid) begin
        rptr <= rptr + 3'd1;
        rcnt <= rcnt - 3'd1;
        if (rcnt == 3'd1) draining <= 1'b0;
      end
    end
  end
endmodule
