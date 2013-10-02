package com.boronine.husl;


public class HuslConverter {

	/* package */ static float PI = 3.1415926535897932384626433832795f;
	// Used for rgb ↔ xyz conversions.
	/* package */ static float m[][] = {{3.2406f, -1.5372f, -0.4986f},
								  {-0.9689f, 1.8758f, 0.0415f},
								  {0.0557f, -0.2040f, 1.0570f}};
	private static float m_inv[][] = {{0.4124f, 0.3576f, 0.1805f},
									  {0.2126f, 0.7152f, 0.0722f},
									  {0.0193f, 0.1192f, 0.9505f}};
	// Hard-coded D65 standard illuminant.
	private static float refX = 0.95047f;
	private static float refY = 1.00000f;
	private static float refZ = 1.08883f;
	private static float refU = 0.19784f; // 4 * refX / (refX + 15 * refY + 3 * refZ)
	private static float refV = 0.46834f; // 9 * refY / (refX + 15 * refY + 3 * refZ)
	// CIE LAB and LUV constants.
	private static float lab_e = 0.008856f;
	private static float lab_k = 903.3f;
	
	private static final int RGB_R = 0;
	private static final int RGB_G = 1;
	private static final int RGB_B = 2;

	private static final int XYZ_X = 0;
	private static final int XYZ_Y = 1;
	private static final int XYZ_Z = 2;

	private static final int LUV_L = 0;
	private static final int LUV_U = 1;
	private static final int LUV_V = 2;

	private static final int LCH_L = 0;
	private static final int LCH_C = 1;
	private static final int LCH_H = 2;

	private static final int HUSL_H = 0;
	private static final int HUSL_S = 1;
	private static final int HUSL_L = 2;

	/**
	 * For a given lightness and hue, return the maximum chroma that fits in the RGB gamut.
	 */
	public static float maxChroma(float L, float H) {
		// The CoffeeScript and JavaScript versions of HUSL have this function broken up into several
		// schönfinkeling/currying-style functions. This however doesn't work as well in Java. Therefore, everything is cramped
		// up into one function.
		float result = Float.POSITIVE_INFINITY;
		final float hrad = H / 360 * 2 * HuslConverter.PI;
		final float sinH = (float) Math.sin(hrad);
		final float cosH = (float) Math.cos(hrad);
		final float sub1 = (float) Math.pow(L + 16, 3) / 1560896f;
		final float sub2 = sub1 > 0.008856f ? sub1 : L / 903.3f;
		// Loop over the channels (red, green and blue).
		for (int channel = 0; 3 != channel; channel++) {
			final float[] channelM = HuslConverter.m[channel];
			final float top = (0.99915f * channelM[0] + 1.05122f * channelM[1] + 1.14460f * channelM[2]) * sub2;
			final float rbottom = 0.86330f * channelM[2] - 0.17266f * channelM[1];
			final float lbottom = 0.12949f * channelM[2] - 0.38848f * channelM[0];
			final float bottom = (rbottom * sinH + lbottom * cosH) * sub2;
			// Calculate the C values that you can put together with the given L and H to produce a colour that with
			// <RGB channel> = 1 or 2. This means that if C goes any higher, the colour will step outside of the RGB gamut.
			final float C0 = L * top / bottom;
			if (C0 > 0 && C0 < result) {
				result = C0;
			}
			final float C1 = L * (top - 1.05122f * 1) / (bottom + 0.17266f * sinH);
			if (C1 > 0 && C1 < result) {
				result = C1;
			}
		}
		return result;
	}

	private static float dotProduct(float a[], float b[]) {
		float result = 0;
		for (int index = 0; 3 != index; index++) {
			result += a[index] * b[index];
		}
		return result;
	}

	private static float round(float num, int places) {
		float n;
		n = (float) Math.pow(10.0f, places);
		return (float) (Math.floor(num * n) / n);
	}

	// Used for Lab and Luv conversions.
	private static float f(float t) {
		if (t > lab_e) {
			return (float) Math.pow(t, 1f / 3);
		} else {
			return 7.787f * t + 16 / 116f;
		}
	}
	private static float f_inv(float t) {
		final float proposedResult = (float) Math.pow(t, 3);
		if (proposedResult > lab_e) {
			return proposedResult;
		} else {
			return (116 * t - 16) / lab_k;
		}
	}

	// Used for RGB conversions.
	private static float fromLinear(float c) {
		if (c <= 0.0031308f) {
			return 12.92f * c;
		} else {
			return 1.055f * (float) Math.pow(c, 1 / 2.4f) - 0.055f;
		}
	}
	private static float toLinear(float c) {
		if (c > 0.04045f) {
			return (float) Math.pow((c + 0.055f) / 1.055f, 2.4f);
		} else {
			return c / 12.92f;
		}
	}

	/**
	 * Converts an XYZ tuple to an RGB one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertXyzToRgb(float tuple[]) {
		// Tuple represents input.
		final float R = fromLinear(dotProduct(m[0], tuple));
		final float G = fromLinear(dotProduct(m[1], tuple));
		// Tuple is being filled with output.
		tuple[RGB_B] = fromLinear(dotProduct(m[2], tuple));
		tuple[RGB_R] = R;
		tuple[RGB_G] = G;
	}

	/**
	 * Converts an XYZ tuple to an RGB one.
	 */
	public static float[] convertXyzToRgb(float xyzTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{xyzTuple[0], xyzTuple[1], xyzTuple[2]};
		unsafeConvertXyzToRgb(result);
		return result;
	}

	/**
	 * Converts an RGB tuple to an XYZ one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertRgbToXyz(float tuple[]) {
		// Tuple represents input.
		float rgbl[] = new float[]{toLinear(tuple[0]), toLinear(tuple[1]), toLinear(tuple[2])};
		// Tuple is being filled with output.
		tuple[XYZ_X] = dotProduct(m_inv[0], rgbl);
		tuple[XYZ_Y] = dotProduct(m_inv[1], rgbl);
		tuple[XYZ_Z] = dotProduct(m_inv[2], rgbl);
	}

	/**
	 * Converts an RGB tuple to an XYZ one.
	 */
	public static float[] convertRgbToXyz(float rgbTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{rgbTuple[0], rgbTuple[1], rgbTuple[2]};
		unsafeConvertRgbToXyz(result);
		return result;
	}

	/**
	 * Converts an XYZ tuple to an LUV one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertXyzToLuv(float tuple[]) {
		// Tuple represents input.
		final float X = tuple[XYZ_X];
		final float Y = tuple[XYZ_Y];
		final float Z = tuple[XYZ_Z];
		final float varU = 4 * X / (X + 15 * Y + 3 * Z);
		final float varV = 9 * Y / (X + 15 * Y + 3 * Z);
		// Tuple is being filled with output.
		final float L;
		// Black will create a divide-by-zero error.
		if (0 == (L = 116 * f(Y / refY) - 16)) {
			tuple[0] = tuple[1] = tuple[2] = 0;
			return;
		}
		tuple[LUV_L] = L;
		tuple[LUV_U] = 13 * L * (varU - refU);
		tuple[LUV_V] = 13 * L * (varV - refV);
	}

	/**
	 * Converts an XYZ tuple to an LUV one.
	 */
	public static float[] convertXyzToLuv(float xzyTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{xzyTuple[0], xzyTuple[1], xzyTuple[2]};
		unsafeConvertXyzToLuv(result);
		return result;
	}

	/**
	 * Converts an LUV tuple to an XYZ one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertLuvToXyz(float tuple[]) {
		// Tuple represents input. Black will create a divide-by-zero error.
		if (tuple[LUV_L] == 0) {
			// Tuple is being filled with output. The X = L in the tuple is left untouched.
			/* tuple[XYZ_X] = */ tuple[XYZ_Y] = tuple[XYZ_Z] = 0;
			return;
		}
		final float L = tuple[LUV_L];
		final float varY = f_inv((L + 16) / 116);
		final float varU = tuple[LUV_U] / (13 * L) + refU;
		final float varV = tuple[LUV_V] / (13 * L) + refV;
		// Tuple is being filled with output.
		final float Y = tuple[XYZ_Y] = varY * refY;
		final float X = tuple[XYZ_X] = -9 * Y * varU / ((varU - 4) * varV - varU * varV);
		/* final float Z = */ tuple[XYZ_Z] = (9 * Y - 15 * varV * Y - varV * X) / (3 * varV);
	}

	/**
	 * Converts an LUV tuple to an XYZ one.
	 */
	public static float[] convertLuvToXyz(float luvTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{luvTuple[0], luvTuple[1], luvTuple[2]};
		unsafeConvertLuvToXyz(result);
		return result;
	}

	/**
	 * Converts an LUV tuple to an LCH one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertLuvToLch(float tuple[]) {
		// Tuple represents input.
		final float U = tuple[LUV_U];
		final float V = tuple[LUV_V];
		// Tuple is being filled with output. The L in the tuple is left untouched.
		tuple[LCH_C] = (float) Math.sqrt(U * U + V * V);
		final float Hrad = (float) Math.atan2(V, U);
		float H = Hrad * 360 / 2 / PI;
		if (H < 0) {
			H += 360;
		}
		tuple[LCH_H] = H;
	}

	/**
	 * Converts an LUV tuple to an LCH one.
	 */
	public static float[] convertLuvToLch(float luvTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{luvTuple[0], luvTuple[1], luvTuple[2]};
		unsafeConvertLuvToLch(result);
		return result;
	}

	/**
	 * Converts an LCH tuple to an LUV one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertLchToLuv(float tuple[]) {
		// Tuple represents input.
		final float C = tuple[LCH_C];
		final float Hrad = tuple[LCH_H] / 360 * 2 * PI;
		// Tuple is being filled with output. The L in the tuple is left untouched.
		tuple[LUV_U] = (float) Math.cos(Hrad) * C;
		tuple[LUV_V] = (float) Math.sin(Hrad) * C;
	}

	/**
	 * Converts an LCH tuple to an LUV one.
	 */
	public static float[] convertLchToLuv(float lchTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{lchTuple[0], lchTuple[1], lchTuple[2]};
		unsafeConvertLchToLuv(result);
		return result;
	}

	/**
	 * Converts an HUSL tuple to an LCH one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertHuslToLch(float tuple[]) {
		// Tuple represents input.
		final float H = tuple[HUSL_H];
		final float L = tuple[HUSL_L];
		// Bad things happen when you reach a limit.
		if (L > 99.9999f) {
			// Tuple is being filled with output. 
			tuple[LCH_L] = 100;
			tuple[LCH_C] = 0;
			tuple[LCH_H] = H;
			return;
		} else if (L < 0.00001f) {
			// Tuple is being filled with output. 
			tuple[LCH_L] = tuple[LCH_C] = 0;
			tuple[LCH_H] = H;
			return;
		}
		// Tuple is being filled with output.
		// I already tried this scaling function to improve the chroma uniformity. It did not work very well.
		// tuple[LCH_C] = Math.pow(tuple[HUSL_S] / 100,  1 / t) * maxChroma(L, H)
		tuple[LCH_C] = maxChroma(L, H) / 100 * tuple[HUSL_S];
		tuple[LCH_L] = L;
		tuple[LCH_H] = H;
	}

	/**
	 * Converts an HUSL tuple to an LCH one.
	 */
	public static float[] convertHuslToLch(float huslTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{huslTuple[0], huslTuple[1], huslTuple[2]};
		unsafeConvertHuslToLch(result);
		return result;
	}

	/**
	 * Converts an LCH tuple to an HUSL one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertLchToHusl(float tuple[]) {
		// Tuple represents input.
		final float L = tuple[LCH_L];
		final float H = tuple[LCH_H];
		// Bad things happen when you reach a limit.
		if (L > 99.9999f) {
			// Tuple is being filled with output. 
			tuple[HUSL_H] = H;
			tuple[HUSL_S] = 0;
			tuple[HUSL_L] = 100;
			return;
		} else if (L < 0.00001f) {
			// Tuple is being filled with output. 
			tuple[HUSL_H] = H;
			tuple[HUSL_S] = tuple[HUSL_L] = 0;
			return;
		}
		// Tuple is being filled with output. 
		tuple[HUSL_S] = tuple[LCH_C] / maxChroma(L, H) * 100;
		tuple[HUSL_H] = H;
		tuple[HUSL_L] = L;
	}

	/**
	 * Converts an LCH tuple to an HUSL one.
	 */
	public static float[] convertLchToHusl(float lchTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{lchTuple[0], lchTuple[1], lchTuple[2]};
		unsafeConvertLchToHusl(result);
		return result;
	}

	/**
	 * Converts an HUSL tuple to an RGB one.
	 */
	public static float[] convertHuslToRgb(float huslTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{huslTuple[0], huslTuple[1], huslTuple[2]};
		// Calculate the LCH values.
		unsafeConvertHuslToLch(result);
		// Calculate the LUV values.
		unsafeConvertLchToLuv(result);
		// Calculate the XYZ values.
		unsafeConvertLuvToXyz(result);
		// Calculate the RGB values.
		unsafeConvertXyzToRgb(result);
		return result;
	}

	/**
	 * Converts an RGB tuple to an HUSL one.
	 */
	public static float[] convertRgbToHusl(float rgbTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{rgbTuple[0], rgbTuple[1], rgbTuple[2]};
		// Calculate the XYZ values.
		unsafeConvertRgbToXyz(result);
		// Calculate the LUV values.
		unsafeConvertXyzToLuv(result);
		// Calculate the LCH values.
		unsafeConvertLuvToLch(result);
		// Calculate the HUSL values.
		unsafeConvertLchToHusl(result);
		return result;
	}

}