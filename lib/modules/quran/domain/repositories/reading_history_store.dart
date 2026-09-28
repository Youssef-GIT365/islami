import 'package:islami/modules/quran/domain/entities/reading_history.dart';

/// Persistence contract for the reader's sura history.
///
/// Declared in `domain` and implemented in `data`, so the presentation layer never learns
/// how the history is stored. This interface deliberately exposes no storage client, no
/// key name, and no serialisation format (constitution I, II).
abstract interface class ReadingHistoryStore {
  /// Loads the persisted reading history.
  ///
  /// Returns an empty history when nothing has been stored yet, and equally when the
  /// stored document is unreadable, malformed, of an unrecognised version, or fully
  /// irreconcilable with the current sura catalogue. Those are not errors: the reader
  /// sees the Al-Fatihah default instead (FR-003, FR-015).
  ///
  /// Completes with a `Failure` only when the underlying storage itself is unavailable,
  /// never when the stored bytes are merely bad.
  Future<ReadingHistory> load();

  /// Persists [history], replacing any previously stored document.
  ///
  /// Completes with a `Failure` if the write cannot be completed. Callers treat a failed
  /// write as non-fatal: the in-memory history stays correct for the current session and
  /// the reader is not shown an error (FR-015).
  ///
  /// Implementations must be atomic with respect to the reader: a concurrent [load]
  /// observes either the whole previous document or the whole new one, never a partial
  /// one.
  Future<void> save(ReadingHistory history);
}
