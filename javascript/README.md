# HUSL - JavaScript implementation

## Installation

Client-side: download the latest husl.min.js from the 
[releases page](https://github.com/husl-colors/husl/releases).
 
Once this module is loaded in the browser, you can access it via the
global ``window.HUSL``.

Server-side: ``npm install husl``.

## Usage

**husl.toHex(hue, saturation, lightness)**

*hue* is a number between 0 and 360, *saturation* and *lightness* are 
numbers between 0 and 100. This function returns the resulting color as 
a hex string.

**husl.toRGB(hue, saturation, lightness)**

Like above, but returns an array of 3 numbers between 0 and 1, for the 
r, g, and b channel.

**husl.fromHex(hex)**

Takes a hex string and returns the HUSL color as array that contains 
the hue (0-360), saturation(0-100) and lightness(0-100) channel.
_Note_: The result can have rounding errors. For example saturation can 
be 100.00000000000007

**husl.fromRGB(red, green, blue)**

Like above, but *red*, *green* and *blue* are passed as numbers between 
0 and 1.

Use **husl.p.toHex**, **husl.p.toRGB**, **husl.p.fromHex** and 
**husl.p.fromRGB** for the pastel variant (HUSLp). Note that HUSLp does 
not contain all the colors of RGB, so converting arbitrary RGB to it may 
generate invalid HUSLp colors.

HUSL can also be used as a [Stylus](http://learnboost.github.com/stylus/) 
plugin. See [here](https://github.com/husl-colors/husl-stylus).

## Testing

```sh
node test.js
```