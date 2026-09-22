# Architecture notes (UCIe 1.1, single-die view)

1. Clock/reset domains: `clock` + MB-AFE FIFO clk + SB-AFE clocks.
2. FDI states: RESET 0x0, ACTIVE 0x1, LINKRESET 0x9, DISABLE 0xC.
3. Sideband opcodes: 0x09/0x19 reset, 0x0C/0x1C disable,
   0x24 param, 0x01/0x11 active, 0x21/0x31/0x32 parity.
4. Bring-up sequence: RESET -> PARAM exchange -> ACTIVE handshake
   -> parity negotiation -> streaming.

## Implementation status (phases 0-3, Sep 2026)

* Flit retry (`flit_pack`): stop-and-wait, `MAX_RETRY=3 -> link_error`
  latch + quiesce (no unbounded retry storms).
* Flit RX (`flit_unpack`): `fmt` decode (data/idle/poison/len check) +
  `exp_seq` window: in-window accepted, `exp-1` duplicates re-acked
  without re-streaming, out-of-window nacked. Cross-die ACK/NACK via
  sideband still future (local wires only).
* Datapath errors surface at `ucie_top.o_flit_link_error/o_flit_overflow`.
* `d2d_mb_flit` has `GATE_ACTIVE` (0 = test without bring-up, 1 =
  production link gating).
* Parity negotiation fixes: RX enable latches on accepted `0x32`,
  TX enable sticky on observed `0x31`.
* PHY: `NLANES` param (`Lanes`/`rdi_map`/`log_phy`/`ucie_top`,
  default 1, 16 = std-pkg target, flit128 striped `512/(NLANES*16)`
  chunks); legacy 64b path is single-lane only. `rdi_map` legacy RX
  has a sticky `rx_overwrite` flag (hierarchical check) proving no
  back-to-back data loss by construction.
* Known limits: SB RX queues have no flush on state change (partner
  BFM uses dup-suppression); 256B flits need a wider datapath
  (`WORDS_PER_FLIT=32` elaboration-checked, still 512b).
