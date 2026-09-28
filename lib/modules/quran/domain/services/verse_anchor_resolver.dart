/// Resolves which verse is at a given scroll offset.
///
/// A pure lookup over the per-verse offset table built by the presentation layer
/// (research.md R-001). This file deliberately imports neither `flutter/` nor `dart:ui`,
/// so the whole of the verse-anchor behaviour is unit-testable without a widget tree
/// (constitution I and V).
///
/// The rule: the visible verse is the last entry whose offset is `<= scrollOffset`, clamped
/// into `1..verseCount`. Arabic verses vary from a few words to several lines, so the
/// offsets are uneven and a uniform estimate would drift badly in long suras.
abstract final class VerseAnchorResolver {
  /// The verse visible at [scrollOffset], as a 1-based ordinal.
  ///
  /// Returns 1 when the table is empty, the offset is negative, or nothing is resolved yet,
  /// and [verseCount] when the offset is past the end of the sura (FR-010, FR-020).
  static int visibleVerse({
    required List<double> offsets,
    required double scrollOffset,
    required int verseCount,
  }) {
    if (verseCount <= 0 || offsets.isEmpty) return 1;

    // Binary search for the last offset that is at or above the scroll position.
    int low = 0;
    int high = offsets.length - 1;
    int resolved = 0;
    while (low <= high) {
      final int mid = low + ((high - low) >> 1);
      if (offsets[mid] <= scrollOffset) {
        resolved = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    final int verse = resolved + 1;
    if (verse < 1) return 1;
    if (verse > verseCount) return verseCount;
    return verse;
  }
}
