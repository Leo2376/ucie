// xcross_tb: lser -> negedge-centered cross (dual-TB design) -> des.
// Sends 3 back-to-back bursts (distinct packets); each must assemble
// intact and in order. Fast isolation of wire-cross timing vs DUT logic.
`timescale 1ns / 1ps
module xcross_tb;
  reg clock = 0;
  reg reset = 1;
  always #5 clock = ~clock;
  integer fails = 0;

  reg [127:0] pkt = 0;
  reg in_vld = 0;
  wire in_rdy;
  wire txbit, txclk;

  sb_lser u_tx (
    .clock(clock), .reset(reset),
    .io_in_ready(in_rdy), .io_in_valid(in_vld), .io_in_bits(pkt),
    .io_out_bits(txbit), .io_out_clock(txclk)
  );

  // Cross under test: TB gearbox (BFM timing, see common/sb_gear.sv).
  wire rxclk;
  wire rxbit;
  sb_gear u_gear (
    .clock(clock), .reset(reset),
    .in_bit(txbit), .in_sending(u_tx.sending),
    .out_bit(rxbit), .out_clk(rxclk)
  );

  wire d_vld;
  wire [127:0] d_bits;
  sb_ldes u_des (
    .clock(clock), .reset(reset),
    .io_in_bits(rxbit), .io_in_remote_clock(rxclk),
    .io_out_ready(1'b1), .io_out_valid(d_vld), .io_out_bits(d_bits)
  );

  reg [127:0] exp [0:2];
  reg [127:0] got [0:7];
  integer got_n = 0;
  reg prev_v = 0;
  always @(posedge clock) begin
    #1;
    if (!reset && d_vld === 1'b1 && prev_v !== 1'b1) begin
      if (got_n < 8) begin got[got_n] = d_bits; got_n = got_n + 1; end
      $display("DES-OUT n=%0d bits=%h", got_n, d_bits);
    end
    prev_v <= d_vld;
  end

  integer sent = 0;
  integer i;

  // Single-accept packet push (negedge-predict, like AHB driver).
  task automatic send_pkt(input [127:0] p);
    begin
      @(negedge clock);
      pkt = p; in_vld = 1;
      #1;
      while (in_rdy !== 1'b1) begin @(negedge clock); #1; end
      @(posedge clock);
      @(negedge clock);
      in_vld = 0;
    end
  endtask
  initial begin
    exp[0] = 128'hDEAD_BEEF_CAFE_F00D_0123_4567_89AB_CDEF;
    exp[1] = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    exp[2] = 128'h55555555555555555555555555555555;
    repeat (4) @(posedge clock);
    reset = 0;
    repeat (4) @(posedge clock);
    // Present 3 packets (exactly one accept each).
    send_pkt(exp[0]);
    send_pkt(exp[1]);
    send_pkt(exp[2]);
    repeat (800) @(posedge clock);
    $display("got_n=%0d", got_n);
    if (got_n < 3) begin
      $display("FAIL: only %0d/3 packets assembled", got_n); fails++;
    end else begin
      for (i = 0; i < 3; i = i + 1)
        if (got[i] !== exp[i]) begin
          $display("FAIL: pkt%0d exp=%h got=%h", i, exp[i], got[i]); fails++;
        end
      if (fails == 0) $display("PASS: 3/3 intact in order");
    end
    if (fails == 0) $display("XCROSS PASS");
    else $display("XCROSS FAIL fails=%0d", fails);
    $finish;
  end
  initial begin
    repeat (50000) @(posedge clock);
    $display("XCROSS watchdog");
    $finish;
  end
endmodule
