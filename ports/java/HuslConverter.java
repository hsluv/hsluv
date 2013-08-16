package com.boronine.husl;

import android.util.FloatMath;

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

	/**
	 * For a given lightness and hue, return the maximum chroma that fits in the RGB gamut.
	 */
	public static float maxChroma(float L, float H) {
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
		final int length = a.length;
		for (int index = 0; length != index; index++) {
			result += a[index] * b[index];
		}
		return result;
	}

	private static float round(float num, int places) {
		float n;
		n = (float) Math.pow(10.0f, places);
		return (float) (Math.floor(num * n) / n);
	}

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
		final float R = fromLinear(dotProduct(m[0], tuple));
		final float G = fromLinear(dotProduct(m[1], tuple));
		final float B = fromLinear(dotProduct(m[2], tuple));

		tuple[0] = R;
		tuple[1] = G;
		tuple[2] = B;
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
		float rgbl[] = new float[]{toLinear(tuple[0]), toLinear(tuple[1]), toLinear(tuple[2])};

		final float X = dotProduct(m_inv[0], rgbl);
		final float Y = dotProduct(m_inv[1], rgbl);
		final float Z = dotProduct(m_inv[2], rgbl);

		tuple[0] = X;
		tuple[1] = Y;
		tuple[2] = Z;
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
		final float X = tuple[0];
		final float Y = tuple[1];
		final float Z = tuple[2];

		final float varU = 4 * X / (X + 15 * Y + 3 * Z);
		final float varV = 9 * Y / (X + 15 * Y + 3 * Z);
		final float L;
		// Black will create a divide-by-zero error.
		if (0 == (L = 116 * f(Y / refY) - 16)) {
			tuple[0] = tuple[1] = tuple[2] = 0;
			return;
		}
		final float U = 13 * L * (varU - refU);
		final float V = 13 * L * (varV - refV);

		tuple[0] = L;
		tuple[1] = U;
		tuple[2] = V;
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
		final float L = tuple[0];
		final float U = tuple[1];
		final float V = tuple[2];

		// Black will create a divide-by-zero error.
		if (L == 0) {
			tuple[2] = tuple[1] = tuple[0] = 0;
			return;
		}

		final float varY = f_inv((L + 16) / 116);
		final float varU = U / (13 * L) + refU;
		final float varV = V / (13 * L) + refV;
		final float Y = varY * refY;
		final float X = 0 - 9 * Y * varU / ((varU - 4) * varV - varU * varV);
		final float Z = (9 * Y - 15 * varV * Y - varV * X) / (3 * varV);

		tuple[0] = X;
		tuple[1] = Y;
		tuple[2] = Z;
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
		final float L = tuple[0];
		final float U = tuple[1];
		final float V = tuple[2];

		final float C = FloatMath.sqrt(U * U + V * V);
		final float Hrad = (float) Math.atan2(V, U);
		float H = Hrad * 360 / 2 / PI;
		if (H < 0) {
			H += 360;
		}

		tuple[0] = L;
		tuple[1] = C;
		tuple[2] = H;
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
		final float L = tuple[0];
		final float C = tuple[1];
		final float H = tuple[2];

		final float Hrad = H / 360 * 2 * PI;
		final float U = (float) Math.cos(Hrad) * C;
		final float V = (float) Math.sin(Hrad) * C;

		tuple[0] = L;
		tuple[1] = U;
		tuple[2] = V;
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
		final float H = tuple[0];
		final float S = tuple[1];
		final float L = tuple[2];

		final float max = maxChroma(L, H);
		final float C = max / 100 * S;

		tuple[0] = L;
		tuple[1] = C;
		tuple[2] = H;
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
		final float L = tuple[0];
		final float C = tuple[1];
		final float H = tuple[2];

		final float max = maxChroma(L, H);
		final float S = C / max * 100;

		tuple[0] = H;
		tuple[1] = S;
		tuple[2] = L;
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
		convertHuslToLch(result);
		// Calculate the LUV values.
		convertLchToLuv(result);
		// Calculate the XYZ values.
		convertLuvToXyz(result);
		// Calculate the RGB values.
		convertXyzToRgb(result);
		return result;
	}

	/**
	 * Converts an RGB tuple to an HUSL one.
	 */
	public static float[] convertRgbToHusl(float rgbTuple[]) {
		// Clone the tuple, to avoid changing the input.
		final float[] result = new float[]{rgbTuple[0], rgbTuple[1], rgbTuple[2]};
		// Calculate the XYZ values.
		convertRgbToXyz(result);
		// Calculate the LUV values.
		convertXyzToLuv(result);
		// Calculate the LCH values.
		convertLuvToLch(result);
		// Calculate the HUSL values.
		convertLchToHusl(result);
		return result;
	}

}