'use strict';
var hsluv = require('hsluv');
var digits = '0123456789abcdef';


var testPrecision = function testPrecision(numDigits) {
    // Test how many digits of HPLuv decimal precision is enough to unambiguously
    // specify a hex-encoded RGB color. Spoiler alert: it's 4.
    // Adapted from: https://gist.github.com/roryokane/f15bb23abcf9938c0707
    for (var i = 0; i < digits.length; i++) {
        var r1 = digits[i];
        for (var j = 0; j < digits.length; j++) {
            var g1 = digits[j];
            for (var k = 0; k < digits.length; k++) {
                // Assuming that only the least significant hex digit can cause a
                // collision. Otherwise this program uses too much memory.
                var b1 = digits[k];
                console.log('Testing #' + r1 + '_' + g1 + '_' + b1 + '_');
                var accum = {};
                for (var i1 = 0; i1 < digits.length; i1++) {
                    var r2 = digits[i1];
                    for (var j1 = 0; j1 < digits.length; j1++) {
                        var g2 = digits[j1];
                        for (var k1 = 0; k1 < digits.length; k1++) {
                            var b2 = digits[k1];
                            var hex = '#' + r1 + r2 + g1 + g2 + b1 + b2;
                            var hsl = hsluv.fromHex(hex);
                            var key = [hsl.map(function (ch) {
                                return ch.toFixed(numDigits);
                            })].join('|');
                            if (accum[key]) {
                                console.log("FOUND COLLISION:");
                                console.log(hex, accum[key]);
                                console.log(key);
                                return;
                            } else {
                                accum[key] = hex;
                            }
                        }
                    }
                }
            }
        }
    }
};

if (require.main === module) {
    testPrecision(4);
}
