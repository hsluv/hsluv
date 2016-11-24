var fs = require('fs');
var pngjs = require('pngjs');
var colorspaces = require('colorspaces');
var onecolor = require('onecolor');
var husl = require('husl');

function hslToRgb(h, s, l) {
    h *= 360;
    s *= 100;
    l *= 100;
    var c = onecolor('hsl(' + h + ', ' + s + ', ' + l + ')');
    return [c.red(), c.green(), c.blue()];
}

function makeImage(file, func, width, height) {
    console.log(' - ' + file);
    var png = new pngjs.PNG({
        width: width,
        height: height
    });
    for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
            var pos = (y * width + x) * 4;
            var rgbVal = func(x / (width - 1), y / (height - 1));
            var rgb = rgbPrepare(rgbVal);

            png.data[pos] = rgb[0];
            png.data[pos + 1] = rgb[1];
            png.data[pos + 2] = rgb[2];
            png.data[pos + 3] = 255;
        }
    }

    return png.pack().pipe(fs.createWriteStream(file));
}

function chromaDemo(color) {
    var C = color.as('CIELCHuv')[1] * 0.8;
    var red = colorspaces.make_color('CIELCHuv', [50, C, 10]);
    return red.as('sRGB');
}

// Rounds number to a given number of decimal places
function round(num, places) {
    var n = Math.pow(10, places);
    return Math.round(num * n) / n;
}

function rgbPrepare(tuple) {
    return tuple.map(function (ch) {
        ch = round(ch, 3);
        if (ch < 0 || ch > 1) {
            throw new Error("Illegal rgb value");
        }
        return Math.round(ch * 255);
    });
}

function makeDemo(name, func) {
    var file = 'dist/img/demo/' + name + '.png';
    return makeImage(file, func, 360, 200);
}

function luvSquare(x, y) {
    var c = husl._conv;

    var umin = -30;
    var umax = 84;
    var vmin = -70;
    var vmax = 45;

    var u = umin + x * (umax - umin);
    var v = vmin + y * (vmax - vmin);

    return c.xyz.rgb(c.luv.xyz([50, u, v]));
}

console.log("Generating demo images:");

try {
    fs.mkdirSync('dist/img');
    fs.mkdirSync('dist/img/demo');
} catch (error) {
}

makeImage('dist/favicon.png', luvSquare, 32, 32);

// Generate larger picture, e.g. for GitHub
// makeImage('dist/github.png', luvSquare, 200, 200);

makeDemo('husl', function (x, y) {
    return husl.toRGB(x * 360, 100 - y * 100, 50);
});

makeDemo('huslp', function (x, y) {
    return husl.p.toRGB(x * 360, 100 - y * 100, 50);
});

makeDemo('husl-chroma', function (x, y) {
    var rgb = husl.toRGB(x * 360, 100 - y * 100, 50);
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
});

makeDemo('cielchuv-chroma', function (x, y) {
    var color = colorspaces.make_color('CIELCHuv', [50, 200 - y * 200, x * 360]);
    var rgb;
    if (!color.is_displayable()) {
        rgb = [0, 0, 0];
    } else {
        rgb = color.as('sRGB');
    }
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
});

makeDemo('cielchuv', function (x, y) {
    var color = colorspaces.make_color('CIELCHuv', [50, 200 - y * 200, x * 360]);
    if (!color.is_displayable()) {
        return [0, 0, 0];
    } else {
        return color.as('sRGB');
    }
});

makeDemo('hsl', function (x, y) {
    return hslToRgb(x, 1 - y, 0.5);
});

makeDemo('hsl-lightness', function (x, y) {
    var rgb = hslToRgb(x, 1 - y, 0.5);
    var color = colorspaces.make_color('sRGB', rgb);
    var l = color.as('CIELUV')[0] / 100;
    return [l, l, l];
});

makeDemo('cielchuv-lightness', function (x, y) {
    var color = colorspaces.make_color('CIELCHuv', [50, 200 - y * 200, x * 360]);
    if (!color.is_displayable()) {
        return [0, 0, 0];
    } else {
        return [0.5, 0.5, 0.5];
    }
});

makeDemo('husl-lightness', function () {
    return [0.5, 0.5, 0.5];
});

makeDemo('huslp-lightness', function () {
    return [0.5, 0.5, 0.5];
});

makeDemo('hsl-chroma', function (x, y) {
    var rgb = hslToRgb(x, 1 - y, 0.5);
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
});

makeDemo('huslp-chroma', function (x, y) {
    var rgb = husl.p.toRGB(x * 360, 100 - y * 100, 50);
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
});
