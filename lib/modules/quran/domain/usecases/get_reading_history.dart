import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/repositories/reading_history_store.dart';

/// Surfaces the reader's sura history to the presentation layer.
class GetReadingHistory {
  const GetReadingHistory(this._store);

  final ReadingHistoryStore _store;

  Future<ReadingHistory> call() => _store.load();
}
