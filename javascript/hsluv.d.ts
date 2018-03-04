// Type definitions for hsluv 0.0.2
// Project: http://hsluv.org/
// TypeScript Version: 2.7


declare namespace Hsluv {

  export type ColorTuple = [number, number, number]

  export interface PublicApi {
    hsluvToRgb: (tuple: ColorTuple) => ColorTuple,
    rgbToHsluv: (tuple: ColorTuple) => ColorTuple,
    hpluvToRgb: (tuple: ColorTuple) => ColorTuple,
    rgbToHpluv: (tuple: ColorTuple) => ColorTuple,
    hsluvToHex: (tuple: ColorTuple) => string,
    hexToHsluv: (hex: string) => ColorTuple,
    hpluvToHex: (tuple: ColorTuple) => string,
    hexToHpluv: (hex: string) => ColorTuple,
    lchToHpluv: (tuple: ColorTuple) => ColorTuple,
    hpluvToLch: (tuple: ColorTuple) => ColorTuple,
    lchToHsluv: (tuple: ColorTuple) => ColorTuple,
    hsluvToLch: (tuple: ColorTuple) => ColorTuple,
    lchToLuv: (tuple: ColorTuple) => ColorTuple,
    luvToLch: (tuple: ColorTuple) => ColorTuple,
    xyzToLuv: (tuple: ColorTuple) => ColorTuple,
    luvToXyz: (tuple: ColorTuple) => ColorTuple,
    xyzToRgb: (tuple: ColorTuple) => ColorTuple,
    rgbToXyz: (tuple: ColorTuple) => ColorTuple,
    lchToRgb: (tuple: ColorTuple) => ColorTuple,
    rgbToLch: (tuple: ColorTuple) => ColorTuple
  }
}

declare module "hsluv" {
  var hsluv: Hsluv.PublicApi;
  export = hsluv;
}