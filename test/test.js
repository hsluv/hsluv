var assert = require('assert');
var husl = require('../husl.js');
var snapshot = require('./snapshot.js');

function manySamples(assertion) {
    var samples = '0123456789abcdef'.split('');
    samples.map(function (r) {
        samples.map(function (g) {
            samples.map(function (b) {
                assertion('#' + r + r + g + g + b + b);
            });
        });
    });
}

describe('HUSL consistency', function () {
    it('should convert between HUSL and hex', function () {
        manySamples(function (hex) {
            assert.deepEqual(hex, husl.toHex.apply(this, husl.fromHex(hex)));
        });
    });
    it('should convert between HUSLp and hex', function () {
        manySamples(function (hex) {
            assert.deepEqual(hex, husl.p.toHex.apply(this, husl.p.fromHex(hex)));
        });
    });
});

var rgbRangeTolerance = 0.00000000001;
var snapshotTolerance = 0.00000000001;

describe('Fits within RGB ranges', function () {
    return it('should fit', function () {
        var H = 0;
        var S = 0;
        var L = 0;

        var channel;
        while (H <= 360) {
            while (S <= 100) {
                while (L <= 100) {
                    var RGB = husl.toRGB(H, S, L);
                    for (var i = 0; i < RGB.length; i++) {
                        channel = RGB[i];
                        assert(-rgbRangeTolerance <= channel && channel <= 1 + rgbRangeTolerance, 'HUSL: ' + [H, S, L] + ' -> ' + RGB);
                    }

                    RGB = husl.p.toRGB(H, S, L);
                    for (var j = 0; j < RGB.length; j++) {
                        channel = RGB[j];
                        assert(-rgbRangeTolerance <= channel && channel <= 1 + rgbRangeTolerance, 'HUSLp: ' + [H, S, L] + ' -> ' + RGB);
                    }
                    L += 5;
                }
                S += 5;
            }
            H += 5;
        }
    });
});

describe('HUSL snapshot', function () {
    return it('should match the stable snapshot', function () {
        var stableSamples;
        var currentSamples;
        var stableTuple;
        var currentTuple;
        var diff;
        this.timeout(10000);

        var current = snapshot.snapshot();
        var stable = require('./snapshot-rev4.json');

        Object.keys(stable).map(function (hex) {
            stableSamples = stable[hex];
            currentSamples = current[hex];
            Object.keys(stableSamples).map(function (tag) {
                stableTuple = stableSamples[tag];
                currentTuple = currentSamples[tag];
                [0, 1, 2].map(function (i) {
                    diff = Math.abs(currentTuple[i] - stableTuple[i]);
                    assert(diff < snapshotTolerance, 'The snapshots for ' + hex + ' don\'t match at ' + tag + '\nStable:  ' + stableTuple + '\nCurrent: ' + currentTuple);
                });
            });
        });
    });
});

