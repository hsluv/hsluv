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
    return $.husl._conv.rgb.hex(rgb);
};

var randomHue = function randomHue() {
    return Math.floor(Math.random() * 360);
};

$('#demo1').click(function () {
    return $(this).closest('div').find('.demo').each(function () {
        return $(this).css('background-color', $.husl.toHex(randomHue(), 90, 60));
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
    return $(this).css('background-color', $.husl.toHex(index * 36, 90, 60));
});
$('#rainbow-hsl div').each(function (index) {
    return $(this).css('background-color', hslToHex(index * 36, 90, 60));
});

var getBounds = function getBounds(L) {
    var b = $.husl._getBounds(L);
    var rev = function rev(p) {
        return [p[1], p[0]];
    };
    return {
        'R0': rev(b[0]),
        'R1': rev(b[1]),
        'G0': rev(b[2]),
        'G1': rev(b[3]),
        'B0': rev(b[4]),
        'B1': rev(b[5])
    };
};

var size = 400;
var sameColorSquareSize = 8;

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

function setL(value) {
    L = value;
    contrasting = L > 70 ? '#1b1b1b' : '#ffffff';
}

setL(50);

var scale = null;
var sortedIntersections = [];
var bounds = [];
var shape = null;


var elSvg = d3.select("#picker svg");

var elPastelBoundary = elSvg.append("circle")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("transform", "translate(200, 200)")
    .attr("stroke-width", 2)
    .attr("fill", "none");

var elCenter = elSvg.append("circle")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", 2)
    .attr("transform", "translate(200, 200)");

elSvg.append("circle")
    .attr("class", "picker-container")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", 190)
    .attr("transform", "translate(200, 200)")
    .attr("fill", "#ffffff")
    .attr("fill-opacity", "0.0")
    .attr("stroke", "#ffffff")
    .attr("stroke-width", 2);

var elPickerScope = elSvg.append("circle")
    .attr("class", "scope")
    .attr("cx", 0)
    .attr("cy", 0)
    .attr("r", 4)
    .attr("style", "display:none")
    .attr("transform", "translate(200, 200)")
    .attr("fill", "none")
    .attr("stroke-width", 2);

elSvg.call(d3.behavior.drag().on("drag", function () {
    var x = d3.event.x - 200;
    var y = d3.event.y - 200;

    return adjustPosition(x, y);
}));

elSvg.on('mousedown', function () {
    var point = d3.mouse(this);
    var x = point[0] - 200;
    var y = point[1] - 200;

    return adjustPosition(x, y);
});

function intersection(c1, s1, c2, s2) {
    var x = (c1 - c2) / (s2 - s1);
    var y = c1 + x * s1;
    return [x, y];
}

function intersection3(line1, line2) {
    return intersection(line1[0], line1[1], line2[0], line2[1]);
}

function intersection2(line1, point) {
    var line2 = [0, point[1] / point[0]];
    var int = intersection3(line1, line2);
    if (int[0] > 0 && int[0] < point[0]) {
        return int;
    }
    if (int[0] < 0 && int[0] > point[0]) {
        return int;
    }
    return null;
}

function distanceFromPole(point) {
    return Math.sqrt(Math.pow(point[0], 2) + Math.pow(point[1], 2));
}

function getIntersections(lines) {
    var line = lines[0];

    var fname = line[0];
    var f = line[1];

    var rest = _.rest(lines);
    if (rest.length === 0) {
        return [];
    }
    var intersections = _.map(rest, function (r) {
        var rname = r[0];
        r = r[1];

        return {
            point: intersection3(f, r),
            names: [fname, rname]
        };
    });

    return intersections.concat(getIntersections(rest));
}

function dominoSortMatch(dominos, match) {
    if (dominos.length === 1) {
        return dominos;
    }

    var first = null;
    var rest = [];

    _(dominos).map(function(domino) {
        if (__in__(match, domino)) {
            first = domino;
        } else {
            rest.push(domino);
        }
    });

    if (first !== null) {
        var next = first[0] !== match ? first[0] : first[1];
        return [first].concat(dominoSortMatch(rest, next));
    } else {
        throw Error();
    }
}

function dominoSort(dominos) {
    var first = _.first(dominos);
    var rest = _.rest(dominos);
    return [first].concat(dominoSortMatch(rest, first[1]));
}

function sortIntersections(intersections) {
    var dominos = dominoSort(_.pluck(intersections, 'names'));
    return _.map(dominos, function (domino) {
        return _.find(intersections, function (i) {
            return i.names[0] === domino[0] && i.names[1] === domino[1];
        });
    });
}

function redrawSquare(x, y, dim) {
    var vx = (x - 200) / scale;
    var vy = (y - 200) / scale;
    var polygon = d3.geom.polygon([[vx, vy], [vx, vy + dim], [vx + dim, vy + dim], [vx + dim, vy]]);
    shape.clip(polygon);
    if (polygon.length > 0) {
        var centroid = polygon.centroid();
        var u = centroid[0];
        var v = centroid[1];

        ctx.fillStyle = $.husl._conv.rgb.hex($.husl._conv.xyz.rgb($.husl._conv.luv.xyz([L, u, v])));
        return ctx.fillRect(x, y, dim, dim);
    }
}

function redrawCanvas() {
    var dim = sameColorSquareSize;
    var point;
    ctx.clearRect(0, 0, width, height);
    ctx.globalCompositeOperation = 'source-over';

    if (L === 0 || L === 100) {
        return;
    }

    var xn = width / dim;
    var yn = height / dim;

    var xs = [];
    var ys = [];
    for (var i = 0; i < shape.length; i++) {
        point = shape[i];
        xs.push(200 + point[0] * scale);
        ys.push(200 + point[1] * scale);
    }

    var xnMin = Math.floor(Math.min.apply(Math, xs) / dim);
    var ynMin = Math.floor(Math.min.apply(Math, ys) / dim);

    for (var x = xnMin; x < xn; x++) {
        for (var y = ynMin; y < yn; y++) {
            var vx = x * dim;
            var vy = y * dim;
            redrawSquare(vx, vy, dim);
        }
    }
    ctx.globalCompositeOperation = 'destination-in';
    ctx.beginPath();
    ctx.moveTo(200 + shape[0][0] * scale, 200 + shape[0][1] * scale);
    var iterable2 = _.rest(shape);
    for (var i1 = 0; i1 < iterable2.length; i1++) {
        point = iterable2[i1];
        ctx.lineTo(200 + point[0] * scale, 200 + point[1] * scale);
    }
    ctx.closePath();
    ctx.fill();
}

function redrawBackground() {
    if (L !== 0 && L !== 100) {
        var minC = $.husl._maxSafeChromaForL(L);
        var point;

        bounds = getBounds(L);

        var intersections = [];
        var iterable = getIntersections(_.pairs(bounds));
        for (var j = 0; j < iterable.length; j++) {
            var i = iterable[j];
            var good = true;
            var iterable1 = _.pairs(bounds);
            for (var k = 0; k < iterable1.length; k++) {
                var _iterable1$k = iterable1[k];

                var name = _iterable1$k[0];
                var bound = _iterable1$k[1];

                if (__in__(name, i.names)) {
                    continue;
                }
                var int = intersection2(bound, i.point);
                if (int !== null) {
                    good = false;
                }
            }
            if (good) {
                intersections.push(i);
            }
        }

        var cleanBounds = [];
        for (var i1 = 0; i1 < intersections.length; i1++) {
            var _intersections$i = intersections[i1];
            point = _intersections$i.point;
            var names = _intersections$i.names;

            cleanBounds = _.union(cleanBounds, names);
        }

        var longest = 0;
        for (var j1 = 0; j1 < intersections.length; j1++) {
            point = intersections[j1].point;

            var length = distanceFromPole(point);
            if (length > longest) {
                longest = length;
            }
        }

        scale = 190 / longest;

        sortedIntersections = _.pluck(sortIntersections(intersections), 'point');

        shape = d3.geom.polygon(sortedIntersections);
        if (shape.area() < 0) {
            sortedIntersections.reverse();
            shape = d3.geom.polygon(sortedIntersections);
        }

        elPastelBoundary.attr("r", scale * minC).attr("stroke", contrasting);

        return elCenter.attr("fill", contrasting);
    } else {
        elPastelBoundary.attr("r", 0).attr("stroke", contrasting);

        return elCenter.attr("fill", contrasting);
    }
}

function redrawForeground() {

    if (L !== 0 && L !== 100) {

        var maxChroma = $.husl._maxChromaForLH(L, H);
        var chroma = maxChroma * S / 100;
        var hrad = H / 360 * 2 * Math.PI;

        elPickerScope.attr("cx", chroma * Math.cos(hrad) * scale)
            .attr("cy", chroma * Math.sin(hrad) * scale)
            .attr("stroke", contrasting)
            .attr("style", "display:inline");

    } else {

        elPickerScope.attr("style", "display:none");
    }

    var colors = d3.range(0, 360, 10).map(function (_) {
        return $.husl.toHex(_, S, L);
    });
    d3.select("#picker div.control-hue").style({
        'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    });

    colors = d3.range(0, 100, 10).map(function (_) {
        return $.husl.toHex(H, _, L);
    });
    d3.select("#picker div.control-saturation").style({
        'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    });

    colors = d3.range(0, 100, 10).map(function (_) {
        return $.husl.toHex(H, S, _);
    });
    d3.select("#picker div.control-lightness").style({
        'background': 'linear-gradient(to right,' + colors.join(',') + ')'
    });
}


var redrawSliderHuePosition = function redrawSliderHuePosition() {
    sliderHue.value(H);
    sliderHue.redraw();
};

var redrawSliderSaturationPosition = function redrawSliderSaturationPosition() {
    sliderSaturation.value(S);
    sliderSaturation.redraw();
};

var redrawSliderLightnessPosition = function redrawSliderLightnessPosition() {
    sliderLightness.value(L);
    sliderLightness.redraw();
};

var updateSliderHueCounter = function updateSliderHueCounter() {
    d3.select('#picker .counter-hue').property('value', H.toFixed(1));
};

var updateSliderSaturationCounter = function updateSliderSaturationCounter() {
    d3.select('#picker .counter-saturation').property('value', S.toFixed(1));
};

var updateSliderLightnessCounter = function updateSliderLightnessCounter() {
    d3.select('#picker .counter-lightness').property('value', L.toFixed(1));
};

var redrawSwatch = function redrawSwatch() {
    var hex = $.husl.toHex(H, S, L);
    d3.select('table.sliders .swatch').style({
        'background-color': hex
    });
};

var updateHexText = function updateHexText() {
    var hex = $.husl.toHex(H, S, L);
    d3.select('#picker .hex').property('value', hex);
};

function doArraysContainAnyEqualElement(arr1, arr2) {
    return arr1.some(function (element) {
        return arr2.indexOf(element) !== -1;
    });
}

function redrawAfterUpdatingVariables(changedVariables, triggeredBy) {
    // out of the redraw functions…
    var necessaryRedrawers = [
        {
            func: redrawBackground,
            executeIfAnyOfTheseVariablesChange: ["L"],
            ignoreIfTriggeredByAnyOf: []
        },
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

function adjustPosition(x, y) {
    var pointer = [x / scale, y / scale];
    U = pointer[0];
    V = pointer[1];

    var lch = $.husl._conv.luv.lch([L, U, V]);
    var husl = $.husl._conv.lch.husl(lch);
    H = husl[0];

    var maxChroma = $.husl._maxChromaForLH(L, H);
    var pointerDistance = distanceFromPole(pointer);
    S = Math.min(pointerDistance / maxChroma * 100, 100);
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

d3.select("#picker div.control-hue").call(sliderHue);
d3.select("#picker div.control-saturation").call(sliderSaturation);
d3.select("#picker div.control-lightness").call(sliderLightness);

var stringIsValidHex = function stringIsValidHex(string) {
    return string.match(/#?[0-9a-f]{6}/i);
};

d3.select("#picker .hex").on('input', function () {
    if (stringIsValidHex(this.value)) {
        var _$$husl$fromHex = $.husl.fromHex(this.value);

        H = _$$husl$fromHex[0];
        S = _$$husl$fromHex[1];
        L = _$$husl$fromHex[2];

        return redrawAfterUpdatingVariables(["H", "S", "L"], "hexText");
    }
});

function stringIsNumberWithinRange(string, min, max) {
    var middle;
    return $.isNumeric(string) && min <= (middle = parseFloat(string)) && middle <= max;
}

d3.select('#picker .counter-hue').on('input', function () {
    if (stringIsNumberWithinRange(this.value, 0, 360)) {
        H = parseFloat(this.value);
        return redrawAfterUpdatingVariables(["H"], "sliderHueCounterText");
    }
});

d3.select('#picker .counter-saturation').on('input', function () {
    if (stringIsNumberWithinRange(this.value, 0, 100)) {
        S = parseFloat(this.value);
        return redrawAfterUpdatingVariables(["S"], "sliderSaturationCounterText");
    }
});

d3.select('#picker .counter-lightness').on('input', function () {
    if (stringIsNumberWithinRange(this.value, 0, 100)) {
        L = parseFloat(this.value);
        return redrawAfterUpdatingVariables(["L"], "sliderLightnessCounterText");
    }
});

redrawAfterUpdatingVariables(["H", "S", "L"], "pageLoad");

function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0;
}
