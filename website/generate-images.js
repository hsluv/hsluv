const fs = require('fs');
const pngjs = require('pngjs');

// Expecting full API
const hsluv = require('hsluv');

function hslToRgb(h, s, l) {
    let r, g, b;

    if (s === 0) {
        r = g = b = l; // achromatic
    } else {
        function hue2rgb(p, q, t) {
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            if (t < 1 / 6) return p + (q - p) * 6 * t;
            if (t < 1 / 2) return q;
            if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
            return p;
        }

        let q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        let p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    }

    return [r, g, b];
}

function makeImage(file, func, width, height) {
    console.log(' - ' + file);
    let png = new pngjs.PNG({
        width: width,
        height: height
    });
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            let pos = (y * width + x) * 4;
            let xn = x / (width - 1);
            let yn = 1 - y / (height - 1);

            let rgbVal = func(xn, yn);
            let rgb = rgbPrepare(rgbVal);

            png.data[pos] = rgb[0];
            png.data[pos + 1] = rgb[1];
            png.data[pos + 2] = rgb[2];
            png.data[pos + 3] = 255;
        }
    }

    return png.pack().pipe(fs.createWriteStream(file));
}

function chromaDemo(rgb) {
    const lch = hsluv.Hsluv.rgbToLch(rgb);
    const C = lch[1] * 0.8;
    return hsluv.Hsluv.lchToRgb([50, C, 10]);
}

// Rounds number to a given number of decimal places
function round(num, places) {
    const n = Math.pow(10, places);
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
    const umin = -30;
    const umax = 84;
    const vmin = -70;
    const vmax = 45;

    const u = umin + x * (umax - umin);
    const v = vmin + y * (vmax - vmin);

    return hsluv.Hsluv.xyzToRgb(hsluv.Hsluv.luvToXyz([50, u, v]));
}

function demoHsluv(x, y) {
    return hsluv.Hsluv.hsluvToRgb([x * 360, y * 100, 50]);
}

function demoHpluv(x, y) {
    return hsluv.Hsluv.hpluvToRgb([x * 360, y * 100, 50]);
}

function demoHsluvChroma(x, y) {
    const rgb = hsluv.Hsluv.hsluvToRgb([x * 360, y * 100, 50]);
    return chromaDemo(rgb);
}

function demoCielchuvChroma(x, y) {
    const lch = [50, y * 200, x * 360];
    const S = hsluv.Hsluv.lchToHsluv(lch)[1];
    let rgb;
    if (S > 100) {
        rgb = [0, 0, 0];
    } else {
        rgb = hsluv.Hsluv.lchToRgb(lch);
    }
    return chromaDemo(rgb);
}

function demoCielchuv(x, y) {
    const lch = [50, y * 200, x * 360];
    const S = hsluv.Hsluv.lchToHsluv(lch)[1];
    if (S > 100) {
        return [0, 0, 0];
    } else {
        return hsluv.Hsluv.lchToRgb(lch);
    }
}

function demoHsl(x, y) {
    return hslToRgb(x, y, 0.5);
}

function demoHslLightness(x, y) {
    const rgb = hslToRgb(x, y, 0.5);
    const lch = hsluv.Hsluv.rgbToLch(rgb);
    const l = lch[0] / 100;
    return [l, l, l];
}

function demoCielchuvLightness(x, y) {
    const lch = [50, y * 200, x * 360];
    const S = hsluv.Hsluv.lchToHsluv(lch)[1];
    if (S > 100) {
        return [0, 0, 0];
    } else {
        return [0.5, 0.5, 0.5];
    }
}

function demoHsluvLightness() {
    return [0.5, 0.5, 0.5];
}

function demoHslChroma(x, y) {
    const rgb = hslToRgb(x, y, 0.5);
    return chromaDemo(rgb);
}

function demoHpluvChroma(x, y) {
    const rgb = hsluv.Hsluv.hpluvToRgb([x * 360, y * 100, 50]);
    return chromaDemo(rgb);
}

function makeDir(path) {
    if (!fs.existsSync(path)) {
        console.log('creating directory', path);
        fs.mkdirSync(path);
    }
}

function generateImages(targetDir) {
    const demos = {
        'hsluv': demoHsluv,
        'hpluv': demoHpluv,
        'hsluv-chroma': demoHsluvChroma,
        'cielchuv-chroma': demoCielchuvChroma,
        'cielchuv': demoCielchuv,
        'hsl': demoHsl,
        'hsl-lightness': demoHslLightness,
        'cielchuv-lightness': demoCielchuvLightness,
        'hsluv-lightness': demoHsluvLightness,
        'hpluv-lightness': demoHsluvLightness,
        'hsl-chroma': demoHslChroma,
        'hpluv-chroma': demoHpluvChroma
    };
    console.log("Generating demo images:");
    makeDir(targetDir + '/images');
    makeImage(targetDir + '/favicon.png', luvSquare, 32, 32);
    Object.keys(demos).forEach(function (demoName) {
        let file = targetDir + '/images/' + demoName + '.png';
        return makeImage(file, demos[demoName], 360, 200);
    });
}

if (require.main === module) {
    const type = process.argv[2];
    const target = process.argv[3];
    if (type === '--website') {
        generateImages(target);
    } else if (type === '--avatar') {
        makeImage(target, luvSquare, 200, 200);
    }
}
