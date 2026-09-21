// flit_reasm: 4 x 128b RDI beats -> 512b flit, LSB first.
//
// beat0 = flit[127:0] expected first. Always ready (4-deep implicit
// buffering would need backpressure; single-flit buffer plus sticky
// overflow flag: if beats arrive while a flit is pending, `overflow`
// latches and the extra beats are dropped — RDI has no beat-level
// backpressure in this RTL. Sized so the normal gap between flits
// (pack needs 7 new words) always drains in time.
module flit_reasm (
  input  wire         clock,
  input  wire         reset,
  output wire         in_ready,
  input  wire         in_valid,
  input  wire [127:0] in_bits,
  input  wire         out_ready,
  output wire         out_valid,
  output wire [511:0] out_bits,
  output wire         overflow
);
  reg [511:0] acc;
  reg [2:0] beats; // beats collected for current flit (0..4)
  reg [511:0] pending;
  reg pending_vld;
  reg overflow_reg;

  assign in_ready = 1'b1; // no RDI beat backpressure (see above)
  assign out_valid = pending_vld;
  assign out_bits = pending;
  assign overflow = overflow_reg;

  always @(posedge clock) begin
    if (reset) begin
      acc <= 512'h0;
      beats <= 3'd0;
      pending <= 512'h0;
      pending_vld <= 1'b0;
      overflow_reg <= 1'b0;
    end else begin
      if (out_valid && out_ready) pending_vld <= 1'b0;
      if (in_valid && in_ready) begin
        case (beats)
          3'd0: acc[127:0] <= in_bits;
          3'd1: acc[255:128] <= in_bits;
          3'd2: acc[383:256] <= in_bits;
          3'd3: acc[511:384] <= in_bits;
          default: ;
        endcase
        if (beats == 3'd3) begin
          if (pending_vld) begin
            overflow_reg <= 1'b1; // previous flit not consumed: drop
          end else begin
            pending <= (beats == 3'd3) ? {in_bits, acc[383:0]} : acc;
            pending_vld <= 1'b1;
          end
          beats <= 3'd0;
        end else begin
          beats <= beats + 3'd1;
        end
      end
    end
  end
endmodule
