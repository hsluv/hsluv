var assert = require('assert');
var husl = require('../bin/husl.min.js');

var rgbRangeTolerance = 0.00000000001;
var snapshotTolerance = 0.000000001;


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

function testConsistency() {
    console.log('should consistently convert between HUSL and hex');
    manySamples(function (hex) {
        assert.deepEqual(hex, husl.toHex.apply(this, husl.fromHex(hex)).toLowerCase());
    });
    console.log('should consistently convert between HUSLp and hex');
    manySamples(function (hex) {
        assert.deepEqual(hex, husl.p.toHex.apply(this, husl.p.fromHex(hex)).toLowerCase());
    });
}

function testRGBRange() {
    console.log('should fit within the RGB ranges');
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
}

function testSnapshot() {
    console.log('should match the stable snapshot');
    var stableSamples;
    var currentSamples;
    var stableTuple;
    var currentTuple;
    var diff;

    var stable = require('../snapshots/snapshot-rev4.json');

    Object.keys(stable).map(function (hex) {
        stableSamples = stable[hex];
        currentSamples = {
            'husl': husl.fromHex(hex),
            'huslp': husl.p.fromHex(hex)
        };

        ['husl', 'huslp'].map(function (tag) {
            stableTuple = stableSamples[tag];
            currentTuple = currentSamples[tag];
            [0, 1, 2].map(function (i) {
                diff = Math.abs(currentTuple[i] - stableTuple[i]);
                assert(diff < snapshotTolerance, 'The snapshots for ' + hex + ' don\'t match at ' + tag + '\nStable:  ' + stableTuple + '\nCurrent: ' + currentTuple);
            });
        });
    });
}


function testAll() {
    testConsistency();
    testRGBRange();
    testSnapshot();
    console.log('All good!')
}

if (require.main === module) {
    testAll();
}
