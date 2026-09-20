# Architecture notes (UCIe 1.1, single-die view)

Fill in as blocks are hardened. Start with:

1. Clock/reset domains: `clock` + MB-AFE FIFO clk + SB-AFE clocks.
2. FDI states: RESET 0x0, ACTIVE 0x1, LINKRESET 0x9, DISABLE 0xC.
3. Sideband opcodes: 0x09/0x19 reset, 0x0C/0x1C disable,
   0x24 param, 0x01/0x11 active, 0x21/0x31/0x32 parity.
4. Bring-up sequence: RESET -> PARAM exchange -> ACTIVE handshake
   -> parity negotiation -> streaming.
