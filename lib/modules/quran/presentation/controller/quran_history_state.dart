import 'package:equatable/equatable.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';
import 'package:islami/modules/quran/domain/services/sura_catalogue.dart';

/// Explicit state of the "Most Recently" strip (research.md R-006, constitution IV).
///
/// There is deliberately no `loading` status: the history is read during startup, so the
/// strip never has a spinner frame to render (FR-014, research R-005). [entries] is always
/// non-null and always between 1 and [ReadingHistory.maxEntries] items, so the widget
/// receiving this state has no branch that decides what to display.
enum QuranHistoryStatus {
  /// One or more suras were remembered.
  resolved,

  /// No remembered sura is usable, so the Al-Fatihah default is presented (FR-003, FR-015).
  fallback,
}

class QuranHistoryState extends Equatable {
  const QuranHistoryState._(this.status, this.entries);

  /// The reader's remembered suras, in the order they should be rendered.
  ///
  /// [entries] is non-empty and most recent first.
  factory QuranHistoryState.resolved(List<ReadingHistoryEntry> entries) {
    if (entries.isEmpty) {
      throw ArgumentError.value(
        entries,
        'entries',
        'A resolved state must carry at least one entry; use fallback instead',
      );
    }
    return QuranHistoryState._(
      QuranHistoryStatus.resolved,
      List<ReadingHistoryEntry>.unmodifiable(entries),
    );
  }

  /// The Al-Fatihah default, used when nothing is remembered or nothing was usable.
  factory QuranHistoryState.fallback() {
    return QuranHistoryState._(
      QuranHistoryStatus.fallback,
      List<ReadingHistoryEntry>.unmodifiable(<ReadingHistoryEntry>[
        ReadingHistoryEntry(suraNumber: SuraCatalogue.defaultSuraNumber),
      ]),
    );
  }

  final QuranHistoryStatus status;

  /// Unmodifiable, non-nullable, never empty, never longer than the history cap.
  final List<ReadingHistoryEntry> entries;

  @override
  List<Object?> get props => <Object?>[status, entries];
}
