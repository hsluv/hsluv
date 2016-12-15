var assert = require('assert');

function testPublicApi(husl) {
    var samples = ['#000000', '#ffffff', '#123456'];
    samples.forEach(function(hexOrig) {
        console.log('testing:', hexOrig);
        var huslTuple = husl.Husl.hexToHusl(hexOrig);
        var huslpTuple = husl.Husl.hexToHuslp(hexOrig);
        var hex1 = husl.Husl.huslToHex(huslTuple);
        var hex2 = husl.Husl.huslpToHex(huslpTuple);
        assert(hexOrig === hex1);
        assert(hexOrig === hex2);
    });
}

if (require.main === module) {
    var husl = require(process.argv[2]);
    testPublicApi(husl);
}
