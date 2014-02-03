CoffeeScript = require 'coffee-script'
CoffeeScript.register()

{exec} = require 'child_process'
tools = require './test/tools.coffee'

fs  = require 'fs'
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

task 'snapshot', 'Take JSON snapshot of the entire gamut', ->
  file = "test/snapshot-current.json"
  fs.writeFileSync file, JSON.stringify tools.snapshot()

