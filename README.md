# UCIe 1.1 Die-to-Die Interface

Single-die side of a UCIe 1.1 link: Transaction layer bridge, Die-to-Die
adapter, and Logical PHY with mainband + sideband paths.

Spec reference: UCIe Consortium, "UCIe 1.1 Specification: Backward
compatible evolution of UCIe for driving an open chiplet ecosystem with
new usage models" (white paper + spec request page):
https://www.uciexpress.org/copy-of-white-papers

Top level: `ucie_top` in `rtl/top/ucie_top.sv`, with clean,
reviewable RTL organized per block under `rtl/` and a repeatable
lint + simulation flow.

## Architecture

```
AHB(64b) <-> ahb_fdi <-> FDI <-> d2d_adapt <-> RDI <-> log_phy <-> AFE
                                                                  |-> MB-AFE (16b data)
                                                                  `-> SB-AFE (serial clk+data)
```

### 1. Protocol layer — `ahb_fdi` (native AHB-Lite 64-bit, direct)

AHB-Lite subordinate to FDI bridge (`rtl/protocol/ahb_fdi.sv`). No
registers, no address map: the AHB data phase IS the streaming transfer.

* Tx push: `HWDATA` drives `lpData_bits` directly; valid is
  `HSEL & HREADY & HWRITE & HTRANS[1]`; `HREADYOUT` is the FDI Tx ready
  on writes (1 on reads/idle, so no `HREADY→HREADYOUT` loop).
* Rx sample: `HRDATA` is driven directly by the FDI Rx bits;
  `HRESP` is always OKAY. `HADDR/HSIZE/HBURST` are ignored (single
  slave, 64-bit only).
* Link controls are discrete pins with original semantics:
  `io_TLlpData_irdy` in, `io_TLplStateStatus[3:0]` out,
  `io_TLplData_bits/valid` out, `io_TLready_to_rcv` in, `io_fault` and
  `io_soft_reset` in. Sequencer behavior unchanged
  (`RESET->ACTIVE` on inband-presence, `LINKRESET` on `soft_reset`).

### 2. D2D adapter — `d2d_adapt`

FDI/RDI bridge plus link-management and sideband/mainband datapaths:

* `d2d_mb` / `d2d_sb`: 64b datapath, parity
  (`par_gen`), stall handling (`fdi_stall`,
  `rdi_stall`), sideband serialize/deserialize, priority queues
  and 1-to-2 / 2-to-1 switches.
* `lnk_mgmt` with 4 link-state engines:
  * `lnk_init`: PARAM exchange (`0x24`) then ACTIVE
    handshake (`0x01` req / `0x11` rsp), drives `plInbandPres`,
    `plRxActiveReq`, `rdi_lpStateReq`.
  * `lnk_rst`: req `0x09` / rsp `0x19`.
  * `lnk_dis`: req `0x0C` / rsp `0x1C`.
  * `par_neg`: req `0x21`, rsp `0x31/0x32`,
    enables `parity_{rx,tx}_enable`.
* Link states observed: `0x0 RESET, 0x1 ACTIVE, 0x9 LINKRESET, 0xB TRAINING?, 0xC DISABLE`.

### 3. Logical PHY — `log_phy`

RDI endpoint, training, and AFE interfacing:

* `rdi_up`, `rdi_map`, `dw_cpl`: RDI streaming
  + config (32b valid/bits/credit) mapping.
* `lnk_train`: RDI state-driven training sequencer with timeout
  counters, sideband message wrapper (`sb_wrap`), pattern
  generation (`pat_gen`), MB init (`mb_init`).
* `sb_chan` + `sb_lser/sb_ldes/sb_lnode`:
  packetized sideband TX/RX over serial AFE.
* `Lanes`: single 16b mainband lane with async-FIFO AFE handshake
  (`txData valid/ready`, `rxData valid/ready`, `rxEn`, `pllLock`).
* CDC: `async_q`, `async_q1`, `AsyncQueueSource/Sink`, `ClockCrossingReg_w16`,
  `AsyncValidSync`, `AsyncResetSynchronizer*`.

### Top-level interfaces (`ucie_top`) — current state

| Group | Signals |
|-------|---------|
| Clock/reset | `HCLK`, `HRESETn` (active-low, synced to active-high inside) |
| Host data (AHB-Lite, 64-bit) | `HSEL`, `HWRITE`, `HTRANS`, `HREADY` in; `HWDATA[63:0]` in; `HRDATA[63:0]`, `HREADYOUT`, `HRESP` (=`link_error`) out. `HADDR[31]` selects streaming (0, `HWDATA`→flit bits) vs config space (1, see below). `HSIZE/HBURST` ignored. |
| Host config (AHB-Lite, `HADDR[31]`=1) | 32b words in `HWDATA[31:0]`: offset 0 = data (write→`plConfig` packet buffer, read←`lpConfig` buffer, pops), offset 4 = status (`{rx_overflow, link_error, tx_ready, rx_valid}`, write clears overflow). See `docs/cfg_spec.md`. |
| Host controls (discrete pins) | `io_TLlpData_irdy` in, `io_TLplStateStatus[3:0]` / `io_TLplData_bits[63:0]` / `io_TLplData_valid` out, `io_TLready_to_rcv` / `io_fault` / `io_soft_reset` in |
| FDI stall | `lpStallAck` out (config legs are internal now: AHB mailbox ↔ `d2d_sb` FDI node) |
| MB-AFE | 16b `txData/rxData`, `txData valid/ready`, `rxData valid/ready`, `rxEn`, `pllLock`, `txFreqSel`, FIFO clk/reset |
| SB-AFE | `txData`, `txClock`, `rxData`, `rxClock`, `rxEn`, `pllLock`, FIFO clk/reset |

The old TileLink-flavored streaming port (`valid/bits/irdy/ready` +
`TLready_to_rcv`, `TLplStateStatus`, `fault`, `soft_reset`) is gone,
replaced by the native AHB map above. See
`rtl/top/ucie_top.sv` and `rtl/protocol/ahb_fdi.sv`. The discrete
top-level FDI config ports are gone: the host reaches the config fabric
only through the AHB mailbox (4-word TX/RX buffers, credit handshake per
`docs/cfg_spec.md`, `HRESP`=`link_error`).

## Host interface: AHB streaming + config mailbox

The TileLink-style data port was replaced by a native AMBA AHB-Lite
64-bit port. `HADDR[31]`=0 is the streaming flit port — no bridge, no
register file: the AHB data phase drives the FDI streaming port directly
(`HWDATA`→flit bits, `HREADYOUT`→ready, `HRDATA`←Rx bits); link controls
stay as discrete pins (`irdy`, `plStateStatus`, `plData`, `ready_to_rcv`,
`fault`, `soft_reset`). `HADDR[31]`=1 is the config mailbox: 32b
sideband-packet words in/out plus a status register (`rx_valid`,
`tx_ready`, `link_error`, `rx_overflow`). Internal FDI/RDI streaming is
unchanged behind it.

## Repository layout

```
.
├── README.md
├── rtl/                  # synthesizable RTL, one file per module
│   ├── top/              # ucie_top
│   ├── protocol/         # ahb_fdi
│   ├── d2d_adapter/      # d2d_adapt, d2d_mb/sb, lnk_mgmt/init/rst/dis, par_neg/gen, fdi/rdi_stall
│   ├── logphy/           # log_phy, lnk_train, mb_init, rdi_up/map, dw_cpl, pat_gen, sb_wrap/chan, Lanes
│   ├── sideband/         # sb_ser/des/node/prioq, sb_lser/ldes/lnode, queues/switches/arbiters
│   └── common/           # async_q/q1, CDC, synchronizers
├── verif/
│   ├── tb/               # testbenches + BFMs (FDI/RDI, TL, MB/SB AFE)
│   ├── tests/            # directed test list
│   ├── sim/              # filelists + simulator Makefiles
│   └── formal/           # SVA properties
├── docs/                 # arch notes, interface specs, state diagrams
└── scripts/              # split/clean/lint helpers
```

All new work lands in `rtl/` (lint-clean) with tests in `verif/`.

## RTL hardening plan

Goal: production-style SystemVerilog, same behavior, no legacy idioms.

1. **Naming**: `ucie_` prefix, `localparam` state/opcode names
   instead of magic `4'hx`/`6'hx`, explicit `always_ff` /
   `always_comb`, `logic` types.
2. **Style**: 2-space indent, `lower_snake_case` ports, header with
   brief + interface table, no tool-annotation comments, `SYNTHESIS`
   guards only where needed.
3. **CDC/reset**: document every clock domain crossing, replace ad-hoc
   shift-reg synchronizers with reviewed `ucie_sync` / `ucie_async_fifo`
   in `rtl/common/`.
4. **Config path**: un-stub FDI `lp/plConfig`, define credit protocol.
5. **Verification**: extend AHB smoke TB -> directed link tests (reset,
   init, active entry, disable, link-reset, parity negotiation, stall)
   with an AFE link partner model.

## References

* UCIe Consortium white papers (UCIe 1.1: "Backward compatible evolution
  of UCIe for driving an open chiplet ecosystem with new usage models",
  PDF download): https://www.uciexpress.org/copy-of-white-papers
* UCIe 1.1 highlights (per Consortium): fully backward compatible with
  1.0; simultaneous multiprotocol with full link-layer functionality for
  streaming protocols; runtime health monitoring/repair (automotive);
  lower-cost packaging bump maps; architectural attributes for compliance
  testing. Layering used here: Protocol -> FDI (flit-aware) -> D2D adapter
  (CRC/retry, link-state mgmt, param negotiation) -> RDI (raw) -> Physical
  (training, lane repair, AFE, sideband).
* AMBA AHB-Lite (target host IF): to be linked once the bridge spec is frozen.

## Quickstart

```sh
# lint (Verilator, run from verif/sim so filelist paths resolve)
cd verif/sim && verilator --lint-only -f filelist.f --top-module ucie_top --timing

# smoke test over the AHB interface (Verilator --binary --timing)
make -C verif/sim sim
```

Smoke (`verif/tb/ucie_top_tb.sv`, 8 checks, all passing): idle
`HREADYOUT/HRESP`/RESET state, Tx push lands directly on FDI bits with
valid raised and dropped after the phase, irdy follows the pin, Rx
sample follows FDI, `fault` pin reaches `lpLinkError`, `soft_reset`
pulse. No link partner is modeled yet, so no AFE traffic is expected.

## Status

* [x] Short block names (`ucie_top`, `ahb_fdi`, …), lint-clean
* [x] Native AHB-Lite 64-bit host IF (`ahb_fdi`, `BASE_ADDR=0x0`) + AHB smoke test passing
* [x] Phase 0 hygiene: `filelist_rtl.f` single source, `verif/tests/regression.list`, `make regress`, shared `verif/tb/common/`
* [x] Phase 1 flit reliability: `MAX_RETRY->link_error` + quiesce, `fmt` decode, `exp_seq` duplicate suppression, `o_flit_link_error/o_flit_overflow` on top, `GATE_ACTIVE` param
* [x] Phase 2 link-mgmt directed tests (`link_mgmt_tb`: PARAM/ACTIVE, LINKRESET 0x09/0x19, DISABLE 0x0C/0x1C, parity 0x21/0x31/0x32 + enables, RETRAIN observation); full SB bring-up (`sb_link_tb`) unchanged
* [x] Phase 3 PHY: `NLANES` param end to end (default 1, target 16), `lane_pll_tb` (4-lane async-FIFO loopback, pllLock=0 negative, rdi overwrite flag)
* [x] Phase 4 host+config: AHB MMIO mailbox (`docs/cfg_spec.md`, 4-word TX/RX, credit handshake, `HRESP`=`link_error`), FDI config wired through `d2d_adapt`/`d2d_sb`, host tap in `sidebandSwitcher`, `ahb_cfg_tb` (TX e2e, backpressure, RX/mgmt/overrun, HRESP)
* [x] Phase 5a-d cross-die ACK/NACK: `docs/ack_spec.md` (0x2A/0x2B, seq in [63:56]), codec in `d2d_sb`, `REMOTE_ACK` plumbing, `sb_ldes` wrap-event fix, `sb_gear` TB wire model; `ack_xchg_tb`, `xcross_tb`, `linkinit_xchg_tb`, `d2d_dual_tb` (+300-cycle latency) all pass
* [ ] Phase 5e dual-die link: `flit_dual_tb` reaches DUAL TRAINED + DUAL
  ACTIVE (PARAM stall fixed via `lnk_init` resend + `lnk_train` drain,
  see below) but flits partial (A->B 7/14, 1-shot retry OK, link_error
  A=1; under debug)
* [ ] Full `make regress` green including `sb_link_tb` bring-up (long)
* [ ] 256B datapath
* [ ] First hardened block review (`ahb_fdi` -> style pass)

## Next steps

Ordered, smallest-first. The current blocker is 1; the rest unblock
once the dual-die link is green.

1. **Finish dual-die flits** (`flit_dual_tb`): PARAM stall is fixed —
    DUAL TRAINED + DUAL ACTIVE now reached via (a) PARAM resend timer
    in `lnk_init` (clear `snt_flag` in PARAM phase without `rcv`,
    ~2048 cycles) and (b) training RX drain in `lnk_train` (accept-and-
    ignore in Active so the TB `sb_gear` training backlog ~400 bursts
    can't head-of-line block PARAM in the shared lower RX queue).
    `SNIFF` is now gap-framed (full 128b bursts). Remaining: A->B 7/14
    (first flit + retry OK, `err_cnt=1`) then `link_error` A=1 — debug
    second-flit/ACK timing, then re-run to flits both ways.
2. **Full `make regress` green**, including the long `link` and
   `flit_dual` targets; keep `sb_link_tb` passing (single-die
   behavior must not change).
3. **256B datapath** (`WORDS_PER_FLIT=32`): widen pack/unpack/slicer,
   RDI to 256b beats, `Lanes` to `NLANES=16`; extend `flit_pack_tb`
   + `flit_stress_tb` to both widths.
4. **Harden `ahb_fdi` first** (style pass per plan above), then the
   flit datapath blocks; add SVA in `verif/formal/` (still empty) for
   CRC/seq-retry/FSM coverage.
5. **Cross-die ACK/NACK hardening**: sideband ACK transport for
   production traffic (Phase 5 covers bring-up-time paths); multi-lane
   (`NLANES=16`) AFE validation in `lane_pll_tb`.
