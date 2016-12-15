function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min;
}

function generateSeed() {
    var seed = "";
    for (var i = 0; i <= 5; i++) {
        seed += getRandomInt(0, 9);
    }
    return seed;
}

function forEach(iterable, f) {
    for (var i=0; i<iterable.length; i++) {
        f(iterable[i]);
    }
}

document.addEventListener('DOMContentLoaded', function () {
    var shuffleButton = document.getElementById('shuffle');
    var vimButton = document.getElementById('vim');
    var textmateButton = document.getElementById('textmate');

    if (window.location.hash === '') {
        shuffle();
    } else {
        Math.seedrandom(window.location.hash.substring(1));
        shuffle();
    }

    shuffleButton.addEventListener('click', function () {
        var seed = generateSeed();
        window.location.hash = seed;
        Math.seedrandom(seed);
        shuffle();
    });

    function shuffle() {
        var data = [];
        // 6 hues to pick from
        var h = getRandomInt(0, 360);
        var H = ([0, 60, 120, 180, 240, 300]).map(function (offset) {
            return (h + offset) % 360;
        });
        // 8 shades of low-saturated color
        var backS = getRandomInt(5, 40);
        var darkL = getRandomInt(0, 10);
        var rangeL = 90 - darkL;
        for (var i = 0; i <= 7; i++) {
            data.push(hsluv.Hsluv.hsluvToHex([H[0], backS, darkL + rangeL * Math.pow(i / 7, 1.5)]));
        }
        // 8 Random shades
        var minS = getRandomInt(30, 70);
        var maxS = minS + 30;
        var minL = getRandomInt(50, 70);
        var maxL = minL + 20;
        for (var j = 0; j <= 7; j++) {
            var _h = H[getRandomInt(0, 5)];
            var _s = getRandomInt(minS, maxS);
            var _l = getRandomInt(minL, maxL);
            data.push(hsluv.Hsluv.hsluvToHex([_h, _s, _l]));
        }
        // Update colors and download links
        var params = [];
        for (var k = 0; k <= 15; k++) {
            var color = data[k];
            var key = 'base0' + k.toString(16).toUpperCase();
            forEach(document.getElementsByClassName(key), function (e) {
                e.style.color = color;
            });
            forEach(document.getElementsByClassName(key + '-background'), function (e) {
                e.style.backgroundColor = color;
            });
            params.push(key + '=' + color.substring(1));
        }
        params = params.join('&');
        vimButton.setAttribute('href', 'http://base16api.boronine.com/vim?' + params);
        textmateButton.setAttribute('href', 'http://base16api.boronine.com/textmate?' + params);

        document.body.style.backgroundColor = hsluv.Hsluv.hsluvToHex([H[0], backS, 3]);
        //document.body.style.backgroundColor = '#000000';
        shuffleButton.style.backgroundColor = hsluv.Hsluv.hsluvToHex([H[0], backS, 20]);
    }
});