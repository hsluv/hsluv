(function () {

    function forEach(iterable, f) {
        for (var i = 0; i < iterable.length; i++) {
            f(iterable[i], i);
        }
    }

    // https://gist.github.com/3716319
    function hslToRgb(h, s, l) {
        var r, g, b;
        h /= 360;
        if (s === 0) {
            r = g = b = l; // achromatic
        } else {
            var hue2rgb = function hue2rgb(p, q, t) {
                if (t < 0) {
                    t += 1;
                }
                if (t > 1) {
                    t -= 1;
                }
                if (t < 1 / 6) {
                    return p + (q - p) * 6 * t;
                }
                if (t < 1 / 2) {
                    return q;
                }
                if (t < 2 / 3) {
                    return p + (q - p) * (2 / 3 - t) * 6;
                }
                return p;
            };

            var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
            var p = 2 * l - q;
            r = hue2rgb(p, q, h + 1 / 3);
            g = hue2rgb(p, q, h);
            b = hue2rgb(p, q, h - 1 / 3);
        }
        return [r, g, b];
    }

    function hslToHex(h, s, l) {
        var rgb = hslToRgb(h, s / 100, l / 100);
        return hsluv.Hsluv.rgbToHex(rgb);
    }

    function randomHue() {
        return Math.floor(Math.random() * 360);
    }

    function refreshDemoHsluv() {
        forEach(demoHsluv.getElementsByTagName('div'), function (e) {
            e.style.backgroundColor = hsluv.Hsluv.hsluvToHex([randomHue(), 90, 60]);
        });
    }

    function refreshDemoHsl() {
        forEach(demoHsl.getElementsByTagName('div'), function (e) {
            e.style.backgroundColor = hslToHex(randomHue(), 90, 60);
        });
    }

    var demoHsluv = document.getElementById('demo-hsluv');
    var demoHsl = document.getElementById('demo-hsl');

    demoHsluv.getElementsByTagName('button')[0].addEventListener('click', refreshDemoHsluv);
    demoHsl.getElementsByTagName('button')[0].addEventListener('click', refreshDemoHsl);

    refreshDemoHsluv();
    refreshDemoHsl();

    var rainbowHsluv = document.getElementById('rainbow-hsluv');
    var rainbowHsl = document.getElementById('rainbow-hsl');

    forEach(rainbowHsluv.getElementsByTagName('div'), function (e, i) {
        e.style.backgroundColor = hsluv.Hsluv.hsluvToHex([i * 36, 90, 60]);
    });

    forEach(rainbowHsl.getElementsByTagName('div'), function (e, i) {
        e.style.backgroundColor = hslToHex(i * 36, 90, 60);
    });

}());
