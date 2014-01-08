# These functions are the mathematical result from Maxima
# DO NOT EXPECT TO UNDERSTAND THE MATH HERE, I used Maxima so
# that neither of us has to!

# All non-husl color math on this page comes from http://www.easyrgb.com
# Thanks guys!

# Hard-coded D65 standard illuminant
refX = 0.95047
refY = 1.00000
refZ = 1.08883
refU = 0.19784 # = (4 * refX) / (refX + (15 * refY) + (3 * refZ))
refV = 0.46834 # = (9 * refY) / (refX + (15 * refY) + (3 * refZ))

refU = (4 * refX) / (refX + (15 * refY) + (3 * refZ))
refV = (9 * refY) / (refX + (15 * refY) + (3 * refZ))

# Used for rgb <-> xyz conversions
# Numbers taken from Maxima file
m =
  R: [ 3.240454162114103, -1.537138512797715, -0.49853140955601 ]
  G: [ -0.96926603050518, 1.876010845446694,  0.041556017530349 ]
  B: [ 0.055643430959114, -0.20402591351675,  1.057225188223179 ]
m_inv =
  X: [ 0.41245643908969,  0.3575760776439,  0.18043748326639  ]
  Y: [ 0.21267285140562,  0.71515215528781, 0.072174993306559 ]
  Z: [ 0.019333895582329, 0.1191920258813,  0.95030407853636  ]


# CIE LUV constants
# http://www.brucelindbloom.com/index.html?LContinuity.html
kappa = 24389 / 27
epsilon = 216 / 24389

# For a given Lightness, Hue, RGB channel, and limit (1 or 0),
# return Chroma, such that passing this chroma value will cause the
# given channel to pass the given limit.
_maxChroma = (L, H) ->
  hrad = H / 360 * 2 * Math.PI
  sinH = Math.sin hrad
  cosH = Math.cos hrad
  sub1 = Math.pow(L + 16, 3) / 1560896
  sub2 = if (sub1 > 216 / 24389) then sub1 else (27 * L / 24389)
  (channel) ->
    [m1, m2, m3] = m[channel]
    top = (12739311 * m3 + 11700000 * m2 + 11120499 * m1) * sub2
    rbottom = 9608480 * m3 - 1921696 * m2
    lbottom = 1441272 * m3 - 4323816 * m1
    bottom = (rbottom * sinH + lbottom * cosH) * sub2
    (limit) ->
      # This is the C value that you can put together with the given L and H
      # to produce a color that with <RGB channel> = 1 or 2. This means that if C
      # goes any higher, the color will step outside of the RGB gamut.
      L * (top - 11700000 * limit) / (bottom + 1921696 * sinH * limit)

# Given Lightness, channel and limit, returns the Hue (in radians) at the point
# where the maximum chroma (the chroma that will make the given channel pass
# the given limit) is smallest. This is the dip in the curve.
_hradExtremum = (L) ->
  lhs = (Math.pow(L, 3) + 48 * Math.pow(L, 2) + 768 * L + 4096) / 1560896
  rhs = 216 / 24389
  sub = if lhs > rhs then lhs else 10 * L / 9033
  (channel, limit) ->
    [m1, m2, m3] = m[channel]
    top = (20 * m3 - 4 * m2) * sub + 4 * limit
    bottom = (3 * m3 - 9 * m1) * sub
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
  he1 = _hradExtremum L
  for channel in ['R', 'G', 'B']
    for limit in [0, 1]
      hrad = he1 channel, limit
      C = maxChroma L, hrad * 180 / Math.PI
      minima_C.push C
  Math.min minima_C...

dotProduct = (a, b) ->
  ret = 0
  for i in [0..a.length-1]
    ret += a[i] * b[i]
  return ret

# Rounds number to a given number of decimal places
round = (num, places) ->
  n = Math.pow 10, places
  return Math.round(num * n) / n

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
    # Error tolerance
    if ch < -0.0001 or ch > 1.0001
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
  'huslp': {}
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

# http://en.wikipedia.org/wiki/CIELUV
Y_to_L = (Y) ->
  if Y <= epsilon
    (Y / refY) * kappa
  else
    116 * Math.pow((Y / refY), 1/3) - 16
L_to_Y = (L) ->
  if L <= 8
    refY * L / kappa
  else
    refY * Math.pow((L + 16) / 116, 3)

conv.xyz.luv = (tuple) ->
  [X, Y, Z] = tuple
  varU = (4 * X) / (X + (15 * Y) + (3 * Z))
  varV = (9 * Y) / (X + (15 * Y) + (3 * Z))
  L = Y_to_L(Y)
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
  varU = U / (13 * L) + refU
  varV = V / (13 * L) + refV
  Y = L_to_Y(L)
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
  # Bad things happen when you reach a limit
  return [100, 0, H] if L > 99.9999999
  return [0, 0, H] if L < 0.00000001
  max = maxChroma L, H
  C = max / 100 * S
  # I already tried this scaling function to improve the chroma
  # uniformity. It did not work very well.
  # C = Math.pow(S / 100,  1 / t) * max
  return [L, C, H]

conv.lch.husl = (tuple) ->
  [L, C, H] = tuple
  return [H, 0, 100] if L > 99.9999999
  return [H, 0, 0] if L < 0.00000001
  max = maxChroma L, H
  S = C / max * 100
  return [H, S, L]

## PASTEL HUSL

conv.huslp.lch = (tuple) ->
  [H, S, L] = tuple
  return [100, 0, H] if L > 99.9999999
  return [0, 0, H] if L < 0.00000001
  max = maxChromaD L
  C = max / 100 * S
  return [L, C, H]

conv.lch.huslp = (tuple) ->
  [L, C, H] = tuple
  return [H, 0, 100] if L > 99.9999999
  return [H, 0, 0] if L < 0.00000001
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

conv.lch.rgb = (tuple) ->
  conv.xyz.rgb conv.luv.xyz conv.lch.luv tuple
conv.rgb.lch = (tuple) ->
  conv.luv.lch conv.xyz.luv conv.rgb.xyz tuple

conv.husl.rgb = (tuple) ->
  conv.lch.rgb conv.husl.lch tuple
conv.rgb.husl = (tuple) ->
  conv.lch.husl conv.rgb.lch tuple
conv.huslp.rgb = (tuple) ->
  conv.lch.rgb conv.huslp.lch tuple
conv.rgb.huslp = (tuple) ->
  conv.lch.huslp conv.rgb.lch tuple

root = {}

# If Stylus is installed, make module.exports work as a plugin
if require?
  try
    stylus = require 'stylus'
    root = ->
      (style) ->
        style.define 'husl', (H, S, L, A) ->
          # TODO: Assert passed types
          [R, G, B] = rgbPrepare conv.husl.rgb [H.val, S.val, L.val]
          new stylus.nodes.RGBA R, G, B, (if A? then A.val else 1)
        style.define 'huslp', (H, S, L, A) ->
          [R, G, B] = rgbPrepare conv.huslp.rgb [H.val, S.val, L.val]
          new stylus.nodes.RGBA R, G, B, (if A? then A.val else 1)

root.fromRGB = (R, G, B) ->
  conv.rgb.husl [R, G, B]
root.fromHex = (hex) ->
  conv.rgb.husl conv.hex.rgb hex
root.toRGB = (H, S, L) ->
  conv.husl.rgb [H, S, L]
root.toHex = (H, S, L) ->
  conv.rgb.hex conv.husl.rgb [H, S, L]
root.p = {}
root.p.toRGB = (H, S, L) ->
  conv.xyz.rgb conv.luv.xyz conv.lch.luv conv.huslp.lch [H, S, L]
root.p.toHex = (H, S, L) ->
  conv.rgb.hex conv.xyz.rgb conv.luv.xyz conv.lch.luv conv.huslp.lch [H, S, L]
root.p.fromRGB = (R, G, B) ->
  conv.lch.huslp conv.luv.lch conv.xyz.luv conv.rgb.xyz [R, G, B]
root.p.fromHex = (hex) ->
  conv.lch.huslp conv.luv.lch conv.xyz.luv conv.rgb.xyz conv.hex.rgb hex

root._conv = conv
root._round = round
root._maxChroma = maxChroma
root._rgbPrepare = rgbPrepare

# If no framework is available, just export to the global object (window.HUSL
# in the browser)
@HUSL = root unless module? or jQuery? or requirejs?
# Export to Node.js
module.exports = root if module?
# Export to jQuery
jQuery.husl = root if jQuery?
# Export to RequireJS
define(root) if requirejs? and define?
