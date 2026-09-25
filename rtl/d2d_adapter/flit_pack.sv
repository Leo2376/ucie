// flit_pack: 64b streaming words -> 512b UCIe streaming flit + retry.
//
// Flit format (docs/flit_spec.md):
//   [RAW-1:RAW-32] hdr = {seq[7:0], fmt[3:0], len[5:0], rsv[14:0]}
//   payload = WORDS_PER_FLIT x 64b words, w0 first (LSB)
//   [31:0]    crc32(hdr ++ payload), IEEE-802.3
// On the wire the raw flit (RAW = W*64+64 bits) is zero-padded to
// FLIT_W (multiple of the RDI beat): 512b/4x128b for W=7, 2304b/9x256b
// for W=32 (192b reserved zeros, outside the CRC).
//
// Handshake: in_valid/in_ready (64b words), out_valid/out_ready (flits).
// After WORDS_PER_FLIT words the flit emits in one cycle (CRC is
// combinational).
// Every data flit is pushed into a 16-deep replay buffer indexed by
// seq[3:0]. `ack_seq_valid/ack_seq` frees entries; `nack` (or timeout)
// retransmits the oldest unacked flit, up to MAX_RETRY=3, then
// `link_error` latches. Retransmit has priority over new flits.
// IDLE: when `idle_req` and no words pending, emits fmt=0x1, len=0,
// payload=0, with fresh seq (keeps link alive, no retry).
module flit_pack #(
  parameter int WORDS_PER_FLIT = 7,
  parameter int RDI_BEAT_W      = 128,
  parameter int REPLAY_DEPTH    = 16,
  parameter int MAX_RETRY       = 3,
  parameter int TIMEOUT_CYC     = 1024
) (
  input  wire        clock,
  input  wire        reset,
  // 64b word in (from ahb_fdi / FDI)
  output wire        in_ready,
  input  wire        in_valid,
  input  wire [63:0] in_bits,
  input  wire        idle_req,
  // padded flit out (to RDI slicer)
  input  wire        out_ready,
  output wire        out_valid,
  output wire [FLIT_W-1:0] out_bits,
  output wire        out_retry,
  // RX feedback (from flit_unpack)
  input  wire        ack_valid,
  input  wire [7:0]  ack_seq,
  input  wire        nack,
  output wire        link_error,
  output wire [7:0]  cur_seq
);
  // Raw flit (hdr + payload + crc) padded with reserved zeros to a
  // whole number of RDI beats.
  localparam int RAW_W = WORDS_PER_FLIT * 64 + 64;
  localparam int BEATS = (RAW_W + RDI_BEAT_W - 1) / RDI_BEAT_W;
  localparam int FLIT_W = BEATS * RDI_BEAT_W;
  localparam logic [3:0] FMT_DATA = 4'h0;
  localparam logic [3:0] FMT_IDLE = 4'h1;
  localparam int PAY_W = WORDS_PER_FLIT * 64;
  localparam int WCNT_W = (WORDS_PER_FLIT <= 7) ? 3 : $clog2(WORDS_PER_FLIT + 1);
  localparam int IDX_W = $clog2(WORDS_PER_FLIT); // wbuf index bits (3 for 7, 5 for 32)
  initial begin
    if (WORDS_PER_FLIT < 1 || WORDS_PER_FLIT > 63) $error("flit_pack: WORDS_PER_FLIT out of len range");
    if (FLIT_W % RDI_BEAT_W != 0) $error("flit_pack: FLIT_W not a multiple of RDI_BEAT_W");
  end

  logic [63:0] wbuf [0:WORDS_PER_FLIT-1];
  logic [WCNT_W-1:0] wcnt;
  logic [7:0] seq_reg;
  logic [7:0] retry_cnt;
  logic [15:0] timer;
  logic err_reg;
  // TEMP DEBUG: exact capture/emission counts (same domain as wcnt).
  logic [31:0] dbg_caps = 0;
  logic [31:0] dbg_newouts = 0;
  logic [31:0] dbg_retouts = 0;

  // Replay buffer: 16 x flit + valid + acked.
  logic [FLIT_W-1:0] replay_mem [0:REPLAY_DEPTH-1];
  logic replay_vld [0:REPLAY_DEPTH-1];
  logic replay_acked [0:REPLAY_DEPTH-1];
  logic [7:0] oldest_seq; // oldest unacked
  logic pending_unacked;

  wire [31:0] hdr;
  logic [PAY_W-1:0] payload;
  wire [31:0] crc;
  wire [RAW_W-1:0] raw_flit;
  wire [FLIT_W-1:0] new_flit;

  // Payload assembly: w0 at LSB. Generated loop keeps 7- and 32-word
  // modes identical (w0 first).
  always_comb begin
    for (int p = 0; p < WORDS_PER_FLIT; p = p + 1)
      payload[p*64+:64] = wbuf[p];
  end
  // New-data header uses current seq; retransmit reuses stored flit as-is.
  // len tracks WORDS_PER_FLIT (7 for 512b streaming flits, 32 for 256B).
  assign hdr = {seq_reg, FMT_DATA, WORDS_PER_FLIT[5:0], 14'h0};

  ucie_crc32 #(.DATA_W(PAY_W + 32)) u_crc (.data({hdr, payload}), .crc(crc));
  assign raw_flit = {hdr, payload, crc};
  assign new_flit = {{(FLIT_W-RAW_W){1'b0}}, raw_flit};

  // Idle flit (fmt=1, len=0, zero payload) with its own CRC, padded.
  wire [31:0] idle_hdr = {seq_reg, FMT_IDLE, 6'd0, 14'h0};
  wire [31:0] idle_crc;
  ucie_crc32 #(.DATA_W(PAY_W + 32)) u_crc_idle (.data({idle_hdr, {PAY_W{1'b0}}}), .crc(idle_crc));
  wire [RAW_W-1:0] idle_raw = {idle_hdr, {PAY_W{1'b0}}, idle_crc};
  wire [FLIT_W-1:0] idle_flit = {{(FLIT_W-RAW_W){1'b0}}, idle_raw};

  wire have_word = (wcnt == WCNT_W'(WORDS_PER_FLIT));
  wire want_idle = idle_req && !in_valid && !have_word && !pending_unacked
                   && !retransmit_due;
  wire retransmit_due = nack || (pending_unacked && timer == 0);

  // Retransmit source: oldest unacked entry.
  wire [FLIT_W-1:0] retry_flit = replay_mem[oldest_seq[3:0]];
  wire retry_avail = pending_unacked && replay_vld[oldest_seq[3:0]];

  // Stop-and-wait: a new flit is emitted only with nothing unacked
  // outstanding. This guarantees in-order delivery (a nack/timeout
  // retry can never be overtaken by newer flits, so the unpack side
  // needs no reorder buffer). Pipelining multiple outstanding flits
  // is future work (needs go-back-N or selective-repeat + reorder).
  wire new_ok = have_word && !pending_unacked && !err_reg;

  // Once link_error latches the link is quiesced: no new or retry flits
  // until reset (prevents unbounded retry storms).
  assign out_valid = !err_reg && (new_ok || want_idle || (retransmit_due && retry_avail));
  assign out_bits = (retransmit_due && retry_avail) ? retry_flit
      : new_ok ? new_flit : idle_flit;
  assign out_retry = !err_reg && retransmit_due && retry_avail && out_valid;
  assign in_ready = (wcnt != WCNT_W'(WORDS_PER_FLIT)) && !retransmit_due && !err_reg;
  assign link_error = err_reg;
  assign cur_seq = seq_reg;

  int i;
  always_ff @(posedge clock) begin
    if (reset) begin
      wcnt <= 0;
      seq_reg <= 8'h0;
      oldest_seq <= 8'h0;
      pending_unacked <= 1'b0;
      retry_cnt <= 8'h0;
      timer <= TIMEOUT_CYC[15:0];
      err_reg <= 1'b0;
      for (i = 0; i < REPLAY_DEPTH; i = i + 1) begin
        replay_vld[i] <= 1'b0;
        replay_acked[i] <= 1'b0;
      end
    end else begin
      // Collect words.
      if (in_valid && in_ready) begin
        wbuf[wcnt[IDX_W-1:0]] <= in_bits;
        wcnt <= wcnt + 1'b1;
        dbg_caps <= dbg_caps + 1;
      end
      // ACK frees all entries up to ack_seq (window assumed in-order).
      if (ack_valid) begin
        // Simple: mark matching entry acked; advance oldest while acked.
        replay_acked[ack_seq[3:0]] <= 1'b1;
        if (ack_seq == oldest_seq) begin
          // advance past consecutively acked entries (bounded walk)
          if (replay_acked[oldest_seq[3:0]+4'd1] || ((oldest_seq+8'd1) == seq_reg)) begin
            oldest_seq <= oldest_seq + 8'd1;
            if ((oldest_seq + 8'd1) == seq_reg) pending_unacked <= 1'b0;
          end else begin
            oldest_seq <= oldest_seq + 8'd1;
            if ((oldest_seq + 8'd1) == seq_reg) pending_unacked <= 1'b0;
          end
        end
        if (ack_seq == (seq_reg - 8'd1)) pending_unacked <= 1'b0;
        retry_cnt <= 8'h0;
        timer <= TIMEOUT_CYC[15:0];
      end
      // Flit accepted downstream.
      if (out_valid && out_ready) begin
        if (retransmit_due && retry_avail) begin
          retry_cnt <= retry_cnt + 8'd1;
          // Latch link_error after MAX_RETRY retransmits (restored: the
          // stop-and-wait rework had dropped this comparison).
          if (retry_cnt >= 8'(MAX_RETRY)) err_reg <= 1'b1;
          timer <= TIMEOUT_CYC[15:0];
          dbg_retouts <= dbg_retouts + 1;
        end else if (new_ok) begin
          dbg_newouts <= dbg_newouts + 1;
          replay_mem[seq_reg[3:0]] <= new_flit;
          replay_vld[seq_reg[3:0]] <= 1'b1;
          replay_acked[seq_reg[3:0]] <= 1'b0;
          seq_reg <= seq_reg + 8'd1;
          wcnt <= '0;
          pending_unacked <= 1'b1;
          retry_cnt <= 8'd0;
          timer <= TIMEOUT_CYC[15:0];
        end else if (want_idle) begin
          seq_reg <= seq_reg + 8'd1;
          timer <= TIMEOUT_CYC[15:0];
        end
      end
      // Timeout countdown while unacked outstanding.
      if (pending_unacked && !(out_valid && out_ready && retransmit_due)) begin
        if (timer != 0) timer <= timer - 16'd1;
      end
      if (nack) timer <= 16'd0;
    end
  end
endmodule
