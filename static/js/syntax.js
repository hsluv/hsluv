function generateSeed() {
    var seed = "";
    for (var i = 0; i <= 5; i++) {
        seed += _.random(0, 9);
    }
    return seed;
}

document.addEventListener('DOMContentLoaded', function () {
    var shuffleEl = document.getElementById('shuffle');
    var vimButton = document.getElementById('vim');
    var textmateButton = document.getElementById('textmate');

    if (window.location.hash === '') {
        shuffle();
    } else {
        Math.seedrandom(window.location.hash.substring(1));
        shuffle();
    }

    shuffleEl.addEventListener('click', function () {
        var seed = generateSeed();
        window.location.hash = seed;
        Math.seedrandom(seed);
        shuffle();
    });

    function shuffle() {
        var data = [];
        // 6 hues to pick from
        var h = _.random(0, 360);
        var H = _.map([0, 60, 120, 180, 240, 300], function (offset) {
            return (h + offset) % 360;
        });
        // 8 shades of low-saturated color
        var backS = _.random(5, 40);
        var darkL = _.random(0, 10);
        var rangeL = 90 - darkL;
        for (var i = 0; i <= 7; i++) {
            data.push(HUSL.Husl.huslToHex([H[0], backS, darkL + rangeL * Math.pow(i / 7, 1.5)]));
        }
        // 8 Random shades
        var minS = _.random(30, 70);
        var maxS = minS + 30;
        var minL = _.random(50, 70);
        var maxL = minL + 20;
        for (var j = 0; j <= 7; j++) {
            var _h = H[_.random(0, 5)];
            var _s = _.random(minS, maxS);
            var _l = _.random(minL, maxL);
            data.push(HUSL.Husl.huslToHex([_h, _s, _l]));
        }
        // Update colors and download links
        var params = [];
        for (var k = 0; k <= 15; k++) {
            var color = data[k];
            var key = 'base0' + k.toString(16).toUpperCase();
            _(document.getElementsByClassName(key)).map(function(e) {
                e.style.color = color;
            });
            _(document.getElementsByClassName(key + '-background')).map(function(e) {
                e.style.backgroundColor = color;
            });
            params.push(key + '=' + color.substring(1));
        }
        params = params.join('&');
        vimButton.setAttribute('href', 'http://base16api.boronine.com/vim?' + params);
        textmateButton.setAttribute('href', 'http://base16api.boronine.com/textmate?' + params);

        document.body.style.backgroundColor = HUSL.Husl.huslToHex([H[0], backS, 3]);
        //document.body.style.backgroundColor = '#000000';
        shuffleEl.style.backgroundColor = HUSL.Husl.huslToHex([H[0], backS, 20]);
    }
});