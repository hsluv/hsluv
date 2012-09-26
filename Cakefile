{exec} = require 'child_process'

fs  = require 'fs'
Png = require('png').Png
Buffer = require('buffer').Buffer
meta = require './package.json'

husl = require './husl.coffee'
coffee = "./node_modules/coffee-script/bin/coffee"

task 'build', 'Build project', ->
  console.log "Compiling HUSL"
  exec "#{coffee} --compile husl.coffee", (err, stdout, stderr) ->
    throw err if err
    exec 'uglifyjs husl.js > husl.min.js', (err, stdout, stderr) ->
      throw err if err

task 'snapshot', 'Take snapshot of the gamut for later testing', ->
  width = 37 + 37
  height = 21 * 21

  rgb = new Buffer width * height * 3
  writePixel = (x, y, rgbVal) ->
    pos = (y * width + x) * 3
    rgb[pos + 0] = rgbVal[0]
    rgb[pos + 1] = rgbVal[1]
    rgb[pos + 2] = rgbVal[2]

  for Hs in [0..36]
    for Ss in [0..20]
      for Ls in [0..20]
        H = Hs * 10
        S = Ss * 5
        L = Ls * 5
        rgbVal = husl._rgbPrepare husl.toRGB H, S, L
        writePixel Hs, Ls * 21 + Ss, rgbVal
        rgbVal = husl._rgbPrepare husl.p.toRGB H, S, L
        writePixel 37 + Hs, Ls * 21 + Ss, rgbVal

  png = new Png rgb, width, height, 'rgb'
  png_image = png.encodeSync()
  file = "test/snapshot-current.png"
  fs.writeFileSync file, png_image.toString('binary'), 'binary'

