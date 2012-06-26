{exec} = require 'child_process'
task 'build', 'Build project', ->
  exec 'coffee --compile husl.coffee', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr
    exec 'uglifyjs husl.js > husl.min.js', (err, stdout, stderr) ->
      throw err if err
      console.log stderr

