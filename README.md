[![Build Status](https://secure.travis-ci.org/boronine/husl.png)](http://travis-ci.org/boronine/husl)

# What is <abbr class="initialism">HUSL</abbr>?

HUSL is a [human-friendly](http://boronine.com/2012/03/26/Color-Spaces-for-Human-Beings/) alternative to the HSL color space. HSL was designed back in the 70s to be computationally cheap. It is a clever geometric transformation of the RGB color space and it does not take into account the complexities of human color vision.

There have long existed color spaces designed for perceptual uniformity. One of these color spaces is [CIELUV](http://en.wikipedia.org/wiki/CIELUV) (and its cylindrically shaped brother CIE LCh<sub>uv</sub>. Like HSL, it defines hue and lightness, but instead of saturation it defines chroma. The problem with its chroma component is that it doesn't fit into a specific range. This makes it very hard to define colors programmatically. **HUSL is a modified version of the CIE LCh<sub>uv</sub> color space with a new saturation component**.

[Demo, documentation etc.](http://boronine.com/husl)

# Testing

Run `npm install` and `npm test`. Try `cake snapshot` to generate a picture of samples from the entire gamut. These picutures are used for regression tests

# Ports

This repo contains the canonical version. With the help of Robert McGinley, HUSL was also [ported to Python](https://github.com/boronine/pyhusl).

A work-in-progress of C and Java ports is included in the repo, done by Lajos Ambrus.

A [Ruby port](https://github.com/soulcutter/husler) has been started by @soulcutter. I would love to see this done so that HUSL could be integrated into [SASS](http://sass-lang.com/).

***

Copyright (C) 2012 Alexei Boronine

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
