# Contract: Reading History Store

**Layer**: `domain` (interface) implemented by `data` | **Status**: agreed

Defines how the reading history is read and written, per constitution III. The domain
declares the contract; the data layer owns the storage mechanism and converts every
failure into a `Failure` from `lib/core/errors/`.

## ReadingHistoryStore

```dart
abstract interface class ReadingHistoryStore {
  /// Loads the persisted reading history.
  ///
  /// Returns an empty history when nothing has been stored yet, or when the stored
  /// document is unreadable, malformed, of an unrecognised version, or fully
  /// irreconcilable with the current sura catalogue. These conditions are NOT errors:
  /// the reader sees the Al-Fatihah default instead (FR-003, FR-015).
  ///
  /// Completes with a [Failure] only when the underlying storage itself is
  /// unavailable, not when the stored bytes are bad.
  Future<ReadingHistory> load();

  /// Persists [history], replacing any previously stored document.
  ///
  /// Completes with a [Failure] if the write cannot be completed. Callers treat a failed
  /// write as non-fatal: the in-memory history stays correct for the current session and
  /// the reader is not shown an error (FR-015).
  ///
  /// Must be atomic with respect to the reader: a concurrent [load] observes either the
  /// whole previous document or the whole new one, never a partial one.
  Future<void> save(ReadingHistory history);
}
```

## Consumers

| Consumer | Uses | Why it needs the contract |
|----------|------|---------------------------|
| `GetReadingHistory` (domain use case) | `load` | Surfaces the history to the presentation layer. |
| `RecordSuraOpened` (domain use case) | `load`, `save` | Applies the capacity and uniqueness rules, then persists. |
| `RecordVerseViewed` (domain use case) | `load`, `save` | Updates only the touched entry's verse, then persists. |

## Constraints

- The interface MUST NOT expose the storage mechanism, its key name, or its serialisation
  format to `domain/` (constitution I).
- The interface MUST NOT expose `Dio`, `SharedPreferencesAsync`, or any other concrete
  client (constitution II, DIP).
- Implementations MUST tolerate an empty catalogue match by returning an empty history
  rather than throwing (FR-015).
- Implementations MUST NOT write more than one key per `save`, so a partial document is not
  representable.

## Test double

A hand-written in-memory implementation backed by a mutable string, so a test can assert
exactly what was written and can simulate corruption by pre-seeding bad bytes. No mocking
library is required, per constitution VI.
