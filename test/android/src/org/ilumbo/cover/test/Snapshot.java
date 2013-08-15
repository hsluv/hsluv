package org.ilumbo.cover.test;

import java.util.Iterator;

import android.util.SparseArray;

/**
 * A map which maps color strings (such as "##FFCC32") to color data objects.
 */
public final class Snapshot implements Iterable<Integer> {
	private final class SnapshotIterator implements Iterator<Integer> {
		private int index;
		private int length;
		public SnapshotIterator() {
			index = 0;
			length = members.size();
		}
		@Override
		public final boolean hasNext() {
			return index != length;
		}
		@Override
		public final Integer next() {
			return members.keyAt(index++);
		}
		@Override
		public final void remove() {
			throw new UnsupportedOperationException();
		}
	}
	private final SparseArray<ColorData> members;
	public Snapshot() {
		members = new SparseArray<ColorData>(4096);
	}
	public final void addMember(String colorString, ColorData data) {
		members.put(Integer.parseInt(colorString.substring(1), 0x10), data);
	}
	public final void addMember(int color, ColorData data) {
		members.put(color, data);
	}
	@Override
	public final Iterator<Integer> iterator() {
		return new SnapshotIterator();
	}
	public final ColorData getMember(String colorString) {
		return members.get(Integer.parseInt(colorString.substring(1)));
	}
	public final ColorData getMember(int color) {
		return members.get(color);
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