// flit_reasm: RDI beats -> padded flit, LSB first.
//
// Default 4x128b -> 512b; 256B mode 9x256b -> 2304b. beat0 expected
// first (ends at LSB via shift-right accumulate). Always ready
// (single-flit buffer plus sticky overflow flag: if beats arrive while
// a flit is pending, `overflow` latches and the extra beats are
// dropped — RDI has no beat-level backpressure in this RTL. Sized so
// the normal gap between flits always drains in time.
module flit_reasm #(
  parameter int FLIT_W = 512,
  parameter int BEAT_W = 128
) (
  input  wire         clock,
  input  wire         reset,
  output wire         in_ready,
  input  wire         in_valid,
  input  wire [BEAT_W-1:0] in_bits,
  input  wire         out_ready,
  output wire         out_valid,
  output wire [FLIT_W-1:0] out_bits,
  output wire         overflow
);
  localparam int BEATS = FLIT_W / BEAT_W;
  localparam int CNT_W = (BEATS <= 4) ? 3 : $clog2(BEATS + 1);
  initial begin
    if (FLIT_W % BEAT_W != 0) $error("flit_reasm: FLIT_W not a multiple of BEAT_W");
  end
  reg [FLIT_W-1:0] acc;
  reg [CNT_W-1:0] beats; // beats collected for current flit (0..BEATS-1)
  reg [FLIT_W-1:0] pending;
  reg pending_vld;
  reg overflow_reg;

  assign in_ready = 1'b1; // no RDI beat backpressure (see above)
  assign out_valid = pending_vld;
  assign out_bits = pending;
  assign overflow = overflow_reg;

  always @(posedge clock) begin
    if (reset) begin
      acc <= {FLIT_W{1'b0}};
      beats <= CNT_W'(0);
      pending <= {FLIT_W{1'b0}};
      pending_vld <= 1'b0;
      overflow_reg <= 1'b0;
    end else begin
      if (out_valid && out_ready) pending_vld <= 1'b0;
      if (in_valid && in_ready) begin
        // Shift-right accumulate: first beat ends at LSB.
        acc <= {in_bits, acc[FLIT_W-1:BEAT_W]};
        if (beats == CNT_W'(BEATS - 1)) begin
          if (pending_vld) begin
            overflow_reg <= 1'b1; // previous flit not consumed: drop
          end else begin
            pending <= {in_bits, acc[FLIT_W-1:BEAT_W]};
            pending_vld <= 1'b1;
          end
          beats <= CNT_W'(0);
        end else begin
          beats <= beats + CNT_W'(1);
        end
      end
    end
  end
endmodule
