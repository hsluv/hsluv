package;

import haxe.unit.TestCase;
import husl.Husl;

class ColorConverterTest extends TestCase {

    private static inline var MAXDIFF:Float = 0.0000000001;
    private static inline var MAXRELDIFF:Float = 0.000000001;

    /**
     * modified from
     * https://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/
     */
    private function assertAlmostEqualRelativeAndAbs(a:Float, b:Float):Bool {
        // Check if the numbers are really close -- needed
        // when comparing numbers near zero.
        var diff:Float = Math.abs(a - b);
        if (diff <= MAXDIFF) {
            return true;
        }

        a = Math.abs(a);
        b = Math.abs(b);
        var largest:Float = (b > a) ? b : a;

        return diff <= largest * MAXRELDIFF;
    }

    private function getTargetName():String {
        #if js 
        return "js";
        #elseif php
        return "php";
        #elseif cpp
        return "cpp";
        #elseif java
        return "java";
        #elseif python
        return "python";
        #elseif neko
        return "neko";
        #elseif sys
        return "sys";
        #elseif flash
        return "flash";
        #elseif cs
        return "cs";
        #else
        return "unknown";
        #end
    }

    private function assertTuplesClose(label:String, expected:Array<Float>, actual:Array<Float>):Void {
        var mismatch:Bool = false;
        var deltas:Array<Float> = [];

        for(i in 0...expected.length) {
            deltas[i] = Math.abs(expected[i] - actual[i]);
            if (!assertAlmostEqualRelativeAndAbs(expected[i], actual[i])) {
                mismatch = true;
            }
        }

        if (mismatch) {
            trace("MISMATCH " + label);
            trace(" expected: " + expected[0] + "," + expected[1] + "," + expected[2]);
            trace("  actual: " + actual[0] + "," + actual[1] + "," + actual[2]);
            trace("  deltas: " + deltas[0] + "," + deltas[1] + "," + expected[2]);
        }

        assertFalse(mismatch);
    }

    function testHusl() {

        var file = haxe.Resource.getString("snapshot-rev4");
        var object = haxe.Json.parse(file);

        for (fieldName in Reflect.fields(object))
        {

            var field = Reflect.field(object, fieldName);
            // print("testing " + fieldName + " on "+getTargetName()+"\n");

            // forward functions

            var rgbFromHex = Husl.hexToRgb(fieldName);
            var xyzFromRgb = Husl.rgbToXyz(field.rgb);
            var luvFromXyz = Husl.xyzToLuv(field.xyz);
            var lchFromLuv = Husl.luvToLch(field.luv);
            var huslFromLch = Husl.lchToHusl(field.lch);
            var huslpFromLch = Husl.lchToHuslp(field.lch);
            var huslFromHex = Husl.hexToHusl(fieldName);
            var huslpFromHex = Husl.hexToHuslp(fieldName);

            assertTuplesClose(fieldName + "→" + "hexToRgb", field.rgb, rgbFromHex);
            assertTuplesClose(fieldName + "→" + "rgbToXyz", field.xyz, xyzFromRgb);
            assertTuplesClose(fieldName + "→" + "xyzToLuv", field.luv, luvFromXyz);
            assertTuplesClose(fieldName + "→" + "luvToLch", field.lch, lchFromLuv);
            assertTuplesClose(fieldName + "→" + "lchToHusl", field.husl, huslFromLch);
            assertTuplesClose(fieldName + "→" + "lchToHuslp", field.huslp, huslpFromLch);
            assertTuplesClose(fieldName + "→" + "hexToHusl", field.husl, huslFromHex);
            assertTuplesClose(fieldName + "→" + "hexToHuslp", field.huslp, huslpFromHex);

            // backward functions

            var lchFromHusl = Husl.huslToLch(field.husl);
            var lchFromHuslp = Husl.huslpToLch(field.huslp);
            var luvFromLch = Husl.lchToLuv(field.lch);
            var xyzFromLuv = Husl.luvToXyz(field.luv);
            var rgbFromXyz = Husl.xyzToRgb(field.xyz);
            var hexFromRgb:String = Husl.rgbToHex(field.rgb);
            var hexFromHusl:String = Husl.huslToHex(field.husl);
            var hexFromHuslp:String = Husl.huslpToHex(field.huslp);

            assertTuplesClose("huslToLch", field.lch, lchFromHusl);
            assertTuplesClose("huslpToLch", field.lch, lchFromHuslp);
            assertTuplesClose("lchToLuv", field.luv, luvFromLch);
            assertTuplesClose("luvToXyz", field.xyz, xyzFromLuv);
            assertTuplesClose("xyzToRgb", field.rgb, rgbFromXyz);
            // toLowerCase because some targets such as lua have hard time parsing hex code with various cases
            assertEquals(fieldName, hexFromRgb.toLowerCase());
            assertEquals(fieldName, hexFromHusl.toLowerCase());
            assertEquals(fieldName, hexFromHuslp.toLowerCase());
        }
    }
}