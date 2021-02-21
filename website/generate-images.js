const fs = require('fs');

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

function makeImage(func, width, height) {
    const depth = 4;
    const header = `P7\nWIDTH ${width}\nHEIGHT ${height}\nDEPTH ${depth}\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n`;
    const body = Buffer.alloc(width * height * depth);
    for (let y = 0; y < height; y++) {
        for (let x = 0; x < width; x++) {
            let pos = (y * width + x) * 4;
            let xn = x / (width - 1);
            let yn = 1 - y / (height - 1);

            let rgbVal = func(xn, yn);
            let rgb = rgbPrepare(rgbVal);

            body.writeUInt8(rgb[0], pos);
            body.writeUInt8(rgb[1], pos + 1);
            body.writeUInt8(rgb[2], pos + 2);
            body.writeUInt8(255, pos + 3);
        }
    }
    // fs.writeFileSync(file + '.pam', Buffer.concat([Buffer.from(header), body]));
    const pam = Buffer.concat([Buffer.from(header), body]);
    process.stdout.write(pam);
}

function chromaDemo(rgb) {
    const lch = hsluv.rgbToLch(rgb);
    const C = lch[1] * 0.8;
    return hsluv.lchToRgb([50, C, 10]);
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

    return hsluv.xyzToRgb(hsluv.luvToXyz([50, u, v]));
}

function demoHsluv(x, y) {
    return hsluv.hsluvToRgb([x * 360, y * 100, 50]);
}

function demoHpluv(x, y) {
    return hsluv.hpluvToRgb([x * 360, y * 100, 50]);
}

function demoHsluvChroma(x, y) {
    const rgb = hsluv.hsluvToRgb([x * 360, y * 100, 50]);
    return chromaDemo(rgb);
}

function demoCielchuvChroma(x, y) {
    const lch = [50, y * 200, x * 360];
    const S = hsluv.lchToHsluv(lch)[1];
    let rgb;
    if (S > 100) {
        rgb = [0, 0, 0];
    } else {
        rgb = hsluv.lchToRgb(lch);
    }
    return chromaDemo(rgb);
}

function demoCielchuv(x, y) {
    const lch = [50, y * 200, x * 360];
    const S = hsluv.lchToHsluv(lch)[1];
    if (S > 100) {
        return [0, 0, 0];
    } else {
        return hsluv.lchToRgb(lch);
    }
}

function demoHsl(x, y) {
    return hslToRgb(x, y, 0.5);
}

function demoHslLightness(x, y) {
    const rgb = hslToRgb(x, y, 0.5);
    const lch = hsluv.rgbToLch(rgb);
    const l = lch[0] / 100;
    return [l, l, l];
}

function demoCielchuvLightness(x, y) {
    const lch = [50, y * 200, x * 360];
    const S = hsluv.lchToHsluv(lch)[1];
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
    const rgb = hsluv.hpluvToRgb([x * 360, y * 100, 50]);
    return chromaDemo(rgb);
}

function makeDir(path) {
    if (!fs.existsSync(path)) {
        console.log('creating directory', path);
        fs.mkdirSync(path);
    }
}

if (require.main === module) {
    const type = process.argv[2];
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

    if (type === 'avatar') {
        makeImage(luvSquare, 200, 200);
    } else if (type === 'favicon') {
        makeImage(luvSquare, 32, 32);
    } else {
        const func = demos[type];
        makeImage(func, 360, 200);
    }
}
