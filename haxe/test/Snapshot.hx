package;

import Sys;
import hsluv.Hsluv;
import haxe.Log;
import haxe.Json;
import haxe.ds.StringMap;


class Snapshot extends Hsluv {

    static public function generateHexSamples () {
        var digits:String = "0123456789abcdef";
        var ret = [];
        for (i in 0...16) {
            var r = digits.charAt(i);
            for (j in 0...16) {
                var g = digits.charAt(j);
                for (k in 0...16) {
                    var b = digits.charAt(k);
                    var hex = "#" + r + r + g + g + b + b;
                    ret.push(hex);
                }
            }
        }
        return ret;
    }

    static public function main () {
        var digits:String = "0123456789abcdef";

        var ret:StringMap<StringMap<Array<Float>>> = new StringMap();
        var samples = Snapshot.generateHexSamples();

        for (hex in samples) {
            
            var rgb = Hsluv.hexToRgb(hex);
            var xyz = Hsluv.rgbToXyz(rgb);
            var luv = Hsluv.xyzToLuv(xyz);
            var lch = Hsluv.luvToLch(luv);

            var sample:StringMap<Array<Float>> = new StringMap();
            sample.set("rgb", rgb);
            sample.set("xyz", xyz);
            sample.set("luv", luv);
            sample.set("lch", lch);
            sample.set("hsluv", Hsluv.lchToHsluv(lch));
            sample.set("hpluv", Hsluv.lchToHpluv(lch));

            ret.set(hex, sample);
        }

        Sys.stdout().writeString(Json.stringify(ret));
    }
}
