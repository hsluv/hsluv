husl = require '../husl.coffee'

digits = '0123456789abcdef'

snapshot = ->
  samples = {}

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

testPrecision = (numDigits) ->
  # Test how many digits of HUSL decimal precision is enough to unambiguously
  # specify a hex-encoded RGB color. Spoiler alert: it's 4.
  # Adapted from: https://gist.github.com/roryokane/f15bb23abcf9938c0707
  for r1 in digits
    for g1 in digits
      for b1 in digits
        # Assuming that only the least significant hex digit can cause a
        # collision. Otherwise this program uses too much memory.
        console.log "Testing #" + r1 + "_" + g1 + "_" + b1 + "_"
        accum = {}
        for r2 in digits
          for g2 in digits
            for b2 in digits
              hex = '#' + r1 + r2 + g1 + g2 + b1 + b2
              hsl = husl.fromHex(hex)
              key = [ch.toFixed(numDigits) for ch in hsl].join('|')
              if accum[key]
                console.log "FOUND COLLISION:"
                console.log hex, accum[key]
                console.log key
                return
              else
                accum[key] = hex

module.exports =
  snapshot: snapshot
  testPrecision: testPrecision

if require.main == module
  console.log JSON.stringify snapshot()
