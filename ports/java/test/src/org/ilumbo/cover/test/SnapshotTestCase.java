package org.ilumbo.cover.test;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import android.test.ActivityTestCase;
import android.util.JsonReader;
import android.util.JsonToken;

import com.boronine.husl.HuslConverter;

public final class SnapshotTestCase extends ActivityTestCase {
	/**
	 * The "current" (or actual) snapshot.
	 */
	private Snapshot currentSnapshot;
	/**
	 * The "stable" (or expected) snapshot.
	 */
	private Snapshot stableSnapshot;
	private final Snapshot loadStableSnapshot() {
		// Get the stream that reads the stable snapshot file.
		final InputStream inputStream = getInstrumentation().getContext().getResources().openRawResource(R.raw.snapshot);
		// Create a reader that reads the stable snapshot file and decodes it as JSON.
		final JsonReader inputReader = new JsonReader(new InputStreamReader(inputStream));
		// Turn the JSON into an object.
		final Snapshot snapshot = new Snapshot();
		try {
			inputReader.beginObject();
			final ColorDataBuffer colorDataBuffer = new ColorDataBuffer();
			while (JsonToken.END_OBJECT != inputReader.peek()) {
				final String colorString = inputReader.nextName();
				inputReader.beginObject();
				while (JsonToken.END_OBJECT != inputReader.peek()) {
					colorDataBuffer.point(inputReader.nextName());
					inputReader.beginArray();
					while (JsonToken.END_ARRAY != inputReader.peek()) {
						colorDataBuffer.push((float) inputReader.nextDouble());
					}
					inputReader.endArray();
				}
				snapshot.addMember(colorString, colorDataBuffer.build());
				inputReader.endObject();
			}
			inputReader.endObject();
		} catch (IOException exception) {
			exception.printStackTrace();
		}
		return snapshot;
	}
	@Override
	protected final void setUp() throws Exception {
		if (null != stableSnapshot && null != currentSnapshot) {
			return;
		}
		// Load the stable snapshot.
		stableSnapshot = loadStableSnapshot();
		// Generate the "current" (or actual) snapshot.
		currentSnapshot = new Snapshot();
		final char[] hexadecimals = "0123456789ABCDEF".toCharArray();
		for (int red = 0; 16 != red; red++) {
			for (int green = 0; 16 != green; green++) {
				for (int blue = 0; 16 != blue; blue++) {
					final String rgbString = new StringBuilder(7)
						.append("#")
						.append(hexadecimals[red]).append(hexadecimals[red])
						.append(hexadecimals[green]).append(hexadecimals[green])
						.append(hexadecimals[blue]).append(hexadecimals[blue])
						.toString();
					final float rgb[] = new float[]{((red << 4) | red) / 255f, ((green << 4) | green) / 255f, ((blue << 4) | blue) / 255f};
					final float xyz[] = HuslConverter.convertRgbToXyz(rgb);
					final float luv[] = HuslConverter.convertXyzToLuv(xyz);
					final float lch[] = HuslConverter.convertLuvToLch(luv);
					final float husl[] = HuslConverter.convertLchToHusl(lch);
					// The Java port doesn't convert to HUSLp, so simply use the HUSL value. This will cause the test to fail.
					final float huslp[] = husl;
					currentSnapshot.addMember(rgbString,
							new ColorData(rgb, xyz, luv, lch, husl, huslp));
				}
			}
		}
	}
	public final void testStep0Rgb() {
		// This is kind-of a sanity check.
		for (final int color : currentSnapshot) {
			final ColorData stable = stableSnapshot.getMember(color);
			String message = "color: " + Integer.toHexString(color);
			assertNotNull(message, stable);
			final ColorData current = currentSnapshot.getMember(color);
			message += ", current: " + current.toString(ColorData.PROPERTIES_RGB);
			assertEquals(message, stable.rgb[0], current.rgb[0], 1e-3f);
			assertEquals(message, stable.rgb[1], current.rgb[1], 1e-3f);
			assertEquals(message, stable.rgb[2], current.rgb[2], 1e-3f);
		}
	}
	public final void testStep1Xyz() {
		for (final int color : currentSnapshot) {
			final ColorData stable = stableSnapshot.getMember(color);
			String message = "color: " + Integer.toHexString(color);
			assertNotNull(message, stable);
			final ColorData current = currentSnapshot.getMember(color);
			message += ", current: " + current.toString(ColorData.PROPERTIES_RGB_XYZ);
			assertEquals(message, stable.xyz[0], current.xyz[0], 1e-3f);
			assertEquals(message, stable.xyz[1], current.xyz[1], 1e-3f);
			assertEquals(message, stable.xyz[2], current.xyz[2], 1e-3f);
		}
	}
	public final void testStep2Luv() {
		for (final int color : currentSnapshot) {
			final ColorData stable = stableSnapshot.getMember(color);
			String message = "color: " + Integer.toHexString(color);
			assertNotNull(message, stable);
			final ColorData current = currentSnapshot.getMember(color);
			message += ", current: " + current.toString(ColorData.PROPERTIES_RGB_THROUGH_LUV);
			assertEquals(message, stable.luv[0], current.luv[0], 1e-1f);
			assertEquals(message, stable.luv[1], current.luv[1], 1e-1f);
			assertEquals(message, stable.luv[2], current.luv[2], 1e-1f);
		}
	}
	public final void testStep3Lch() {
		for (final int color : currentSnapshot) {
			final ColorData stable = stableSnapshot.getMember(color);
			String message = "Color: " + Integer.toHexString(color);
			assertNotNull(message, stable);
			final ColorData current = currentSnapshot.getMember(color);
			message += ", current: " + current.toString(ColorData.PROPERTIES_RGB_THROUGH_LCH);
			assertEquals(message, stable.lch[0], current.lch[0], 1e-1f);
			assertEquals(message, stable.lch[1], current.lch[1], 1e-1f);
			assertEquals(message, stable.lch[2], current.lch[2], 1e-1f);
		}
	}
	public final void testStep4Husl() {
		for (final int color : currentSnapshot) {
			final ColorData stable = stableSnapshot.getMember(color);
			String message = "Color: " + Integer.toHexString(color);
			assertNotNull(message, stable);
			final ColorData current = currentSnapshot.getMember(color);
			message += ", current: " + current.toString(ColorData.PROPERTIES_RGB_THROUGH_HUSL);
			assertEquals(message, stable.husl[0], current.husl[0], 1e-1f);
			assertEquals(message, stable.husl[1], current.husl[1], 1e-1f);
			assertEquals(message, stable.husl[2], current.husl[2], 1e-1f);
		}
	}
	public final void testStep4Huslp() {
		for (final int color : currentSnapshot) {
			final ColorData stable = stableSnapshot.getMember(color);
			String message = "Color: " + Integer.toHexString(color);
			assertNotNull(message, stable);
			final ColorData current = currentSnapshot.getMember(color);
			message += ", current: " + current.toString(ColorData.PROPERTIES_RGB_THROUGH_HUSL_HUSLP);
			assertEquals(message, stable.huslp[0], current.huslp[0], 1e-3f);
			assertEquals(message, stable.huslp[1], current.huslp[1], 1e-3f);
			assertEquals(message, stable.huslp[2], current.huslp[2], 1e-3f);
		}
	}
}