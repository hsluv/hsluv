// Matching the public exports in husl-colors/husl
function expandParams(f) {
	return function(c1, c2, c3) {
		return f([c1, c2, c3])
	}
}
module['exports'] = {};
module['exports']["fromRGB"] = expandParams(husl.Husl.rgbToHusl);
module['exports']["fromHex"] = husl.Husl.hexToHusl;
module['exports']["toRGB"] = expandParams(husl.Husl.huslToRgb);
module['exports']["toHex"] = expandParams(husl.Husl.huslToHex);
module['exports']['p'] = {};
module['exports']['p']["fromRGB"] = expandParams(husl.Husl.rgbToHuslp);
module['exports']['p']["fromHex"] = husl.Husl.hexToHuslp;
module['exports']['p']["toRGB"] = expandParams(husl.Husl.huslpToRgb);
module['exports']['p']["toHex"] = expandParams(husl.Husl.huslpToHex);