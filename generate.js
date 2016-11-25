var fs = require('fs');
var pngjs = require('pngjs');
var colorspaces = require('colorspaces');
var onecolor = require('onecolor');
var husl = require('husl');
var mustache = require('mustache');


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
            var xn = x / (width - 1);
            var yn = 1 - y / (height - 1);

            var rgbVal = func(xn, yn);
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

function demoHusl(x, y) {
    return husl.toRGB(x * 360, y * 100, 50);
}

function demoHuslp(x, y) {
    return husl.p.toRGB(x * 360, y * 100, 50);
}

function demoHuslChroma(x, y) {
    var rgb = husl.toRGB(x * 360, y * 100, 50);
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
}

function demoCielchuvChroma(x, y) {
    var color = colorspaces.make_color('CIELCHuv', [50, 200 - y * 200, x * 360]);
    var rgb;
    if (!color.is_displayable()) {
        rgb = [0, 0, 0];
    } else {
        rgb = color.as('sRGB');
    }
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
}

function demoCielchuv(x, y) {
    var color = colorspaces.make_color('CIELCHuv', [50, 200 - y * 200, x * 360]);
    if (!color.is_displayable()) {
        return [0, 0, 0];
    } else {
        return color.as('sRGB');
    }
}

function demoHsl(x, y) {
    return hslToRgb(x, 1 - y, 0.5);
}

function demoHslLightness(x, y) {
    var rgb = hslToRgb(x, 1 - y, 0.5);
    var color = colorspaces.make_color('sRGB', rgb);
    var l = color.as('CIELUV')[0] / 100;
    return [l, l, l];
}

function demoCielchuvLightness(x, y) {
    var color = colorspaces.make_color('CIELCHuv', [50, 200 - y * 200, x * 360]);
    if (!color.is_displayable()) {
        return [0, 0, 0];
    } else {
        return [0.5, 0.5, 0.5];
    }
}

function demoHuslLightness() {
    return [0.5, 0.5, 0.5];
}

function demoHslChroma(x, y) {
    var rgb = hslToRgb(x, 1 - y, 0.5);
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
}

function demoHuslpChroma(x, y) {
    var rgb = husl.p.toRGB(x * 360, y * 100, 50);
    return chromaDemo(colorspaces.make_color('sRGB', rgb));
}




// Generate larger picture, e.g. for GitHub
// makeImage('dist/github.png', luvSquare, 200, 200);

function makeDir(path) {
    if (!fs.existsSync(path)) {
        console.log('creating directory', path);
        fs.mkdirSync(path);
    }
}

function generateImages() {
    var demos = {
        'husl': demoHusl,
        'huslp': demoHuslp,
        'husl-chroma': demoHuslChroma,
        'cielchuv-chroma': demoCielchuvChroma,
        'cielchuv': demoCielchuv,
        'hsl': demoHsl,
        'hsl-lightness': demoHslLightness,
        'cielchuv-lightness': demoCielchuvLightness,
        'husl-lightness': demoHuslLightness,
        'huslp-lightness': demoHuslLightness,
        'hsl-chroma': demoHslChroma,
        'huslp-chroma': demoHuslpChroma
    };
    console.log("Generating demo images:");

    makeDir('dist');
    makeDir('dist/images');

    makeImage('dist/favicon.png', luvSquare, 32, 32);
    Object.keys(demos).forEach(function(demoName) {
        var file = 'dist/images/' + demoName + '.png';
        return makeImage(file, demos[demoName], 360, 200);
    });
}

function generateHtml() {
    var baseTemplate = fs.readFileSync('templates/base.mustache').toString();
    var pages = [
        {
            page: 'index',
            index: true,
            bodyClass: 'dark',
            title: 'HUSL'
        },
        {
            page: 'comparison',
            title: 'Comparing HUSL to HSL'
        },
        {
            page: 'implementations',
            title: 'Implementations'
        },
        {
            page: 'math',
            title: 'Math'
        },
        {
            page: 'syntax',
            title: 'Random Syntax Highlighting Color Schemes',
            bodyClass: 'dark'
        }
    ];

    pages.forEach(function (pageInfo) {
        var pageContent = fs.readFileSync('content/' + pageInfo.page + '.html').toString();
        var target;
        var context = {
            content: pageContent,
            bodyClass: pageInfo.bodyClass,
            title: pageInfo.title
        };
        if (pageInfo.index) {
            target = 'dist/' + pageInfo.page + '.html';
        } else {
            makeDir('dist/' + pageInfo.page);
            target = 'dist/' + pageInfo.page + '/index.html';
        }
        console.log('generating ' + target);
        var renderedContent = mustache.render(baseTemplate, context);
        fs.writeFileSync(target, renderedContent);
    });
}

if (require.main === module) {
    var command = process.argv[2];
    if (command === '--images') {
        generateImages();
    } else if (command === '--html') {
        generateHtml();
    }
}
