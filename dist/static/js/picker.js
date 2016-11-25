function stringIsValidHex(string) {
    return string.match(/#?[0-9a-f]{6}/i);
}

function stringIsNumberWithinRange(string, min, max) {
    var middle = parseFloat(string);
    // May be NaN
    return min <= middle && middle <= max;
}

function equidistantSamples(numSamples) {
    // 6 -> [0, 0.2, 0.4, 0.6, 0.8, 1]
    var samples = [];
    for (var i=0; i<numSamples; i++) {
        samples.push(i / (numSamples - 1));
    }
    return samples;
}

function dragListener(element, onDrag) {
    // Generic drag event listener, onDrag returns mouse position
    // relative to element, x and y normalized to [0, 1] range.
    var dragging = false;

    function trigger(event) {
        var rect = element.getBoundingClientRect();
        var clientX, clientY;
        if (event.touches) {
            clientX = event.touches[0].clientX;
            clientY = event.touches[0].clientY;
        } else {
            clientX = event.clientX;
            clientY = event.clientY;
        }

        var width = rect.width;
        var height = rect.height;
        var x = (clientX - rect.left) / width;
        var y = (clientY - rect.top) / height;
        onDrag({
            x: Math.min(1, Math.max(0, x)),
            y: Math.min(1, Math.max(0, y))
        })
    }

    function startEvent(event) {
        // Ignore right click
        if (event.which !== 3) {
            dragging = true;
            trigger(event);
        }
    }

    function endEvent() {
        dragging = false;
    }

    function moveEvent(event) {
        if (dragging) {
            event.preventDefault();
            trigger(event);
        }
    }

    element.addEventListener('mousedown', startEvent);
    element.addEventListener('touchstart', startEvent);
    document.addEventListener('mousemove', moveEvent);
    document.addEventListener('touchmove', moveEvent);
    document.addEventListener('mouseup', endEvent);
    document.addEventListener('touchend', endEvent);
}

function makeSlider(element, initVal, onChange) {
    var handle = document.createElement('div');
    handle.className = 'range-slider-handle';
    element.appendChild(handle);

    var rangeWidth = element.getBoundingClientRect().width;
    var handleWidth = handle.getBoundingClientRect().width;
    var val = initVal;

    function moveHandle() {
        handle.style.left = (val * rangeWidth - handleWidth / 2) + 'px';
    }

    dragListener(element, function (point) {
        val = point.x;
        moveHandle();
        onChange(val);
    });

    return function (newVal) {
        val = newVal;
        moveHandle();
    };
}

document.addEventListener('DOMContentLoaded', function () {

    var size = 400;
    var squareSize = 8;
    var outerCircleRadiusPixel = 190;

    var height = size;
    var width = size;

    var H = 0;
    var S = 100;
    var L;
    var U;
    var V;
    var scale = 1;
    var pickerGeometry;

    var picker = document.getElementById('picker');
    var ctx = picker.getElementsByTagName('canvas')[0].getContext('2d');
    var contrasting;

    var controlL = document.getElementById('control-l');
    var sliderL = controlL.getElementsByClassName('range-slider')[0];
    var setSliderL = makeSlider(sliderL, 0.5, function (newVal) {
        setL(newVal * 100);
        redrawAfterUpdatingVariables(["L"], "sliderLightness");
    });

    var controlS = document.getElementById('control-s');
    var sliderS = controlS.getElementsByClassName('range-slider')[0];
    var setSliderS = makeSlider(sliderS, 0.5, function (newVal) {
        S = newVal * 100;
        redrawAfterUpdatingVariables(["S"], "sliderSaturation");
    });

    var controlH = document.getElementById('control-h');
    var sliderH = controlH.getElementsByClassName('range-slider')[0];
    var setSliderH = makeSlider(sliderH, 0, function (newVal) {
        H = newVal * 360;
        redrawAfterUpdatingVariables(["H"], "sliderHue");
    });

    var inputHex = picker.getElementsByClassName('hex')[0];
    var counterHue = picker.getElementsByClassName('counter-hue')[0];
    var counterSaturation = picker.getElementsByClassName('counter-saturation')[0];
    var counterLightness = picker.getElementsByClassName('counter-lightness')[0];

    var swatch = picker.getElementsByClassName('swatch')[0];

    var svg = picker.getElementsByTagName('svg')[0];

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
        scale = outerCircleRadiusPixel / pickerGeometry.outerCircleRadius;

        elementCenter.setAttribute('fill', contrasting);
        pastelBoundary.setAttribute('stroke', contrasting);
        if (L !== 0 && L !== 100) {
            pastelBoundary.setAttribute('r', (scale * pickerGeometry.innerCircleRadius).toString());
        } else {
            pastelBoundary.setAttribute('r', '0');
        }
    }

    var centerPoint = toPixelCoordinate({x: 0, y: 0});

    var pastelBoundary = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    pastelBoundary.setAttribute('cx', centerPoint.x.toString());
    pastelBoundary.setAttribute('cy', centerPoint.y.toString());
    pastelBoundary.setAttribute('fill', 'none');
    pastelBoundary.setAttribute('stroke-width', '2');
    svg.appendChild(pastelBoundary);

    var elementCenter = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    elementCenter.setAttribute('cx', centerPoint.x.toString());
    elementCenter.setAttribute('cy', centerPoint.y.toString());
    elementCenter.setAttribute('r', (2).toString());
    svg.appendChild(elementCenter);

    var outerCircle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    outerCircle.setAttribute('cx', centerPoint.x.toString());
    outerCircle.setAttribute('cy', centerPoint.y.toString());
    outerCircle.setAttribute('r', (outerCircleRadiusPixel).toString());
    outerCircle.setAttribute('fill', 'none');
    outerCircle.setAttribute('stroke', 'white');
    outerCircle.setAttribute('stroke-width', '1');
    svg.appendChild(outerCircle);

    var pickerScope = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    pickerScope.setAttribute('cx', centerPoint.x.toString());
    pickerScope.setAttribute('cy', centerPoint.y.toString());
    pickerScope.setAttribute('r', '4');
    pickerScope.setAttribute('fill', 'none');
    pickerScope.setAttribute('stroke-width', '2');
    pickerScope.style.display = 'none';
    pickerScope.className = 'scope';
    svg.appendChild(pickerScope);

    dragListener(svg, function (point) {
        var pointer = fromPixelCoordinate({
            x: point.x * size,
            y: point.y * size
        });
        pointer = HUSL.ColorPicker.closestPoint(pickerGeometry, pointer);

        U = pointer.x;
        V = pointer.y;

        var lch = HUSL.Husl.luvToLch([L, U, V]);
        var husl = HUSL.Husl.lchToHusl(lch);

        H = husl[0];
        S = husl[1];
        redrawAfterUpdatingVariables(["H", "S"], "adjustPosition");
    });

    function redrawCanvas() {
        var shapePointsPixel = pickerGeometry.vertices.map(toPixelCoordinate);

        ctx.clearRect(0, 0, width, height);
        ctx.globalCompositeOperation = 'source-over';

        if (L === 0 || L === 100) {
            return;
        }

        var xs = [];
        var ys = [];

        var point;
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
                var px = x * squareSize;
                var py = y * squareSize;
                var p = fromPixelCoordinate({
                    x: px + squareSize / 2,
                    y: py + squareSize / 2
                });
                var closest = HUSL.ColorPicker.closestPoint(pickerGeometry, p);
                var luv = [L, closest.x, closest.y];
                ctx.fillStyle = HUSL.Husl.rgbToHex(HUSL.Husl.xyzToRgb(HUSL.Husl.luvToXyz(luv)));
                ctx.fillRect(px, py, squareSize, squareSize);
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

            pickerScope.setAttribute('cx', point.x.toString());
            pickerScope.setAttribute('cy', point.y.toString());
            pickerScope.setAttribute('stroke', contrasting);
            pickerScope.style.display = 'inline';

        } else {
            pickerScope.style.display = 'none';
        }

        var hueColors = equidistantSamples(20).map(function (s) {
            return HUSL.Husl.huslToHex([s * 360, S, L]);
        });
        var saturationColors = equidistantSamples(10).map(function (s) {
            return HUSL.Husl.huslToHex([H, s * 100, L]);
        });
        var lightnessColors = equidistantSamples(10).map(function (s) {
            return HUSL.Husl.huslToHex([H, S, s * 100]);
        });

        sliderH.style.background = 'linear-gradient(to right,' + hueColors.join(',') + ')';
        sliderS.style.background = 'linear-gradient(to right,' + saturationColors.join(',') + ')';
        sliderL.style.background = 'linear-gradient(to right,' + lightnessColors.join(',') + ')';
    }


    function redrawSliderHuePosition() {
        setSliderH(H / 360);
    }

    function redrawSliderSaturationPosition() {
        setSliderS(S / 100);
    }

    function redrawSliderLightnessPosition() {
        setSliderL(L / 100);
    }

    function updateSliderHueCounter() {
        counterHue.setAttribute('value', H.toFixed(1))
    }

    function updateSliderSaturationCounter() {
        counterSaturation.setAttribute('value', S.toFixed(1));
    }

    function updateSliderLightnessCounter() {
        counterLightness.setAttribute('value', L.toFixed(1));
    }

    function redrawSwatch() {
        swatch.style.backgroundColor = HUSL.Husl.huslToHex([H, S, L]);
    }

    function updateHexText() {
        var hex = HUSL.Husl.huslToHex([H, S, L]);
        inputHex.setAttribute('value', hex);
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
            redrawerData["func"]();
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

    inputHex.addEventListener('input', function () {
        if (stringIsValidHex(this.value)) {
            var husl = HUSL.Husl.hexToHusl(this.value);
            H = husl[0];
            S = husl[1];
            L = husl[2];
            redrawAfterUpdatingVariables(["H", "S", "L"], "hexText");
        }
    });

    counterHue.addEventListener('input', function () {
        if (stringIsNumberWithinRange(this.value, 0, 360)) {
            H = parseFloat(this.value);
            redrawAfterUpdatingVariables(["H"], "sliderHueCounterText");
        }
    });

    counterSaturation.addEventListener('input', function () {
        if (stringIsNumberWithinRange(this.value, 0, 100)) {
            S = parseFloat(this.value);
            redrawAfterUpdatingVariables(["S"], "sliderSaturationCounterText");
        }
    });

    counterLightness.addEventListener('input', function () {
        if (stringIsNumberWithinRange(this.value, 0, 100)) {
            setL(parseFloat(this.value));
            setSliderL(L / 100);
            redrawAfterUpdatingVariables(["L"], "sliderLightnessCounterText");
        }
    });

    setL(50);
    redrawAfterUpdatingVariables(["H", "S", "L"], "pageLoad");

});

