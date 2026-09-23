# Cross-die flit ACK/NACK over sideband — frozen spec

Status: frozen for Phase 5 implementation.

## 1. Why

`flit_pack` retransmits on `nack`/timeout and advances on `ack_seq`,
but both arrive over LOCAL wires from the on-die `flit_unpack`
(`d2d_mb_flit`). Across dies the feedback must travel the sideband
(D2D domain), like link-management messages.

## 2. Opcodes and packet format (128b, LSB-first on wire)

New D2D-domain codes: `ACK = 0x2A`, `NACK = 0x2B` (no clash with
`0x01/0x11/0x09/0x19/0x0C/0x1C/0x21/0x31/0x32/0x24/...`).

```
[127:64]  0
[63:56]   seq (ACK only; NACK sends 0x00, stop-and-wait needs no seq)
[55:48]   0x00
[47:40]   0x00 (reserved)
[39:32]   code (0x2A ACK / 0x2B NACK)
[31:22]   0x080
[21:14]   0x04 (D2D-RSP class)
[13:5]    0
[4]       1
[3:0]     2 (message format)
```

`seq` lives in `[63:56]` because the `d2d_sb` decode mask
(`0xffffff003fc01f`, low 56 bits) ignores exactly that byte: one
`==` entry matches every seq value, and the raw bits give the seq.
`[47:40]` stays 0 for future use.

Decode entries (on the masked word; the mask zeroes `[31:22]`, so only
dir+fmt appear below): `0x00002A00010012 -> 0x2A`,
`0x00002B00010012 -> 0x2B`. `io_sideband_rcv` stays 0 for both
(link-mgmt never sees them).

## 3. Codec placement (`d2d_sb`)

* TX: `io_ack_tx_valid/seq`, `io_nack_tx` (from the local unpack).
  1-deep pending regs; template mux priority link-mgmt (`snt!=0`) >
  NACK > ACK; pending clears when the switch takes the packet
  (`valid & below_inner_ready`). Link-mgmt traffic only exists during
  bring-up, ACK/NACK only after — conflicts are rare but arbitrated.
* RX: decode match on the RDI-ingress merge (partner packets) gives
  `io_ack_rx_valid/seq`, `io_nack_rx`, edge-detected (1-cycle, safe if
  the queue ever holds a packet >1 cycle). Duplicate ACKs are harmless
  (pack re-acks idempotently); the unpack-side `exp_seq` window already
  drops duplicate DATA.
* Host-injected packets with code `0x2A/0x2B` would inject ACKs:
  reserved codes, hosts must not craft them (future: filter).

## 4. Modes (`REMOTE_ACK` param, default 0)

* 0 (local, all existing TBs): pack consumes the on-die unpack
  `ack/nack` directly; codec outputs are still driven (harmless).
* 1 (production/dual): pack consumes decoded partner `ack/nack`;
  local unpack output goes to the encoder. `USE_FLIT=1` required.

## 5. Credit notes

ACK/NACK are normal (non-mgmt, low5=`0x12`) packets: they consume one
`sb_ser` credit each way (32 initial, plenty) and return RX credit on
dequeue. The host tap (Phase 4) copies partner ACKs to the mailbox;
the dual TB drains it (overflow is status-only).

## 6. Test plan

* `ack_xchg_tb`: two `d2d_sb` cross-connected at RDI 32b (no training
  gates in `d2d_sb`): ACK seq both directions, NACK, back-to-back
  order, mgmt priority, decode quiet (`rcv==0`).
* `flit_dual_tb`: two `ucie_top` (`USE_FLIT=1, REMOTE_ACK=1`), crossed
  MB + SB AFEs, real training; A->B and B->A flits match; MB error
  injection still delivers via retry.

## 7. TB wire model notes (`verif/tb/common/sb_gear.sv`)

Same-clock forwarding of `txData/txClock` 1:1 breaks the des (needs
edges away from local posedges), so the gearbox captures burst bits
and re-emits BFM-exact 2-HCLK/bit pulses. Two subtleties found
debugging dual bring-up:

* Link-mgmt sends each template ONCE (`snt_flag` latches on first
  accept; no retry, no timeout at this level). A dropped PARAM is
  therefore fatal: capture is burst-gated (whole bursts only, never
  partial — partial drops destroy des framing for everything after).
* Retry-until-complete senders (training `sb_wrap`, pattern gen) fill
  faster than the emitter drains, so the FIFO is deep (64k bits) and
  the gate only engages under true pathology.
