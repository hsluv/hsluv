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

var $canvas = $('#picker canvas');

var ctx = $canvas[0].getContext('2d');
var contrasting = null;

var H = 0;
var S = 100;
var L = 50;
var scale = null;
var sortedIntersections = [];
var bounds = [];
var shape = null;

var normalizeRad = function normalizeRad(hrad) {
    return (hrad + 2 * Math.PI) % (2 * Math.PI);
};

var intersection = function intersection(c1, s1, c2, s2) {
    var x = (c1 - c2) / (s2 - s1);
    var y = c1 + x * s1;
    return [x, y];
};

var intersection3 = function intersection3(line1, line2) {
    return intersection(line1[0], line1[1], line2[0], line2[1]);
};

var intersection2 = function intersection2(line1, point) {
    var line2 = [0, point[1] / point[0]];
    var int = intersection3(line1, line2);
    if (int[0] > 0 && int[0] < point[0]) {
        return int;
    }
    if (int[0] < 0 && int[0] > point[0]) {
        return int;
    }
    return null;
};

var distanceFromPole = function distanceFromPole(point) {
    return Math.sqrt(Math.pow(point[0], 2) + Math.pow(point[1], 2));
};

var getIntersections = function getIntersections(lines) {
    var _$first = _.first(lines);

    var fname = _$first[0];
    var f = _$first[1];

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
};

var dominoSortMatch = function dominoSortMatch(dominos, match) {
    if (dominos.length === 1) {
        return dominos;
    }

    var _$groupBy = _.groupBy(dominos, function (domino) {
        if (__in__(match, domino)) {
            return '_first';
        } else {
            return 'rest';
        }
    });

    var _first = _$groupBy._first;
    var rest = _$groupBy.rest;

    var first = _first[0];

    var next = first[0] !== match ? first[0] : first[1];
    return [first].concat(dominoSortMatch(rest, next));
};

var dominoSort = function dominoSort(dominos) {
    var first = _.first(dominos);
    var rest = _.rest(dominos);
    return [first].concat(dominoSortMatch(rest, first[1]));
};

var sortIntersections = function sortIntersections(intersections) {
    var dominos = dominoSort(_.pluck(intersections, 'names'));
    return _.map(dominos, function (domino) {
        return _.find(intersections, function (i) {
            return i.names[0] === domino[0] && i.names[1] === domino[1];
        });
    });
};

var redrawSquare = function redrawSquare(x, y, dim) {
    var vx = (x - 200) / scale;
    var vy = (y - 200) / scale;
    var polygon = d3.geom.polygon([[vx, vy], [vx, vy + dim], [vx + dim, vy + dim], [vx + dim, vy]]);
    shape.clip(polygon);
    if (polygon.length > 0) {
        var _polygon$centroid = polygon.centroid();

        vx = _polygon$centroid[0];
        vy = _polygon$centroid[1];

        ctx.fillStyle = $.husl._conv.rgb.hex($.husl._conv.xyz.rgb($.husl._conv.luv.xyz([L, vx, vy])));
        return ctx.fillRect(x, y, dim, dim);
    }
};

var redrawCanvas = function redrawCanvas(dim) {
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
    return ctx.fill();
};

var makeBackground = function makeBackground() {

    var background = d3.select("#picker svg").append("g").attr("class", "background");

    var pastelBoundary = background.append("circle").attr("cx", 0).attr("cy", 0).attr("transform", "translate(200, 200)").attr("stroke-width", 2).attr("fill", "none");

    var center = background.append("circle").attr("cx", 0).attr("cy", 0).attr("r", 2).attr("transform", "translate(200, 200)");

    background.redraw = function redrawBackground() {
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

            contrasting = L > 70 ? '#1b1b1b' : '#ffffff';

            pastelBoundary.attr("r", scale * minC).attr("stroke", contrasting);

            return center.attr("fill", contrasting);
        } else {
            pastelBoundary.attr("r", 0).attr("stroke", contrasting);

            return center.attr("fill", contrasting);
        }
    };

    return background;
};

var makeForeground = function makeForeground() {

    var foreground = d3.select("#picker svg").append("g").attr("class", "foreground");

    foreground.append("circle").attr("class", "picker-container").attr("cx", 0).attr("cy", 0).attr("r", 190).attr("transform", "translate(200, 200)").attr("fill", "#ffffff").attr("fill-opacity", "0.0").attr("stroke", "#ffffff").attr("stroke-width", 2);

    var pickerScope = foreground.append("circle").attr("class", "scope").attr("cx", 0).attr("cy", 0).attr("r", 4).attr("style", "display:none").attr("transform", "translate(200, 200)").attr("fill", "none").attr("stroke-width", 2);

    $("#picker svg g.foreground").mousedown(function (e) {
        e.preventDefault();
        var offset = $canvas.offset();
        var x = e.pageX - offset.left - 200;
        var y = e.pageY - offset.top - 200;

        return adjustPosition(x, y);
    });

    var dragmove = function dragmove() {
        var x = d3.event.x - 200;
        var y = d3.event.y - 200;

        return adjustPosition(x, y);
    };

    var drag = d3.behavior.drag().on("drag", dragmove);

    foreground.call(drag);

    foreground.redraw = function redrawForeground() {

        if (L !== 0 && L !== 100) {

            var maxChroma = $.husl._maxChromaForLH(L, H);
            var chroma = maxChroma * S / 100;
            var hrad = H / 360 * 2 * Math.PI;

            window.xxx = chroma * Math.cos(hrad);
            window.yyy = chroma * Math.sin(hrad);

            pickerScope.attr("cx", chroma * Math.cos(hrad) * scale).attr("cy", chroma * Math.sin(hrad) * scale).attr("stroke", contrasting).attr("style", "display:inline");
        } else {

            pickerScope.attr("style", "display:none");
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
        return d3.select("#picker div.control-lightness").style({
            'background': 'linear-gradient(to right,' + colors.join(',') + ')'
        });
    };

    return foreground;
};

var foreground = makeForeground();
var background = makeBackground();

var redrawSliderHuePosition = function redrawSliderHuePosition() {
    sliderHue.value(H);
    return sliderHue.redraw();
};

var redrawSliderSaturationPosition = function redrawSliderSaturationPosition() {
    sliderSaturation.value(S);
    return sliderSaturation.redraw();
};

var redrawSliderLightnessPosition = function redrawSliderLightnessPosition() {
    sliderLightness.value(L);
    return sliderLightness.redraw();
};

var updateSliderHueCounter = function updateSliderHueCounter() {
    return d3.select('#picker .counter-hue').property('value', H.toFixed(1));
};

var updateSliderSaturationCounter = function updateSliderSaturationCounter() {
    return d3.select('#picker .counter-saturation').property('value', S.toFixed(1));
};

var updateSliderLightnessCounter = function updateSliderLightnessCounter() {
    return d3.select('#picker .counter-lightness').property('value', L.toFixed(1));
};

var redrawSwatch = function redrawSwatch() {
    var hex = $.husl.toHex(H, S, L);
    return d3.select('table.sliders .swatch').style({
        'background-color': hex
    });
};

var updateHexText = function updateHexText() {
    var hex = $.husl.toHex(H, S, L);
    return d3.select('#picker .hex').property('value', hex);
};

var redrawFunctionsInSafeOrderWithDependencyData = [{
    func: background.redraw,
    executeIfAnyOfTheseVariablesChange: ["L"],
    ignoreIfTriggeredByAnyOf: []
}, {
    func: redrawCanvas.bind(null, sameColorSquareSize),
    executeIfAnyOfTheseVariablesChange: ["L"],
    ignoreIfTriggeredByAnyOf: []
}, {
    func: foreground.redraw,
    executeIfAnyOfTheseVariablesChange: ["H", "S", "L"],
    ignoreIfTriggeredByAnyOf: []
}, {
    func: redrawSliderHuePosition,
    executeIfAnyOfTheseVariablesChange: ["H"],
    ignoreIfTriggeredByAnyOf: ["sliderHue"]
}, {
    func: redrawSliderSaturationPosition,
    executeIfAnyOfTheseVariablesChange: ["S"],
    ignoreIfTriggeredByAnyOf: ["sliderSaturation"]
}, {
    func: redrawSliderLightnessPosition,
    executeIfAnyOfTheseVariablesChange: ["L"],
    ignoreIfTriggeredByAnyOf: ["sliderLightness"]
}, {
    func: updateSliderHueCounter,
    executeIfAnyOfTheseVariablesChange: ["H"],
    ignoreIfTriggeredByAnyOf: ["sliderHueCounterText"]
}, {
    func: updateSliderSaturationCounter,
    executeIfAnyOfTheseVariablesChange: ["S"],
    ignoreIfTriggeredByAnyOf: ["sliderSaturationCounterText"]
}, {
    func: updateSliderLightnessCounter,
    executeIfAnyOfTheseVariablesChange: ["L"],
    ignoreIfTriggeredByAnyOf: ["sliderLightnessCounterText"]
}, {
    func: redrawSwatch,
    executeIfAnyOfTheseVariablesChange: ["H", "S", "L"],
    ignoreIfTriggeredByAnyOf: []
}, {
    func: updateHexText,
    executeIfAnyOfTheseVariablesChange: ["H", "S", "L"],
    ignoreIfTriggeredByAnyOf: ["hexText"]
}];

var doArraysContainAnyEqualElement = function doArraysContainAnyEqualElement(arr1, arr2) {
    return arr1.some(function (element) {
        return arr2.indexOf(element) !== -1;
    });
};

var redrawAfterUpdatingVariables = function redrawAfterUpdatingVariables(changedVariables, triggeredBy) {
    // out of the redraw functions…
    var necessaryRedrawers = redrawFunctionsInSafeOrderWithDependencyData;

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
    return necessaryRedrawers.map(function (redrawerData) {
        return redrawerData["func"]();
    });
};

var adjustPosition = function adjustPosition(x, y) {
    var pointer = [x / scale, y / scale];

    var hrad = normalizeRad(Math.atan2(pointer[1], pointer[0]));
    H = hrad / 2 / Math.PI * 360;

    var maxChroma = $.husl._maxChromaForLH(L, H);
    var pointerDistance = distanceFromPole(pointer);
    S = Math.min(pointerDistance / maxChroma * 100, 100);

    return redrawAfterUpdatingVariables(["H", "S"], "adjustPosition");
};

var sliderHue = d3.slider().min(0).max(360).on('slide', function (e, value) {
    H = value;
    return redrawAfterUpdatingVariables(["H"], "sliderHue");
});

var sliderSaturation = d3.slider().min(0).max(100).on('slide', function (e, value) {
    S = value;
    return redrawAfterUpdatingVariables(["S"], "sliderSaturation");
});

var sliderLightness = d3.slider().min(0).max(100).on('slide', function (e, value) {
    L = value;
    return redrawAfterUpdatingVariables(["L"], "sliderLightness");
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

var stringIsNumberWithinRange = function stringIsNumberWithinRange(string, min, max) {
    var middle;
    return $.isNumeric(string) && min <= (middle = parseFloat(string)) && middle <= max;
};

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
