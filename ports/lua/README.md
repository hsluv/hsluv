# husl.lua

Lua port of [HUSL](http://www.boronine.com/husl/), courtesy of [Mark Wonnacott](https://github.com/Ragzouken).

    > husl = require 'husl'
    > = husl.hex_to_husl('#123456')
    248.60320341681 85.43201417605  21.04172364179
    > = husl.husl_to_hex(248.60, 85.43, 21.04)
    #123456
    > = husl.rgb_to_husl(0.07, 0.20, 0.33)
    248.49244211716 85.009956491035 20.58410610897
    > = husl.husl_to_rgb(248.49, 85.00, 20.58)
    0.070014042122372   0.19996570399156   0.32991848455264

For HUSLp, use `hex_to_huslp`, `huslp_to_hex`, `rgb_to_huslp` and `huslp_to_rgb`.
