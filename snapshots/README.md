# Snapshots

A snapshot is the conformance test data for one revision of the HSLuv color math.
Every implementation is expected to reproduce the values in the current snapshot,
which is how we know that ports in different languages agree with each other.

`snapshot-rev4.json` is the current snapshot. Use it for new ports.

## Format

A snapshot is a JSON object keyed by sRGB hex color. The 4096 keys are every
combination of repeated hex digits, from `#000000` to `#ffffff` — `#11ee00` is
present, `#123456` is not. This samples the sRGB cube evenly on a 16×16×16 grid,
without shipping all 16777216 colors.

Each value holds the full chain of transformations for that color, as arrays of
three numbers:

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

| Field   | Components | Range                                         |
| ------- | ---------- | --------------------------------------------- |
| `rgb`   | R, G, B    | 0–1, gamma-encoded sRGB                        |
| `xyz`   | X, Y, Z    | D65 white point, Y of white is 1               |
| `luv`   | L, u, v    | L is 0–100; u and v are roughly -176 to 176    |
| `lch`   | L, C, h    | L is 0–100, C is 0 to ~179, h is 0–360 degrees |
| `hsluv` | H, S, L    | H is 0–360 degrees, S and L are 0–100          |
| `hpluv` | H, P, L    | H is 0–360 degrees, L is 0–100, **P is not bounded** |

The intermediate values are included on purpose. When a port disagrees with the
snapshot, comparing each stage tells you which transformation is wrong instead of
leaving you to guess.

Note the ordering difference: `lch` and `luv` put lightness first, while `hsluv`
and `hpluv` put hue first, matching how the color spaces are conventionally
written.

### HPLuv saturation above 100

HPLuv restricts chroma to what is available at *every* hue for a given lightness,
so it cannot represent every sRGB color. For saturated colors the snapshot
therefore contains P values above 100 — 3547 of the 4096 entries, up to about
1784. These are correct outputs of the math, not errors. A port must reproduce
them rather than clamping, and `hpluvToRgb` is only meaningful for P in 0–100.

## Testing a port against a snapshot

Test both directions for every entry:

- forward: hex → RGB → XYZ → LUV → LCh → HSLuv and HPLuv
- backward: HSLuv → hex, and HPLuv → hex

Compare floating point values with a tolerance, never for exact equality.
Different languages and platforms produce slightly different last digits from the
same arithmetic. Existing ports use tolerances between `1e-11` and `1e-8`; `1e-9`
is a reasonable default. If a port is close to its tolerance it will fail
sporadically on some platforms, as happened in
[issue #87](https://github.com/hsluv/hsluv/issues/87) on FreeBSD.

## Regenerating a snapshot

We generate a new snapshot only when releasing a new revision of the color math.
Existing snapshots are never edited: a published revision is a fixed contract that
ports depend on.

The generator lives in the reference implementation,
[hsluv-haxe](https://github.com/hsluv/hsluv-haxe):

```sh
haxe -cp src -cp test -main test.Snapshot --interp > snapshot.json
```

Regenerating the *current* revision must reproduce the committed file. The Haxe
test suite checks exactly this, because a faulty generator would otherwise rewrite
the expected values for every port at once — which is what
[hsluv-haxe#3](https://github.com/hsluv/hsluv-haxe/pull/3) fixed, where the
generator dropped the X channel and wrote Z twice.

## Older revisions

`snapshot-rev0.json` through `snapshot-rev3.json` cover superseded revisions of
the math. They are kept so that older releases of a port remain verifiable, and
should not be used for new work.

`snapshot-rev4-legacy.json` is the same revision 4 data under the project's
earlier field names, `husl` and `huslp` instead of `hsluv` and `hpluv`. The values
agree with `snapshot-rev4.json` to within 3e-9. It exists only for ports written
before the 2016 rename; no port in this organization uses it. **Use
`snapshot-rev4.json`.**
