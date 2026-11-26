# Snapshots

Conformance test data for the HSLuv color math. Ports are tested against
`snapshot-rev4.json`, the current revision.

## Format

JSON keyed by hex color. The 4096 keys are the repeated-digit colors from
`#000000` to `#ffffff`: `#11ee00` is present, `#123456` is not.

```json
"#11ee00": {
  "rgb":   [0.06666666666666667, 0.9333333333333333, 0],
  "xyz":   [0.3080435788862998, 0.6126558588108919, 0.10201901246071324],
  "luv":   [82.52131190083256, -77.39919470828836, 100.94522293122722],
  "lch":   [82.52131190083256, 127.20288272726643, 127.47898819200516],
  "hsluv": [127.47898819200516, 100.00000000000242, 82.52131190083256],
  "hpluv": [127.47898819200516, 308.19522276267344, 82.52131190083256]
}
```

| Field   | Components | Range                                     |
| ------- | ---------- | ----------------------------------------- |
| `rgb`   | R, G, B    | 0–1, gamma-encoded sRGB                   |
| `xyz`   | X, Y, Z    | D65, Y of white is 1                      |
| `luv`   | L, u, v    | L 0–100, u and v about -176 to 176        |
| `lch`   | L, C, h    | L 0–100, C 0 to ~179, h 0–360             |
| `hsluv` | H, S, L    | H 0–360, S and L 0–100                    |
| `hpluv` | H, P, L    | H 0–360, L 0–100, P **not** bounded       |

The intermediate stages are included so a failing port can be debugged one
transformation at a time.

HPLuv limits chroma to what is available at every hue, so it cannot represent all
of sRGB: 3547 entries have P above 100, up to ~1784. Reproduce these, don't clamp.
`hpluvToRgb` is only meaningful for P in 0–100.

## Testing a port

Check both directions for every entry: hex → RGB → XYZ → LUV → LCh → HSLuv/HPLuv,
and HSLuv → hex, HPLuv → hex.

Compare with a tolerance, never exact equality. Ports use `1e-11` to `1e-8`;
`1e-9` is a sane default. Cutting it too fine causes platform-specific failures
([#87](https://github.com/hsluv/hsluv/issues/87)).

## Regenerating

Only when releasing a new revision. Published snapshots are a fixed contract and
are never edited.

```sh
# in hsluv-haxe
haxe -cp src -cp test -main test.Snapshot --interp > snapshot.json
```

Regenerating the current revision must reproduce the committed file byte for byte
in value. The Haxe test suite enforces this — a faulty generator would otherwise
rewrite the expected values for every port at once
([hsluv-haxe#3](https://github.com/hsluv/hsluv-haxe/pull/3)).

## Older files

`snapshot-rev0` through `rev3` are superseded revisions, kept so older port
releases stay verifiable.

`snapshot-rev4-legacy.json` is the same revision 4 data under the pre-2016 field
names `husl`/`huslp` (agreeing to within 2.8e-9). No port uses it. Use
`snapshot-rev4.json`.
