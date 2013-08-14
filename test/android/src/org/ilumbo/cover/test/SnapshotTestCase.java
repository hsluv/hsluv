package org.ilumbo.cover.test;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import android.test.ActivityTestCase;
import android.util.JsonReader;
import android.util.JsonToken;

import com.boronine.husl.HuslConverter;

public final class SnapshotTestCase extends ActivityTestCase {
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
	public final void testSnapshotEquality() {
		// Load the stable snapshot.
		final Snapshot stableSnapshot = loadStableSnapshot();
		// Generate the "current" (or actual) snapshot.
		final Snapshot currentSnapshot = new Snapshot();
		final char[] hexadecimals = "0123456789ABCDEF".toCharArray();
		for (int red = 0; 16 != red; red++) {
			for (int green = 0; 16 != green; green++) {
				for (int blue = 0; 16 != blue; blue++) {
					final float rgb[] = new float[]{((red << 4) | red) / 255f, ((green << 4) | green) / 255f, ((blue << 4) | blue) / 255f};
					final float husl[] = HuslConverter.RGBtoHUSL(rgb[0], rgb[1], rgb[2]);
					currentSnapshot.addMember("#" + hexadecimals[red] + hexadecimals[red] + hexadecimals[green] + hexadecimals[green] + hexadecimals[blue] + hexadecimals[blue],
							new ColorData(rgb, null, null, null, husl, null));
				}
			}
		}
	}
}