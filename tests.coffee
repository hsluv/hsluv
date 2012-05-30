assert = require 'assert'
husl = require './husl.js'

styl = """
.someclass
  // Some edge cases
  color husl(0, 0, 0, 0.1)
  color husl(0, 0, 0)
  color husl(0, 100, 0)
  color husl(0, 0, 100)
  color husl(0, 100, 100)
  color husl(360, 0, 0)
  color husl(360, 100, 0)
  color husl(360, 0, 100)
  color husl(360, 100, 100)
  // Some random colors, these tests can only
  // change when a major version is released!
  color husl(360, 10, 10)
  color husl(350, 20, 20)
  color husl(340, 30, 30)
  color husl(330, 40, 40)
  color husl(320, 50, 50)
  color husl(200, 60, 60)
  color husl(250, 100, 60)
"""

css = """
.someclass {
  color: rgba(0,0,0,0.1);
  color: #000;
  color: #000;
  color: #fff;
  color: #fff;
  color: #000;
  color: #000;
  color: #fff;
  color: #fff;
  color: #211a1b;
  color: #3e2b31;
  color: #5f3c4d;
  color: #844c6f;
  color: #ab5b9a;
  color: #5f9a9f;
  color: #0094fc;
}

"""

stylus = require 'stylus'
stylus(styl).use(husl()).render (err, test_css) ->
  throw err if err
  if test_css is css
    console.log 'OK'
  else
    console.log 'FAIL\n' + test_css

