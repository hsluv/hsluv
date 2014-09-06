husl = require '../husl.coffee'

snapshot = ->
  samples = {}

  digits = '0123456789abcdef'

  # Take 16 ^ 3 = 4096 samples
  for r in digits
    for g in digits
      for b in digits
        hex = '#' + r + r + g + g + b + b
        rgb = husl._conv.hex.rgb hex
        xyz = husl._conv.rgb.xyz rgb
        luv = husl._conv.xyz.luv xyz
        lch = husl._conv.luv.lch luv
        samples[hex] =
          rgb: rgb
          xyz: xyz
          luv: luv
          lch: lch
          husl: husl._conv.lch.husl lch
          huslp: husl._conv.lch.huslp lch

  return samples

module.exports = snapshot: snapshot

if require.main == module
  console.log JSON.stringify snapshot()
