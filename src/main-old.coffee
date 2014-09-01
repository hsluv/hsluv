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
  return $.colorspaces.converter('sRGB', 'hex') rgb

randomHue = ->
  Math.floor Math.random() * 360

$('#demo1').click ->
  $(this).closest('div').find('.demo').each ->
    $(this).css 'background-color', $.husl.toHex randomHue(), 90, 60

$('#demo2').click ->
  $(this).closest('div').find('.demo').each ->
    $(this).css 'background-color', hslToHex randomHue(), 90, 60

$('#demo1').click()
$('#demo2').click()

$('#rainbow-husl div').each (index) ->
  $(this).css 'background-color', $.husl.toHex index * 36, 90, 60
$('#rainbow-hsl div').each (index) ->
  $(this).css 'background-color', hslToHex index * 36, 90, 60


do ->

  $canvas = $ '#picker canvas'
  $scope = $ '#picker .scope'
  $hex = $ '#picker .hex'
  ctx = $canvas[0].getContext '2d'

  current_H = 200
  current_S = 80
  current_L = 50
  variant = $.husl

  $hex.click ->
    $(this).select()

  redrawSwatch = do ->

    $swatch = $ '#picker .swatch'
    $channels = {}

    for c in ['R', 'G', 'B', 'H', 'S', 'L', 'C']
      $channels[c] = $ "#picker .#{c}"

    chromaFromHex = ->
    conv = $.colorspaces.converter 'hex', 'CIELCHuv'

    return ->
      $channels.H.text Math.round current_H
      $channels.S.text Math.round current_S
      $channels.L.text Math.round current_L
      [R, G, B] = variant.toRGB current_H, current_S, current_L
      $channels.R.text Math.round R * 255
      $channels.G.text Math.round G * 255
      $channels.B.text Math.round B * 255
      hex = variant.toHex current_H, current_S, current_L
      $swatch.css 'background-color', hex
      $hex.attr 'value', hex
      C = conv(hex)[1]
      $channels.C.text Math.round C
      $scope.css 'left', current_H - 5
      $scope.css 'top', (100 - current_S) * 2 - 5
      $scope.css 'border-color', if current_L > 50 then '#1b1b1b' else 'white'

  redraw = ->
    redrawSwatch()
    width = 360
    height = 200
    dim = 4
    xn = width / dim
    yn = height / dim
    for x in [0..xn]
      for y in [0..yn]
        h = x * dim + dim / 2
        s = 100 * (1 - y * dim / height)
        ctx.fillStyle = variant.toHex h, s, current_L
        ctx.fillRect x * dim, y * dim, dim, dim

  redraw()
  $('#picker .slider').slider
    orientation: 'vertical'
    value: current_L
    slide: (event, ui) ->
      current_L = ui.value
      redraw()

  update = (e) ->
    e.stopPropagation()
    e.preventDefault()
    offset = $canvas.offset()
    current_H = e.pageX - offset.left
    current_S = 100 - (e.pageY - offset.top) / 2
    redrawSwatch()

  $canvas.mousedown (e) ->
    $canvas.mousemove update
    $scope.hide()
    update(e)

  $(document).mouseup ->
    $scope.show()
    $canvas.unbind 'mousemove', update

  $('#picker .variants .choice').click (e) ->
    e.preventDefault()
    $('#picker .variants .choice').removeClass 'selected'
    $(this).addClass 'selected'
    if $(this).hasClass 'pastel'
      variant = $.husl.p
    else
      variant = $.husl
    redraw()

$(document).ready ->
  hljs.initHighlightingOnLoad()
  