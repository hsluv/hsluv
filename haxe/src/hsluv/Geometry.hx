package hsluv;

typedef Point = {
    var x:Float;
    var y:Float;
}

typedef Line = {
    var slope:Float;
    var intercept:Float;
}

// All angles in radians
typedef Angle = Float;


class Geometry {

    public static function intersectLineLine(a:Line, b:Line):Point {
        var x = (a.intercept - b.intercept) / (b.slope - a.slope);
        var y = a.slope * x + a.intercept;
        return {x: x, y: y};
    }

    public static function distanceFromOrigin(point:Point):Float {
        return Math.sqrt(Math.pow(point.x, 2) + Math.pow(point.y, 2));
    }

    public static function distanceLineFromOrigin(line:Line):Float {
        // https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
        return Math.abs(line.intercept) / Math.sqrt(Math.pow(line.slope, 2) + 1);
    }

    public static function perpendicularThroughPoint(line:Line, point:Point):Line {
        var slope = -1 / line.slope;
        var intercept = point.y - slope * point.x;
        return {
            slope: slope,
            intercept: intercept
        }
    }

    public static function angleFromOrigin(point:Point):Angle {
        return Math.atan2(point.y, point.x);
    }

    public static function normalizeAngle(angle:Angle):Angle {
        var m = 2 * Math.PI;
        return ((angle % m) + m) % m;
    }

    public static function lengthOfRayUntilIntersect(theta:Angle, line:Line):Float {
        /*
        theta  -- angle of ray starting at (0, 0)
        m, b   -- slope and intercept of line
        x1, y1 -- coordinates of intersection
        len    -- length of ray until it intersects with line
        
        b + m * x1        = y1
        len              >= 0
        len * cos(theta)  = x1
        len * sin(theta)  = y1
        
        
        b + m * (len * cos(theta)) = len * sin(theta)
        b = len * sin(hrad) - m * len * cos(theta)
        b = len * (sin(hrad) - m * cos(hrad))
        len = b / (sin(hrad) - m * cos(hrad))
        */
        return line.intercept / (Math.sin(theta) - line.slope * Math.cos(theta));
    }

}
