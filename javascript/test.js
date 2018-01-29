if (require.main === module) {
    const assert = require('assert');
    const samples = ['#000000', '#ffffff', '#f19fb7'];
    for (let hexOrig of samples) {
        console.log('testing:', hexOrig);
        const hsluvTuple = hsluv.hexToHsluv(hexOrig);
        const hpluvTuple = hsluv.hexToHpluv(hexOrig);
        const hex1 = hsluv.hsluvToHex(hsluvTuple);
        const hex2 = hsluv.hpluvToHex(hpluvTuple);
        assert(hexOrig === hex1);
        assert(hexOrig === hex2);
    }
}
