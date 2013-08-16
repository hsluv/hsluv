package com.boronine.husl;

public class HuslConverter {

	private static double PI = 3.1415926535897932384626433832795;
	// Used for rgb ↔ xyz conversions.
	private static float m[][] = {{3.2406f, -1.5372f, -0.4986f},
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

	private static float maxChroma(float L, float H){

		float C, bottom, cosH, hrad, lbottom, m1, m2, m3, rbottom, result, sinH, sub1, sub2, t, top;
		int _i, _j, _len, _len1;
		float row[];
		float _ref[] = {0.0f, 1.0f};


		hrad = (float) (H / 360.0f * 2 * PI);
		sinH = (float) Math.sin(hrad);
		cosH = (float) Math.cos(hrad);
		sub1 = (float) (Math.pow(L + 16, 3) / 1560896.0);
		sub2 = sub1 > 0.008856 ? sub1 : (float) (L / 903.3);
		result = Float.POSITIVE_INFINITY;
		for (_i = 0, _len = 3; _i < _len; ++_i) {
			row = m[_i];
			m1 = row[0];
			m2 = row[1];
			m3 = row[2];
			top = (float) ((0.99915 * m1 + 1.05122 * m2 + 1.14460 * m3) * sub2);
			rbottom = (float) (0.86330 * m3 - 0.17266 * m2);
			lbottom = (float) (0.12949 * m3 - 0.38848 * m1);
			bottom = (rbottom * sinH + lbottom * cosH) * sub2;

			for (_j = 0, _len1 = 2; _j < _len1; ++_j) {
				t = _ref[_j];
				C = (float) (L * (top - 1.05122 * t) / (bottom + 0.17266 * sinH * t));
				if (C > 0 && C < result) {
					result = C;
				}
			}
		}
		return result;
	}

	private static float dotProduct(float a[], float b[], int len){

		int i, _i, _ref;
		float ret = 0.0f;
		for (i = _i = 0, _ref = len - 1;    0 <= _ref ? _i <= _ref : _i >= _ref;    i = 0 <= _ref ? ++_i : --_i) {
			ret += a[i] * b[i];
		}
		return ret;

	}

	private static float round( float num, int places )
	{
		float n;
		n = (float) Math.pow(10.0f, places);
		return (float) (Math.floor(num * n) / n);
	}

	private static float f( float t )
	{
		if (t > lab_e) {
			return (float) Math.pow(t, 1.0f / 3.0f);
		} else {
			return (float) (7.787 * t + 16 / 116.0);
		}
	}

	private static float f_inv( float t )
	{
		if (Math.pow(t, 3) > lab_e) {
			return (float) Math.pow(t, 3);
		} else {
			return (116 * t - 16) / lab_k;
		}
	}

	private static float fromLinear( float c )
	{
		if (c <= 0.0031308) {
			return 12.92f * c;
		} else {
			return (float) (1.055 * Math.pow(c, 1 / 2.4f) - 0.055);
		}
	}

	private static float toLinear( float c )
	{
		float a = 0.055f;

		if (c > 0.04045) {
			return (float) Math.pow((c + a) / (1 + a), 2.4f);
		} else {
			return (float) (c / 12.92);
		}
	}

	private static float[] rgbPrepare( float tuple[] )
	{
		int i;

		for(i = 0; i < 3; ++i){
			tuple[i] = round(tuple[i], 3);

			if (tuple[i] < 0 || tuple[i] > 1) {
				if(tuple[i] < 0) {
					tuple[i] = 0;
				}
				else {
					tuple[i] = 1;
				//System.out.println("Illegal rgb value: " + tuple[i]);
				}
			}

			tuple[i] = round(tuple[i]*255, 0);
		}

		return tuple;
	}
	
	/**
	 * Converts an XYZ tuple to an RGB one, altering the passed array to represent the output (discarding the input).
	 */
	private static void unsafeConvertXyzToRgb(float tuple[]) {
		float B, G, R;
		R = fromLinear(dotProduct(m[0], tuple, 3));
		G = fromLinear(dotProduct(m[1], tuple, 3));
		B = fromLinear(dotProduct(m[2], tuple, 3));

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
		float B, G, R, X, Y, Z;
		float rgbl[] = new float[3];

		R = tuple[0];
		G = tuple[1];
		B = tuple[2];

		rgbl[0] = toLinear(R);
		rgbl[1] = toLinear(G);
		rgbl[2] = toLinear(B);

		X = dotProduct(m_inv[0], rgbl, 3);
		Y = dotProduct(m_inv[1], rgbl, 3);
		Z = dotProduct(m_inv[2], rgbl, 3);

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
		float L, U, V, X, Y, Z, varU, varV;

		X = tuple[0];
		Y = tuple[1];
		Z = tuple[2];

		varU = 4 * X / (X + 15f * Y + 3 * Z);
		varV = 9 * Y / (X + 15f * Y + 3 * Z);
		if (0 == (L = 116 * f(Y / refY) - 16)) {
			tuple[0] = tuple[1] = tuple[2] = 0;
			return;
		}
		U = 13 * L * (varU - refU);
		V = 13 * L * (varV - refV);

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
		float L, U, V, X, Y, Z, varU, varV, varY;

		L = tuple[0];
		U = tuple[1];
		V = tuple[2];

		// Black will create a divide-by-zero error.
		if (L == 0) {
			tuple[2] = tuple[1] = tuple[0] = 0f;
			return;
		}

		varY = f_inv((L + 16) / 116f);
		varU = U / (13.0f * L) + refU;
		varV = V / (13.0f * L) + refV;
		Y = varY * refY;
		X = 0 - 9 * Y * varU / ((varU - 4.0f) * varV - varU * varV);
		Z = (9 * Y - 15 * varV * Y - varV * X) / (3f * varV);

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
		float C, H, Hrad, L, U, V;

		L = tuple[0];
		U = tuple[1];
		V = tuple[2];

		C = (float) Math.pow(Math.pow(U, 2) + Math.pow(V, 2), 1 / 2.0f);
		Hrad = (float) Math.atan2(V, U);
		H = (float) (Hrad * 360.0f / 2.0f / PI);
		if (H < 0) {
			H = 360 + H;
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
		float C, H, Hrad, L, U, V;

		L = tuple[0];
		C = tuple[1];
		H = tuple[2];

		Hrad = (float) (H / 360.0 * 2.0 * PI);
		U = (float) (Math.cos(Hrad) * C);
		V = (float) (Math.sin(Hrad) * C);

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
		float C, H, L, S, max;

		H = tuple[0];
		S = tuple[1];
		L = tuple[2];

		max = maxChroma(L, H);
		C = max / 100.0f * S;

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
		float C, H, L, S, max;

		L = tuple[0];
		C = tuple[1];
		H = tuple[2];

		max = maxChroma(L, H);
		S = C / max * 100;

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