[![Build Status](https://secure.travis-ci.org/boronine/husl.png)](http://travis-ci.org/boronine/husl)

# What is <abbr class="initialism">HUSL</abbr>?

HUSL is a [human-friendly](http://boronine.com/2012/03/26/Color-Spaces-for-Human-Beings/) alternative to the HSL color space. HSL was designed back in the 70s to be computationally cheap. It is a clever geometric transformation of the RGB color space and it does not take into account the complexities of human color vision.

There have long existed color spaces designed for perceptual uniformity. One of these color spaces is [CIELUV](http://en.wikipedia.org/wiki/CIELUV) (and its cylindrically shaped brother CIE LCh<sub>uv</sub>. Like HSL, it defines hue and lightness, but instead of saturation it defines chroma. The problem with its chroma component is that it doesn't fit into a specific range. This makes it very hard to define colors programmatically. **HUSL is a modified version of the CIE LCh<sub>uv</sub> color space with a new saturation component**.

[Read more](http://boronine.com/husl)
