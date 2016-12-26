[![Build Status](https://travis-ci.org/hsluv/hsluv-lua.svg)](https://travis-ci.org/hsluv/hsluv-lua)
[![Package Version](https://img.shields.io/badge/luarocks-0.1--0-blue.svg)](https://luarocks.org/modules/hsluv/hsluv)

Lua implementation of [HSLuv](http://www.hsluv.org/) (revision 4), courtesy of [Mark Wonnacott](https://github.com/Ragzouken).

# Installation

Copy the husl.lua file directly into your project or install from luarocks:

    luarocks install hsluv

# Usage

    > hsluv = require 'hsluv'
    > = hsluv.hex_to_hsluv('#123456')
    248.60320341681 85.43201417605  21.04172364179
    > = hsluv.husl_to_hex({248.60, 85.43, 21.04})
    #123456
    > = hsluv.rgb_to_hsluv({0.07, 0.20, 0.33})
    248.49244211716 85.009956491035 20.58410610897
    > = hsluv.hsluv_to_rgb({248.49, 85.00, 20.58})
    0.070014042122372   0.19996570399156   0.32991848455264

For HUSLp, use `hex_to_hpluv`, `hpluv_to_hex`, `rgb_to_hpluv` and `hpluv_to_rgb`.

# License

Copyright (C) 2016 Alexei Boronine

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the 
following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN 
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
