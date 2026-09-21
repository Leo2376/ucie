// ucie_crc32: IEEE-802.3 CRC-32 (poly 0x04C11DB7, init all-1, xorout all-1).
//
// Combinational helper for the 512b streaming flit (docs/flit_spec.md):
// crc covers hdr[31:0] ++ payload[447:0] (480b, LSB-first).
// Byte-oriented, reflected (LSB-first) implementation; matches
// Ethernet/ZIP check value (crc of "123456789" = 0xCBF43926).
module ucie_crc32 (
  input  wire [479:0] data,
  output wire [31:0]  crc
);
  function automatic [31:0] crc32_480(input [479:0] d);
    reg [31:0] c;
    integer i, b;
    begin
      c = 32'hFFFFFFFF;
      for (i = 0; i < 60; i = i + 1) begin
        c = c ^ {24'h0, d[i*8+:8]};
        for (b = 0; b < 8; b = b + 1)
          c = c[0] ? (c >> 1) ^ 32'hEDB88320 : (c >> 1);
      end
      crc32_480 = ~c;
    end
  endfunction

  assign crc = crc32_480(data);
endmodule
