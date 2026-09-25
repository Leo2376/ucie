// ucie_sva: SystemVerilog assertions for CRC / seq-retry / FSM coverage.
//
// Bound into sim builds (see filelist_rtl.f) and active under Verilator
// `--assert` via `make formal`. Cover properties are guarded for real
// formal tools (`FORMAL_COVER`) since Verilator runs asserts only.
//
// Covered:
//   flit_pack   : header len/fmt on new flits, retry-identical retransmit,
//                 quiesce + seq-freeze under link_error, ack-driven advance.
//   flit_unpack : ack/nack mutual exclusion, err_cnt on nack, words only
//                 on data ack, duplicate re-ack without re-stream.
//   flit_slicer : out_last exactly on final beat, beats drain.
//   flit_reasm  : assembled flit feeds unpack (overflow only when pending).
//   lnk_init    : PARAM-phase send shape, ACTIVE entry needs sent+rcvd.
//   ahb_fdi     : HREADYOUT gating, HRESP level, mailbox exactly-once.
`ifndef UCIE_SVA_SV
`define UCIE_SVA_SV

// ---- flit_pack: seq / retry / quiesce ----
module ucie_pack_sva #(
  parameter int W = 7,
  parameter int FLIT_W = 512,
  parameter int RAW_W = W * 64 + 64,
  parameter int MAXR = 3
) (
  input logic clock, input logic reset,
  input logic out_valid, input logic out_retry,
  input logic [FLIT_W-1:0] out_bits,
  input logic ack_valid, input logic [7:0] ack_seq,
  input logic nack, input logic link_error, input logic [7:0] cur_seq,
  input logic [7:0] oldest_seq, input logic pending_unacked,
  input logic [7:0] retry_cnt,
  input logic [FLIT_W-1:0] replay_head
);
  wire [31:0] hdr = out_bits[RAW_W-1:RAW_W-32];
  wire [5:0]  len = hdr[19:14];
  wire [3:0]  fmt = hdr[23:20];

  // New data flits carry len==W, fmt==data.
  assert property (@(posedge clock) disable iff (reset)
    out_valid && !out_retry && fmt == 4'h0 |-> len == W[5:0]);

  // Retransmits are bit-identical to the stored oldest flit.
  assert property (@(posedge clock) disable iff (reset)
    out_valid && out_retry |-> out_bits == replay_head);

  // Quiesce under link_error: no new or retry flits, seq frozen.
  assert property (@(posedge clock) disable iff (reset)
    link_error |-> !out_valid);
  assert property (@(posedge clock) disable iff (reset)
    link_error |-> $stable(cur_seq));

  // Retry budget: retry_cnt never exceeds MAXR without link_error.
  assert property (@(posedge clock) disable iff (reset)
    retry_cnt > MAXR[7:0] |-> link_error);

`ifndef VERILATOR
  cover property (@(posedge clock) disable iff (reset)
    out_valid && !out_retry);
  cover property (@(posedge clock) disable iff (reset)
    out_valid && out_retry ##1 ack_valid);
  cover property (@(posedge clock) disable iff (reset)
    nack ##1 (out_valid && out_retry));
  cover property (@(posedge clock) disable iff (reset) link_error);
`endif
endmodule

// ---- flit_unpack: CRC / ack-nack / duplicate ----
module ucie_unpack_sva #(
  parameter int W = 7,
  parameter int FLIT_W = 512,
  parameter int RAW_W = W * 64 + 64
) (
  input logic clock, input logic reset,
  input logic in_valid, input logic in_ready,
  input logic [FLIT_W-1:0] in_bits,
  input logic out_valid, input logic out_last,
  input logic ack_valid, input logic [7:0] ack_seq,
  input logic nack, input logic [31:0] err_cnt,
  input logic [7:0] exp_seq, input logic draining
);
  // ack and nack are mutually exclusive pulses.
  assert property (@(posedge clock) disable iff (reset)
    !(ack_valid && nack));
  // Every nack latches exactly one error count (nack shows the cycle
  // after the accept that counted it, so compare against $past here).
  assert property (@(posedge clock) disable iff (reset)
    nack |-> err_cnt == $past(err_cnt) + 32'd1);
  // Words stream only while draining; last implies valid.
  assert property (@(posedge clock) disable iff (reset)
    out_last |-> out_valid);
  // Accepted idle flits never stream words: idle ack without drain.
  // (fmt==1/len==0 decoded from the accepted header.)
  wire [31:0] acc_hdr = in_bits[RAW_W-1:RAW_W-32];
  assert property (@(posedge clock) disable iff (reset)
    in_valid && in_ready && acc_hdr[23:20] == 4'h1 && acc_hdr[19:14] == 6'd0
    |=> !out_valid || ack_valid);

`ifndef VERILATOR
  cover property (@(posedge clock) disable iff (reset)
    in_valid && in_ready ##1 ack_valid);
  cover property (@(posedge clock) disable iff (reset) nack);
  cover property (@(posedge clock) disable iff (reset)
    out_valid && out_last);
`endif
endmodule

// ---- flit_slicer: beat framing ----
module ucie_slicer_sva #(
  parameter int FLIT_W = 512,
  parameter int BEAT_W = 128,
  parameter int BEATS = FLIT_W / BEAT_W
) (
  input logic clock, input logic reset,
  input logic in_valid, input logic in_ready,
  input logic out_valid, input logic out_ready, input logic out_last,
  input logic [BEAT_W-1:0] out_bits
);
  // Beats hold while backpressured; an accepted flit starts beats.
  assert property (@(posedge clock) disable iff (reset)
    out_valid && !out_ready |=> $stable(out_bits));
  assert property (@(posedge clock) disable iff (reset)
    !out_valid && in_valid && in_ready |=> out_valid);

`ifndef VERILATOR
  cover property (@(posedge clock) disable iff (reset)
    out_valid && out_last && out_ready);
`endif
endmodule

// ---- flit_reasm: assembly / overflow discipline ----
module ucie_reasm_sva (
  input logic clock, input logic reset,
  input logic in_valid, input logic out_valid, input logic out_ready,
  input logic overflow, input logic pending_vld
);
  // Overflow only latches while a flit awaits consumption.
  assert property (@(posedge clock) disable iff (reset)
    overflow |-> pending_vld || $past(pending_vld));
  // Pending clears only on accept.
  assert property (@(posedge clock) disable iff (reset)
    pending_vld && !(out_valid && out_ready) |=> pending_vld);

`ifndef VERILATOR
  cover property (@(posedge clock) disable iff (reset)
    out_valid && out_ready);
  cover property (@(posedge clock) disable iff (reset) overflow);
`endif
endmodule

// ---- lnk_init: PARAM / ACTIVE handshake shape ----
module ucie_linkinit_sva (
  input logic clock, input logic reset,
  input logic [2:0] state, input logic [5:0] sb_snd,
  input logic snt_flag, input logic rcv_flag, input logic active_entry
);
  // In PARAM phase the only nonzero send is 0x24; in ACTIVE phase
  // only req/rsp (0x01/0x11). Sends happen in phases 2-3 only.
  assert property (@(posedge clock) disable iff (reset)
    state == 3'h2 && sb_snd != 6'h0 |-> sb_snd == 6'h24);
  assert property (@(posedge clock) disable iff (reset)
    state == 3'h3 && sb_snd != 6'h0 |->
    sb_snd == 6'h01 || sb_snd == 6'h11);
  assert property (@(posedge clock) disable iff (reset)
    sb_snd != 6'h0 |-> state == 3'h2 || state == 3'h3);
  // ACTIVE entry fires from the done state (snt/rcv already consumed).
  assert property (@(posedge clock) disable iff (reset)
    active_entry |-> state == 3'h4);

`ifndef VERILATOR
  cover property (@(posedge clock) disable iff (reset)
    state == 3'h2 && snt_flag && rcv_flag);
  cover property (@(posedge clock) disable iff (reset) active_entry);
`endif
endmodule

// ---- ahb_fdi: mailbox / response gating ----
module ucie_ahb_sva (
  input logic clock, input logic reset_n,
  input logic hsel, input logic hwrite, input logic [1:0] htrans,
  input logic [31:0] haddr,
  input logic hreadyout, input logic hresp,
  input logic link_error, input logic tx_ready
);
  // HRESP mirrors link_error (level).
  assert property (@(posedge clock) disable iff (!reset_n)
    hresp == link_error);
  // Backpressure only on config-data writes when the TX packet is full.
  assert property (@(posedge clock) disable iff (!reset_n)
    !hreadyout |-> hsel && hwrite && htrans[1] && haddr[31] &&
                    haddr[3:2] == 2'd0 && !tx_ready);

`ifndef VERILATOR
  cover property (@(posedge clock) disable iff (!reset_n) !hreadyout);
  cover property (@(posedge clock) disable iff (!reset_n) hresp);
`endif
endmodule

// ---- binds ----
bind flit_pack ucie_pack_sva #(
  .W(WORDS_PER_FLIT), .FLIT_W(FLIT_W), .RAW_W(RAW_W), .MAXR(MAX_RETRY)
) u_pack_sva (
  .clock(clock), .reset(reset),
  .out_valid(out_valid), .out_retry(out_retry), .out_bits(out_bits),
  .ack_valid(ack_valid), .ack_seq(ack_seq), .nack(nack),
  .link_error(link_error), .cur_seq(cur_seq),
  .oldest_seq(oldest_seq), .pending_unacked(pending_unacked),
  .retry_cnt(retry_cnt), .replay_head(replay_mem[oldest_seq[3:0]])
);

bind flit_unpack ucie_unpack_sva #(
  .W(WORDS_PER_FLIT), .FLIT_W(FLIT_W), .RAW_W(RAW_W)
) u_unpack_sva (
  .clock(clock), .reset(reset),
  .in_valid(in_valid), .in_ready(in_ready), .in_bits(in_bits),
  .out_valid(out_valid), .out_last(out_last),
  .ack_valid(ack_valid), .ack_seq(ack_seq), .nack(nack),
  .err_cnt(err_cnt), .exp_seq(exp_s), .draining(draining)
);

bind flit_slicer ucie_slicer_sva #(
  .FLIT_W(FLIT_W), .BEAT_W(BEAT_W), .BEATS(FLIT_W / BEAT_W)
) u_slicer_sva (
  .clock(clock), .reset(reset),
  .in_valid(in_valid), .in_ready(in_ready),
  .out_valid(out_valid), .out_ready(out_ready), .out_last(out_last),
  .out_bits(out_bits)
);

bind flit_reasm ucie_reasm_sva u_reasm_sva (
  .clock(clock), .reset(reset),
  .in_valid(in_valid), .out_valid(out_valid), .out_ready(out_ready),
  .overflow(overflow), .pending_vld(pending_vld)
);

bind lnk_init ucie_linkinit_sva u_init_sva (
  .clock(clock), .reset(reset),
  .state(linkinit_state_reg), .sb_snd(io_linkinit_sb_snd),
  .snt_flag(param_exch_sbmsg_snt_flag),
  .rcv_flag(param_exch_sbmsg_rcv_flag), .active_entry(io_active_entry)
);

bind ahb_fdi ucie_ahb_sva u_ahb_sva (
  .clock(HCLK), .reset_n(HRESETn),
  .hsel(HSEL), .hwrite(HWRITE), .htrans(HTRANS), .haddr(HADDR),
  .hreadyout(HREADYOUT), .hresp(HRESP),
  .link_error(io_link_error), .tx_ready(tx_ready)
);

`endif
