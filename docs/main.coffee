# https://gist.github.com/3716319
hslToRgb = (h, s, l) ->
  h /= 360
  if s == 0
    r = g = b = l # achromatic
  else
    hue2rgb = (p, q, t) ->
      if t < 0 then t += 1
      if t > 1 then t -= 1
      if t < 1/6 then return p + (q - p) * 6 * t
      if t < 1/2 then return q
      if t < 2/3 then return p + (q - p) * (2/3 - t) * 6
      return p

    q = if l < 0.5 then l * (1 + s) else l + s - l * s
    p = 2 * l - q
    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  [r, g, b]

hslToHex = (h, s, l) ->
  rgb = hslToRgb h, s / 100, l / 100
  console.log h, s, l, rgb
  return $.colorspaces.converter('sRGB', 'hex') rgb

$('.tagline span').each (index) ->
  $(this).css 'color', $.husl.husl index / 17 * 360, 90, 50

L = 50

"""
function set($canvas, func) {
  var c = $canvas.get(0).getContext("2d");
  for (var x = 0; x < 360; x ++) {
    for (var y = 0; y < 100; y ++) {
      var rgb = func(x, y);
      var r = rgb[0] * 256;
      var g = rgb[1] * 256;
      var b = rgb[2] * 256;
      index = (x + y * 360) * 4
      imageData.data[index+0] = r;
      imageData.data[index+1] = g;
      imageData.data[index+2] = b;
      imageData.data[index+3] = 256;
    }
  }
  c.putImageData(imageData, 0, 0);
}
set($("#picker canvas"), function(x, y) {
  return $.husl.husl(x, 100 - y, 50, true);
})
"""

randomHue = ->
  Math.floor Math.random() * 360

$('#demo1').click ->
  $(this).closest('div').find('.demo').each ->
    $(this).css 'background-color', $.husl.husl randomHue(), 90, 60

$('#demo2').click ->
  $(this).closest('div').find('.demo').each ->
    $(this).css 'background-color', hslToHex randomHue(), 90, 60

$('#demo1').click()
$('#demo2').click()