# This function is the mathematical result from Maxima
# DO NOT EXPECT TO UNDERSTAND THE MATH HERE, I used Maxima so
# that neither of us has to!
#
# For a given lightness and saturation, return the maximum
# chroma that fits in the RGB gamut. When we have the maximum
# chroma, we can protect the user from stepping outside of
# the RGB gamut.

maxChroma = (L, H) ->
  # Pre-calculate some pluggable values
  hrad = H / 360 * 2 * Math.PI
  sinH = Math.sin hrad
  cosH = Math.cos hrad
  sub1 = Math.pow(L + 16, 3) / 1560896
  sub2 = if sub1 > 0.008856 then sub1 else L / 903.3
  result = Infinity
  # For each channel (red, green and blue)
  for row in m
    # Get the relevant matrix values and plug them into
    # some variables to be used later
    [m1, m2, m3] = row
    top = (0.99914902410024 * m1 + 1.05121573691680 * m2 + 1.14459523831237 * m3) * L
    rbottom = (0.86329789712775 * m3 - 0.17265957942555 * m2) * sinH
    lbottom = (0.12949468478388 * m3 - 0.38848405435164 * m1) * cosH
    bottom = rbottom + lbottom
    # Solve for <RGB channel> = 1
    # This is the C value that you can put together with the given L and H
    # to produce a color that with <RGB channel> = 1. This means that if C
    # goes any higher, the color will step outside of the RGB gamut.
    C = (top * sub2 - 1.05121573691680 * L) / (bottom * sub2 + 1.7265957942555 * sinH)
    # We have to do this for every channel and take the smallest value
    result = C if 0 < C < result
    # Increasing C might decrease an RGB channel below zero, so we do the
    # same solving for <RGB channel> = 0. TODO: do some math to see if this
    # step can be omitted.
    C = top / bottom
    result = C if 0 < C < result
  return result

# All non-husl color math on this page comes from http://www.easyrgb.com
# Thanks guys!

# Used for rgb <-> xyz conversions
m = [
  [3.2406, -1.5372, -0.4986]
  [-0.9689, 1.8758,  0.0415]
  [0.0557, -0.2040,  1.0570]
]
m_inv = [
  [0.4124, 0.3576, 0.1805]
  [0.2126, 0.7152, 0.0722]
  [0.0193, 0.1192, 0.9505]
]

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
    if ch < 0 or ch > 1
      throw new Error "Illegal rgb value"
  (Math.round(ch * 255) for ch in tuple)

# This map will contain our conversion functions
conv =
  'xyz': {}
  'luv': {}
  'lch': {}
  'husl': {}
  'rgb': {}
  'hex': {}

conv.xyz.rgb = (tuple) ->
  R = fromLinear dotProduct m[0], tuple
  G = fromLinear dotProduct m[1], tuple
  B = fromLinear dotProduct m[2], tuple
  return [R, G, B]

conv.rgb.xyz = (tuple) ->
  [R, G, B] = tuple
  rgbl = [toLinear(R), toLinear(G), toLinear(B)]
  X = dotProduct m_inv[0], rgbl
  Y = dotProduct m_inv[1], rgbl
  Z = dotProduct m_inv[2], rgbl
  [X, Y, Z]

conv.xyz.luv = (tuple) ->
  [X, Y, Z] = tuple
  varU = (4 * X) / (X + (15 * Y) + (3 * Z))
  varV = (9 * Y) / (X + (15 * Y) + (3 * Z))
  L = 116 * f(Y / refY) - 16
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
  Hrad = Math.atan2 U, V
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
  return [L, C, H]

conv.lch.husl = (tuple) ->
  [L, C, H] = tuple
  max = maxChroma L, H
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

# Main conversion chains, don't include them in conv to avoid confusion
huslToRgb = (tuple...) ->
  conv.xyz.rgb conv.luv.xyz conv.lch.luv conv.husl.lch tuple
rgbToHusl = (tuple...) ->
  conv.lch.husl conv.luv.lch conv.xyz.luv conv.rgb.xyz tuple

root = {}

# If Stylus is installed, make module.exports work as a plugin
try
  stylus = require 'stylus'
  root = ->
    (style) ->
      style.define 'husl', (H, S, L) ->
        # TODO: Assert passed types, allow passing alpha channel
        [R, G, B] = rgbPrepare huslToRgb [H.val, S.val, L.val]
        new stylus.nodes.RGBA(R, G, B, 1)

root.husl = (H, S, L) ->
  conv.rgb.hex huslToRgb H, S, L
root.rgb = (R, G, B) ->
  rgbToHusl R, G, B
root.hex = (hex) ->
  rgbToHusl conv.hex.rgb hex
root._conv = conv

# Export to Node.js
module.exports = root if module?
# Export to jQuery
jQuery.husl = root if jQuery?