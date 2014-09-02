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
  return $.husl._conv.rgb.hex rgb

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





kappa = 24389 / 27
epsilon = 216 / 24389
m =
  R: [ 3.240454162114103, -1.537138512797715, -0.49853140955601 ]
  G: [ -0.96926603050518, 1.876010845446694,  0.041556017530349 ]
  B: [ 0.055643430959114, -0.20402591351675,  1.057225188223179 ]

getBounds = (L) ->
  sub1 = Math.pow(L + 16, 3) / 1560896
  sub2 = if (sub1 > epsilon) then sub1 else (L / kappa)
  ret = {}
  for channel in ['R', 'G', 'B']
    [m1, m2, m3] = m[channel]
    for t in [0, 1]

      top1 = (1441272 * m3 - 4323816 * m1) * sub2
      top2 = (-12739311 * m3 - 11700000 * m2 - 11120499 * m1) * L * sub2 + 11700000 * t * L
      bottom = -((9608480 * m3 - 1921696 * m2) * sub2 + 1921696 * t)

      V = (top1 + top2) / bottom

      s = top1 / bottom
      c = top2 / bottom

      ret[channel + t] = [c, s]
  return ret






size = 400

height = size
width = size
maxRadius = size / 2



toCart = (angle, radius) ->
  return {
    x: (height / 2) + radius * Math.cos(angle)
    y: (width / 2) + radius * Math.sin(angle)
  }

normalizeRad = (hrad) ->
  return (hrad + 2 * Math.PI) % (2 * Math.PI)

intersection = (c1, s1, c2, s2) ->
  x = (c1 - c2) / (s2 - s1)
  y = c1 + x * s1
  return [x, y]

intersection3 = (line1, line2) ->
  return intersection line1[0], line1[1], line2[0], line2[1]

intersection2 = (line1, point) ->
  line2 = [0, point[1] / point[0]]
  int = intersection3 line1, line2
  if int[0] > 0 and int[0] < point[0]
    return int
  if int[0] < 0 and int[0] > point[0]
    return int
  return null

distanceFromPole = (point) ->
  Math.sqrt(Math.pow(point[0], 2) + Math.pow(point[1], 2))

getIntersections = (lines) ->
  [fname, f] = _.first lines
  rest = _.rest lines
  if rest.length == 0
    return []
  intersections = _.map rest, (r) ->
    [rname, r] = r
    {
      point: intersection3 f, r
      names: [fname, rname]
    }
    
  return intersections.concat getIntersections rest

dominoSortMatch = (dominos, match) ->
  if dominos.length == 1
    return dominos

  {_first, rest} = _.groupBy dominos, (domino) ->
    if match in domino then '_first' else 'rest'

  first = _first[0]

  next = if first[0] != match then first[0] else first[1]
  return [first].concat dominoSortMatch rest, next

dominoSort = (dominos) ->
  first = _.first dominos
  rest = _.rest dominos
  [first].concat dominoSortMatch rest, first[1]

sortIntersections = (intersections) ->
  dominos = dominoSort _.pluck intersections, 'names'
  _.map dominos, (domino) ->
    _.find intersections, (i) ->
      i.names[0] == domino[0] and i.names[1] == domino[1]

hs = (L) ->
  ret = []
  he1 = $.husl._hradExtremum L
  for channel in ['R', 'G', 'B']
    for limit in [0, 1]
      ret.push normalizeRad(he1(channel, limit))
  ret.sort()
  return ret

$canvas     = $ '#picker canvas'
$svg        = $ '#picker svg'

$controlHue        = $ "#picker .control-hue"
$controlSaturation = $ "#picker .control-saturation"
$controlLightness  = $ "#picker .control-lightness"

ctx = $canvas[0].getContext '2d'
contrasting = null


redrawSquare = (x, y, dim) ->
  vx = (x - 200) / scale
  vy = (y - 200) / scale
  polygon = d3.geom.polygon [
    [vx, vy], [vx, vy + dim], [vx + dim, vy + dim], [vx + dim, vy]
  ]
  shape.clip(polygon)
  if polygon.length > 0
    [vx, vy] = polygon.centroid()
    hex = $.husl._conv.rgb.hex $.husl._conv.xyz.rgb $.husl._conv.luv.xyz [L, vx, vy]
    ctx.fillStyle = hex
    ctx.fillRect x, y, dim, dim

redrawCanvas = (dim) ->
  ctx.clearRect 0, 0, width, height
  ctx.globalCompositeOperation = 'source-over'

  if L == 0 or L == 100
    return

  xn = width / dim
  yn = height / dim

  xs = []
  ys = []
  for point in shape
    xs.push 200 + point[0] * scale
    ys.push 200 + point[1] * scale

  xnMin = Math.floor Math.min(xs...) / dim
  ynMin = Math.floor Math.min(ys...) / dim
  xnMax = Math.ceil Math.max(xs...) / dim
  ynMax = Math.ceil Math.max(ys...) / dim

  for x in [xnMin..xn]
    for y in [ynMin..yn]
      vx = x * dim
      vy = y * dim
      redrawSquare vx, vy, dim

  ctx.globalCompositeOperation = 'destination-in'
  ctx.beginPath()
  ctx.moveTo (200 + shape[0][0] * scale), (200 + shape[0][1] * scale)
  for point in _.rest shape
    ctx.lineTo (200 + point[0] * scale), (200 + point[1] * scale)
  ctx.closePath()
  ctx.fill()

H = 0
S = 100
L = 50
scale = null
sortedIntersections = []
bounds = []
shape = null
pointer = null

makeBackground = ->

  background = d3.select("#picker svg").append("g")
    .attr("class", "background")

  pastelBoundary = background.append("circle")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("transform", "translate(200, 200)")
    .attr("stroke-width", 2)

    .attr("fill", "none")

  center = background.append("circle")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", 2)
    .attr("transform", "translate(200, 200)")

  redrawBackground = ->
    if L != 0 and L != 100

      pairs = _.map hs(L), (hrad) ->
        C = $.husl._maxChroma L, hrad * 180 / Math.PI
        return [hrad, C]

      Cs = _.map pairs, (pair) -> pair[1]

      maxC = Math.max Cs...
      minC = Math.min Cs...

      bounds = getBounds L

      intersections = []
      for i in getIntersections _.pairs bounds
        good = true
        for [name, bound] in _.pairs bounds
          if name in i.names
            continue
          int = intersection2 bound, i.point
          if int != null
            good = false
        if good
          intersections.push(i)

      cleanBounds = []
      for {point, names} in intersections
        cleanBounds = _.union cleanBounds, names

      longest = 0
      for {point} in intersections
        length = distanceFromPole point
        if length > longest
          longest = length

      scale = 190 / longest

      sortedIntersections = _.pluck sortIntersections(intersections), 'point'

      shape = d3.geom.polygon sortedIntersections
      if shape.area() < 0
        sortedIntersections.reverse()
        shape = d3.geom.polygon sortedIntersections

      contrasting = if L > 70 then '#1b1b1b' else '#ffffff'

      pastelBoundary
        .attr("r", scale * minC)
        .attr("stroke", contrasting)

      center
        .attr("fill", contrasting)

    else
      pastelBoundary
        .attr("r", 0)
        .attr("stroke", contrasting)

      center
        .attr("fill", contrasting)


  background.redraw = redrawBackground

  return background


makeForeground = ->

  foreground = d3.select("#picker svg").append("g")
    .attr("class", "foreground")

  foreground.append("circle")
    .attr("class", "picker-container")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", 190)
    .attr("transform", "translate(200, 200)")
    .attr("fill", "#ffffff")
    .attr("fill-opacity", "0.0")
    .attr("stroke", "#ffffff")
    .attr("stroke-width", 2)

  pickerScope = foreground.append("circle")
    .attr("class", "scope")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", 4)
    .attr("style", "display:none")
    .attr("transform", "translate(200, 200)")
    .attr("fill", "none")
    .attr("stroke-width", 2)

  $("#picker svg g.foreground").mousedown (e) ->
    e.preventDefault()
    offset = $canvas.offset()
    x = e.pageX - offset.left - 200
    y = e.pageY - offset.top - 200
    
    adjustPosition x, y

  dragmove = ->
    x = d3.event.x - 200
    y = d3.event.y - 200

    adjustPosition x, y

  drag = d3.behavior.drag()
    .on("drag", dragmove)

  foreground.call(drag)

  redrawForeground = ->

    if L != 0 and L != 100

      maxChroma = $.husl._maxChroma L, H
      chroma = maxChroma * S / 100
      hrad = H / 360 * 2 * Math.PI

      pickerScope
        .attr("cx", chroma * Math.cos(hrad) * scale)
        .attr("cy", chroma * Math.sin(hrad) * scale)
        .attr("stroke", contrasting)
        .attr("style", "display:inline")

    else

      pickerScope
        .attr("style", "display:none")


    colors = d3.range(0, 360, 10).map (_) -> $.husl.toHex _, S, L
    d3.select("#picker div.control-hue").style {
      'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    }

    colors = d3.range(0, 100, 10).map (_) -> $.husl.toHex H, _, L
    d3.select("#picker div.control-saturation").style {
      'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    }

    colors = d3.range(0, 100, 10).map (_) -> $.husl.toHex H, S, _
    d3.select("#picker div.control-lightness").style {
      'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    }

  foreground.redraw = redrawForeground;

  return foreground

redrawSwatch = ->
  hex = $.husl.toHex H, S, L
  d3.select('#picker .swatch').style {
    'background-color': hex
  }
  d3.select('#picker .hex').attr 'value', hex
  d3.select('#picker .counter-hue').text        H.toPrecision 3
  d3.select('#picker .counter-saturation').text S.toPrecision 3
  d3.select('#picker .counter-lightness').text  L.toPrecision 3


foreground = makeForeground()
background = makeBackground()


redrawSliderPositions = ->

  sliderHue.value        H
  sliderSaturation.value S
  sliderLightness.value  L

  sliderHue.redraw()
  sliderSaturation.redraw()
  sliderLightness.redraw()


adjustPosition = (x, y) ->
  pointer = [x / scale, y / scale]

  hrad = normalizeRad Math.atan2 pointer[1], pointer[0]

  H = hrad / 2 / Math.PI * 360

  maxChroma = $.husl._maxChroma L, H
  pointerDistance = distanceFromPole(pointer)

  S = Math.min(pointerDistance / maxChroma * 100, 100)

  foreground.redraw()
  redrawSliderPositions()
  redrawSwatch()

sliderHue = d3.slider()
  .min(0)
  .max(360)
  .on 'slide', (e, value) ->
    H = value
    foreground.redraw()
    redrawSwatch()

sliderSaturation = d3.slider()
  .min(0)
  .max(100)
  .on 'slide', (e, value) ->
    S = value
    foreground.redraw()
    redrawSwatch()

sliderLightness = d3.slider()
  .min(0)
  .max(100)
  .on 'slide', (e, value) ->
    L = value
    background.redraw()
    redrawCanvas(8)
    foreground.redraw()
    redrawSwatch()

d3.select("#picker div.control-hue").call(sliderHue)
d3.select("#picker div.control-saturation").call(sliderSaturation)
d3.select("#picker div.control-lightness").call(sliderLightness)

background.redraw()
redrawCanvas(8)
foreground.redraw()
redrawSliderPositions()
redrawSwatch()
