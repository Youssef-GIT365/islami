import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/data/models/reading_history_model.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/repositories/reading_history_store.dart';

/// In-memory `ReadingHistoryStore` for tests.
///
/// Backed by a raw string so a test can pre-seed corrupt bytes via [seedRaw] and assert
/// the exact document written via [savedDocuments]. No mocking library is used, per
/// constitution VI.
class FakeReadingHistoryStore implements ReadingHistoryStore {
  FakeReadingHistoryStore({this.failOnLoad = false, this.failOnSave = false});

  /// When true, [load] completes with a `Failure` instead of a history.
  bool failOnLoad;

  /// When true, [save] completes with a `Failure` instead of writing.
  bool failOnSave;

  String? _raw;

  /// Every document passed to [save], in order.
  final List<String> savedDocuments = <String>[];

  /// Number of times [load] was called.
  int loadCount = 0;

  /// Pre-seeds the stored document, bypassing serialisation.
  ///
  /// Pass malformed JSON, a wrong `version`, or a document referencing an impossible sura
  /// to exercise the reconciliation rules.
  void seedRaw(String? raw) {
    _raw = raw;
  }

  @override
  Future<ReadingHistory> load() async {
    loadCount++;
    if (failOnLoad) {
      throw DataBaseFailure("storage unavailable");
    }
    final String? raw = _raw;
    if (raw == null) return ReadingHistory.empty();
    return ReadingHistoryModel.fromJsonString(raw).toDomain();
  }

  @override
  Future<void> save(ReadingHistory history) async {
    if (failOnSave) {
      throw DataBaseFailure("write rejected");
    }
    final String document = ReadingHistoryModel.fromDomain(history).toJsonString();
    _raw = document;
    savedDocuments.add(document);
  }
}
