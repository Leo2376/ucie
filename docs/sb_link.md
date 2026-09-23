# Sideband link protocol (as implemented in `rtl/`)

Serial sideband between the two dies: 1 data wire + 1 forwarded clock,
`io_sbAfe_txData/txClock` out, `io_sbAfe_rxData/rxClock` in.

## Bit layer

- TX (`sb_lser`): each 128-bit packet shifts LSB-first, `tx = data[0]`,
  right-shift per `HCLK`, `txClock = sending & HCLK`. 128 clock pulses
  per packet (`sendCount` 0..0x7f), line idle between packets.
- RX (`sb_ldes`): `recvCount` increments on **posedge of the remote
  clock**; on the local clock, `io_in_bits` is captured into `data[N]`
  while the delayed count equals N. After 128 edges `receiving` drops
  and the 128-bit packet is presented (`out_valid = ~receiving`, held
  until downstream accepts). So a partner must present bit N on
  `rxData` and pulse `rxClock`, 128 pulses per packet, LSB first.
- Same-clock TB: run the partner on `HCLK`; sample `txData` on
  `posedge txClock`; drive `rxData`+`rxClock` pulses the same way.

## Packet layer (128-bit)

```
[127:64] params / upper       (PARAM capabilities live up here)
[63:48]  domain              (0500 = D2D mgmt, 0600 = SBINIT, 0200 = RDI bringup)
[47:40]  00
[39:32]  message code        (01 ACTIVE, 09 LINKRESET, 0c DISABLE, ...)
[21:14]  direction/class     (03 D2D-REQ, 04 D2D-RSP, 07 parity-REQ, 08 parity-RSP,
                               01/02 RDI bringup, 91/95/9a SBINIT phase)
[13:5]   0
[4:0]    format              (12 = message, 1b = PARAM, 00 = SBINIT probe)
```

Internal queues carry 143-bit entries = `{15'b0, 128-bit packet}`
(`lnk_train _GEN_146`, `d2d_sb`/`rdi_up` templates).

Known packets (from `d2d_sb` send table, `lnk_train`, `rdi_up`):

| Packet (low bits) | Meaning |
|---|---|
| `…050000012000c012` | D2D ACTIVE req (0x1) |
| `…0500000120010012` | D2D ACTIVE rsp (0x11) |
| `…050000092000c012` / `…0920010012` | LINKRESET req/rsp (0x9/0x19) |
| `…0500000c2000c012` / `…0c20010012` | DISABLE req/rsp (0xc/0x1c) |
| `…050000002001c012` / `…020012`/`…120020012` | parity req (0x21) / rsp (0x31/0x32) |
| `488000050000002000401b` | PARAM req (0x24, caps in upper bits) |
| `…0600000040244000` | SBINIT probe (substate 2) |
| `…0600000140254012` / `…0268012` | SBINIT exchange (substate 4/6) |
| `…0200000140004012` / `…04008012` | RDI bringup exchange (LinkInit) |

## Bring-up sequence to Active

`lnk_train.currentState`: 0 RESET → 1 SBINIT → 2 MBINIT → 3 LinkInit →
4 Active (`rdiBringup_io_active`), 5 error. `io_rdi_plInbandPres` (which
unblocks the whole D2D side) asserts only in state 4
(`log_phy`: `plInbandPres = (currentState == 4)`).

- State 0→1: MB + SB `pllLock` and a 20-cycle counter.
- State 1 (SBINIT, `sbInitSubState` 0..7): pattern phase via `pat_gen`
  (sub 0/1), then 3 `sb_wrap` request/response exchanges (send at sub
  2/4/6, complete at 3/5/7). `sb_wrap` sends the 128-bit packet and
  waits for a response matching `[4:0]`, `[21:14]`, `[39:32]` of the
  request, else times out.
- State 2 (MBINIT): `mb_init` + `sb_wrap`, timeout `0x61a800` (~6.4M).
- State 3 (LinkInit): `rdi_up` messages through `sb_wrap`, timeout
  `0xf4240` (~1M). `rdi_up` starts at `resetSubstate=2`, sends its packet
  at substate 3, reaches `state=1` (ACTIVE) on response → `io_active`.
- State 4: Active. D2D `lnk_init` then runs PARAM (`0x24`) + ACTIVE
  (`0x01`/`0x11`) over the same serial link (RDI-config path through
  `sb_chan` upper node → switcher → serial).

## Partner BFM rules

1. Sample TX on `posedge txClock`, assemble 128 bits LSB-first.
2. Training packets (`0600…`, `0200…`, any domain): reply with the match fields
   `[4:0]`, `[21:14]`, `[39:32]` echoed (partner-alive ack; echo works).
3. D2D packets (`0500…`, `0488…`): reply with the exact RSP template
   for the decoded opcode (table above).
4. Shift the response on `rxData` with 128 `rxClock` pulses, LSB first.
5. Timeouts are long; run millions of cycles (Verilator-fast).

## RTL fix: RX routing to training (2026-09-20)

Bug: `sidebandOneInTwoOutSwitch_2` routed serial-RX packets to the
training engine only when `bits[58:56]==0`. No defined packet satisfies
that — not patterns (`AA..A` has `[58:56]==010`), not training messages
(`0600…`/`0200…` have 6/2), not D2D messages. The training RX path
(`sb_wrap`, `pat_gen` detect) was unreachable: the pattern phase always
hit its 6.4M-cycle timeout with `status=1`, killing training
(`train=5`, link error `0xa`). Observed: responses assembled correctly
in `sb_ldes` but `patternDetectedCount` stayed 0 forever.

Fix: `ROUTE_TRAIN` parameter on the switch (default 0 = legacy),
enabled only for the serial-RX instance in `sidebandSwitcher_1`:
training domains (`0600`, `0200`, later `0002` for MBINIT) and
non-message packets (patterns) route inner; D2D-domain messages still
route up to RDI. Above-switch instance unchanged (already fixed with
`ROUTE_ALL_INNER=1` on its RDI side).

## Bring-up to ACTIVE (2026-09-21, `LINKBRINGUP PASS`)

Five defects blocked `sb_link_tb` past training; all fixed, link now
reaches `FDI/ACTIVE` (`tb_state==1`, `fdi_req==1`):

1. **TB held LINKRESET during training.** `tb_soft_rst=1` forces RDI
   state `9`, which the training FSM treats as fatal (`train=5`), and
   D2D reset traffic contends with training on the shared serial link.
   Fix (TB): `tb_soft_rst=0` throughout; the protocol side requests
   ACTIVE by itself once `inbandPres` asserts. Separate train/link
   timeout budgets.
2. **`rdi_up` deadlock (substate 2→3).** Bringup waited for
   `nextState==1` (a D2D ACTIVE request) before even sending its
   message — but D2D `lnk_init` waits for `train==4`, which waits for
   this exchange. Fix (RTL): substate 2→3 unconditional; the message
   can only transmit once training reaches LinkInit anyway (sb path
   connected in train state 3 only).
3. **`rdi_up` deadlock (substate 5→6).** After the first exchange's
   status handshake the wrapper returns to idle, so waiting for another
   *status* handshake (`_T_33`) can never fire. Substate 5 presents the
   second message and must wait for the *request* handshake (`_T_21`).
   Fix (RTL): `_GEN_17 = sub5 ? (_T_21 ? 6 : 5) : ...` (dropped the
   now-unused `_GEN_10`).
4. **MBINIT responses misrouted.** `mb_init` uses domain `0002`,
   which `ROUTE_TRAIN` sent up to RDI instead of training, so MBINIT
   burned the full 6.4M-cycle timeout. Fix (RTL): `0002` added to
   `train_domain`.
5. **`sb_lser` drops packets presented mid-burst.** `waited` re-arms
   32 cycles after burst *start* (bursts are 128), so a packet
   arriving mid-burst is dequeued upstream but never loaded (shift has
   priority over load in `data`). Training never hits this (large
   inter-burst gaps); the first D2D PARAM does. Fix (RTL): ready gated
   on `waited & ~sending & gap_ok` with a 3-cycle post-burst gap.
6. **`sb_lnode` drops TX bit 58.** `{bits[127:59],1'b0}` wiring forced
   bit 58 to 0, corrupting the domain of D2D messages (`0500`→`0100`
   on the wire; training packets unaffected). Fix (RTL): shift the
   full 128b word.
7. **BFM answered duplicates 3×.** Late duplicate echoes accumulated
   as stale packets in RX queues and head-of-line blocked later
   traffic. Fix (TB): answer each distinct packet once.

8. **`sb_ldes` completes one edge early (2026-09-23).** `receiving`
   dropped when `recvCount==0x7f` was *observed* (127 edges), so the
   packet presented before bit127 arrived; bit127 spilled into the
   next packet's `data_0`, and every packet lost its top bit. Invisible
   until now: every defined sideband packet has `bit127==0` and all
   matching/CRC is on low bits. Found by a lser→des loopback TB with
   single-bit packets (`xcross_tb`). Fix (RTL): wrap-*event*
   detect (`prev==0x7f && count==0x00`) + `prev_count` reg; packet
   presents with data_127 correct in the same cycle.

Note for later: RX queues have no flush on state change, so any
future stale packet would block the same way; consider drain-on-idle
hardening (see flit-spec retry work).

## MBINIT is timeout-driven (2026-09-23)

`mb_init` templates (`0x20000a54000001b`, `0x20000aa4000001b`) have
`[4:0]=0x1b` (message) but `[63:48]=0x0000` (not a train domain), so
the `ROUTE_TRAIN` switch sends them UP to RDI, never to either side's
training logic. Both sides therefore burn 2×6.4M-cycle `sb_wrap`
timeouts in train state 2 and advance anyway. Single-die bring-up is
fast only because the BFM *echoes* these messages back (same match
shape), completing the waiters in ~1000 cycles. Consequences:

* Dual-die bring-up needs ~13M extra cycles in MBINIT. Budget train
  timeouts at 30M cycles (`flit_dual_tb`).
* If MBINIT ever needs a real exchange, either give its messages the
  `0002` domain (matching the `train_domain` entry the switch already
  has) or route `code==0x40` inner. Until then: do not "fix" the
  timeouts away — both sides rely on them identically.
