// sb_gear: TB-side sideband gearbox (DUT-to-DUT wire model).
//
// Problem: forwarding lser txData/txClock 1:1 same-clock breaks the des
// (its synchronizer + delayed-count pipeline needs edges away from local
// posedges; sampling the gated clock sticks; BFM timing with 2 HCLK/bit
// works because edges land mid-cycle).
// Fix: capture burst bits (1/HCLK while sending) into a deep FIFO and
// re-emit BFM-exact pulses (data stable, clk high a full cycle then
// low). Order/count preserved; adds ~2 cycles/bit latency.
// OVERRUN RULE (critical): some senders retry until complete (link-mgmt
// holds, training sb_wrap holds), filling faster (1/HCLK) than the
// emitter drains (1/2HCLK). Dropping BITS destroys des framing for
// everything after, and single-shot packets (D2D PARAM: sent once, no
// retry!) would be lost forever if dropped. So capture is burst-gated:
// a burst is taken only with room for all 128 bits, else the WHOLE
// burst is skipped (sender retries anyway; framing preserved). The FIFO
// is deep (64k bits = 512 bursts) so the gate only engages under true
// pathology (in which case the test should fail on protocol, not on a
// TB artifact).
module sb_gear (
  input  wire clock,
  input  wire reset,
  input  wire in_bit,
  input  wire in_sending,
  output reg  out_bit,
  output reg  out_clk
);
  localparam int DEPTH = 65536;
  reg gmem [0:DEPTH-1];
  reg [15:0] gwpt;
  reg [15:0] grpt;
  wire gempty = (gwpt == grpt);
  // Occupancy with wrap: free slots (reserve one).
  wire [15:0] occ = gwpt - grpt;
  wire room128 = (occ <= 16'(DEPTH-129));
  reg prev_send;
  reg capturing;
  reg [7:0] cap_cnt;
  reg phase;
  // Sticky total forwarded (diagnostic: proves TX reached the gearbox).
  reg [31:0] total_fwd;

  always @(negedge clock) begin
    if (reset) begin
      gwpt <= 16'd0;
      grpt <= 16'd0;
      prev_send <= 1'b0;
      capturing <= 1'b0;
      cap_cnt <= 8'd0;
      phase <= 1'b0;
      out_bit <= 1'b0;
      out_clk <= 1'b0;
      total_fwd <= 32'd0;
    end else begin
      // Burst gate: arm capture at burst start iff a full packet fits.
      // The arming cycle's bit is captured inline (else bit0 is lost).
      if (in_sending && !prev_send) begin
        capturing <= room128;
        if (room128) begin
          gmem[gwpt] <= in_bit;
          gwpt <= gwpt + 16'd1;
          cap_cnt <= 8'd1;
        end else begin
          cap_cnt <= 8'd0;
        end
      end else if (in_sending && capturing && cap_cnt < 8'd128) begin
        gmem[gwpt] <= in_bit;
        gwpt <= gwpt + 16'd1;
        cap_cnt <= cap_cnt + 8'd1;
      end
      if (!in_sending) capturing <= 1'b0;
      prev_send <= in_sending;
      // Emit BFM-style: phase0 data+clk=1, phase1 clk=0 then pop.
      if (!gempty) begin
        if (phase == 1'b0) begin
          out_bit <= gmem[grpt];
          out_clk <= 1'b1;
          phase <= 1'b1;
          total_fwd <= total_fwd + 32'd1;
        end else begin
          out_clk <= 1'b0;
          grpt <= grpt + 16'd1;
          phase <= 1'b0;
        end
      end else begin
        out_clk <= 1'b0;
        phase <= 1'b0;
      end
    end
  end
endmodule
