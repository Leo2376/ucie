// flit_slicer: padded flit -> RDI beats, LSB first.
//
// Default 512b/128b: beat0 = flit[127:0] ... beat3 = flit[511:384].
// 256B mode 2304b/256b: 9 beats. Backpressure: beats hold while
// out_ready is low; in_ready low while a flit is draining.
module flit_slicer #(
  parameter int FLIT_W = 512,
  parameter int BEAT_W = 128
) (
  input  wire         clock,
  input  wire         reset,
  output wire         in_ready,
  input  wire         in_valid,
  input  wire [FLIT_W-1:0] in_bits,
  input  wire         out_ready,
  output wire         out_valid,
  output wire [BEAT_W-1:0] out_bits,
  output wire         out_last
);
  localparam int BEATS = FLIT_W / BEAT_W;
  localparam int CNT_W = (BEATS <= 4) ? 3 : $clog2(BEATS + 1);
  localparam int IDX_W = (BEATS <= 4) ? 2 : $clog2(BEATS);
  initial begin
    if (FLIT_W % BEAT_W != 0) $error("flit_slicer: FLIT_W not a multiple of BEAT_W");
  end
  logic [FLIT_W-1:0] flit_buf;
  logic [CNT_W-1:0] beats_left; // 0 = idle
  logic [IDX_W-1:0] idx;

  wire idle = (beats_left == CNT_W'(0));

  assign in_ready = idle;
  assign out_valid = !idle;
  assign out_bits = flit_buf[idx*BEAT_W+:BEAT_W];
  assign out_last = !idle && (beats_left == CNT_W'(1));

  always_ff @(posedge clock) begin
    if (reset) begin
      beats_left <= CNT_W'(0);
      idx <= IDX_W'(0);
      flit_buf <= {FLIT_W{1'b0}};
    end else if (idle && in_valid && in_ready) begin
      flit_buf <= in_bits;
      beats_left <= CNT_W'(BEATS);
      idx <= IDX_W'(0);
    end else if (!idle && out_ready && out_valid) begin
      idx <= idx + IDX_W'(1);
      beats_left <= beats_left - CNT_W'(1);
    end
  end
endmodule
