var assert = require('assert');

function testPublicApi(hsluv) {
    var samples = ['#000000', '#ffffff', '#f19fb7'];
    samples.forEach(function(hexOrig) {
        console.log('testing:', hexOrig);
        var hsluvTuple = hsluv.hexToHsluv(hexOrig);
        var hpluvTuple = hsluv.hexToHpluv(hexOrig);
        var hex1 = hsluv.hsluvToHex(hsluvTuple);
        var hex2 = hsluv.hpluvToHex(hpluvTuple);
        assert(hexOrig === hex1);
        assert(hexOrig === hex2);
    });
}

if (require.main === module) {
    var hsluv = require(process.argv[2]);
    testPublicApi(hsluv);
}
