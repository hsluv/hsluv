assert = require 'assert'
husl = require '../husl.coffee'
meta = require '../package.json'
tools = require './tools.coffee'
{exec} = require 'child_process'
_ = require 'underscore'

describe 'HUSL consistency', ->
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

describe 'Fits within RGB ranges', ->
  it 'should fit', ->
    for H in (n for n in [0..360] by 5)
      for S in (n for n in [0..100] by 5)
        for L in (n for n in [0..100] by 5)
          RGB = husl.toRGB H, S, L
          for channel in RGB
            assert -0.00000001 <= channel <= 1.00000001, "HUSL: #{[H, S, L]} -> #{RGB}"

          RGB = husl.p.toRGB H, S, L
          for channel in RGB
            assert -0.00000001 <= channel <= 1.00000001, "HUSLp: #{[H, S, L]} -> #{RGB}"

describe 'Stylus integration', ->

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
      assert.equal css, test_css


describe 'HUSL snapshot', ->

  it 'should match the stable snapshot', ->

    current = tools.snapshot()
    stable = require './snapshot-4.x.x.json'

    for hex, stableSamples of stable
      currentSamples = current[hex]
      for tag, stableTuple of stableSamples
        currentTuple = currentSamples[tag]
        for i in [0..2]
          diff = Math.abs currentTuple[i] - stableTuple[i]
          assert (diff < 0.00000001), """
            The snapshots for #{hex} don't match at #{tag}
            Stable:  #{stableTuple}
            Current: #{currentTuple}
            """




