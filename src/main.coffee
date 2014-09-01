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

intersection2 = (line1, point) ->
  line2 = [0, point[1] / point[0]]
  int = intersection line1[0], line1[1], line2[0], line2[1]
  if int[0] > 0 and int[0] < point[0]
    return int
  if int[0] < 0 and int[0] > point[0]
    return int
  return null

getIntersections = (lines) ->
  [fname, f] = _.first lines
  rest = _.rest lines
  if rest.length == 0
    return []
  intersections = _.map rest, (r) ->
    [rname, r] = r
    {
      point: intersection f[0], f[1], r[0], r[1]
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


svgContainer = d3.select("#picker svg")
                .attr("width", width)
                .attr("height", height)

cancelDraw = false

redraw = (L) ->
  svgContainer[0][0].innerHTML = ''

  cancelDraw = false

  pairs = _.map hs(L), (hrad) ->
    C = $.husl._maxChroma L, hrad * 180 / Math.PI
    return [hrad, C]

  Cs = _.map pairs, (pair) -> pair[1]

  maxC = Math.max Cs...
  minC = Math.min Cs...

  bounds = getBounds L

  window.eee = intersections = []
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
    length = Math.sqrt(Math.pow(point[0], 2) + Math.pow(point[1], 2))
    if length > longest
      longest = length

  scale = 190 / longest


  """
  for xi in [-40..40]
    for yi in [-40..40]
      x = xi * 5
      y = yi * 5
      try
        hex = $.husl._conv.rgb.hex $.husl._conv.xyz.rgb $.husl._conv.luv.xyz [L, x, y]
        svgContainer.append("rect")
          .attr("x", xi * 5)
          .attr("y", yi * 5)
          .attr("height", 5)
          .attr("width", 5)
          .attr("transform", "translate(200, 200)")
          .attr("fill", hex)
  """

  if cancelDraw
    return
      
  for name in cleanBounds
    [c, s] = bounds[name]
    lineGraph = svgContainer.append("line")
      .attr("x1", scale * (-200))
      .attr("y1", scale * (c + (-200) * s))
      .attr("x2", scale * 200)
      .attr("y2", scale * (c + 200 * s))
      .attr("transform", "translate(200, 200)")
      .attr("stroke", "white")
      .attr("stroke-width", 1)

    if cancelDraw
      return

  svgContainer.append("circle")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", scale * minC)
    .attr("transform", "translate(200, 200)")
    .attr("stroke", "#ffffff")
    .attr("stroke-width", 1)
    .attr("fill", "none")

  if cancelDraw
    return

  svgContainer.append("circle")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", scale * longest)
    .attr("transform", "translate(200, 200)")
    .attr("stroke", "#ffffff")
    .attr("stroke-width", 1)
    .attr("fill", "none")

  if cancelDraw
    return

  svgContainer.append("circle")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", 2)
    .attr("transform", "translate(200, 200)")
    .attr("fill", "white")


redraw 50

$('#lightness-slider').on 'input', ->
  cancelDraw = true
  redraw parseInt $('#lightness-slider').val()