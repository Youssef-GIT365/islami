import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the reading history document under a single key.
///
/// Uses `SharedPreferencesAsync` rather than the legacy `SharedPreferences` class, which
/// the package documents as slated for deprecation. The client is injected so it is
/// constructed once in the composition root, never inside a feature (constitution V).
class ReadingHistoryLocalDataSource {
  const ReadingHistoryLocalDataSource(this._prefs);

  final SharedPreferencesAsync _prefs;

  /// The stored document, or `null` when nothing has been written.
  ///
  /// Throws whatever the platform throws, which the repository converts to a `Failure`.
  Future<String?> read() => _prefs.getString(_key);

  /// Replaces the stored document in a single write, so a concurrent read observes either
  /// the whole previous document or the whole new one.
  Future<void> write(String document) => _prefs.setString(_key, document);

  static const String _key = 'quran_reading_history_v1';
}
