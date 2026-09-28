import 'package:equatable/equatable.dart';

/// One sura the reader opened, with the verse they last viewed in it.
class ReadingHistoryEntry extends Equatable {
  ReadingHistoryEntry({required this.suraNumber, this.lastVerse}) {
    if (suraNumber < 1) {
      throw ArgumentError.value(
        suraNumber,
        'suraNumber',
        'suraNumber MUST be >= 1',
      );
    }
    if (lastVerse != null && lastVerse! < 1) {
      throw ArgumentError.value(
        lastVerse,
        'lastVerse',
        'lastVerse, when present, MUST be >= 1',
      );
    }
  }

  /// 1-based ordinal identifying the sura, matching the catalogue's ordering.
  final int suraNumber;

  /// 1-based ordinal of the last verse viewed.
  ///
  /// `null` means the reader never viewed a verse in this sura. That is distinct from
  /// verse 1: `null` falls back to the start of the sura, while 1 records a real
  /// position (FR-010).
  final int? lastVerse;

  ReadingHistoryEntry copyWith({int? lastVerse, bool clearLastVerse = false}) {
    return ReadingHistoryEntry(
      suraNumber: suraNumber,
      lastVerse: clearLastVerse ? null : (lastVerse ?? this.lastVerse),
    );
  }

  @override
  List<Object?> get props => [suraNumber, lastVerse];
}
