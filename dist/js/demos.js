(function () {

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
        return HUSL.Husl.rgbToHex(rgb);
    }

    function randomHue() {
        return Math.floor(Math.random() * 360);
    }

    function refreshDemoHusl() {
        _(demoHusl.getElementsByClassName('demo')).map(function(e) {
            e.style.backgroundColor = HUSL.Husl.huslToHex([randomHue(), 90, 60]);
        });
    }

    function refreshDemoHsl() {
        _(demoHsl.getElementsByClassName('demo')).map(function(e) {
            e.style.backgroundColor = hslToHex(randomHue(), 90, 60);
        });
    }

    var demoHusl = document.getElementById('demo-husl');
    var demoHsl = document.getElementById('demo-hsl');

    demoHusl.getElementsByTagName('button')[0].addEventListener('click', refreshDemoHusl);
    demoHsl.getElementsByTagName('button')[0].addEventListener('click', refreshDemoHsl);

    refreshDemoHusl();
    refreshDemoHsl();

    var rainbowHusl = document.getElementById('rainbow-husl');
    var rainbowHsl = document.getElementById('rainbow-hsl');

    _(rainbowHusl.getElementsByTagName('div')).map(function (e, i) {
        e.style.backgroundColor = HUSL.Husl.huslToHex([i * 36, 90, 60]);
    });

    _(rainbowHsl.getElementsByTagName('div')).map(function (e, i) {
        e.style.backgroundColor = hslToHex(i * 36, 90, 60);
    });

}());
