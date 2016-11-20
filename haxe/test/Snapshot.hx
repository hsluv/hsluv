package;

import Sys;
import husl.Husl;
import haxe.Log;
import haxe.Json;
import haxe.ds.StringMap;

@:access(husl.Husl.hexToRgb)
@:access(husl.Husl.rgbToXyz)
@:access(husl.Husl.xyzToLuv)
@:access(husl.Husl.luvToLch)
@:access(husl.Husl.lchToHusl)
@:access(husl.Husl.lchToHuslp)
class Snapshot extends Husl {
    static public function main () {
        var digits:String = "0123456789abcdef";

        var ret:StringMap<StringMap<Array<Float>>> = new StringMap();

        for (i in 0...digits.length) {
            var r = digits.charAt(i);
            for (j in 0...digits.length) {
                var g = digits.charAt(j);
                for (k in 0...digits.length) {
                    var b = digits.charAt(k);
                    var hex = "#" + r + r + g + g + b + b;

                    var rgb = Husl.hexToRgb(hex);
                    var xyz = Husl.rgbToXyz(rgb);
                    var luv = Husl.xyzToLuv(xyz);
                    var lch = Husl.luvToLch(luv);

                    var sample:StringMap<Array<Float>> = new StringMap();
                    sample.set("rgb", rgb);
                    sample.set("xyz", xyz);
                    sample.set("luv", luv);
                    sample.set("lch", lch);
                    sample.set("husl", Husl.lchToHusl(lch));
                    sample.set("huslp", Husl.lchToHuslp(lch));

                    ret.set(hex, sample);
                }
            }
        }

        Sys.stdout().writeString(Json.stringify(ret));
    }
}
