// Matching the public API of the original JavaScript implementation

function expandParams(f) {
    return function (c1, c2, c3) {
        return f([c1, c2, c3])
    }
}

var exportObject = {
    'fromRGB': expandParams(husl.Husl.rgbToHusl),
    'fromHex': husl.Husl.hexToHusl,
    'toRGB': expandParams(husl.Husl.huslToRgb),
    'toHex': expandParams(husl.Husl.huslToHex),
    'p': {
        'fromRGB': expandParams(husl.Husl.rgbToHuslp),
        'fromHex': husl.Husl.hexToHuslp,
        'toRGB': expandParams(husl.Husl.huslpToRgb),
        'toHex': expandParams(husl.Husl.huslpToHex)
    }
};