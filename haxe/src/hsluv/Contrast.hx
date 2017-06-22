package hsluv;
import hsluv.Hsluv;

/* See math/contrast.wxm */

class Contrast {

    public static var W3C_CONTRAST_TEXT:Float = 4.5;
    public static var W3C_CONTRAST_LARGE_TEXT:Float = 3;

    public static function contrastRatio(lighterL, darkerL) {
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-procedure
        var lighterY = Hsluv.lToY(lighterL);
        var darkerY = Hsluv.lToY(darkerL);
        return (lighterY + 0.05) / (darkerY + 0.05);
    }

    public static function lighterMinL(r:Float):Float {
        return Hsluv.yToL((r - 1) / 20);
    }

    public static function darkerMaxL(r:Float, lighterL:Float) {
        var lighterY = Hsluv.lToY(lighterL);
        var maxY = (20 * lighterY - r + 1) / (20 * r);
        return Hsluv.yToL(maxY);
    }

}