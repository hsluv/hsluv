package org.ilumbo.cover.test;

public final class ColorDataBuffer {
	private static final class Pointer {
		public float[] array;
		public int index;
	}
	private float[] bufferedHusl;
	private float[] bufferedHuslp;
	private float[] bufferedLch;
	private float[] bufferedLuv;
	private float[] bufferedRgb;
	private float[] bufferedXyz;
	private Pointer pointer;
	public ColorDataBuffer() {
		pointer = new Pointer();
		reset();
	}
	/**
	 * Builds the color data using the pushed values, and then resets this buffer so it can be re-used.
	 */
	public final ColorData build() {
		final ColorData result = new ColorData(bufferedRgb, bufferedXyz, bufferedLuv, bufferedLch, bufferedHusl, bufferedHuslp);
		reset();
		return result;
	}
	private final void point(float[] array) {
		pointer.array = array;
		pointer.index = 0;
	}
	/**
	 * Indicates the array of the color data which will be pushed to next. One must point to every array exactly once.
	 */
	public final void point(String name) {
		if ("husl".equals(name)) {
			throwIfNotNull(name, bufferedHusl);
			point(bufferedHusl = new float[3]);
		} else if ("huslp".equals(name)) {
			throwIfNotNull(name, bufferedHuslp);
			point(bufferedHuslp = new float[3]);
		} else if ("lch".equals(name)) {
			throwIfNotNull(name, bufferedLch);
			point(bufferedLch = new float[3]);
		} else if ("luv".equals(name)) {
			throwIfNotNull(name, bufferedLuv);
			point(bufferedLuv = new float[3]);
		} else if ("rgb".equals(name)) {
			throwIfNotNull(name, bufferedRgb);
			point(bufferedRgb = new float[3]);
		} else if ("xyz".equals(name)) {
			throwIfNotNull(name, bufferedXyz);
			point(bufferedXyz = new float[3]);
		}
	}
	/**
	 * Adds a value to the array previously pointed to.
	 */
	public final void push(float value) {
		if (null == pointer.array) {
			throw new IllegalStateException();
		}
		// Might throw an IndexOutOfBoundsException. That's OK.
		pointer.array[pointer.index++] = value;
	}
	private final void reset() {
		pointer.array = null;
		bufferedHusl = null;
		bufferedHuslp = null;
		bufferedLch = null;
		bufferedLuv = null;
		bufferedRgb = null;
		bufferedXyz = null;
	}
	private final void throwIfNotNull(String name, float[] array) {
		if (null != array) {
			throw new IllegalStateException("\"" + name + "\" was already pointed to.");
		}
	}
}