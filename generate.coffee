fs  = require 'fs'
Buffer = require('buffer').Buffer
PNG = require('pngjs').PNG

colorspaces = require 'colorspaces'
onecolor = require 'onecolor'
husl = require 'husl'
  
hslToRgb = (h, s, l) ->
  h *= 360
  s *= 100
  l *= 100
  c = onecolor "hsl(#{h}, #{s}, #{l})"
  [c.red(), c.green(), c.blue()]

makeImage = (file, func, width, height) ->
  png = new PNG {
    width: width
    height: height
  }
  for y in [0..height - 1]
    for x in [0..width - 1]
      pos = (y * width + x) * 4
      rgbVal = func x / (width - 1), y / (height - 1)
      png.data[pos + 0] = rgbVal[0]
      png.data[pos + 1] = rgbVal[1]
      png.data[pos + 2] = rgbVal[2]
      png.data[pos + 3] = 255

  png.pack().pipe(fs.createWriteStream(file))

chromaDemo = (color) ->
  C = color.as('CIELCHuv')[1] * 0.8
  red = colorspaces.make_color 'CIELCHuv', [50, C, 10]
  return red.as 'sRGB'

makeDemo = (name, func, width = 360, height = 200) ->
  console.log " - #{name}"
  file = "dist/img/demo/#{name}.png"
  func2 = (x, y) ->
    try
      husl._rgbPrepare func x, y
    catch e
      console.log x, y
      console.log x * 360, 100 - y * 100
      console.log func x, y
      console.log husl.p.toRGB x * 360, 100 - y * 100, 50
      throw e
  makeImage file, func2, width, height


console.log "Generating demo images:"

try
  fs.mkdirSync 'dist/img'
  fs.mkdirSync 'dist/img/demo'

makeDemo 'husl', (x, y) ->
  rgb = husl.toRGB x * 360, 100 - y * 100, 50
  return rgb

makeDemo 'huslp', (x, y) ->
  rgb = husl.p.toRGB x * 360, 100 - y * 100, 50
  return rgb

makeDemo 'husl-chroma', (x, y) ->
  rgb = husl.toRGB x * 360, 100 - y * 100, 50
  return chromaDemo colorspaces.make_color 'sRGB', rgb

makeDemo 'cielchuv-chroma', (x, y) ->
  color = colorspaces.make_color 'CIELCHuv', [50, 200 - y * 200, x * 360]
  if !color.is_displayable()
    rgb = [0, 0, 0]
  else
    rgb = color.as 'sRGB'
  return chromaDemo colorspaces.make_color 'sRGB', rgb

makeDemo 'cielchuv', (x, y) ->
  color = colorspaces.make_color 'CIELCHuv', [50, 200 - y * 200, x * 360]
  if !color.is_displayable()
    rgb = [0, 0, 0]
  else
    rgb = color.as 'sRGB'
  return rgb

makeDemo 'hsl', (x, y) ->
  return hslToRgb x, 1 - y, 0.5

makeDemo 'hsl-lightness', (x, y) ->
  rgb = hslToRgb x, 1 - y, 0.5
  color = colorspaces.make_color 'sRGB', rgb
  l = color.as('CIELUV')[0] / 100
  return [l, l, l]

makeDemo 'cielchuv-lightness', (x, y) ->
  color = colorspaces.make_color 'CIELCHuv', [50, 200 - y * 200, x * 360]
  if !color.is_displayable()
    return [0, 0, 0]
  else
    return [0.5, 0.5, 0.5]

makeDemo 'husl-lightness', (x, y) ->
  return [0.5, 0.5, 0.5]

makeDemo 'huslp-lightness', (x, y) ->
  return [0.5, 0.5, 0.5]

makeDemo 'hsl-chroma', (x, y) ->
  rgb = hslToRgb x, 1 - y, 0.5
  return chromaDemo colorspaces.make_color 'sRGB', rgb

makeDemo 'huslp-chroma', (x, y) ->
  rgb = husl.p.toRGB x * 360, 100 - y * 100, 50
  return chromaDemo colorspaces.make_color 'sRGB', rgb

