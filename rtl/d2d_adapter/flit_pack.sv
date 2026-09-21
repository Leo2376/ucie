// flit_pack: 64b streaming words -> 512b UCIe streaming flit + retry.
//
// Format (docs/flit_spec.md):
//   [511:480] hdr = {seq[7:0], fmt[3:0], len[5:0], rsv[14:0]}
//   [479:32]  payload = 7 x 64b words, w0 first (LSB)
//   [31:0]    crc32(hdr ++ payload), IEEE-802.3
//
// Handshake: in_valid/in_ready (64b words), out_valid/out_ready (flits).
// After 7 words the flit emits in one cycle (CRC is combinational).
// Every data flit is pushed into a 16-deep replay buffer indexed by
// seq[3:0]. `ack_seq_valid/ack_seq` frees entries; `nack` (or timeout)
// retransmits the oldest unacked flit, up to MAX_RETRY=3, then
// `link_error` latches. Retransmit has priority over new flits.
// IDLE: when `idle_req` and no words pending, emits fmt=0x1, len=0,
// payload=0, with fresh seq (keeps link alive, no retry).
module flit_pack #(
  parameter int WORDS_PER_FLIT = 7,
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
  // 512b flit out (to RDI slicer)
  input  wire        out_ready,
  output wire        out_valid,
  output wire [511:0] out_bits,
  output wire        out_retry,
  // RX feedback (from flit_unpack)
  input  wire        ack_valid,
  input  wire [7:0]  ack_seq,
  input  wire        nack,
  output wire        link_error,
  output wire [7:0]  cur_seq
);
  localparam int CNT_W = 3; // 0..7

  reg [63:0] wbuf [0:WORDS_PER_FLIT-1];
  reg [CNT_W-1:0] wcnt;
  reg [7:0] seq_reg;
  reg [7:0] retry_cnt;
  reg [15:0] timer;
  reg err_reg;

  // Replay buffer: 16 x 512b + valid + acked.
  reg [511:0] replay_mem [0:REPLAY_DEPTH-1];
  reg replay_vld [0:REPLAY_DEPTH-1];
  reg replay_acked [0:REPLAY_DEPTH-1];
  reg [7:0] oldest_seq; // oldest unacked
  reg pending_unacked;

  wire [31:0] hdr;
  wire [447:0] payload;
  wire [31:0] crc;
  wire [511:0] new_flit;

  assign payload = {wbuf[6], wbuf[5], wbuf[4], wbuf[3], wbuf[2], wbuf[1], wbuf[0]};
  // New-data header uses current seq; retransmit reuses stored flit as-is.
  assign hdr = {seq_reg, 4'h0, 6'd7, 14'h0};

  ucie_crc32 u_crc (.data({hdr, payload}), .crc(crc));
  assign new_flit = {hdr, payload, crc};

  // Idle flit (fmt=1, len=0, zero payload) with its own CRC.
  wire [31:0] idle_hdr = {seq_reg, 4'h1, 6'd0, 14'h0};
  wire [31:0] idle_crc;
  ucie_crc32 u_crc_idle (.data({idle_hdr, 448'h0}), .crc(idle_crc));
  wire [511:0] idle_flit = {idle_hdr, 448'h0, idle_crc};

  wire have_word = (wcnt == CNT_W'(WORDS_PER_FLIT));
  wire want_idle = idle_req && !in_valid && !have_word && !pending_unacked
                   && !retransmit_due;
  wire retransmit_due = nack || (pending_unacked && timer == 0);

  // Retransmit source: oldest unacked entry.
  wire [511:0] retry_flit = replay_mem[oldest_seq[3:0]];
  wire retry_avail = pending_unacked && replay_vld[oldest_seq[3:0]];

  assign out_valid = have_word || want_idle || (retransmit_due && retry_avail);
  assign out_bits = (retransmit_due && retry_avail) ? retry_flit
      : have_word ? new_flit : idle_flit;
  assign out_retry = retransmit_due && retry_avail && out_valid;
  assign in_ready = (wcnt != CNT_W'(WORDS_PER_FLIT)) && !retransmit_due;
  assign link_error = err_reg;
  assign cur_seq = seq_reg;

  integer i;
  always @(posedge clock) begin
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
        wbuf[wcnt] <= in_bits;
        wcnt <= wcnt + 1'b1;
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
          timer <= TIMEOUT_CYC[15:0];
          if (retry_cnt >= 8'(MAX_RETRY)) err_reg <= 1'b1;
        end else if (have_word) begin
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
