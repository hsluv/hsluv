# These functions are the mathematical result from Maxima
# DO NOT EXPECT TO UNDERSTAND THE MATH HERE, I used Maxima so
# that neither of us has to!

# For a given Lightness, Hue, RGB channel, and limit (1 or 0),
# return Chroma, such that passing this chroma value will cause the
# given channel to pass the given limit.
_maxChroma = (L, H) ->
  hrad = H / 360 * 2 * Math.PI
  sinH = Math.sin hrad
  cosH = Math.cos hrad
  sub1 = Math.pow(L + 16, 3) / 1560896
  sub2 = if sub1 > 0.008856 then sub1 else L / 903.3
  (channel) ->
    [m1, m2, m3] = m[channel]
    top = (0.99915 * m1 + 1.05122 * m2 + 1.14460 * m3) * sub2
    rbottom = 0.86330 * m3 - 0.17266 * m2
    lbottom = 0.12949 * m3 - 0.38848 * m1
    bottom = (rbottom * sinH + lbottom * cosH) * sub2
    (limit) ->
      # This is the C value that you can put together with the given L and H
      # to produce a color that with <RGB channel> = 1 or 2. This means that if C
      # goes any higher, the color will step outside of the RGB gamut.
      L * (top - 1.05122 * limit) / (bottom + 0.17266 * sinH * limit)

# Same function as above, rewritten for different partial application order
# (Hue is given in radians)
_maxChroma2 = (L) ->
  sub1 = Math.pow(L + 16, 3) / 1560896
  sub2 = if sub1 > 0.008856 then sub1 else L / 903.3
  (channel) ->
    [m1, m2, m3] = m[channel]
    top = (0.99915 * m1 + 1.05122 * m2 + 1.14460 * m3) * sub2
    rbottom = 0.86330 * m3 - 0.17266 * m2
    lbottom = 0.12949 * m3 - 0.38848 * m1
    (limit, hrad) ->
      sinH = Math.sin hrad
      cosH = Math.cos hrad
      bottom = (rbottom * sinH + lbottom * cosH) * sub2
      L * (top - 1.05122 * limit) / (bottom + 0.17266 * sinH * limit)

# Given Lightness, channel and limit, returns the Hue (in radians) at the point
# where the maximum chroma (the chroma that will make the given channel pass
# the given limit) is smallest. This is the dip in the curve.
_hradExtremum = (L) ->
  lhs = (Math.pow(L, 3) + 48 * Math.pow(L, 2) + 768 * L + 4096) / 1560896
  rhs = 1107 / 125000
  sub = if lhs > rhs then lhs else 10 * L / 9033
  (channel, limit) ->
    [m1, m2, m3] = m[channel]
    top = -3015466475 * m3 * sub + 603093295 * m2 * sub - 603093295 * limit
    bottom = 1356959916 * m1 * sub - 452319972 * m3 * sub
    hrad = Math.atan2(top, bottom)
    # This is a math hack to deal with tan quadrants, I'm too lazy to figure
    # out how to do this properly
    if limit == 0
      hrad += Math.PI
    return hrad

# For a given lightness and hue, return the maximum chroma that fits in 
# the RGB gamut.
maxChroma = (L, H) ->
  result = Infinity
  mc1 = _maxChroma L, H
  # For each channel (red, green and blue)
  for channel in ['R', 'G', 'B']
    mc2 = mc1 channel
    # For each limit (0 and 1)
    for limit in [0, 1]
      C = mc2 limit
      result = C if 0 < C < result
  return result

# For given lightness, returns the maximum chroma. Keeping the chroma value
# below this number will ensure that for any hue, the color is within the RGB
# gamut.
maxChromaD = (L) ->
  minima_C = []
  mc1 = _maxChroma2 L
  he1 = _hradExtremum L
  for channel in ['R', 'G', 'B']
    mc2 = mc1 channel
    for limit in [0, 1]
      hrad = he1 channel, limit
      C = mc2 limit, hrad
      minima_C.push C
  Math.min minima_C...

# All non-husl color math on this page comes from http://www.easyrgb.com
# Thanks guys!

# Used for rgb <-> xyz conversions
m =
  R: [3.2406, -1.5372, -0.4986]
  G: [-0.9689, 1.8758,  0.0415]
  B: [0.0557, -0.2040,  1.0570]
m_inv =
  X: [0.4124, 0.3576, 0.1805]
  Y: [0.2126, 0.7152, 0.0722]
  Z: [0.0193, 0.1192, 0.9505]

dotProduct = (a, b) ->
  ret = 0
  for i in [0..a.length-1]
    ret += a[i] * b[i]
  return ret

# Rounds number to a given number of decimal places
round = (num, places) ->
  n = Math.pow 10, places
  return Math.round(num * n) / n

# Hard-coded D65 standard illuminant
refX = 0.95047
refY = 1.00000
refZ = 1.08883
refU = 0.19784 # = (4 * refX) / (refX + (15 * refY) + (3 * refZ))
refV = 0.46834 # = (9 * refY) / (refX + (15 * refY) + (3 * refZ))

# CIE LAB and LUV constants
lab_e = 0.008856
lab_k = 903.3

# Used for Lab and Luv conversions
f = (t) ->
  if t > lab_e
    Math.pow(t, 1 / 3)
  else
    7.787 * t + 16 / 116
f_inv = (t) ->
  if Math.pow(t, 3) > lab_e
    Math.pow(t, 3)
  else
    (116 * t - 16) / lab_k

# Used for rgb conversions
fromLinear = (c) ->
  if c <= 0.0031308
    12.92 * c
  else
    1.055 * Math.pow(c, 1 / 2.4) - 0.055
toLinear = (c) ->
  a = 0.055
  if c > 0.04045
    Math.pow (c + a) / (1 + a), 2.4
  else
    c / 12.92

# Represents rgb [0-1] values as [0-225] values. Errors out if value
# out of the range
rgbPrepare = (tuple) ->
  tuple = (round(n, 3) for n in tuple)
  for ch in tuple
    # Extremely generous error tolerance
    if ch < -0.2 or ch > 1.2
      throw new Error "Illegal rgb value: #{ch}"
    ch = 0 if ch < 0
    ch = 1 if ch > 1
  (Math.round(ch * 255) for ch in tuple)

# This map will contain our conversion functions
conv =
  'xyz': {}
  'luv': {}
  'lch': {}
  'husl': {}
  'husl2': {}
  'rgb': {}
  'hex': {}

conv.xyz.rgb = (tuple) ->
  R = fromLinear dotProduct m.R, tuple
  G = fromLinear dotProduct m.G, tuple
  B = fromLinear dotProduct m.B, tuple
  return [R, G, B]

conv.rgb.xyz = (tuple) ->
  [R, G, B] = tuple
  rgbl = [toLinear(R), toLinear(G), toLinear(B)]
  X = dotProduct m_inv.X, rgbl
  Y = dotProduct m_inv.Y, rgbl
  Z = dotProduct m_inv.Z, rgbl
  [X, Y, Z]

conv.xyz.luv = (tuple) ->
  [X, Y, Z] = tuple
  varU = (4 * X) / (X + (15 * Y) + (3 * Z))
  varV = (9 * Y) / (X + (15 * Y) + (3 * Z))
  L = 116 * f(Y / refY) - 16
  # Black will create a divide-by-zero error
  if L is 0
    return [0, 0, 0]
  U = 13 * L * (varU - refU)
  V = 13 * L * (varV - refV)
  [L, U, V]

conv.luv.xyz = (tuple) ->
  [L, U, V] = tuple
  # Black will create a divide-by-zero error
  if L is 0
    return [0, 0, 0]
  varY = f_inv((L + 16) / 116)
  varU = U / (13 * L) + refU
  varV = V / (13 * L) + refV
  Y = varY * refY
  X = 0 - (9 * Y * varU) / ((varU - 4) * varV - varU * varV)
  Z = (9 * Y - (15 * varV * Y) - (varV * X)) / (3 * varV)
  [X, Y, Z]

conv.luv.lch = (tuple) ->
  [L, U, V] = tuple
  C = Math.pow Math.pow(U, 2) + Math.pow(V, 2), 1 / 2
  Hrad = Math.atan2 V, U
  H = Hrad * 360 / 2 / Math.PI
  H = 360 + H if H < 0
  [L, C, H]

conv.lch.luv = (tuple) ->
  [L, C, H] = tuple
  Hrad = H / 360 * 2 * Math.PI
  U = Math.cos(Hrad) * C
  V = Math.sin(Hrad) * C
  [L, U, V]

conv.husl.lch = (tuple) ->
  [H, S, L] = tuple
  max = maxChroma L, H
  C = max / 100 * S
  # I already tried this scaling function to improve the chroma
  # uniformity. It did not work very well.
  # C = Math.pow(S / 100,  1 / t) * max
  return [L, C, H]

conv.lch.husl = (tuple) ->
  [L, C, H] = tuple
  max = maxChroma L, H
  S = C / max * 100
  return [H, S, L]

## EXPERIMENTAL HUSL VARIANT

conv.husl2.lch = (tuple) ->
  [H, S, L] = tuple
  max = maxChromaD L
  C = max / 100 * S
  # I already tried this scaling function to improve the chroma
  # uniformity. It did not work very well.
  # C = Math.pow(S / 100,  1 / t) * max
  return [L, C, H]

conv.lch.husl2 = (tuple) ->
  [L, C, H] = tuple
  max = maxChromaD L
  S = C / max * 100
  return [H, S, L]

conv.rgb.hex = (tuple) ->
  hex = "#"
  tuple = rgbPrepare tuple
  for ch in tuple
    ch = ch.toString(16)
    ch = "0" + ch if ch.length is 1
    hex += ch
  hex

conv.hex.rgb = (hex) ->
  if hex.charAt(0) is "#"
    hex = hex.substring 1, 7
  r = hex.substring 0, 2
  g = hex.substring 2, 4
  b = hex.substring 4, 6
  [r, g, b].map (n) ->
    parseInt(n, 16) / 255

conv.husl.rgb = (tuple) ->
  conv.xyz.rgb conv.luv.xyz conv.lch.luv conv.husl.lch tuple
conv.rgb.husl = (tuple) ->
  conv.lch.husl conv.luv.lch conv.xyz.luv conv.rgb.xyz tuple

root = {}

# If Stylus is installed, make module.exports work as a plugin
try
  stylus = require 'stylus'
  root = ->
    (style) ->
      style.define 'husl', (H, S, L, A) ->
        # TODO: Assert passed types
        [R, G, B] = rgbPrepare conv.husl.rgb [H.val, S.val, L.val]
        new stylus.nodes.RGBA R, G, B, (if A? then A.val else 1)
      style.define 'husl2', (H, S, L, A) ->
        [R, G, B] = rgbPrepare conv.xyz.rgb conv.luv.xyz conv.lch.luv conv.husl2.lch [H.val, S.val, L.val]
        new stylus.nodes.RGBA R, G, B, (if A? then A.val else 1)

root.husl = (H, S, L, noHex = false) ->
  rgb = conv.husl.rgb [H, S, L]
  return rgb if noHex
  conv.rgb.hex rgb
root.rgb = (R, G, B) ->
  conv.rgb.husl [R, G, B]
root.hex = (hex) ->
  conv.rgb.husl conv.hex.rgb hex
# TESTING
root.husl2 = (H, S, L, noHex = false) ->
  rgb = conv.xyz.rgb conv.luv.xyz conv.lch.luv conv.husl2.lch [H, S, L]
  return rgb if noHex
  conv.rgb.hex rgb
root.rgb2 = (R, G, B) ->
  conv.lch.husl2 conv.luv.lch conv.xyz.luv conv.rgb.xyz [R, G, B]
root.hex2 = (hex) ->
  conv.lch.husl2 conv.luv.lch conv.xyz.luv conv.rgb.xyz conv.hex.rgb hex
root._conv = conv
root._maxChroma = maxChroma
root._rgbPrepare = rgbPrepare

# Export to Node.js
module.exports = root if module?
# Export to jQuery
jQuery.husl = root if jQuery?