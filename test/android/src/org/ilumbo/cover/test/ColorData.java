package org.ilumbo.cover.test;

public final class ColorData {
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
		return new StringBuilder(32)
			.append("[h:")
			.append(husl[0])
			.append(" s:")
			.append(husl[1])
			.append(" l:")
			.append(husl[2])
			.append("]")
			.toString();
	}
}