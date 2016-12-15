var assert = require('assert');
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

function testConsistency(husl) {
    console.log('should consistently convert between HUSL and hex');
    manySamples(function (hex) {
        assert.deepEqual(hex, husl.Husl.huslToHex(husl.Husl.hexToHusl(hex)));
    });
    console.log('should consistently convert between HUSLp and hex');
    manySamples(function (hex) {
        assert.deepEqual(hex, husl.Husl.huslpToHex(husl.Husl.hexToHuslp(hex)));
    });
}

function testRGBRange(husl) {
    console.log('should fit within the RGB ranges');
    var H = 0;
    var S = 0;
    var L = 0;

    var channel;
    while (H <= 360) {
        while (S <= 100) {
            while (L <= 100) {
                var RGB = husl.Husl.huslToRgb([H, S, L]);
                for (var i = 0; i < RGB.length; i++) {
                    channel = RGB[i];
                    assert(-rgbRangeTolerance <= channel && channel <= 1 + rgbRangeTolerance, 'HUSL: ' + [H, S, L] + ' -> ' + RGB);
                }

                RGB = husl.Husl.huslpToRgb([H, S, L]);
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

function testSnapshot(husl, snapshot) {
    console.log('should match the stable snapshot');
    var stableSamples;
    var currentSamples;
    var stableTuple;
    var currentTuple;
    var diff;

    Object.keys(snapshot).map(function (hex) {
        stableSamples = snapshot[hex];
        currentSamples = {
            'husl': husl.Husl.hexToHusl(hex),
            'huslp': husl.Husl.hexToHuslp(hex)
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

if (require.main === module) {
    console.log(JSON.stringify(process.argv));
    var husl = require(process.argv[2]);
    var snapshot = require(process.argv[3]);
    testConsistency(husl);
    testRGBRange(husl);
    testSnapshot(husl, snapshot);
    console.log('All good!')
}
