package org.ilumbo.cover.test;

public final class ColorData {
	public static final int PROPERTIES_RGB = 0;
	public static final int PROPERTIES_RGB_XYZ = 1;
	public static final int PROPERTIES_RGB_THROUGH_LUV = 2;
	public static final int PROPERTIES_RGB_THROUGH_LCH = 3;
	public static final int PROPERTIES_RGB_THROUGH_HUSL = 4;
	public static final int PROPERTIES_RGB_THROUGH_HUSL_HUSLP = 5;
	public final float[] husl;
	public final float[] huslp;
	public final float[] lch;
	public final float[] luv;
	public final float[] rgb;
	public final float[] xyz;
	public ColorData(float[] rgb, float[] xyz, float[] luv, float[] lch, float[] husl, float[] huslp) {
		this.rgb = rgb;
		this.xyz = xyz;
		this.luv = luv;
		this.lch = lch;
		this.husl = husl;
		this.huslp = huslp;
	}
	@Override
	public final String toString() {
		return toString(Integer.MAX_VALUE);
	}
	/**
	 * Returns a string representation, containing the passed properties.
	 */
	public final String toString(int properties) {
		final StringBuilder resultBuilder = new StringBuilder(64)
			.append("[");
		if (properties >= PROPERTIES_RGB) {
			resultBuilder.append("[r: ")
				.append(rgb[0])
				.append(", g: ")
				.append(rgb[1])
				.append(", b: ")
				.append(rgb[2])
				.append("]");
			if (properties >= PROPERTIES_RGB_XYZ) {
				resultBuilder.append(" ↔ [x: ")
					.append(xyz[0])
					.append(", y: ")
					.append(xyz[1])
					.append(", z: ")
					.append(xyz[2])
					.append("]");
				if (properties >= PROPERTIES_RGB_THROUGH_LUV) {
					resultBuilder.append(" ↔ [l: ")
						.append(luv[0])
						.append(", u: ")
						.append(luv[1])
						.append(", v: ")
						.append(luv[2])
						.append("]");
					if (properties >= PROPERTIES_RGB_THROUGH_LCH) {
						resultBuilder.append(" ↔ [l: ")
							.append(lch[0])
							.append(", c: ")
							.append(lch[1])
							.append(", h: ")
							.append(lch[2])
							.append("]");
						if (properties >= PROPERTIES_RGB_THROUGH_HUSL) {
							resultBuilder.append(" ↔ [h: ")
								.append(husl[0])
								.append(", s: ")
								.append(husl[1])
								.append(", l: ")
								.append(husl[2])
								.append("]");
							if (properties >= PROPERTIES_RGB_THROUGH_HUSL_HUSLP) {
								resultBuilder.append(" ∨ [h: ")
									.append(huslp[0])
									.append(", s: ")
									.append(huslp[1])
									.append(", l: ")
									.append(huslp[2])
									.append("]");
							}
						}
					}
				}
			}
		}
		return resultBuilder.append("]")
				.toString();
	}
}