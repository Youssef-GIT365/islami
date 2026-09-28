import 'package:flutter_test/flutter_test.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';
import 'package:islami/modules/quran/domain/services/sura_catalogue.dart';
import 'package:islami/modules/quran/domain/usecases/get_reading_history.dart';
import 'package:islami/modules/quran/presentation/controller/quran_history_cubit.dart';
import 'package:islami/modules/quran/presentation/controller/quran_history_state.dart';

import '../fakes/fake_reading_history_store.dart';

/// Builds the Cubit the way the composition root does: the preloaded value supplies the
/// synchronous initial state, and the use case is used for later refreshes.
QuranHistoryCubit buildCubit(FakeReadingHistoryStore store) {
  return QuranHistoryCubit(
    getReadingHistory: GetReadingHistory(store),
    preloaded: ReadingHistory.empty(),
  );
}

void main() {
  group('QuranHistoryState', () {
    test('resolved carries the entries it was given', () {
      final QuranHistoryState state = QuranHistoryState.resolved(<ReadingHistoryEntry>[
        ReadingHistoryEntry(suraNumber: 2, lastVerse: 12),
        ReadingHistoryEntry(suraNumber: 1),
      ]);

      expect(state.status, QuranHistoryStatus.resolved);
      expect(state.entries, hasLength(2));
      expect(state.entries.first.suraNumber, 2);
    });

    test('resolved rejects an empty entry list', () {
      expect(
        () => QuranHistoryState.resolved(const <ReadingHistoryEntry>[]),
        throwsArgumentError,
      );
    });

    test('fallback carries exactly the Al-Fatihah entry (FR-003)', () {
      final QuranHistoryState state = QuranHistoryState.fallback();

      expect(state.status, QuranHistoryStatus.fallback);
      expect(state.entries, hasLength(1));
      expect(state.entries.single.suraNumber, SuraCatalogue.defaultSuraNumber);
    });

    test('entries are never null and never grow (FR-004)', () {
      for (final QuranHistoryState state in <QuranHistoryState>[
        QuranHistoryState.fallback(),
        QuranHistoryState.resolved(<ReadingHistoryEntry>[
          ReadingHistoryEntry(suraNumber: 3),
        ]),
      ]) {
        expect(state.entries, isNotNull);
        expect(state.entries.length, inInclusiveRange(1, ReadingHistory.maxEntries));
      }
    });

    test('the exposed list cannot be mutated', () {
      final QuranHistoryState state = QuranHistoryState.fallback();
      expect(
        () => state.entries.add(ReadingHistoryEntry(suraNumber: 5)),
        throwsUnsupportedError,
      );
    });

    test('equality is by status and entries', () {
      expect(QuranHistoryState.fallback(), QuranHistoryState.fallback());
      expect(
        QuranHistoryState.resolved(<ReadingHistoryEntry>[
          ReadingHistoryEntry(suraNumber: 2),
        ]),
        QuranHistoryState.resolved(<ReadingHistoryEntry>[
          ReadingHistoryEntry(suraNumber: 2),
        ]),
      );
      expect(
        QuranHistoryState.fallback(),
        isNot(QuranHistoryState.resolved(<ReadingHistoryEntry>[
          ReadingHistoryEntry(suraNumber: 1),
        ])),
      );
    });
  });

  group('QuranHistoryCubit initial state', () {
    test('starts resolved when the preloaded history has entries', () {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      final QuranHistoryCubit cubit = QuranHistoryCubit(
        getReadingHistory: GetReadingHistory(store),
        preloaded: ReadingHistory.empty().recordOpened(2, openingVerse: 12),
      );

      expect(cubit.state.status, QuranHistoryStatus.resolved);
      expect(cubit.state.entries.first.suraNumber, 2);
      expect(cubit.state.entries.first.lastVerse, 12);
      cubit.close();
    });

    test('starts in fallback when nothing is preloaded', () {
      final QuranHistoryCubit cubit = buildCubit(FakeReadingHistoryStore());

      expect(cubit.state.status, QuranHistoryStatus.fallback);
      expect(
        cubit.state.entries.single.suraNumber,
        SuraCatalogue.defaultSuraNumber,
      );
      cubit.close();
    });

    test('never emits a loading state, from construction through refresh', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      final QuranHistoryCubit cubit = buildCubit(store);

      final List<QuranHistoryStatus> seen = <QuranHistoryStatus>[];
      cubit.stream.listen((QuranHistoryState s) => seen.add(s.status));

      expect(cubit.state.status, isNotNull, reason: 'has a state immediately');

      await cubit.refresh();

      // A loading status does not exist, so none can be emitted (FR-014).
      expect(QuranHistoryStatus.values, hasLength(2));
      expect(
        seen.toSet(),
        everyElement(
          isIn(<QuranHistoryStatus>[
            QuranHistoryStatus.resolved,
            QuranHistoryStatus.fallback,
        ]),
        ),
      );
      cubit.close();
    });

    test('the state is available synchronously, before any await', () {
      final QuranHistoryCubit cubit = buildCubit(FakeReadingHistoryStore());
      expect(cubit.state.entries, isNotEmpty, reason: 'FR-014: no spinner frame');
      cubit.close();
    });
  });

  group('QuranHistoryCubit refresh', () {
    test('resolves to the stored entries', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      await store.save(
        ReadingHistory.empty().recordOpened(36, openingVerse: 5).recordOpened(2),
      );

      final QuranHistoryCubit cubit = buildCubit(store);
      await cubit.refresh();

      expect(cubit.state.status, QuranHistoryStatus.resolved);
      expect(cubit.state.entries.map((ReadingHistoryEntry e) => e.suraNumber).toList(),
          <int>[2, 36]);
      expect(cubit.state.entries.last.lastVerse, 5);
      cubit.close();
    });

    test('resolves to fallback when the store is empty', () async {
      final QuranHistoryCubit cubit = buildCubit(FakeReadingHistoryStore());
      await cubit.refresh();

      expect(cubit.state.status, QuranHistoryStatus.fallback);
      expect(
        cubit.state.entries.single.suraNumber,
        SuraCatalogue.defaultSuraNumber,
      );
      cubit.close();
    });

    test('resolves to fallback when the store throws (FR-015)', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore(
        failOnLoad: true,
      );
      final QuranHistoryCubit cubit = buildCubit(store);

      await expectLater(cubit.refresh(), completes);
      expect(cubit.state.status, QuranHistoryStatus.fallback);
      expect(
        cubit.state.entries.single.suraNumber,
        SuraCatalogue.defaultSuraNumber,
      );
      cubit.close();
    });

    test('resolves to fallback when stored data is unusable (FR-015)', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      store.seedRaw('{"version":99,"entries":[]}');

      final QuranHistoryCubit cubit = buildCubit(store);
      await cubit.refresh();

      expect(cubit.state.status, QuranHistoryStatus.fallback);
      cubit.close();
    });

    test('a newly opened sura becomes the centred first entry (FR-001)', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      final QuranHistoryCubit cubit = buildCubit(store);

      await store.save(ReadingHistory.empty().recordOpened(2, openingVerse: 1));
      await cubit.refresh();
      await store.save(
        ReadingHistory.empty().recordOpened(2, openingVerse: 1).recordOpened(18),
      );
      await cubit.refresh();

      expect(cubit.state.entries.first.suraNumber, 18);
      expect(cubit.state.entries.last.suraNumber, 2);
      cubit.close();
    });

    test('capped at five entries (FR-004)', () async {
      final FakeReadingHistoryStore store = FakeReadingHistoryStore();
      ReadingHistory history = ReadingHistory.empty();
      for (int i = 1; i <= 8; i++) {
        history = history.recordOpened(i);
        await store.save(history);
      }

      final QuranHistoryCubit cubit = buildCubit(store);
      await cubit.refresh();

      expect(cubit.state.entries, hasLength(ReadingHistory.maxEntries));
      expect(cubit.state.entries.first.suraNumber, 8);
      cubit.close();
    });
  });
}
