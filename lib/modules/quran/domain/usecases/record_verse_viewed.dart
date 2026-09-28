import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/repositories/reading_history_store.dart';

/// Records the verse the reader has reached in a sura they are already reading (FR-012).
///
/// Replaces only the touched entry's `lastVerse`; a sura absent from the history is a no-op
/// so a stale scroll event cannot resurrect it. A failed write is non-fatal and leaves the
/// in-memory history correct for the session (FR-015).
class RecordVerseViewed {
  const RecordVerseViewed(this._store);

  final ReadingHistoryStore _store;

  Future<ReadingHistory> call(int suraNumber, int verse) async {
    final ReadingHistory current = await _loadOrEmpty();
    final ReadingHistory next = current.recordVerseViewed(suraNumber, verse);
    if (identical(next, current)) return current;
    await _saveQuietly(next);
    return next;
  }

  Future<ReadingHistory> _loadOrEmpty() async {
    try {
      return await _store.load();
    } on Failure {
      return ReadingHistory.empty();
    }
  }

  Future<void> _saveQuietly(ReadingHistory history) async {
    try {
      await _store.save(history);
    } on Failure {
      // Non-fatal by design (FR-015).
    }
  }
}
