import 'package:islami/modules/quran/suras/sura_model.dart';

/// Read-only view over the sura catalogue already used by the Quran list.
///
/// The catalogue lives as mutable top-level lists in `sura_model.dart`. Constitution I
/// forbids new code depending on mutable global state, so this facade exposes unmodifiable
/// views and lookup helpers instead. The raw lists are left in place; consolidating them
/// into a proper catalogue is a separate refactor (see plan.md, Complexity Tracking).
abstract final class SuraCatalogue {
  /// Number of suras in the catalogue. Sura numbers are 1-based, matching list order.
  static const int length = 114;

  /// Ordinal of the sura shown when the reader has no remembered sura, or when stored
  /// data cannot be used. Al-Fatihah is the first sura.
  static const int defaultSuraNumber = 1;

  static final List<String> _arabicNames = List<String>.unmodifiable(
    arabicAuranSuras,
  );

  static final List<String> _englishNames = List<String>.unmodifiable(
    englishQuranSurahs,
  );

  static final List<int> _verseCounts = List<int>.unmodifiable(
    AyaNumber.map(int.parse),
  );

  static List<String> get arabicNames => _arabicNames;

  static List<String> get englishNames => _englishNames;

  static List<int> get verseCounts => _verseCounts;

  /// Whether [suraNumber] identifies a sura in the current catalogue.
  static bool contains(int suraNumber) =>
      suraNumber >= 1 && suraNumber <= _verseCounts.length;

  /// Verse count of [suraNumber], or 0 when the sura is unknown.
  static int verseCountOf(int suraNumber) =>
      contains(suraNumber) ? _verseCounts[suraNumber - 1] : 0;

  /// Arabic name of [suraNumber], or an empty string when the sura is unknown.
  static String arabicNameOf(int suraNumber) =>
      contains(suraNumber) ? _arabicNames[suraNumber - 1] : '';

  /// English name of [suraNumber], or an empty string when the sura is unknown.
  static String englishNameOf(int suraNumber) =>
      contains(suraNumber) ? _englishNames[suraNumber - 1] : '';

  /// Clamps [verse] into `1..verseCount` for [suraNumber].
  ///
  /// An unknown sura resolves to 1 so callers never have to pre-validate (FR-010, FR-020).
  static int clampVerse(int suraNumber, int verse) {
    final int count = verseCountOf(suraNumber);
    if (count <= 0) return 1;
    if (verse < 1) return 1;
    if (verse > count) return count;
    return verse;
  }
}
