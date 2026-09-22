# Config (sideband-packet) transport + AHB mailbox — frozen spec

Status: frozen for Phase 4 implementation.

## 1. 32b word transport (FDI/RDI config legs)

Both config legs (`plConfig` host->DUT, `lpConfig` DUT->host, and the
RDI pair) use the same valid/credit discipline as the Chisel `sb_node`
outer port:

* Sender puts `bits`, raises `valid`, and HOLDS both until a 1-cycle
  `credit` pulse is observed. (`sb_ser` freezes mid-packet otherwise.)
* Receiver pulses `credit` when it accepts. `sb_des` has no backpressure
  (accepts any `valid` cycle); `sb_node` returns RX credit per dequeued
  non-management packet.
* Packets are always 4 words, LSB first (`word0 = pkt[31:0]`).
* Credit accounting (`sb_ser`): 32 initial credits, -1 per non-mgmt
  packet sent, +1 per credit pulse. Management packets (packet
  `bits[4:0]` in `{0x10,0x11,0x19}`) bypass credit: they neither consume
  nor (on RX) return it. Receivers must return at most one credit per
  packet or the 6-bit counter wraps to 0 and stalls the serializer.

## 2. AHB MMIO mailbox (`ahb_fdi`)

`HADDR[31]` selects the space: 0 = streaming flit port (unchanged),
1 = config space. `HADDR[3:2]`: `0` = data, `1` = status.

* TX (host->DUT, `plConfig`): 4-deep buffer = one packet. `HREADYOUT`
  low while full-and-waiting-credit (4 buffered, packet in flight).
  Words presented back-to-back, then the entry waits for the fabric
  credit pulse. First packet needs no credit.
* RX (DUT->host, `lpConfig`): 4-deep buffer. `credit` returned per
  accepted word is NOT enough (see wrap rule): the mailbox counts words
  and pulses `tx_credit` once per completed non-management packet
  (management-ness from `word0[4:0]`, same mask as `sb_ser`).
  Overrun (words arrive while 4 unread) sets sticky `rx_overflow`.
* Status read `[3:0] = {rx_overflow, link_error, tx_ready, rx_valid}`.
  Status write clears `rx_overflow`. Data read pops one word.
* `HRESP = link_error` (level): while the flit `link_error` latch is
  set, every AHB transfer completes with ERROR. Reads never stall;
  only config-data writes stall (on TX full).

## 3. Fabric wiring

* `ahb_fdi` <-> `d2d_adapt` <-> `d2d_sb` FDI node: previously tied off
  (`d2d_sb.sv` `outer_tx_credit/rx_bits/rx_valid = 0`). Now live.
* Host TX flows FDI node -> des -> switch `node_to_node` chain -> RDI
  node -> `io_rdi_lp_cfg` (toward the PHY/partner). Packets with
  `bits[58:56]==1` would route to link-mgmt decode instead; host
  packets must avoid that pattern.
* Host RX ("tap"): RDI-ingress packets are copied to the FDI node
  (`sidebandSwitcher` above-`node_to_node` leg, previously dead). The
  tap is lossy if the host stalls (single-pulse broadcast, no
  backpressure into the decode path). Link-mgmt decode is unaffected.
