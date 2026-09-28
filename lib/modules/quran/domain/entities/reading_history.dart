import 'package:equatable/equatable.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';

/// The ordered set of suras the reader opened, most recently opened first.
///
/// Immutable: every mutation returns a new instance, so a history handed to a caller can
/// never change underneath it. All four invariants from data-model.md are enforced here,
/// so no caller can build a history that breaks them:
///
/// - capacity: at most [maxEntries]; the least recently opened is discarded beyond that
/// - uniqueness: the same `suraNumber` never appears twice
/// - ordering: sorted most recently opened first
/// - immutability: updates produce a new instance
class ReadingHistory extends Equatable {
  const ReadingHistory._(this._entries);

  /// An empty history. The empty case is represented by the presentation layer's fallback
  /// state, not by rendering an empty list.
  factory ReadingHistory.empty() => const ReadingHistory._(<ReadingHistoryEntry>[]);

  /// Builds a history from [entries], normalising order, duplicates, and capacity.
  ///
  /// Input is treated as most-recent-first and is truncated to [maxEntries].
  factory ReadingHistory.from(List<ReadingHistoryEntry> entries) {
    return ReadingHistory._(_normalise(entries));
  }

  /// At most 5 suras retained; the least recently opened is discarded beyond that (FR-004).
  static const int maxEntries = 5;

  final List<ReadingHistoryEntry> _entries;

  /// Entries ordered most recently opened first. The returned list is unmodifiable.
  List<ReadingHistoryEntry> get entries => List<ReadingHistoryEntry>.unmodifiable(
    _entries,
  );

  bool get isEmpty => _entries.isEmpty;

  bool get isNotEmpty => _entries.isNotEmpty;

  int get length => _entries.length;

  /// The most recently opened sura (FR-007).
  ReadingHistoryEntry? get mostRecent =>
      _entries.isEmpty ? null : _entries.first;

  /// Returns a new history with [suraNumber] as the most recently opened sura.
  ///
  /// A sura already present is promoted to the front rather than duplicated, and the other
  /// entries keep their `lastVerse` values (FR-001, FR-005, FR-012, FR-013).
  ReadingHistory recordOpened(int suraNumber, {int? openingVerse}) {
    final List<ReadingHistoryEntry> next = <ReadingHistoryEntry>[];
    next.add(ReadingHistoryEntry(suraNumber: suraNumber, lastVerse: openingVerse));
    for (final ReadingHistoryEntry entry in _entries) {
      if (entry.suraNumber == suraNumber) continue;
      next.add(entry);
    }
    return ReadingHistory._(_cap(next));
  }

  /// Returns a new history with only [suraNumber]'s `lastVerse` replaced.
  ///
  /// Order and capacity are unchanged. A no-op when the sura is absent, so a scroll event
  /// for a sura that is no longer remembered does not resurrect it (FR-012).
  ReadingHistory recordVerseViewed(int suraNumber, int verse) {
    final int index = _entries.indexWhere(
      (ReadingHistoryEntry e) => e.suraNumber == suraNumber,
    );
    if (index == -1) return this;
    final List<ReadingHistoryEntry> next = List<ReadingHistoryEntry>.from(
      _entries,
    );
    next[index] = next[index].copyWith(lastVerse: verse);
    return ReadingHistory._(List<ReadingHistoryEntry>.unmodifiable(next));
  }

  /// The entry for [suraNumber], or `null` when it is not remembered.
  ReadingHistoryEntry? entryFor(int suraNumber) {
    for (final ReadingHistoryEntry entry in _entries) {
      if (entry.suraNumber == suraNumber) return entry;
    }
    return null;
  }

  /// Drops entries for suras that [isValid] rejects, preserving order (FR-015).
  ReadingHistory retainingWhere(bool Function(ReadingHistoryEntry) isValid) {
    return ReadingHistory._(
      List<ReadingHistoryEntry>.unmodifiable(
        _entries.where(isValid).toList(growable: false),
      ),
    );
  }

  static List<ReadingHistoryEntry> _normalise(
    List<ReadingHistoryEntry> entries,
  ) {
    final List<ReadingHistoryEntry> seen = <ReadingHistoryEntry>[];
    final Set<int> taken = <int>{};
    for (final ReadingHistoryEntry entry in entries) {
      if (!taken.add(entry.suraNumber)) continue;
      seen.add(entry);
    }
    return List<ReadingHistoryEntry>.unmodifiable(_cap(seen));
  }

  static List<ReadingHistoryEntry> _cap(List<ReadingHistoryEntry> entries) {
    if (entries.length <= maxEntries) {
      return List<ReadingHistoryEntry>.unmodifiable(entries);
    }
    return List<ReadingHistoryEntry>.unmodifiable(
      entries.sublist(0, maxEntries),
    );
  }

  @override
  List<Object?> get props => [_entries];
}
