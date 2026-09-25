// ucie_crc32: IEEE-802.3 CRC-32 (poly 0x04C11DB7, init all-1, xorout all-1).
//
// Combinational helper for streaming flits (docs/flit_spec.md):
// crc covers hdr[31:0] ++ payload (LSB-first). Default DATA_W=480 covers
// the 512b flit (hdr ++ 7x64b); WORDS_PER_FLIT=32 uses DATA_W=2080
// (hdr ++ 32x64b). Byte-oriented, reflected (LSB-first) implementation;
// matches Ethernet/ZIP check value (crc of "123456789" = 0xCBF43926).
module ucie_crc32 #(
  parameter int DATA_W = 480
) (
  input  wire [DATA_W-1:0] data,
  output wire [31:0]  crc
);
  localparam int NBYTES = DATA_W / 8;
  initial begin
    if (DATA_W % 8 != 0) $error("ucie_crc32: DATA_W must be a multiple of 8");
  end
  function automatic [31:0] crc32(input [DATA_W-1:0] d);
    logic [31:0] c;
    int i, b;
    begin
      c = 32'hFFFFFFFF;
      for (i = 0; i < NBYTES; i = i + 1) begin
        c = c ^ {24'h0, d[i*8+:8]};
        for (b = 0; b < 8; b = b + 1)
          c = c[0] ? (c >> 1) ^ 32'hEDB88320 : (c >> 1);
      end
      crc32 = ~c;
    end
  endfunction

  assign crc = crc32(data);
endmodule
