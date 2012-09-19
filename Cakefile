{exec} = require 'child_process'

fs  = require 'fs'
Png = require('png').Png
Buffer = require('buffer').Buffer

husl = require './husl'
colorspaces = require 'colorspaces'
onecolor = require 'onecolor'

task 'build:docs', 'Build docs', ->

  hslToRgb = (h, s, l) ->
    h *= 360
    s *= 100
    l *= 100
    c = onecolor "hsl(#{h}, #{s}, #{l})"
    [c.red(), c.green(), c.blue()]

  chromaDemo = (color) ->
    C = color.as('CIELCHuv')[1] * 0.8
    red = colorspaces.make_color 'CIELCHuv', [50, C, 10]
    return red.as 'sRGB'

  makeImage = (file, func, width, height) ->
    rgb = new Buffer width * height * 3
    for y in [0..height - 1]
      for x in [0..width - 1]
        pos = (y * width + x) * 3
        rgbVal = func x / 360, y / height
        rgb[pos + 0] = rgbVal[0]
        rgb[pos + 1] = rgbVal[1]
        rgb[pos + 2] = rgbVal[2]
    png = new Png rgb, width, height, 'rgb'
    png_image = png.encodeSync()
    fs.writeFileSync file, png_image.toString('binary'), 'binary'

  makeDemo = (name, func, width = 360, height = 200) ->
    console.log " - #{name}"
    file = "./gh-pages/img/demo/#{name}.png"
    func2 = (x, y) ->
      husl._rgbPrepare func x, y
    makeImage file, func2, width, height

  console.log "Generating demo images:"

  makeDemo 'husl', (x, y) ->
    rgb = husl.husl x * 360, 100 - y * 100, 50, true
    return rgb

  makeDemo 'husl-chroma', (x, y) ->
    rgb = husl.husl x * 360, 100 - y * 100, 50, true
    return chromaDemo colorspaces.make_color 'sRGB', rgb

  makeDemo 'husl-low', ((x, y) ->
    rgb = husl.husl x * 360, 100 - y * 100, 10, true
    return rgb), 270, 150

  makeDemo 'husl-high', ((x, y) ->
    rgb = husl.husl x * 360, 100 - y * 100, 95, true
    return rgb), 270, 150

  makeDemo 'cielchuv', (x, y) ->
    color = colorspaces.make_color 'CIELCHuv', [50, 200 - y * 200, x * 360]
    if !color.is_displayable()
      rgb = [0, 0, 0]
    else
      rgb = color.as 'sRGB'
    return rgb

  makeDemo 'cielchuv-chroma', (x, y) ->
    color = colorspaces.make_color 'CIELCHuv', [50, 200 - y * 200, x * 360]
    if !color.is_displayable()
      return [0, 0, 0]
    return chromaDemo color

  makeDemo 'hsl', (x, y) ->
    return hslToRgb x, 1 - y, 0.5

  makeDemo 'hsl-lightness', (x, y) ->
    rgb = hslToRgb x, 1 - y, 0.5
    color = colorspaces.make_color 'sRGB', rgb
    l = color.as('CIELUV')[0] / 100
    return [l, l, l]

  makeDemo 'hsl-chroma', (x, y) ->
    rgb = hslToRgb x, 1 - y, 0.5
    return chromaDemo colorspaces.make_color 'sRGB', rgb

task 'build', 'Build project', ->
  console.log "Compile HUSL"
  exec 'coffee --compile husl.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    exec 'uglifyjs husl.js > husl.min.js', (err, stdout, stderr) ->
      throw err if err
      console.log stderr
      invoke 'build:docs'

