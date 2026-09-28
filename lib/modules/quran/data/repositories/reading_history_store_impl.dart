import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/data/datasources/reading_history_local_datasource.dart';
import 'package:islami/modules/quran/data/models/reading_history_model.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/repositories/reading_history_store.dart';

/// Local-storage failure. Kept in `data` so nothing above the layer imports it.
class ReadingHistoryStorageFailure extends Failure {
  ReadingHistoryStorageFailure(super.message);
}

/// `ReadingHistoryStore` over on-device key-value storage.
///
/// Converts every storage exception into a [ReadingHistoryStorageFailure] so no raw
/// exception escapes the data layer (constitution III). Bad stored bytes are not an error:
/// they resolve to an empty history inside the model (FR-015).
class ReadingHistoryStoreImpl implements ReadingHistoryStore {
  const ReadingHistoryStoreImpl(this._dataSource);

  final ReadingHistoryLocalDataSource _dataSource;

  @override
  Future<ReadingHistory> load() async {
    try {
      final String? raw = await _dataSource.read();
      return ReadingHistoryModel.fromJsonString(raw).toDomain();
    } on Failure {
      rethrow;
    } catch (error) {
      throw ReadingHistoryStorageFailure("Unable to read reading history: $error");
    }
  }

  @override
  Future<void> save(ReadingHistory history) async {
    try {
      final String document = ReadingHistoryModel.fromDomain(history).toJsonString();
      await _dataSource.write(document);
    } on Failure {
      rethrow;
    } catch (error) {
      throw ReadingHistoryStorageFailure("Unable to save reading history: $error");
    }
  }
}
