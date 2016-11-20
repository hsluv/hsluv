// Matching the public exports in husl-colors/husl
module['exports'] = {};
module['exports']["fromRGB"] = husl.Husl.rgbToHusl;
module['exports']["fromHex"] = husl.Husl.hexToHusl;
module['exports']["toRGB"] = husl.Husl.huslToRgb;
module['exports']["toHex"] = husl.Husl.huslToHex;
module['exports']['p'] = {};
module['exports']['p']["fromRGB"] = husl.Husl.rgbToHuslp;
module['exports']['p']["fromHex"] = husl.Husl.hexToHuslp;
module['exports']['p']["toRGB"] = husl.Husl.huslpToRgb;
module['exports']['p']["toHex"] = husl.Husl.huslpToHex;