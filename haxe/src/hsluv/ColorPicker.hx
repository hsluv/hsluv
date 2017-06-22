package hsluv;
import hsluv.Hsluv;
import hsluv.Geometry;


typedef PickerGeometry = {
    var lines:Array<Line>;
    // Ordered such that 1st vertex is interection between first and
    // second line, 2nd vertex between second and third line etc.
    var vertices:Array<Point>;
    // Angles from origin to corresponding vertex
    var angles:Array<Angle>;
    // Smallest circle with center at origin such that polygon fits inside
    var outerCircleRadius:Float;
    // Largest circle with center at origin such that it fits inside polygon
    var innerCircleRadius:Float;
}

class ColorPicker {

    public static function getPickerGeometry(lightness:Float):PickerGeometry {
        // Array of lines
        var lines = Hsluv.getBounds(lightness);
        var numLines = lines.length;
        var outerCircleRadius = 0.0;

        // Find the line closest to origin
        var closestIndex2 = null;
        var closestLineDistance = null;

        for (i in 0...numLines) {
            var d = Geometry.distanceLineFromOrigin(lines[i]);
            if (closestLineDistance == null || d < closestLineDistance) {
                closestLineDistance = d;
                closestIndex2 = i;
            }
        }

        var closestLine = lines[closestIndex2];
        var perpendicularLine = {slope: 0 - (1 / closestLine.slope), intercept: 0.0};
        var intersectionPoint = Geometry.intersectLineLine(closestLine, perpendicularLine);
        var startingAngle = Geometry.angleFromOrigin(intersectionPoint);

        var intersections = [];
        var intersectionPoint;
        var intersectionPointAngle;
        var relativeAngle;

        for (i1 in 0...numLines - 1) {
            for (i2 in i1 + 1...numLines) {
                intersectionPoint = Geometry.intersectLineLine(lines[i1], lines[i2]);
                intersectionPointAngle = Geometry.angleFromOrigin(intersectionPoint);
                relativeAngle = intersectionPointAngle - startingAngle;
                intersections.push({
                    line1: i1,
                    line2: i2,
                    intersectionPoint: intersectionPoint,
                    intersectionPointAngle: intersectionPointAngle,
                    relativeAngle: Geometry.normalizeAngle(intersectionPointAngle - startingAngle)
                });
            }
        }

        intersections.sort(function(a, b) {
            if (a.relativeAngle > b.relativeAngle) {
                return 1;
            } else {
                return -1;
            }
        });

        var orderedLines = [];
        var orderedVertices = [];
        var orderedAngles = [];

        var nextIndex2;
        var currentIntersection;
        var intersectionPointDistance;

        var currentIndex2 = closestIndex2;
        var d = [];

        for (j in 0...intersections.length) {
            currentIntersection = intersections[j];
            nextIndex2 = null;
            if (currentIntersection.line1 == currentIndex2) {
                nextIndex2 = currentIntersection.line2;
            } else if (currentIntersection.line2 == currentIndex2) {
                nextIndex2 = currentIntersection.line1;
            }
            if (nextIndex2 != null) {
                currentIndex2 = nextIndex2;

                d.push(currentIndex2);
                orderedLines.push(lines[nextIndex2]);
                orderedVertices.push(currentIntersection.intersectionPoint);
                orderedAngles.push(currentIntersection.intersectionPointAngle);

                intersectionPointDistance = Geometry.distanceFromOrigin(currentIntersection.intersectionPoint);
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
        }
    }

    public static function closestPoint(geometry:PickerGeometry, point:Point):Point {
        // In order to find the closest line we use the point's angle
        var angle = Geometry.angleFromOrigin(point);
        var numVertices = geometry.vertices.length;
        var relativeAngle;
        var smallestRelativeAngle = Math.PI * 2;
        var index1 = 0;

        for (i in 0...numVertices) {
            relativeAngle = Geometry.normalizeAngle(geometry.angles[i] - angle);
            if (relativeAngle < smallestRelativeAngle) {
                smallestRelativeAngle = relativeAngle;
                index1 = i;
            }
        }

        var index2 = (index1 - 1 + numVertices) % numVertices;
        var closestLine = geometry.lines[index2];

        // Provided point is within the polygon
        if (Geometry.distanceFromOrigin(point) < Geometry.lengthOfRayUntilIntersect(angle, closestLine)) {
            return point;
        }

        var perpendicularLine = Geometry.perpendicularThroughPoint(closestLine, point);
        var intersectionPoint = Geometry.intersectLineLine(closestLine, perpendicularLine);

        var bound1 = geometry.vertices[index1];
        var bound2 = geometry.vertices[index2];
        var upperBound:Point;
        var lowerBound:Point;

        if (bound1.x > bound2.x) {
            upperBound = bound1;
            lowerBound = bound2;
        } else {
            upperBound = bound2;
            lowerBound = bound1;
        }

        var borderPoint;
        if (intersectionPoint.x > upperBound.x) {
            borderPoint = upperBound;
        } else if (intersectionPoint.x < lowerBound.x) {
            borderPoint = lowerBound;
        } else {
            borderPoint = intersectionPoint;
        }

        return borderPoint;
    }
}
