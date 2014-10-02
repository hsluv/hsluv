# The math for most of this module was taken from:
#
#  * http://www.easyrgb.com
#  * http://www.brucelindbloom.com
#  * Wikipedia
#

# All numbers taken from math/bounds.wxm wxMaxima file:
#
#    fpprintprec: 16;
#    float(M_XYZ_RGB);
#    float(M_RGB_XYZ);
#    float(refX);
#    float(refY);
#    float(refZ);
#    float(refU);
#    float(refV);
#    float(lab_k);
#    float(lab_e);
#

m =
  R: [ 3.240969941904521, -1.537383177570093, -0.498610760293    ]
  G: [ -0.96924363628087,  1.87596750150772,   0.041555057407175 ]
  B: [ 0.055630079696993, -0.20397695888897,   1.056971514242878 ]
m_inv =
  X: [ 0.41239079926595,  0.35758433938387, 0.18048078840183  ]
  Y: [ 0.21263900587151,  0.71516867876775, 0.072192315360733 ]
  Z: [ 0.019330818715591, 0.11919477979462, 0.95053215224966  ]

# Hard-coded D65 standard illuminant
refX = 0.95045592705167
refY = 1.0
refZ = 1.089057750759878

refU = 0.19783000664283
refV = 0.46831999493879

# CIE LUV constants
kappa = 903.2962962
epsilon = 0.0088564516


# For a given lightness, return a list of 6 lines in slope-intercept
# form that represent the bounds in CIELUV, stepping over which will
# push a value out of the RGB gamut
getBounds = (L) ->
  sub1 = Math.pow(L + 16, 3) / 1560896
  sub2 = if (sub1 > epsilon) then sub1 else (L / kappa)
  ret = []
  for channel in ['R', 'G', 'B']
    [m1, m2, m3] = m[channel]
    for t in [0, 1]

      top1 = (284517 * m1 - 94839 * m3) * sub2
      top2 = (838422 * m3 + 769860 * m2 + 731718 * m1) * L * sub2 - 769860 * t * L
      bottom = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t

      ret.push [top1 / bottom, top2 / bottom]
  return ret


intersectLineLine = (line1, line2) ->
  (line1[1] - line2[1]) / (line2[0] - line1[0])

distanceFromPole = (point) ->
  Math.sqrt(Math.pow(point[0], 2) + Math.pow(point[1], 2))


lengthOfRayUntilIntersect = (theta, line) ->
  # theta  -- angle of ray starting at (0, 0)
  # m, b   -- slope and intercept of line
  # x1, y1 -- coordinates of intersection
  # len    -- length of ray until it intersects with line
  #
  # b + m * x1        = y1
  # len              >= 0
  # len * cos(theta)  = x1
  # len * sin(theta)  = y1
  #
  #
  # b + m * (len * cos(theta)) = len * sin(theta)
  # b = len * sin(hrad) - m * len * cos(theta)
  # b = len * (sin(hrad) - m * cos(hrad))
  # len = b / (sin(hrad) - m * cos(hrad))
  #
  [m1, b1] = line
  len = b1 / (Math.sin(theta) - m1 * Math.cos(theta))
  if len < 0
    return null
  return len


# For given lightness, returns the maximum chroma. Keeping the chroma value
# below this number will ensure that for any hue, the color is within the RGB
# gamut.
maxSafeChromaForL = (L) ->
  lengths = []
  for [m1, b1] in getBounds L
    # x where line intersects with perpendicular running though (0, 0)
    x = intersectLineLine [m1, b1], [-1 / m1, 0]
    lengths.push distanceFromPole [x, b1 + x * m1]
  return Math.min lengths...

# For a given lightness and hue, return the maximum chroma that fits in
# the RGB gamut.
maxChromaForLH = (L, H) ->
  hrad = H / 360 * Math.PI * 2
  lengths = []
  for line in getBounds L
    l = lengthOfRayUntilIntersect hrad, line
    if l != null
      lengths.push l
  return Math.min lengths...

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

# Represents rgb [0-1] values as [0-255] values. Errors out if value
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
  max = maxChromaForLH L, H
  C = max / 100 * S
  # I already tried this scaling function to improve the chroma
  # uniformity. It did not work very well.
  # C = Math.pow(S / 100,  1 / t) * max
  return [L, C, H]

conv.lch.husl = (tuple) ->
  [L, C, H] = tuple
  return [H, 0, 100] if L > 99.9999999
  return [H, 0, 0] if L < 0.00000001
  max = maxChromaForLH L, H
  S = C / max * 100
  return [H, S, L]

## PASTEL HUSL

conv.huslp.lch = (tuple) ->
  [H, S, L] = tuple
  return [100, 0, H] if L > 99.9999999
  return [0, 0, H] if L < 0.00000001
  max = maxSafeChromaForL L
  C = max / 100 * S
  return [L, C, H]

conv.lch.huslp = (tuple) ->
  [L, C, H] = tuple
  return [H, 0, 100] if L > 99.9999999
  return [H, 0, 0] if L < 0.00000001
  max = maxSafeChromaForL L
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
  parseInt(n, 16) / 255 for n in [r, g, b]

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
root._rgbPrepare = rgbPrepare
root._getBounds = getBounds
root._maxChromaForLH = maxChromaForLH
root._maxSafeChromaForL = maxSafeChromaForL

# If no framework is available, just export to the global object (window.HUSL
# in the browser)
@HUSL = root unless module? or jQuery? or requirejs?
# Export to Node.js
module.exports = root if module?
# Export to jQuery
jQuery.husl = root if jQuery?
# Export to RequireJS
define(root) if requirejs? and define?
