import 'package:flutter_test/flutter_test.dart';
import 'package:islami/core/errors/failer.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/usecases/get_reading_history.dart';
import 'package:islami/modules/quran/domain/usecases/record_sura_opened.dart';

import '../fakes/fake_reading_history_store.dart';

void main() {
  group('RecordSuraOpened', () {
    test('returns the updated history and persists it', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      final RecordSuraOpened useCase = RecordSuraOpened(store);

      final ReadingHistory history = await useCase(2, openingVerse: 12);

      expect(history.length, 1);
      expect(history.mostRecent?.suraNumber, 2);
      expect(store.savedDocuments, hasLength(1));
    });

    test('promotes a re-opened sura without duplicating it (FR-005)', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      final RecordSuraOpened useCase = RecordSuraOpened(store);

      await useCase(2, openingVerse: 12);
      await useCase(36, openingVerse: 5);
      await useCase(1, openingVerse: 1);
      final ReadingHistory history = await useCase(2, openingVerse: 30);

      expect(history.length, 3, reason: 'no duplicate created');
      expect(history.mostRecent?.suraNumber, 2);
      expect(history.mostRecent?.lastVerse, 30);
      expect(history.entryFor(36)?.lastVerse, 5, reason: 'other entries preserved');
      expect(history.entryFor(1)?.lastVerse, 1);
    });

    test('discards the least recent beyond the cap (FR-004)', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      final RecordSuraOpened useCase = RecordSuraOpened(store);

      ReadingHistory history = ReadingHistory.empty();
      for (int i = 1; i <= 7; i++) {
        history = await useCase(i);
      }

      expect(history.length, ReadingHistory.maxEntries);
      expect(history.entryFor(1), isNull, reason: 'least recent is dropped');
      expect(history.mostRecent?.suraNumber, 7);
    });

    test('records a sura opened with no verse as unrecorded (FR-010)', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      final ReadingHistory history = await RecordSuraOpened(store)(2);

      expect(history.mostRecent?.lastVerse, isNull);
    });

    test('a failed save does not throw and the result is still correct', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore(
        failOnSave: true,
      );
      final RecordSuraOpened useCase = RecordSuraOpened(store);

      ReadingHistory? history;
      await expectLater(
        useCase(2, openingVerse: 8).then((ReadingHistory h) => history = h),
        completes,
      );

      expect(history?.mostRecent?.suraNumber, 2,
          reason: 'non-fatal: session state stays correct (FR-015)');
      expect(store.savedDocuments, isEmpty);
    });

    test('a failed load does not throw and starts from empty', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore(
        failOnLoad: true,
      );
      final RecordSuraOpened useCase = RecordSuraOpened(store);

      ReadingHistory? history;
      await expectLater(
        useCase(2, openingVerse: 8).then((ReadingHistory h) => history = h),
        completes,
      );

      expect(history?.mostRecent?.suraNumber, 2);
    });
  });

  group('GetReadingHistory', () {
    test('returns what the store holds', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      await RecordSuraOpened(store)(2, openingVerse: 12);

      final ReadingHistory history = await GetReadingHistory(store)();
      expect(history.mostRecent?.suraNumber, 2);
      expect(store.loadCount, greaterThan(0));
    });

    test('propagates a storage failure to the caller', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore(
        failOnLoad: true,
      );
      await expectLater(
        GetReadingHistory(store)(),
        throwsA(isA<Failure>()),
      );
    });
  });
}
