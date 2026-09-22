// ucie_tb_common: shared helpers for all testbenches.
// Negedge-drive convention (avoids posedge races under Verilator --timing).
`ifndef UCIE_TB_COMMON_SV
`define UCIE_TB_COMMON_SV
package ucie_tb_common;
  // Xorshift64 PRNG for stress patterns.
  function automatic [63:0] xorshift64(input [63:0] s);
    reg [63:0] x;
    begin
      x = s;
      x ^= x << 13; x ^= x >> 7; x ^= x << 17;
      xorshift64 = x;
    end
  endfunction
endpackage
`endif
