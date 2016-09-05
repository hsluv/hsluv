'use strict';

// The math for most of this module was taken from:
//
//  * http://www.easyrgb.com
//  * http://www.brucelindbloom.com
//  * Wikipedia
//
// All numbers below taken from math/bounds.wxm wxMaxima file. We use 17
// digits of decimal precision to export the numbers, effectively exporting
// them as double precision IEEE 754 floats.
//
// "If an IEEE 754 double precision is converted to a decimal string with at
// least 17 significant digits and then converted back to double, then the 
// final number must match the original"
//
// Source: https://en.wikipedia.org/wiki/Double-precision_floating-point_format

var m = {
    R: [3.2409699419045214, -1.5373831775700935, -0.49861076029300328],
    G: [-0.96924363628087983, 1.8759675015077207, 0.041555057407175613],
    B: [0.055630079696993609, -0.20397695888897657, 1.0569715142428786]
};
var m_inv = {
    X: [0.41239079926595948, 0.35758433938387796, 0.18048078840183429],
    Y: [0.21263900587151036, 0.71516867876775593, 0.072192315360733715],
    Z: [0.019330818715591851, 0.11919477979462599, 0.95053215224966058]
};

var refU = 0.19783000664283681;
var refV = 0.468319994938791;

// CIE LUV constants
var kappa = 903.2962962962963;
var epsilon = 0.0088564516790356308;

// For a given lightness, return a list of 6 lines in slope-intercept
// form that represent the bounds in CIELUV, stepping over which will
// push a value out of the RGB gamut
var getBounds = function getBounds(L) {
    var sub1 = Math.pow(L + 16, 3) / 1560896;
    var sub2 = sub1 > epsilon ? sub1 : L / kappa;
    var ret = [];
    var iterable = ['R', 'G', 'B'];
    for (var i = 0; i < iterable.length; i++) {
        var channel = iterable[i];

        var m1 = m[channel][0];
        var m2 = m[channel][1];
        var m3 = m[channel][2];

        var iterable1 = [0, 1];
        for (var j = 0; j < iterable1.length; j++) {

            var t = iterable1[j];
            var top1 = (284517 * m1 - 94839 * m3) * sub2;
            var top2 = (838422 * m3 + 769860 * m2 + 731718 * m1) * L * sub2 - 769860 * t * L;
            var bottom = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t;

            ret.push([top1 / bottom, top2 / bottom]);
        }
    }
    return ret;
};

var intersectLineLine = function intersectLineLine(line1, line2) {
    return (line1[1] - line2[1]) / (line2[0] - line1[0]);
};

var distanceFromPole = function distanceFromPole(point) {
    return Math.sqrt(Math.pow(point[0], 2) + Math.pow(point[1], 2));
};

var lengthOfRayUntilIntersect = function lengthOfRayUntilIntersect(theta, line) {
    // theta  -- angle of ray starting at (0, 0)
    // m, b   -- slope and intercept of line
    // x1, y1 -- coordinates of intersection
    // len    -- length of ray until it intersects with line
    //
    // b + m * x1        = y1
    // len              >= 0
    // len * cos(theta)  = x1
    // len * sin(theta)  = y1
    //
    //
    // b + m * (len * cos(theta)) = len * sin(theta)
    // b = len * sin(hrad) - m * len * cos(theta)
    // b = len * (sin(hrad) - m * cos(hrad))
    // len = b / (sin(hrad) - m * cos(hrad))
    //
    var m1 = line[0];
    var b1 = line[1];

    var len = b1 / (Math.sin(theta) - m1 * Math.cos(theta));
    if (len < 0) {
        return null;
    }
    return len;
};

// For given lightness, returns the maximum chroma. Keeping the chroma value
// below this number will ensure that for any hue, the color is within the RGB
// gamut.
var maxSafeChromaForL = function maxSafeChromaForL(L) {
    var lengths = [];
    var iterable = getBounds(L);
    for (var i = 0; i < iterable.length; i++) {
        // x where line intersects with perpendicular running though (0, 0)

        var m1 = iterable[i][0];
        var b1 = iterable[i][1];

        var x = intersectLineLine([m1, b1], [-1 / m1, 0]);
        lengths.push(distanceFromPole([x, b1 + x * m1]));
    }
    return Math.min.apply(Math, lengths);
};

// For a given lightness and hue, return the maximum chroma that fits in
// the RGB gamut.
var maxChromaForLH = function maxChromaForLH(L, H) {
    var hrad = H / 360 * Math.PI * 2;
    var lengths = [];
    var iterable = getBounds(L);
    for (var i = 0; i < iterable.length; i++) {
        var line = iterable[i];
        var l = lengthOfRayUntilIntersect(hrad, line);
        if (l !== null) {
            lengths.push(l);
        }
    }
    return Math.min.apply(Math, lengths);
};

var dotProduct = function dotProduct(a, b) {
    var ret = 0;
    var iterable = __range__(0, a.length - 1, true);
    for (var j = 0; j < iterable.length; j++) {
        var i = iterable[j];
        ret += a[i] * b[i];
    }
    return ret;
};

// Used for rgb conversions
var fromLinear = function fromLinear(c) {
    if (c <= 0.0031308) {
        return 12.92 * c;
    } else {
        return 1.055 * Math.pow(c, 1 / 2.4) - 0.055;
    }
};

var toLinear = function toLinear(c) {
    var a = 0.055;
    if (c > 0.04045) {
        return Math.pow((c + a) / (1 + a), 2.4);
    } else {
        return c / 12.92;
    }
};

// This map will contain our conversion functions
var conv = {
    'xyz': {},
    'luv': {},
    'lch': {},
    'husl': {},
    'huslp': {},
    'rgb': {},
    'hex': {}
};

conv.xyz.rgb = function (tuple) {
    var R = fromLinear(dotProduct(m.R, tuple));
    var G = fromLinear(dotProduct(m.G, tuple));
    var B = fromLinear(dotProduct(m.B, tuple));
    return [R, G, B];
};

conv.rgb.xyz = function (tuple) {

    var R = tuple[0];
    var G = tuple[1];
    var B = tuple[2];

    var rgbl = [toLinear(R), toLinear(G), toLinear(B)];
    var X = dotProduct(m_inv.X, rgbl);
    var Y = dotProduct(m_inv.Y, rgbl);
    var Z = dotProduct(m_inv.Z, rgbl);
    return [X, Y, Z];
};

// http://en.wikipedia.org/wiki/CIELUV
// In these formulas, Yn refers to the reference white point. We are using
// illuminant D65, so Yn (see refY in Maxima file) equals 1. The formula is
// simplified accordingly.
var Y_to_L = function (Y) {
    if (Y <= epsilon) {
        return Y * kappa;
    } else {
        return 116 * Math.pow(Y, 1 / 3) - 16;
    }
};
var L_to_Y = function (L) {
    if (L <= 8) {
        return L / kappa;
    } else {
        return Math.pow((L + 16) / 116, 3);
    }
};

conv.xyz.luv = function (tuple) {

    var X = tuple[0];
    var Y = tuple[1];
    var Z = tuple[2];
    // Black will create a divide-by-zero error in
    // the following two lines

    if (Y === 0) {
        return [0, 0, 0];
    }
    var L = Y_to_L(Y);
    var varU = 4 * X / (X + 15 * Y + 3 * Z);
    var varV = 9 * Y / (X + 15 * Y + 3 * Z);
    var U = 13 * L * (varU - refU);
    var V = 13 * L * (varV - refV);
    return [L, U, V];
};

conv.luv.xyz = function (tuple) {

    var L = tuple[0];
    var U = tuple[1];
    var V = tuple[2];
    // Black will create a divide-by-zero error

    if (L === 0) {
        return [0, 0, 0];
    }
    var varU = U / (13 * L) + refU;
    var varV = V / (13 * L) + refV;
    var Y = L_to_Y(L);
    var X = 0 - 9 * Y * varU / ((varU - 4) * varV - varU * varV);
    var Z = (9 * Y - 15 * varV * Y - varV * X) / (3 * varV);
    return [X, Y, Z];
};

conv.luv.lch = function (tuple) {
    var L = tuple[0];
    var U = tuple[1];
    var V = tuple[2];
    var H, Hrad;

    var C = Math.sqrt(Math.pow(U, 2) + Math.pow(V, 2));
    // Greys: disambiguate hue
    if (C < 0.00000001) {
        H = 0;
    } else {
        Hrad = Math.atan2(V, U);
        H = Hrad * 360 / 2 / Math.PI;
        if (H < 0) {
            H = 360 + H;
        }
    }
    return [L, C, H];
};

conv.lch.luv = function (tuple) {
    var L = tuple[0];
    var C = tuple[1];
    var H = tuple[2];

    var Hrad = H / 360 * 2 * Math.PI;
    var U = Math.cos(Hrad) * C;
    var V = Math.sin(Hrad) * C;
    return [L, U, V];
};

conv.husl.lch = function (tuple) {
    var H = tuple[0];
    var S = tuple[1];
    var L = tuple[2];
    var C, max;
    // White and black: disambiguate chroma

    if (L > 99.9999999 || L < 0.00000001) {
        C = 0;
    } else {
        max = maxChromaForLH(L, H);
        C = max / 100 * S;
    }
    return [L, C, H];
};

conv.lch.husl = function (tuple) {
    var L = tuple[0];
    var C = tuple[1];
    var H = tuple[2];
    var S, max;
    // White and black: disambiguate saturation

    if (L > 99.9999999 || L < 0.00000001) {
        S = 0;
    } else {
        max = maxChromaForLH(L, H);
        S = C / max * 100;
    }
    return [H, S, L];
};

//# PASTEL HUSL

conv.huslp.lch = function (tuple) {
    var H = tuple[0];
    var S = tuple[1];
    var L = tuple[2];
    var C, max;

    // White and black: disambiguate chroma
    if (L > 99.9999999 || L < 0.00000001) {
        C = 0;
    } else {
        max = maxSafeChromaForL(L);
        C = max / 100 * S;
    }
    return [L, C, H];
};

conv.lch.huslp = function (tuple) {
    var S, max;

    var L = tuple[0];
    var C = tuple[1];
    var H = tuple[2];
    // White and black: disambiguate saturation

    if (L > 99.9999999 || L < 0.00000001) {
        S = 0;
    } else {
        max = maxSafeChromaForL(L);
        S = C / max * 100;
    }
    return [H, S, L];
};

conv.rgb.hex = function (tuple) {
    var hex = "#";
    for (var i = 0; i < tuple.length; i++) {
        // Round to 6 decimal places
        var ch = tuple[i];
        ch = Math.round(ch * 1e6) / 1e6;
        if (ch < 0 || ch > 1) {
            throw new Error('Illegal rgb value: ' + ch);
        }
        ch = Math.round(ch * 255).toString(16);
        if (ch.length === 1) {
            ch = '0' + ch;
        }
        hex += ch;
    }
    return hex;
};

conv.hex.rgb = function (hex) {
    if (hex.charAt(0) === "#") {
        hex = hex.substring(1, 7);
    }
    var r = hex.substring(0, 2);
    var g = hex.substring(2, 4);
    var b = hex.substring(4, 6);
    return [r, g, b].map(function (n) {
        return parseInt(n, 16) / 255;
    });
};

conv.lch.rgb = function (tuple) {
    return conv.xyz.rgb(conv.luv.xyz(conv.lch.luv(tuple)));
};
conv.rgb.lch = function (tuple) {
    return conv.luv.lch(conv.xyz.luv(conv.rgb.xyz(tuple)));
};

conv.husl.rgb = function (tuple) {
    return conv.lch.rgb(conv.husl.lch(tuple));
};
conv.rgb.husl = function (tuple) {
    return conv.lch.husl(conv.rgb.lch(tuple));
};
conv.huslp.rgb = function (tuple) {
    return conv.lch.rgb(conv.huslp.lch(tuple));
};
conv.rgb.huslp = function (tuple) {
    return conv.lch.huslp(conv.rgb.lch(tuple));
};

var root = {};

root.fromRGB = function (R, G, B) {
    return conv.rgb.husl([R, G, B]);
};
root.fromHex = function (hex) {
    return conv.rgb.husl(conv.hex.rgb(hex));
};
root.toRGB = function (H, S, L) {
    return conv.husl.rgb([H, S, L]);
};
root.toHex = function (H, S, L) {
    return conv.rgb.hex(conv.husl.rgb([H, S, L]));
};
root.p = {};
root.p.toRGB = function (H, S, L) {
    return conv.xyz.rgb(conv.luv.xyz(conv.lch.luv(conv.huslp.lch([H, S, L]))));
};
root.p.toHex = function (H, S, L) {
    return conv.rgb.hex(conv.xyz.rgb(conv.luv.xyz(conv.lch.luv(conv.huslp.lch([H, S, L])))));
};
root.p.fromRGB = function (R, G, B) {
    return conv.lch.huslp(conv.luv.lch(conv.xyz.luv(conv.rgb.xyz([R, G, B]))));
};
root.p.fromHex = function (hex) {
    return conv.lch.huslp(conv.luv.lch(conv.xyz.luv(conv.rgb.xyz(conv.hex.rgb(hex)))));
};

root._conv = conv;
root._getBounds = getBounds;
root._maxChromaForLH = maxChromaForLH;
root._maxSafeChromaForL = maxSafeChromaForL;

// If no framework is available, just export to the global object (window.HUSL
// in the browser)
if ((typeof module === 'undefined' || module === null) && (typeof jQuery === 'undefined' || jQuery === null) && (typeof requirejs === 'undefined' || requirejs === null)) {
    undefined.HUSL = root;
}
// Export to Node.js
if (typeof module !== 'undefined' && module !== null) {
    module.exports = root;
}
// Export to jQuery
if (typeof jQuery !== 'undefined' && jQuery !== null) {
    jQuery.husl = root;
}
// Export to RequireJS
if (typeof requirejs !== 'undefined' && requirejs !== null && typeof define !== 'undefined' && define !== null) {
    define(root);
}

function __range__(left, right, inclusive) {
    var range = [];
    var ascending = left < right;
    var end = !inclusive ? right : ascending ? right + 1 : right - 1;
    for (var i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
        range.push(i);
    }
    return range;
}

