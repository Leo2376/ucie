# Flit spec freeze — UCIe 1.1 streaming step 1 (this repo)

Status: frozen for implementation. Legacy 64b word path stays default
(`USE_FLIT=0`) until migration completes.

## 1. Widths

| Interface | Frozen value | Notes |
|---|---|---|
| Host (AHB-Lite) | `64b` streaming word, unchanged (`ahb_fdi`) | 7 words = 1 flit payload |
| FDI flit (`flit_pack/unpack`) | `512b` = `64B` | stepping stone to 256B; matches ucb-bar `512b` + WIOWIZ `480+32` |
| RDI chunk | `128b`, 4 beats/flit | ucb-bar compatible (`512/128=4`) |
| MB PHY beat | `16b x NLANES`, `NLANES=1` now, target `16` (std pkg) | `512b` = 32 beats @1 lane, 2 beats @16 lanes |

Legacy RTL today is `64b` on FDI **and** RDI (`d2d_mb`, `rdi_map`,
`log_phy`); that is `1/8` flit, `1/2` RDI chunk — non-compliant, kept only
behind `USE_FLIT=0`.

## 2. 512b streaming flit format (bit numbers, LSB-first on wire)

```
[511:480] hdr[31:0]  = {seq[7:0], fmt[3:0], len[5:0], rsv[14:0]}
[479:32]  payload[447:0] = 7 x 64b AHB words {w6..w0}, w0 first
[31:0]    crc32      = IEEE-802.3 over hdr ++ payload (480b), init
                       0xFFFFFFFF, poly 0x04C11DB7, xorout 0xFFFFFFFF
```

* `fmt`: `0x0` data, `0x1` idle/skip, `0xF` poisoned/retry marker.
* `seq`: 8b flit sequence, increments per data flit, wraps 255->0.
* `len`: always 7 (words) for data; 0 for idle.
* TX computes CRC, appends. RX recomputes, drops on mismatch, asserts `err`.

Full 256B (`2048b`: 236/250B payload + hdr + CRC) is the next step and
reuses the same CRC/retry blocks with `WORDS_PER_FLIT=32`.

## 3. RDI slicing

Flit `f[511:0]` -> 4 beats, LSB first:

```
beat0 = f[127:0], beat1 = f[255:128], beat2 = f[383:256], beat3 = f[511:384]
```

`rdi_map` upgrade path: `128b` beat -> `8x16b` MB beats (1 lane) or
`16 lanes x 16b` in one shot (16-lane target).

## 4. Retry

* Replay buffer: depth 16 flits, indexed by `seq[3:0]`.
* TX stores every data flit; on `nack` or timeout (`TIMEOUT_CYC` param,
  default 1024) retransmits, up to `MAX_RETRY=3`, then `link_error`.
* RX returns `ack_seq` + `nack` pulse per flit. Sideband ACK mapping
  (D2D opcode) is out of scope for step 1 — local `ack/nack` wires only.
* `par_gen` XOR parity is legacy debug only; CRC is authoritative when
  `USE_FLIT=1`.

## 5. Migration

1. `ucie_crc32`, `flit_pack`, `flit_unpack` land alongside `d2d_mb`
   (this change, `USE_FLIT=0` default → no top change).
2. Next: `d2d_mb` gets `USE_FLIT` port, `rdi_map` 128b port, `Lanes`
   array `NLANES`; `ucie_top` param to enable.
3. Then: 256B flit (`WORDS_PER_FLIT=32`), AXI bridge, sideband ACK.
