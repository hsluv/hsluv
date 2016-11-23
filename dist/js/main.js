// https://gist.github.com/3716319
var hslToRgb = function hslToRgb(h, s, l) {
    var r, g, b;
    h /= 360;
    if (s === 0) {
        r = g = b = l; // achromatic
    } else {
        var hue2rgb = function hue2rgb(p, q, t) {
            if (t < 0) {
                t += 1;
            }
            if (t > 1) {
                t -= 1;
            }
            if (t < 1 / 6) {
                return p + (q - p) * 6 * t;
            }
            if (t < 1 / 2) {
                return q;
            }
            if (t < 2 / 3) {
                return p + (q - p) * (2 / 3 - t) * 6;
            }
            return p;
        };

        var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        var p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    }
    return [r, g, b];
};

var hslToHex = function hslToHex(h, s, l) {
    var rgb = hslToRgb(h, s / 100, l / 100);
    return HUSL.Husl.rgbToHex(rgb);
};

var randomHue = function randomHue() {
    return Math.floor(Math.random() * 360);
};

$('#demo1').click(function () {
    return $(this).closest('div').find('.demo').each(function () {
        return $(this).css('background-color', HUSL.Husl.huslToHex([randomHue(), 90, 60]));
    });
});

$('#demo2').click(function () {
    return $(this).closest('div').find('.demo').each(function () {
        return $(this).css('background-color', hslToHex(randomHue(), 90, 60));
    });
});

$('#demo1').click();
$('#demo2').click();

$('#rainbow-husl div').each(function (index) {
    return $(this).css('background-color', HUSL.Husl.huslToHex([index * 36, 90, 60]));
});
$('#rainbow-hsl div').each(function (index) {
    return $(this).css('background-color', hslToHex(index * 36, 90, 60));
});

var size = 400;
var squareSize = 8;

var height = size;
var width = size;

var $picker = $('#picker');

var $canvas = $picker.find('canvas');

var ctx = $canvas[0].getContext('2d');
var contrasting;

var H = 0;
var S = 100;
var L;
var U;
var V;
var scale = 1;
var shapePixel;
var shapePointsPixel;
var pickerGeometry;

function pointToVector(point) {
    return [point.x, point.y];
}

function toPixelCoordinate(point) {
    return {
        x: point.x * scale + 200,
        y: 200 - point.y * scale
    }
}

function fromPixelCoordinate(point) {
    return {
        x: (point.x - 200) / scale,
        y: (200 - point.y) / scale
    }
}


function setL(value) {
    L = value;
    contrasting = L > 70 ? '#1b1b1b' : '#ffffff';
    pickerGeometry = HUSL.ColorPicker.getPickerGeometry(L);
    scale = 190 / pickerGeometry.outerCircleRadius;

    shapePointsPixel = _(pickerGeometry.vertices).map(toPixelCoordinate);
    shapePixel = d3.geom.polygon(_(shapePointsPixel).map(pointToVector));

    elCenter.attr("fill", contrasting);
    if (L !== 0 && L !== 100) {
        elPastelBoundary.attr("r", scale * pickerGeometry.innerCircleRadius).attr("stroke", contrasting);
    } else {
        elPastelBoundary.attr("r", 0).attr("stroke", contrasting);
    }
}


var elSvg = d3.select("#picker svg");
var centerPoint = toPixelCoordinate({x: 0, y: 0});

var elPastelBoundary = elSvg.append("circle")
    .attr("cx", centerPoint.x)
    .attr("cy", centerPoint.y)
    .attr("stroke-width", 2)
    .attr("fill", "none");

var elCenter = elSvg.append("circle")
    .attr("cx", centerPoint.x)
    .attr("cy", centerPoint.y)
    .attr("r", 2);

elSvg.append("circle")
    .attr("class", "picker-container")
    .attr("cx", centerPoint.x)
    .attr("cy", centerPoint.y)
    .attr("r", 190)
    .attr("fill", "#ffffff")
    .attr("fill-opacity", "0.0")
    .attr("stroke", "#ffffff")
    .attr("stroke-width", 2);

var elPickerScope = elSvg.append("circle")
    .attr("class", "scope")
    .attr("cx", centerPoint.x)
    .attr("cy", centerPoint.y)
    .attr("r", 4)
    .attr("style", "display:none")
    .attr("fill", "none")
    .attr("stroke-width", 2);

var controlHue = d3.select("#picker div.control-hue");
var controlSaturation = d3.select("#picker div.control-saturation");
var controlLightness = d3.select("#picker div.control-lightness");
var counterHue = d3.select('#picker .counter-hue');
var counterSaturation = d3.select('#picker .counter-saturation');
var counterLightness = d3.select('#picker .counter-lightness');
var inputHex = d3.select("#picker .hex");
var pickerSwatch = d3.select('table.sliders .swatch');


elSvg.call(d3.behavior.drag().on("drag", function () {
    return adjustPosition({x: d3.event.x, y: d3.event.y});
}));

elSvg.on('mousedown', function () {
    var point = d3.mouse(this);
    return adjustPosition({x: point[0], y: point[1]});
});

function redrawCanvas() {
    var point;
    ctx.clearRect(0, 0, width, height);
    ctx.globalCompositeOperation = 'source-over';

    if (L === 0 || L === 100) {
        return;
    }

    var xs = [];
    var ys = [];
    for (var i = 0; i < shapePointsPixel.length; i++) {
        point = shapePointsPixel[i];
        xs.push(point.x);
        ys.push(point.y);
    }

    var xmin = Math.floor(Math.min.apply(Math, xs) / squareSize);
    var ymin = Math.floor(Math.min.apply(Math, ys) / squareSize);
    var xmax = Math.ceil(Math.max.apply(Math, xs) / squareSize);
    var ymax = Math.ceil(Math.max.apply(Math, ys) / squareSize);

    for (var x = xmin; x < xmax; x++) {
        for (var y = ymin; y < ymax; y++) {
            var p = {
                x: x * squareSize,
                y: y * squareSize
            };

            var polygonPixel = d3.geom.polygon([
                [p.x + squareSize, p.y],
                [p.x + squareSize, p.y + squareSize],
                [p.x, p.y + squareSize],
                [p.x, p.y]
            ]);

            shapePixel.clip(polygonPixel);

            if (polygonPixel.length > 0) {
                var centroid = polygonPixel.centroid();
                var po = fromPixelCoordinate({
                    x: centroid[0],
                    y: centroid[1]
                });

                ctx.fillStyle = HUSL.Husl.rgbToHex(HUSL.Husl.xyzToRgb(HUSL.Husl.luvToXyz([L, po.x, po.y])));
                ctx.fillRect(p.x, p.y, squareSize, squareSize);
            }
        }
    }
    ctx.globalCompositeOperation = 'destination-in';
    ctx.beginPath();
    ctx.moveTo(shapePointsPixel[0].x, shapePointsPixel[0].y);
    for (var j = 1; j < shapePointsPixel.length; j++) {
        point = shapePointsPixel[j];
        ctx.lineTo(point.x, point.y);
    }
    ctx.closePath();
    ctx.fill();
}

function redrawForeground() {
    if (L !== 0 && L !== 100) {

        var maxChroma = HUSL.Husl.maxChromaForLH(L, H);
        var chroma = maxChroma * S / 100;
        var hrad = H / 360 * 2 * Math.PI;
        var point = toPixelCoordinate({
            x: chroma * Math.cos(hrad),
            y: chroma * Math.sin(hrad)
        });

        elPickerScope
            .attr("cx", point.x)
            .attr("cy", point.y)
            .attr("stroke", contrasting)
            .attr("style", "display:inline");

    } else {

        elPickerScope.attr("style", "display:none");
    }

    var colors = d3.range(0, 360, 10).map(function (x) {
        return HUSL.Husl.huslToHex([x, S, L]);
    });
    controlHue.style({
        'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    });
    colors = d3.range(0, 100, 10).map(function (x) {
        return HUSL.Husl.huslToHex([H, x, L]);
    });
    controlSaturation.style({
        'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    });
    colors = d3.range(0, 100, 10).map(function (x) {
        return HUSL.Husl.huslToHex([H, S, x]);
    });
    controlLightness.style({
        'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    });
}


function redrawSliderHuePosition() {
    sliderHue.value(H);
    sliderHue.redraw();
}

function redrawSliderSaturationPosition() {
    sliderSaturation.value(S);
    sliderSaturation.redraw();
}

function redrawSliderLightnessPosition() {
    sliderLightness.value(L);
    sliderLightness.redraw();
}

function updateSliderHueCounter() {
    counterHue.property('value', H.toFixed(1));
}

function updateSliderSaturationCounter() {
    counterSaturation.property('value', S.toFixed(1));
}

function updateSliderLightnessCounter() {
    counterLightness.property('value', L.toFixed(1));
}

function redrawSwatch() {
    var hex = HUSL.Husl.huslToHex([H, S, L]);
    pickerSwatch.style({
        'background-color': hex
    });
}

function updateHexText() {
    var hex = HUSL.Husl.huslToHex([H, S, L]);
    inputHex.property('value', hex);
}

function doArraysContainAnyEqualElement(arr1, arr2) {
    return arr1.some(function (element) {
        return arr2.indexOf(element) !== -1;
    });
}

function redrawAfterUpdatingVariables(changedVariables, triggeredBy) {
    // out of the redraw functions…
    var necessaryRedrawers = [
        {
            func: redrawCanvas,
            executeIfAnyOfTheseVariablesChange: ["L"],
            ignoreIfTriggeredByAnyOf: []
        },
        {
            func: redrawForeground,
            executeIfAnyOfTheseVariablesChange: ["H", "S", "L"],
            ignoreIfTriggeredByAnyOf: []
        },
        {
            func: redrawSliderHuePosition,
            executeIfAnyOfTheseVariablesChange: ["H"],
            ignoreIfTriggeredByAnyOf: ["sliderHue"]
        },
        {
            func: redrawSliderSaturationPosition,
            executeIfAnyOfTheseVariablesChange: ["S"],
            ignoreIfTriggeredByAnyOf: ["sliderSaturation"]
        },
        {
            func: redrawSliderLightnessPosition,
            executeIfAnyOfTheseVariablesChange: ["L"],
            ignoreIfTriggeredByAnyOf: ["sliderLightness"]
        },
        {
            func: updateSliderHueCounter,
            executeIfAnyOfTheseVariablesChange: ["H"],
            ignoreIfTriggeredByAnyOf: ["sliderHueCounterText"]
        },
        {
            func: updateSliderSaturationCounter,
            executeIfAnyOfTheseVariablesChange: ["S"],
            ignoreIfTriggeredByAnyOf: ["sliderSaturationCounterText"]
        },
        {
            func: updateSliderLightnessCounter,
            executeIfAnyOfTheseVariablesChange: ["L"],
            ignoreIfTriggeredByAnyOf: ["sliderLightnessCounterText"]
        },
        {
            func: redrawSwatch,
            executeIfAnyOfTheseVariablesChange: ["H", "S", "L"],
            ignoreIfTriggeredByAnyOf: []
        },
        {
            func: updateHexText,
            executeIfAnyOfTheseVariablesChange: ["H", "S", "L"],
            ignoreIfTriggeredByAnyOf: ["hexText"]
        }
    ];

    // find the ones that rely on any of the changed variables
    necessaryRedrawers = necessaryRedrawers.filter(function (redrawerData) {
        var reliedOnVariables = redrawerData["executeIfAnyOfTheseVariablesChange"];
        return doArraysContainAnyEqualElement(changedVariables, reliedOnVariables);
    });

    // filter out redrawers that shouldn’t be run after this trigger
    necessaryRedrawers = necessaryRedrawers.filter(function (redrawerData) {
        return redrawerData["ignoreIfTriggeredByAnyOf"].indexOf(triggeredBy) === -1;
    });

    // run all remaining redrawers in their proper order
    necessaryRedrawers.map(function (redrawerData) {
        return redrawerData["func"]();
    });
}

function adjustPosition(p) {
    var pointer = fromPixelCoordinate(p);
    pointer = HUSL.ColorPicker.closestPoint(pickerGeometry, pointer);

    U = pointer.x;
    V = pointer.y;

    var lch = HUSL.Husl.luvToLch([L, U, V]);
    var husl = HUSL.Husl.lchToHusl(lch);

    H = husl[0];
    S = husl[1];
    redrawAfterUpdatingVariables(["H", "S"], "adjustPosition");
}

var sliderHue = d3.slider().min(0).max(360).on('slide', function (e, value) {
    H = value;
    redrawAfterUpdatingVariables(["H"], "sliderHue");
});

var sliderSaturation = d3.slider().min(0).max(100).on('slide', function (e, value) {
    S = value;
    redrawAfterUpdatingVariables(["S"], "sliderSaturation");
});

var sliderLightness = d3.slider().min(0).max(100).on('slide', function (e, value) {
    setL(value);
    redrawAfterUpdatingVariables(["L"], "sliderLightness");
});

function stringIsValidHex(string) {
    return string.match(/#?[0-9a-f]{6}/i);
}


function stringIsNumberWithinRange(string, min, max) {
    var middle = parseFloat(string);
    return $.isNumeric(string) && min <= middle && middle <= max;
}


inputHex.on('input', function () {
    if (stringIsValidHex(this.value)) {
        var husl = HUSL.Husl.hexToHusl(this.value);
        H = husl[0];
        S = husl[1];
        L = husl[2];
        return redrawAfterUpdatingVariables(["H", "S", "L"], "hexText");
    }
});

counterHue.on('input', function () {
    if (stringIsNumberWithinRange(this.value, 0, 360)) {
        H = parseFloat(this.value);
        return redrawAfterUpdatingVariables(["H"], "sliderHueCounterText");
    }
});

counterSaturation.on('input', function () {
    if (stringIsNumberWithinRange(this.value, 0, 100)) {
        S = parseFloat(this.value);
        return redrawAfterUpdatingVariables(["S"], "sliderSaturationCounterText");
    }
});

counterLightness.on('input', function () {
    if (stringIsNumberWithinRange(this.value, 0, 100)) {
        L = parseFloat(this.value);
        return redrawAfterUpdatingVariables(["L"], "sliderLightnessCounterText");
    }
});

setL(50);
redrawAfterUpdatingVariables(["H", "S", "L"], "pageLoad");
controlHue.call(sliderHue);
controlSaturation.call(sliderSaturation);
controlLightness.call(sliderLightness);
