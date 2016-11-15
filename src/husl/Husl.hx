package husl;

private class Length {
    public var greaterEqualZero(default, null):Bool;
    public var length(default, null):Float;


    public function new(length:Float) {
        this.greaterEqualZero = length >= 0;
        this.length = length;
    }
}

class Husl {

    private static var m = 
            [
                    [3.240969941904521, -1.537383177570093, -0.498610760293],
                    [-0.96924363628087, 1.87596750150772, 0.041555057407175],
                    [0.055630079696993, -0.20397695888897, 1.056971514242878],
            ];

    private static var minv =
            [
                    [0.41239079926595, 0.35758433938387, 0.18048078840183],
                    [0.21263900587151, 0.71516867876775, 0.072192315360733],
                    [0.019330818715591, 0.11919477979462, 0.95053215224966],
            ];

    private static var refY:Float = 1.0;

    private static var refU:Float = 0.19783000664283;
    private static var refV:Float = 0.46831999493879;

    private static var kappa:Float = 903.2962962;
    private static var epsilon:Float = 0.0088564516;

    private static function getBounds(L:Float):Array<Array<Float>> {
        var result:Array<Array<Float>> = [];

        var sub1:Float = Math.pow(L + 16, 3) / 1560896;
        var sub2:Float = sub1 > epsilon ? sub1 : L / kappa;

        for (c in 0...3) {
            var m1:Float = m[c][0];
            var m2:Float = m[c][1];
            var m3:Float = m[c][2];

            for (t in 0...2) {
                var top1:Float = (284517 * m1 - 94839 * m3) * sub2;
                var top2:Float = (838422 * m3 + 769860 * m2 + 731718 * m1) * L * sub2 - 769860 * t * L;
                var bottom:Float = (632260 * m3 - 126452 * m2) * sub2 + 126452 * t;

                result.push([top1 / bottom, top2 / bottom]);
            }
        }

        return result;
    }

    private static function intersectLineLine(lineA:Array<Float>, lineB:Array<Float>) {
        return (lineA[1] - lineB[1]) / (lineB[0] - lineA[0]);
    }

    private static function distanceFromPole(point:Array<Float>) {
        return Math.sqrt(Math.pow(point[0], 2) + Math.pow(point[1], 2));
    }


    private static function lengthOfRayUntilIntersect(theta:Float, line:Array<Float>):Length {
        var length:Float = line[1] / (Math.sin(theta) - line[0] * Math.cos(theta));

        return new Length(length);
    }

    private static function maxSafeChromaForL(L:Float):Float {
        var bounds:Array<Array<Float>> = getBounds(L);
        // var min:Float = Float.MAX_VALUE;
        var min:Float = 1.7976931348623157e+308;

        for (i in 0...2) {
            var m1:Float = bounds[i][0];
            var b1:Float = bounds[i][1];
            var line:Array<Float> = [m1, b1];

            var x:Float = intersectLineLine(line, [-1 / m1, 0]);
            var length:Float = distanceFromPole([x, b1 + x * m1]);

            min = Math.min(min, length);
        }

        return min;
    }

    private static function maxChromaForLH(L:Float, H:Float) {
        var hrad:Float = H / 360 * Math.PI * 2;

        var bounds:Array<Array<Float>> = getBounds(L);
        // var min:Float = Float.MAX_VALUE;
        var min:Float = 1.7976931348623157e+308;

        for (bound in bounds) {
            var length:Length = lengthOfRayUntilIntersect(hrad, bound);
            if (length.greaterEqualZero) {
                min = Math.min(min, length.length);
            }
        }

        return min;
    }

    private static function dotProduct(a:Array<Float>, b:Array<Float>):Float {
        var sum:Float = 0;

        for (i in 0...a.length) {
            sum += a[i] * b[i];
        }

        return sum;
    }

    private static function round(value:Float, places:Int):Float {
        var n:Float = Math.pow(10, places);

        return Math.round(value * n) / n;
    }

    private static function fromLinear(c:Float):Float {
        if (c <= 0.0031308) {
            return 12.92 * c;
        } else {
            return 1.055 * Math.pow(c, 1 / 2.4) - 0.055;
        }
    }

    private static function toLinear(c:Float):Float {
        if (c > 0.04045) {
            return Math.pow((c + 0.055) / (1 + 0.055), 2.4);
        } else {
            return c / 12.92;
        }
    }

    private static function rgbPrepare(tuple:Array<Float>):Array<Int> {

        var results:Array<Int> = [];

        for (i in 0...tuple.length) {
            var chan:Float = tuple[i];
            var rounded = round(chan, 3);

            if (rounded < -0.0001 || rounded > 1.0001) {
                throw "Illegal rgb value: " + rounded;
            }

            results[i] = Math.round(rounded * 255);
        }

        return results;
    }


    public static function xyzToRgb(tuple:Array<Float>) {
        return [                
            fromLinear(dotProduct(m[0], tuple)),
            fromLinear(dotProduct(m[1], tuple)),
            fromLinear(dotProduct(m[2], tuple)),
        ];
    }
    
    public static function rgbToXyz(tuple:Array<Float>):Array<Float> {
        var rgbl:Array<Float> = 
                [
                    toLinear(tuple[0]),
                    toLinear(tuple[1]),
                    toLinear(tuple[2]),
                ];

        return [        
            dotProduct(minv[0], rgbl),
            dotProduct(minv[1], rgbl),
            dotProduct(minv[2], rgbl),
        ];
    }

    private static function yToL(Y:Float):Float {
        if (Y <= epsilon) {
            return (Y / refY) * kappa;
        } else {
            return 116 * Math.pow(Y / refY, 1.0 / 3.0) - 16;
        }
    }

    private static function lToY(L:Float) {
        if (L <= 8) {
            return refY * L / kappa;
        } else {
            return refY * Math.pow((L + 16) / 116, 3);
        }
    }

    public static function xyzToLuv(tuple:Array<Float>):Array<Float> {
        var X:Float = tuple[0];
        var Y:Float = tuple[1];
        var Z:Float = tuple[2];

        // This divider fix avoids a crash on Python (divide by zero except.)
        var divider:Float = (X + (15 * Y) + (3 * Z));
        var varU:Float = 4 * X;
        var varV:Float = 9 * Y;

        if(divider != 0) {
            varU /= divider;
            varV /= divider;
        }
        else {
            varU = Math.NaN;
            varV = Math.NaN;
        }

        var L:Float = yToL(Y);

        if (L == 0) {
            return [0, 0, 0];
        }

        var U:Float = 13 * L * (varU - refU);
        var V:Float = 13 * L * (varV - refV);

        return [L, U, V];
    }

    public static function luvToXyz(tuple:Array<Float>):Array<Float> {
        var L:Float = tuple[0];
        var U:Float = tuple[1];
        var V:Float = tuple[2];

        if (L == 0) {
            return [0, 0, 0];
        }

        var varU:Float = U / (13 * L) + refU;
        var varV:Float = V / (13 * L) + refV;

        var Y:Float = lToY(L);
        var X:Float = 0 - (9 * Y * varU) / ((varU - 4) * varV - varU * varV);
        var Z:Float = (9 * Y - (15 * varV * Y) - (varV * X)) / (3 * varV);

        return [X, Y, Z];
    }

    public static function luvToLch(tuple:Array<Float>):Array<Float> {
        var L:Float = tuple[0];
        var U:Float = tuple[1];
        var V:Float = tuple[2];

        var C:Float = Math.sqrt(U * U + V * V);
        var H:Float;

        if (C < 0.00000001) {
            H = 0;
        } else {
            var Hrad:Float = Math.atan2(V, U);

            // pi to more digits than they provide it in the stdlib
            H = (Hrad * 180.0) / 3.1415926535897932;

            if (H < 0) {
                H = 360 + H;
            }
        }

        return [L, C, H];
    }

    public static function lchToLuv(tuple:Array<Float>):Array<Float> {
        var L:Float = tuple[0];
        var C:Float = tuple[1];
        var H:Float = tuple[2];

        var Hrad:Float = H / 360.0 * 2 * Math.PI;
        var U:Float = Math.cos(Hrad) * C;
        var V:Float = Math.sin(Hrad) * C;

        return [L, U, V];
    }

    public static function huslToLch(tuple:Array<Float>):Array<Float> {
        var H:Float = tuple[0];
        var S:Float = tuple[1];
        var L:Float = tuple[2];

        if (L > 99.9999999) {
            return [100, 0, H];
        }

        if (L < 0.00000001) {
            return [0, 0, H];
        }

        var max:Float = maxChromaForLH(L, H);
        var C:Float = max / 100 * S;

        return [L, C, H];
    }

    public static function lchToHusl(tuple:Array<Float>):Array<Float> {
        var L:Float = tuple[0];
        var C:Float = tuple[1];
        var H:Float = tuple[2];

        if (L > 99.9999999) {
            return [H, 0, 100];
        }

        if (L < 0.00000001) {
            return [H, 0, 0];
        }

        var max:Float = maxChromaForLH(L, H);
        var S:Float = C / max * 100;

        return [H, S, L];
    }

    public static function huslpToLch(tuple:Array<Float>):Array<Float> {
        var H:Float = tuple[0];
        var S:Float = tuple[1];
        var L:Float = tuple[2];

        if (L > 99.9999999) {
            return [100, 0, H];
        }

        if (L < 0.00000001) {
            return [0, 0, H];
        }

        var max:Float = maxSafeChromaForL(L);
        var C:Float = max / 100 * S;

        return [L, C, H];
    }

    public static function lchToHuslp(tuple:Array<Float>):Array<Float> {
        var L:Float = tuple[0];
        var C:Float = tuple[1];
        var H:Float = tuple[2];

        if (L > 99.9999999) {
            return [H, 0, 100];
        }

        if (L < 0.00000001) {
            return [H, 0, 0];
        }

        var max:Float = maxSafeChromaForL(L);
        var S:Float = C / max * 100;

        return [H, S, L];
    }

    public static function rgbToHex(tuple:Array<Float>) {
        var prepared = rgbPrepare(tuple);

        return "#"
            +StringTools.hex(prepared[0], 2)
            +StringTools.hex(prepared[1], 2)
            +StringTools.hex(prepared[2], 2);
    }

    public static function hexToRgb(hex:String):Array<Float> {
        // toUpperCase because some targets such as lua have hard time parsing hex code with various cases
        return [
            Std.parseInt("0x"+hex.substr(1, 2).toUpperCase()) / 255.0,
            Std.parseInt("0x"+hex.substr(3, 2).toUpperCase()) / 255.0,
            Std.parseInt("0x"+hex.substr(5, 2).toUpperCase()) / 255.0,
        ];
    }

    public static function lchToRgb(tuple:Array<Float>):Array<Float> {
        return xyzToRgb(luvToXyz(lchToLuv(tuple)));
    }

    public static function rgbToLch(tuple:Array<Float>):Array<Float> {
        return luvToLch(xyzToLuv(rgbToXyz(tuple)));
    }

    // RGB <--> HUSL(p)

    public static function huslToRgb(tuple:Array<Float>):Array<Float> {
        return lchToRgb(huslToLch(tuple));
    }

    public static function rgbToHusl(tuple:Array<Float>):Array<Float> {
        return lchToHusl(rgbToLch(tuple));
    }

    public static function huslpToRgb(tuple:Array<Float>):Array<Float> {
        return lchToRgb(huslpToLch(tuple));
    }

    public static function rgbToHuslp(tuple:Array<Float>):Array<Float> {
        return lchToHuslp(rgbToLch(tuple));
    }

    // Hex

    public static function huslToHex(tuple:Array<Float>):String {
        return rgbToHex(huslToRgb(tuple));
    }

    public static function huslpToHex(tuple:Array<Float>):String {
        return rgbToHex(huslpToRgb(tuple));
    }

    public static function hexToHusl(s:String):Array<Float> {
        return rgbToHusl(hexToRgb(s));
    }

    public static function hexToHuslp(s:String):Array<Float> {
        return rgbToHuslp(hexToRgb(s));
    }

}