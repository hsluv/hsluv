# HSL<sub>uv</sub> - Human-friendly HSL

## Installation

Client-side: download the latest hsluv.min.js from the 
[releases page](https://github.com/hsluv/hsluv/releases).
 
Once this module is loaded in the browser, you can access it via the
global ``window.hsluv``.

Server-side: ``npm install hsluv``.

## Usage

**hsluvToHex([hue, saturation, lightness])**

*hue* is a number between 0 and 360, *saturation* and *lightness* are 
numbers between 0 and 100. This function returns the resulting color as 
a hex string.

**hsluvToRgb([hue, saturation, lightness])**

Like above, but returns an array of 3 numbers between 0 and 1, for the 
r, g, and b channel.

**hexToHsluv(hex)**

Takes a hex string and returns the HSLuv color as array that contains 
the hue (0-360), saturation (0-100) and lightness (0-100) channel.
_Note:_ The result can have rounding errors. For example saturation can 
be 100.00000000000007

**rgbToHsluv([red, green, blue])**

Like above, but *red*, *green* and *blue* are passed as numbers between 
0 and 1.

Use **hpluvToHex**, **hpluvToRgb**, **hexToHpluv** and **rgbToHpluv** for 
the pastel variant (HPLuv). Note that HPLuv does not contain all the colors 
of RGB, so converting arbitrary RGB to it may generate invalid HPLuv colors.

Also available for [Stylus](http://stylus-lang.com/). See 
[here](https://github.com/hsluv/hsluv-stylus).
