import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/repositories/reading_history_store.dart';

/// Records that the reader opened a sura, making it the most recent entry (FR-001, FR-012).
///
/// A failed write is non-fatal: the returned history is still correct for the current
/// session and the reader is never shown an error (FR-015).
class RecordSuraOpened {
  const RecordSuraOpened(this._store);

  final ReadingHistoryStore _store;

  Future<ReadingHistory> call(int suraNumber, {int? openingVerse}) async {
    final ReadingHistory current = await _loadOrEmpty();
    final ReadingHistory next = current.recordOpened(suraNumber, openingVerse: openingVerse);
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
