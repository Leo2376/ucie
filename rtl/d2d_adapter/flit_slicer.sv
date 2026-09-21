// flit_slicer: 512b flit -> 4 x 128b RDI beats, LSB first.
//
// beat0 = flit[127:0] ... beat3 = flit[511:384]. Backpressure: beats
// hold while out_ready is low; in_ready low while a flit is draining.
module flit_slicer (
  input  wire         clock,
  input  wire         reset,
  output wire         in_ready,
  input  wire         in_valid,
  input  wire [511:0] in_bits,
  input  wire         out_ready,
  output wire         out_valid,
  output wire [127:0] out_bits,
  output wire         out_last
);
  reg [511:0] flit_buf;
  reg [2:0] beats_left; // 0 = idle
  reg [1:0] idx;

  wire idle = (beats_left == 3'd0);
  wire [127:0] beat0 = flit_buf[127:0];
  wire [127:0] beat1 = flit_buf[255:128];
  wire [127:0] beat2 = flit_buf[383:256];
  wire [127:0] beat3 = flit_buf[511:384];

  assign in_ready = idle;
  assign out_valid = !idle;
  assign out_bits = (idx == 2'd0) ? beat0 : (idx == 2'd1) ? beat1 :
                    (idx == 2'd2) ? beat2 : beat3;
  assign out_last = !idle && (beats_left == 3'd1);

  always @(posedge clock) begin
    if (reset) begin
      beats_left <= 3'd0;
      idx <= 2'd0;
      flit_buf <= 512'h0;
    end else if (idle && in_valid && in_ready) begin
      flit_buf <= in_bits;
      beats_left <= 3'd4;
      idx <= 2'd0;
    end else if (!idle && out_ready && out_valid) begin
      idx <= idx + 2'd1;
      beats_left <= beats_left - 3'd1;
    end
  end
endmodule
