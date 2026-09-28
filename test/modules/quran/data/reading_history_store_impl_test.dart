import 'package:flutter_test/flutter_test.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/data/datasources/reading_history_local_datasource.dart';
import 'package:islami/modules/quran/data/repositories/reading_history_store_impl.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';
import 'package:islami/modules/quran/domain/repositories/reading_history_store.dart';

/// Records writes so the repository's single-key contract can be asserted.
///
/// `SharedPreferencesAsync` has no test seam in this package version (the legacy
/// `setMockInitialValues` does not cover it), which is why the data source is written
/// against an injected client and exercised through this fake rather than against the
/// real plugin (constitution V and VI).
class _RecordingDataSource implements ReadingHistoryLocalDataSource {
  String? stored;
  final List<String> writes = <String>[];
  Object? readError;
  Object? writeError;

  @override
  Future<String?> read() async {
    if (readError != null) throw readError!;
    return stored;
  }

  @override
  Future<void> write(String document) async {
    if (writeError != null) throw writeError!;
    writes.add(document);
    stored = document;
  }
}

void main() {
  group('ReadingHistoryStoreImpl', () {
    late _RecordingDataSource dataSource;
    late ReadingHistoryStoreImpl store;

    setUp(() {
      dataSource = _RecordingDataSource();
      store = ReadingHistoryStoreImpl(dataSource);
    });

    test('is a ReadingHistoryStore', () {
      expect(store, isA<ReadingHistoryStore>());
    });

    test('load returns an empty history when nothing is stored', () async {
      final ReadingHistory history = await store.load();
      expect(history.isEmpty, isTrue);
    });

    test('save writes exactly one document', () async {
      await store.save(ReadingHistory.empty().recordOpened(2, openingVerse: 12));
      expect(dataSource.writes, hasLength(1));
    });

    test('save then load round-trips the history', () async {
      await store.save(
        ReadingHistory.empty()
            .recordOpened(36, openingVerse: 4)
            .recordOpened(2),
      );

      final ReadingHistory restored = await store.load();
      expect(restored.mostRecent?.suraNumber, 2);
      expect(restored.entryFor(36)?.lastVerse, 4);
    });

    test('a stored document with bad bytes loads as empty, not an error', () async {
      dataSource.stored = '{ this is not json';
      final ReadingHistory history = await store.load();
      expect(history.isEmpty, isTrue);
    });

    test('a read failure surfaces as a Failure, not a raw exception', () async {
      dataSource.readError = StateError('platform channel down');
      await expectLater(store.load(), throwsA(isA<Failure>()));
    });

    test('a write failure surfaces as a Failure, not a raw exception', () async {
      dataSource.writeError = StateError('disk full');
      await expectLater(
        store.save(ReadingHistory.empty().recordOpened(2)),
        throwsA(isA<Failure>()),
      );
    });

    test('an entry survives a store round-trip with its verse intact', () async {
      await store.save(
        ReadingHistory.empty()
            .recordOpened(1, openingVerse: 3)
            .recordOpened(2, openingVerse: 4)
            .recordOpened(3, openingVerse: 5),
      );

      final List<ReadingHistoryEntry> entries = (await store.load()).entries;
      expect(entries, hasLength(3));
      expect(
        entries.map((ReadingHistoryEntry e) => e.lastVerse).toList(),
        <int>[5, 4, 3],
      );
    });

    test('an unrecognised stored version loads as empty', () async {
      dataSource.stored = '{"version":42,"entries":[{"suraNumber":2,"lastVerse":1}]}';
      expect((await store.load()).isEmpty, isTrue);
    });
  });
}
