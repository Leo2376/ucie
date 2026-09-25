# Flit spec freeze — UCIe 1.1 streaming step 1 (this repo)

Status: frozen for implementation. Legacy 64b word path stays default
(`USE_FLIT=0`) until migration completes.

## 1. Widths

| Interface | Frozen value | Notes |
|---|---|---|
| Host (AHB-Lite) | `64b` streaming word, unchanged (`ahb_fdi`) | 7 words = 1 flit payload (512b mode); 32 words = 1 flit payload (256B mode) |
| FDI flit (`flit_pack/unpack`) | `512b` = `64B` (`WORDS_PER_FLIT=7`) or padded `2304b` (`WORDS_PER_FLIT=32`, payload `256B` + hdr/CRC + reserved) | `WORDS_PER_FLIT` + `RDI_BEAT_W` params; 256B reuses the same CRC/retry blocks |
| RDI chunk | `128b`, 4 beats/flit (512b) or `256b`, 9 beats/flit (256B) | slicer/reasm parameterized by `FLIT_W/BEAT_W` |
| MB PHY beat | `16b x NLANES`, `NLANES=1` now, target `16` (std pkg) | `512b` = 32 beats @1 lane, 2 beats @16 lanes; `2304b` = 144 beats @1 lane, 9 beats @16 lanes |

Legacy RTL today is `64b` on FDI **and** RDI (`d2d_mb`, `rdi_map`,
`log_phy`); that is `1/8` flit, `1/2` RDI chunk — non-compliant, kept only
behind `USE_FLIT=0`.

## 2. Streaming flit format (bit numbers, LSB-first on wire)

`WORDS_PER_FLIT=W` host words per flit (`W=7` for 512b, `W=32` for 256B):

```
[RAW-1:RAW-32] hdr[31:0]  = {seq[7:0], fmt[3:0], len[5:0], rsv[14:0]}
[RAW-33:32]    payload     = W x 64b AHB words {w[W-1]..w0}, w0 first
[31:0]         crc32       = IEEE-802.3 over hdr ++ payload, init
                             0xFFFFFFFF, poly 0x04C11DB7, xorout 0xFFFFFFFF
[FLIT-1:RAW]   reserved    = zero padding to a whole number of RDI beats
                             (outside the CRC)
```

* `RAW = W*64+64`. `FLIT = ceil(RAW/BEAT)*BEAT`: 512b (`W=7`, BEAT=128,
  no padding) or 2304b (`W=32`, BEAT=256, 192b reserved zeros, 9 beats).
* `fmt`: `0x0` data, `0x1` idle/skip, `0xF` poisoned/retry marker.
* `seq`: 8b flit sequence, increments per data flit, wraps 255->0.
* `len`: `W` (7 or 32) for data; 0 for idle.
* TX computes CRC, appends. RX recomputes, drops on mismatch, asserts `err`.

Full 256B (`WORDS_PER_FLIT=32`: 2048b payload + hdr + CRC, padded to
2304b = 9x256b beats) is implemented with the same CRC/retry blocks;
`rdi_map`/`Lanes` carry it as `NCHUNK=FLIT_W/(NLANES*16)` lane chunks
(9 cycles at `NLANES=16`, 144 at `NLANES=1`).

## 3. RDI slicing

Flit `f[FLIT-1:0]` -> `BEATS = FLIT/BEAT` beats, LSB first
(`512/128=4`, `2304/256=9`):

```
beati = f[(i+1)*BEAT-1:i*BEAT], beat0 first
```

`rdi_map`: RDI beats -> lane chunks (`CHUNK=NLANES*16`, `NCHUNK=FLIT/CHUNK`
lane cycles per flit, LSB-first).

## 4. Retry

* Replay buffer: depth 16 flits, indexed by `seq[3:0]`.
* TX stores every data flit; on `nack` or timeout (`TIMEOUT_CYC` param,
  default 1024) retransmits, up to `MAX_RETRY=3`, then `link_error`.
* RX returns `ack_seq` + `nack` pulse per flit; cross-die transport is
  the sideband ACK/NACK codec (`docs/ack_spec.md`, `REMOTE_ACK=1`).
* `par_gen` XOR parity is legacy debug only; CRC is authoritative when
  `USE_FLIT=1`.

## 5. Migration

1. `ucie_crc32`, `flit_pack`, `flit_unpack` land alongside `d2d_mb`
   (this change, `USE_FLIT=0` default → no top change).
2. Next: `d2d_mb` gets `USE_FLIT` port, `rdi_map` 128b port, `Lanes`
   array `NLANES`; `ucie_top` param to enable.
3. Done: 256B flit (`WORDS_PER_FLIT=32`, padded `2304b`, `256b` RDI,
   `NLANES=16` target); unit + stress TBs cover both widths. Next: AXI
   bridge, production sideband ACK load.
