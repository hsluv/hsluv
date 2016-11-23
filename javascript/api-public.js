// Matching the public API of the original JavaScript implementation

function expandParams(f) {
    return function (c1, c2, c3) {
        return f([c1, c2, c3])
    }
}

var exportObject = {
    'fromRGB': expandParams(husl_Husl.rgbToHusl),
    'fromHex': husl_Husl.hexToHusl,
    'toRGB': expandParams(husl_Husl.huslToRgb),
    'toHex': expandParams(husl_Husl.huslToHex),
    'p': {
        'fromRGB': expandParams(husl_Husl.rgbToHuslp),
        'fromHex': husl_Husl.hexToHuslp,
        'toRGB': expandParams(husl_Husl.huslpToRgb),
        'toHex': expandParams(husl_Husl.huslpToHex)
    }
};