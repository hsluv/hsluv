'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.testPrecision = exports.snapshot = undefined;

var _husl = require('../husl.js');

var _husl2 = _interopRequireDefault(_husl);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var digits = '0123456789abcdef';

var snapshot = function snapshot() {
  var samples = {};

  // Take 16 ^ 3 = 4096 samples
  for (var i = 0; i < digits.length; i++) {
    var r = digits[i];
    for (var j = 0; j < digits.length; j++) {
      var g = digits[j];
      for (var k = 0; k < digits.length; k++) {
        var b = digits[k];
        var hex = '#' + r + r + g + g + b + b;
        var rgb = _husl2.default._conv.hex.rgb(hex);
        var xyz = _husl2.default._conv.rgb.xyz(rgb);
        var luv = _husl2.default._conv.xyz.luv(xyz);
        var lch = _husl2.default._conv.luv.lch(luv);
        samples[hex] = {
          rgb: rgb,
          xyz: xyz,
          luv: luv,
          lch: lch,
          husl: _husl2.default._conv.lch.husl(lch),
          huslp: _husl2.default._conv.lch.huslp(lch)
        };
      }
    }
  }

  return samples;
};

var testPrecision = function testPrecision(numDigits) {
  // Test how many digits of HUSL decimal precision is enough to unambiguously
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
              var hsl = _husl2.default.fromHex(hex);
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

exports.snapshot = snapshot;
exports.testPrecision = testPrecision;


if (require.main === module) {
  console.log(JSON.stringify(snapshot()));
}
