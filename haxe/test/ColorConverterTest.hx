package;

import haxe.unit.TestCase;
import hsluv.Hsluv;


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

    function testConsistency() {
        var samples = Snapshot.generateHexSamples();
        for (hex in samples) {
            assertEquals(hex, Hsluv.hsluvToHex(Hsluv.hexToHsluv(hex)));
            assertEquals(hex, Hsluv.hpluvToHex(Hsluv.hexToHpluv(hex)));
        }
    }

    function testRgbChannelBounds() {
        // TODO: Consider clipping RGB channels instead and testing with 0 error tolerance
        for (r in [0.0, 1.0]) {
            for (g in [0.0, 1.0]) {
                for (b in [0.0, 1.0]) {
                    var sample = [r, g, b];
                    var hsluv = Hsluv.rgbToHsluv(sample);
                    var hpluv = Hsluv.rgbToHpluv(sample);
                    var rgbHsluv = Hsluv.hsluvToRgb(hsluv);
                    var rgbHpluv = Hsluv.hpluvToRgb(hpluv);
                    assertTuplesClose('RGB -> HSLuv -> RGB', sample, rgbHsluv);
                    assertTuplesClose('RGB -> HPLuv -> RGB', sample, rgbHpluv);
                }
            }
        }
    }

    function testHsluv() {

        var file = haxe.Resource.getString("snapshot-rev4");
        if(file == null) {
            trace("Couldn't load the snapshot file snapshot-rev4, make sure it's present in test/resources.");
        }
        assertFalse(file == null);
        var object = haxe.Json.parse(file);

        for (fieldName in Reflect.fields(object))
        {

            var field = Reflect.field(object, fieldName);
            // print("testing " + fieldName + " on "+getTargetName()+"\n");

            // forward functions

            var rgbFromHex = Hsluv.hexToRgb(fieldName);
            var xyzFromRgb = Hsluv.rgbToXyz(field.rgb);
            var luvFromXyz = Hsluv.xyzToLuv(field.xyz);
            var lchFromLuv = Hsluv.luvToLch(field.luv);
            var hsluvFromLch = Hsluv.lchToHsluv(field.lch);
            var hpluvFromLch = Hsluv.lchToHpluv(field.lch);
            var hsluvFromHex = Hsluv.hexToHsluv(fieldName);
            var hpluvFromHex = Hsluv.hexToHpluv(fieldName);

            assertTuplesClose(fieldName + "→" + "hexToRgb", field.rgb, rgbFromHex);
            assertTuplesClose(fieldName + "→" + "rgbToXyz", field.xyz, xyzFromRgb);
            assertTuplesClose(fieldName + "→" + "xyzToLuv", field.luv, luvFromXyz);
            assertTuplesClose(fieldName + "→" + "luvToLch", field.lch, lchFromLuv);
            assertTuplesClose(fieldName + "→" + "lchToHsluv", field.hsluv, hsluvFromLch);
            assertTuplesClose(fieldName + "→" + "lchToHpluv", field.hpluv, hpluvFromLch);
            assertTuplesClose(fieldName + "→" + "hexToHsluv", field.hsluv, hsluvFromHex);
            assertTuplesClose(fieldName + "→" + "hexToHpluv", field.hpluv, hpluvFromHex);

            // backward functions

            var lchFromHsluv = Hsluv.hsluvToLch(field.hsluv);
            var lchFromHpluv = Hsluv.hpluvToLch(field.hpluv);
            var luvFromLch = Hsluv.lchToLuv(field.lch);
            var xyzFromLuv = Hsluv.luvToXyz(field.luv);
            var rgbFromXyz = Hsluv.xyzToRgb(field.xyz);
            var hexFromRgb:String = Hsluv.rgbToHex(field.rgb);
            var hexFromHsluv:String = Hsluv.hsluvToHex(field.hsluv);
            var hexFromHpluv:String = Hsluv.hpluvToHex(field.hpluv);

            assertTuplesClose("hsluvToLch", field.lch, lchFromHsluv);
            assertTuplesClose("hpluvToLch", field.lch, lchFromHpluv);
            assertTuplesClose("lchToLuv", field.luv, luvFromLch);
            assertTuplesClose("luvToXyz", field.xyz, xyzFromLuv);
            assertTuplesClose("xyzToRgb", field.rgb, rgbFromXyz);
            // toLowerCase because some targets such as lua have hard time parsing hex code with various cases
            assertEquals(fieldName, hexFromRgb.toLowerCase());
            assertEquals(fieldName, hexFromHsluv.toLowerCase());
            assertEquals(fieldName, hexFromHpluv.toLowerCase());
        }
    }
}