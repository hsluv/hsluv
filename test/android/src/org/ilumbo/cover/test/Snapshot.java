package org.ilumbo.cover.test;

import android.util.SparseArray;

/**
 * A map which maps color strings (such as "##FFCC32") to color data objects.
 */
public final class Snapshot {
	private final SparseArray<ColorData> members;
	public Snapshot() {
		members = new SparseArray<ColorData>(4096);
	}
	public final void addMember(String colorString, ColorData data) {
		members.put(Integer.parseInt(colorString.substring(1), 0x10), data);
	}
	@Override
	public final String toString() {
		final StringBuilder resultBuilder = new StringBuilder(1024)
			.append("[");
		final int memberCount = members.size();
		for (int index = 0; memberCount != index; index++) {
			resultBuilder.append("[#");
			final String hexKey = Integer.toHexString(members.keyAt(index));
			int missingCharacterCount = 6 - hexKey.length();
			while (0 != missingCharacterCount--) {
				resultBuilder.append("0");
			}
			resultBuilder.append(hexKey)
				.append(": ")
				.append(members.valueAt(index).toString())
				.append("]");
			if (index + 1 != memberCount) {
				resultBuilder.append(", ");
			}
			// Return only the first 10 members. Otherwise, things take way too long.
			if (9 == index) {
				resultBuilder.append("…");
				break;
			}
		}
		return resultBuilder.append("]")
				.toString();
	}
}