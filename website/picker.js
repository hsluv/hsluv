import {Hsluv} from "hsluv";

const conv = new Hsluv();

const symSliderHue = 0;
const symSliderSaturation = 1;
const symSliderLightness = 2;
const symSliderHueCounterText = 3;
const symSliderSaturationCounterText = 4;
const symSliderLightnessCounterText = 5;
const symHexText = 6;

const size = 400;
const squareSize = 8;
const outerCircleRadiusPixel = 190;
const height = size;
const width = size;


function intersectLineLine(a, b) {
    let x = (a.intercept - b.intercept) / (b.slope - a.slope);
    let y = a.slope * x + a.intercept;
    return {x: x, y: y};
}

function distanceFromOrigin(point) {
    return Math.sqrt(Math.pow(point.x, 2) + Math.pow(point.y, 2));
}

function distanceLineFromOrigin(line) {
    return Math.abs(line.intercept) / Math.sqrt(Math.pow(line.slope, 2) + 1);
}

function perpendicularThroughPoint(line, point) {
    let slope = -1 / line.slope;
    let intercept = point.y - slope * point.x;
    return {slope: slope, intercept: intercept};
}

function angleFromOrigin(point) {
    return Math.atan2(point.y, point.x);
}

function normalizeAngle(angle) {
    let m = 2 * Math.PI;
    return (angle % m + m) % m;
}

function lengthOfRayUntilIntersect(theta, line) {
    return line.intercept / (Math.sin(theta) - line.slope * Math.cos(theta));
}

function getPickerGeometry(lightness) {
    conv.calculateBoundingLines(lightness);
    let lines = [
        {slope: conv.r0s, intercept: conv.r0i},
        {slope: conv.r1s, intercept: conv.r1i},
        {slope: conv.g0s, intercept: conv.g0i},
        {slope: conv.g1s, intercept: conv.g1i},
        {slope: conv.b0s, intercept: conv.b0i},
        {slope: conv.b1s, intercept: conv.b1i}
    ];
    let numLines = lines.length;
    let outerCircleRadius = 0.0;
    let closestIndex = null;
    let closestLineDistance = null;
    let _g = 0;
    while (_g < numLines) {
        let i = _g++;
        let d = distanceLineFromOrigin(lines[i]);
        if (closestLineDistance == null || d < closestLineDistance) {
            closestLineDistance = d;
            closestIndex = i;
        }
    }
    let closestLine = lines[closestIndex];
    let perpendicularLine = {slope: 0 - 1 / closestLine.slope, intercept: 0.0};
    let intersectionPoint = intersectLineLine(closestLine, perpendicularLine);
    let startingAngle = angleFromOrigin(intersectionPoint);
    let intersections = [];
    let intersectionPoint1;
    let intersectionPointAngle;
    let relativeAngle;
    let _g2 = 0;
    let _g3 = numLines - 1;
    while (_g2 < _g3) {
        let i1 = _g2++;
        let _g = i1 + 1;
        while (_g < numLines) {
            let i2 = _g++;
            intersectionPoint1 = intersectLineLine(lines[i1], lines[i2]);
            intersectionPointAngle = angleFromOrigin(intersectionPoint1);
            relativeAngle = intersectionPointAngle - startingAngle;
            intersections.push({
                line1: i1,
                line2: i2,
                intersectionPoint: intersectionPoint1,
                intersectionPointAngle: intersectionPointAngle,
                relativeAngle: normalizeAngle(intersectionPointAngle - startingAngle)
            });
        }
    }
    intersections.sort(function (a, b) {
        if (a.relativeAngle > b.relativeAngle) {
            return 1;
        } else {
            return -1;
        }
    });
    let orderedLines = [];
    let orderedVertices = [];
    let orderedAngles = [];
    let nextIndex;
    let currentIntersection;
    let intersectionPointDistance;
    let currentIndex = closestIndex;
    let _g4 = 0;
    let _g5 = intersections.length;
    while (_g4 < _g5) {
        let j = _g4++;
        currentIntersection = intersections[j];
        nextIndex = null;
        if (currentIntersection.line1 === currentIndex) {
            nextIndex = currentIntersection.line2;
        } else if (currentIntersection.line2 === currentIndex) {
            nextIndex = currentIntersection.line1;
        }
        if (nextIndex != null) {
            currentIndex = nextIndex;
            orderedLines.push(lines[nextIndex]);
            orderedVertices.push(currentIntersection.intersectionPoint);
            orderedAngles.push(currentIntersection.intersectionPointAngle);
            intersectionPointDistance = distanceFromOrigin(currentIntersection.intersectionPoint);
            if (intersectionPointDistance > outerCircleRadius) {
                outerCircleRadius = intersectionPointDistance;
            }
        }
    }
    return {
        lines: orderedLines,
        vertices: orderedVertices,
        angles: orderedAngles,
        outerCircleRadius: outerCircleRadius,
        innerCircleRadius: closestLineDistance
    };
}

function closestPoint(geometry, point) {
    let angle = angleFromOrigin(point);
    let numVertices = geometry.vertices.length;
    let relativeAngle;
    let smallestRelativeAngle = Math.PI * 2;
    let index1 = 0;
    let _g = 0;
    while (_g < numVertices) {
        let i = _g++;
        relativeAngle = normalizeAngle(geometry.angles[i] - angle);
        if (relativeAngle < smallestRelativeAngle) {
            smallestRelativeAngle = relativeAngle;
            index1 = i;
        }
    }
    let index2 = (index1 - 1 + numVertices) % numVertices;
    let closestLine = geometry.lines[index2];
    if (distanceFromOrigin(point) < lengthOfRayUntilIntersect(angle, closestLine)) {
        return point;
    }
    let perpendicularLine = perpendicularThroughPoint(closestLine, point);
    let intersectionPoint = intersectLineLine(closestLine, perpendicularLine);
    let bound1 = geometry.vertices[index1];
    let bound2 = geometry.vertices[index2];
    let upperBound;
    let lowerBound;
    if (bound1.x > bound2.x) {
        upperBound = bound1;
        lowerBound = bound2;
    } else {
        upperBound = bound2;
        lowerBound = bound1;
    }
    let borderPoint;
    if (intersectionPoint.x > upperBound.x) {
        borderPoint = upperBound;
    } else if (intersectionPoint.x < lowerBound.x) {
        borderPoint = lowerBound;
    } else {
        borderPoint = intersectionPoint;
    }
    return borderPoint;
}


function stringIsNumberWithinRange(string, min, max) {
    const middle = parseFloat(string);
    // May be NaN
    return min <= middle && middle <= max;
}

function equidistantSamples(numSamples) {
    // 6 -> [0, 0.2, 0.4, 0.6, 0.8, 1]
    const samples = [];
    for (let i = 0; i < numSamples; i++) {
        samples.push(i / (numSamples - 1));
    }
    return samples;
}

function addDragEventListener(element, options) {
    // Generic drag event listener, onDrag returns mouse position
    // relative to element, x and y normalized to [0, 1] range.
    const onDrag = options.onDrag;
    const dragZone = options.dragZone || function () {
        return true;
    };
    let dragging = false;

    function getCoordinates(event) {
        const rect = element.getBoundingClientRect();
        let clientX, clientY;
        if (event.touches) {
            clientX = event.touches[0].clientX;
            clientY = event.touches[0].clientY;
        } else {
            clientX = event.clientX;
            clientY = event.clientY;
        }

        const width = rect.width;
        const height = rect.height;
        const x = (clientX - rect.left) / width;
        const y = (clientY - rect.top) / height;
        return {
            x: Math.min(1, Math.max(0, x)),
            y: Math.min(1, Math.max(0, y))
        };
    }

    function startEvent(event) {
        // Ignore right click
        if (event.which !== 3) {
            const coordinates = getCoordinates(event);
            if (dragZone(coordinates)) {
                dragging = true;
                event.preventDefault();
                onDrag(coordinates);
            }
        }
    }

    function endEvent() {
        dragging = false;
    }

    function moveEvent(event) {
        if (dragging) {
            event.preventDefault();
            onDrag(getCoordinates(event));
        }
    }

    element.addEventListener('mousedown', startEvent);
    element.addEventListener('touchstart', startEvent);
    document.addEventListener('mousemove', moveEvent);
    document.addEventListener('touchmove', moveEvent);
    document.addEventListener('mouseup', endEvent);
    document.addEventListener('touchend', endEvent);
}

class Slider {
    constructor(element, initVal, onChange) {
        const self = this;
        this.element = element;
        this.val = initVal;
        this.handle = document.createElement('div');
        this.handle.className = 'range-slider-handle';
        this.rangeWidth = this.element.getBoundingClientRect().width;
        element.appendChild(this.handle);

        function sliderDragListener(point) {
            self.setVal(point.x);
            onChange(point.x);
        }

        addDragEventListener(this.element, {onDrag: sliderDragListener});
    }

    setVal(newVal) {
        this.val = newVal;
        this.handle.style.left = (this.val * this.rangeWidth - 5) + 'px';
    }

    setBackground(hexColors) {
        this.element.style.background = 'linear-gradient(to right,' + hexColors.join(',') + ')';
    }
}

document.addEventListener('DOMContentLoaded', function () {
    let H = 0;
    let S = 100;
    let L = 50;
    let scale = 1;
    let pickerGeometry;
    let contrasting;

    const picker = document.getElementById('picker');
    const ctx = picker.getElementsByTagName('canvas')[0].getContext('2d');
    const elControlL = document.getElementById('control-l');
    const elControlS = document.getElementById('control-s');
    const elControlH = document.getElementById('control-h');
    const elSliderL = elControlL.getElementsByClassName('range-slider')[0];
    const elSliderS = elControlS.getElementsByClassName('range-slider')[0];
    const elSliderH = elControlH.getElementsByClassName('range-slider')[0];
    const elInputHex = picker.getElementsByClassName('input-hex')[0];
    const elCounterHue = picker.getElementsByClassName('counter-hue')[0];
    const elCounterSaturation = picker.getElementsByClassName('counter-saturation')[0];
    const elCounterLightness = picker.getElementsByClassName('counter-lightness')[0];
    const elSwatch = picker.getElementsByClassName('swatch')[0];
    const elSvg = picker.getElementsByTagName('svg')[0];

    const sliderL = new Slider(elSliderL, 0.5, function (newVal) {
        L = newVal * 100;
        redrawAfterUpdatingVariables(false, false, true, symSliderLightness);
    });

    const sliderS = new Slider(elSliderS, 0.5, function (newVal) {
        S = newVal * 100;
        redrawAfterUpdatingVariables(false, true, false, symSliderSaturation);
    });

    const sliderH = new Slider(elSliderH, 0, function (newVal) {
        H = newVal * 360;
        redrawAfterUpdatingVariables(true, false, true, symSliderHue);
    });

    elCounterHue.addEventListener('input', function () {
        if (stringIsNumberWithinRange(this.value, 0, 360)) {
            H = parseFloat(this.value);
            redrawAfterUpdatingVariables(true, false, false, symSliderHueCounterText);
        }
    });

    elCounterSaturation.addEventListener('input', function () {
        if (stringIsNumberWithinRange(this.value, 0, 100)) {
            S = parseFloat(this.value);
            redrawAfterUpdatingVariables(false, true, false, symSliderSaturationCounterText);
        }
    });

    elCounterLightness.addEventListener('input', function () {
        if (stringIsNumberWithinRange(this.value, 0, 100)) {
            L = parseFloat(this.value);
            redrawAfterUpdatingVariables(false, false, true, symSliderLightnessCounterText);
        }
    });

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

    const centerPoint = toPixelCoordinate({x: 0, y: 0});

    const pastelBoundary = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    pastelBoundary.setAttribute('cx', centerPoint.x.toString());
    pastelBoundary.setAttribute('cy', centerPoint.y.toString());
    pastelBoundary.setAttribute('fill', 'none');
    pastelBoundary.setAttribute('stroke-width', '2');
    elSvg.appendChild(pastelBoundary);

    const elementCenter = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    elementCenter.setAttribute('cx', centerPoint.x.toString());
    elementCenter.setAttribute('cy', centerPoint.y.toString());
    elementCenter.setAttribute('r', (2).toString());
    elSvg.appendChild(elementCenter);

    const outerCircle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    outerCircle.setAttribute('cx', centerPoint.x.toString());
    outerCircle.setAttribute('cy', centerPoint.y.toString());
    outerCircle.setAttribute('r', outerCircleRadiusPixel.toString());
    outerCircle.setAttribute('fill', 'none');
    outerCircle.setAttribute('stroke', 'white');
    outerCircle.setAttribute('stroke-width', '1');
    elSvg.appendChild(outerCircle);

    const pickerScope = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    pickerScope.setAttribute('cx', centerPoint.x.toString());
    pickerScope.setAttribute('cy', centerPoint.y.toString());
    pickerScope.setAttribute('r', '4');
    pickerScope.setAttribute('fill', 'none');
    pickerScope.setAttribute('stroke-width', '2');
    pickerScope.style.display = 'none';
    pickerScope.className = 'scope';
    elSvg.appendChild(pickerScope);

    function pickerDragListener(point) {
        let pointer = fromPixelCoordinate({
            x: point.x * size,
            y: point.y * size
        });
        pointer = closestPoint(pickerGeometry, pointer);

        const u = pointer.x;
        const v = pointer.y;
        conv.luv_l = L;
        conv.luv_u = u;
        conv.luv_v = v;
        conv.luvToLch();
        conv.lchToHsluv();
        H = conv.hsluv_h;
        S = conv.hsluv_s;
        redrawAfterUpdatingVariables(true, true, false, null);
    }

    function pickerDragZone(point) {
        // Don't allow dragging to start when clicked outside outer circle
        const maximumDistance = pickerGeometry.outerCircleRadius;
        const actualDistance = distanceFromOrigin(fromPixelCoordinate({
            x: point.x * size,
            y: point.y * size
        }));
        return actualDistance < maximumDistance;
    }

    addDragEventListener(elSvg, {onDrag: pickerDragListener, dragZone: pickerDragZone});

    function redrawCanvas() {
        const shapePointsPixel = pickerGeometry.vertices.map(toPixelCoordinate);

        ctx.clearRect(0, 0, width, height);
        ctx.globalCompositeOperation = 'source-over';

        if (L === 0 || L === 100) {
            return;
        }

        const xs = [];
        const ys = [];

        let point;
        for (let i = 0; i < shapePointsPixel.length; i++) {
            point = shapePointsPixel[i];
            xs.push(point.x);
            ys.push(point.y);
        }

        const xmin = Math.floor(Math.min.apply(Math, xs) / squareSize);
        const ymin = Math.floor(Math.min.apply(Math, ys) / squareSize);
        const xmax = Math.ceil(Math.max.apply(Math, xs) / squareSize);
        const ymax = Math.ceil(Math.max.apply(Math, ys) / squareSize);

        for (let x = xmin; x < xmax; x++) {
            for (let y = ymin; y < ymax; y++) {
                let px = x * squareSize;
                let py = y * squareSize;
                let p = fromPixelCoordinate({
                    x: px + squareSize / 2,
                    y: py + squareSize / 2
                });
                let closest = closestPoint(pickerGeometry, p);
                conv.luv_l = L;
                conv.luv_u = closest.x;
                conv.luv_v = closest.y;
                conv.luvToXyz();
                conv.xyzToRgb();
                conv.rgbToHex();
                ctx.fillStyle = conv.hex;
                ctx.fillRect(px, py, squareSize, squareSize);
            }
        }
        ctx.globalCompositeOperation = 'destination-in';
        ctx.beginPath();
        ctx.moveTo(shapePointsPixel[0].x, shapePointsPixel[0].y);
        for (let j = 1; j < shapePointsPixel.length; j++) {
            point = shapePointsPixel[j];
            ctx.lineTo(point.x, point.y);
        }
        ctx.closePath();
        ctx.fill();
    }

    function redrawForeground() {
        elementCenter.setAttribute('fill', contrasting);
        pastelBoundary.setAttribute('stroke', contrasting);

        if (L !== 0 && L !== 100) {
            conv.calculateBoundingLines(L);
            let maxChroma = conv.calcMaxChromaHsluv(H);
            let chroma = maxChroma * S / 100;
            let hrad = H / 360 * 2 * Math.PI;
            let point = toPixelCoordinate({
                x: chroma * Math.cos(hrad),
                y: chroma * Math.sin(hrad)
            });

            pickerScope.setAttribute('cx', point.x.toString());
            pickerScope.setAttribute('cy', point.y.toString());
            pickerScope.setAttribute('stroke', contrasting);

            pickerScope.style.display = 'inline';
            pastelBoundary.setAttribute('r', (scale * pickerGeometry.innerCircleRadius).toString());

        } else {
            pickerScope.style.display = 'none';
            pastelBoundary.setAttribute('r', '0');
        }

        const hueColors = equidistantSamples(20).map(function (s) {
            conv.hsluv_h = s * 360;
            conv.hsluv_s = S;
            conv.hsluv_l = L;
            conv.hsluvToHex();
            return conv.hex;
        });
        const saturationColors = equidistantSamples(10).map(function (s) {
            conv.hsluv_h = H;
            conv.hsluv_s = s * 100;
            conv.hsluv_l = L;
            conv.hsluvToHex();
            return conv.hex;
        });
        const lightnessColors = equidistantSamples(10).map(function (s) {
            conv.hsluv_h = H;
            conv.hsluv_s = S;
            conv.hsluv_l = s * 100;
            conv.hsluvToHex();
            return conv.hex;
        });

        sliderH.setBackground(hueColors);
        sliderS.setBackground(saturationColors);
        sliderL.setBackground(lightnessColors);
    }

    function redrawAfterUpdatingVariables(changeH, changeS, changeL, triggeredBySym) {
        if (changeL) {
            contrasting = L > 70 ? '#1b1b1b' : '#ffffff';
            pickerGeometry = getPickerGeometry(L);
            scale = outerCircleRadiusPixel / pickerGeometry.outerCircleRadius;
        }
        redrawForeground();
        conv.hsluv_h = H;
        conv.hsluv_s = S;
        conv.hsluv_l = L;
        conv.hsluvToHex();
        const hex = conv.hex;
        elSwatch.style.backgroundColor = hex;
        if (triggeredBySym !== symHexText)
            elInputHex.value = hex;
        if (changeL)
            redrawCanvas();
        if (changeH && triggeredBySym !== symSliderHue)
            sliderH.setVal(H / 360);
        if (changeS && triggeredBySym !== symSliderSaturation)
            sliderS.setVal(S / 100);
        if (changeL && triggeredBySym !== symSliderLightness)
            sliderL.setVal(L / 100);
        if (changeH && triggeredBySym !== symSliderHueCounterText)
            elCounterHue.value = H.toFixed(1);
        if (changeS && triggeredBySym !== symSliderSaturationCounterText)
            elCounterSaturation.value = S.toFixed(1);
        if (changeL && triggeredBySym !== symSliderLightnessCounterText)
            elCounterLightness.value = L.toFixed(1);
    }

    elInputHex.addEventListener('input', function () {
        const match = elInputHex.value.match(/^\s*#?([\da-f]{6})\s*$/i);
        if (match) {
            const matchedHexDigits = match[1];
            conv.hex = '#' + matchedHexDigits;
            conv.hexToHsluv();
            H = conv.hsluv_h;
            S = conv.hsluv_s;
            L = conv.hsluv_l;
            redrawAfterUpdatingVariables(true, true, true, symHexText);
        }
    });

    redrawAfterUpdatingVariables(true, true, true, null);
});
