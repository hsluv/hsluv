assert = require 'assert'
husl = require '../husl.coffee'
meta = require '../package.json'
{exec} = require 'child_process'


describe 'HUSL', ->  
  manySamples = (assertion) ->
    samples = '0123456789abcdef'
    for r in samples
      for g in samples
        for b in samples
          assertion '#' + r + r + g + g + b + b

  it 'should convert between HUSL and hex', ->  
    manySamples (hex) ->
      assert.deepEqual hex, husl.toHex (husl.fromHex hex)...
  it 'should convert between HUSLp and hex', ->  
    manySamples (hex) ->
      assert.deepEqual hex, husl.p.toHex (husl.p.fromHex hex)...

  it 'should be able to work with Stylus programmatically', ->  
    styl = """
    .someclass
      color husl(0, 50, 0, 0.1)
      color husl(60, 10, 10)
      color huslp(40, 10, 20, 0.3)
      color huslp(60, 10, 30)
    """
    css = """
    .someclass {
      color: rgba(0,0,0,0.1);
      color: #1d1b1a;
      color: rgba(50,48,47,0.3);
      color: #484644;
    }

    """
    stylus = require 'stylus'
    stylus(styl).use(husl()).render (err, test_css) ->
      throw err if err
      assert.equal test_css, css

  it 'should match the stable snapshot', (done) ->
    cake = 'node_modules/coffee-script/bin/cake'
    imagediff = 'node_modules/imagediff/bin/imagediff'
    exec "#{cake} snapshot", (err, stdout, stderr) ->
      throw err if err
      current = "test/snapshot-current.png"
      major = meta.version.split('.')[0]
      stable = "test/snapshot-#{major}.x.x.png"
      exec "#{imagediff} -e #{current} #{stable}", (err, stdout, stderr) ->
        throw err if err
        if stdout != 'true\n'
          throw new Error "The snapshots don't match"
        done()




