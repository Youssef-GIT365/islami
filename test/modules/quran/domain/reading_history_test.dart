import 'package:flutter_test/flutter_test.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';

void main() {
  ReadingHistoryEntry entry(int suraNumber, {int? lastVerse}) {
    return ReadingHistoryEntry(suraNumber: suraNumber, lastVerse: lastVerse);
  }

  group('ReadingHistoryEntry', () {
    test('rejects a suraNumber below 1', () {
      expect(() => entry(0), throwsArgumentError);
      expect(() => entry(-3), throwsArgumentError);
    });

    test('rejects a lastVerse below 1 but allows null', () {
      expect(() => entry(2, lastVerse: 0), throwsArgumentError);
      expect(() => entry(2, lastVerse: -1), throwsArgumentError);
      expect(entry(2).lastVerse, isNull);
    });

    test('null lastVerse is distinct from verse 1', () {
      expect(entry(2).lastVerse, isNot(1));
      expect(entry(2, lastVerse: 1).lastVerse, 1);
      expect(entry(2) == entry(2, lastVerse: 1), isFalse);
    });

    test('copyWith replaces lastVerse and can clear it', () {
      final ReadingHistoryEntry original = entry(2, lastVerse: 12);
      expect(original.copyWith(lastVerse: 20).lastVerse, 20);
      expect(original.copyWith(clearLastVerse: true).lastVerse, isNull);
      expect(original.lastVerse, 12, reason: 'original must be untouched');
    });
  });

  group('ReadingHistory capacity', () {
    test('retains at most 5 entries and discards the least recent', () {
      ReadingHistory history = ReadingHistory.empty();
      for (int i = 1; i <= 7; i++) {
        history = history.recordOpened(i, openingVerse: 1);
      }

      expect(history.length, ReadingHistory.maxEntries);
      expect(
        history.entries.map((ReadingHistoryEntry e) => e.suraNumber).toList(),
        <int>[7, 6, 5, 4, 3],
        reason: 'newest first; the two least recent are discarded',
      );
    });

    test('from() truncates to the cap while preserving order', () {
      final ReadingHistory history = ReadingHistory.from(<ReadingHistoryEntry>[
        for (int i = 1; i <= 9; i++) entry(i),
      ]);
      expect(history.length, ReadingHistory.maxEntries);
      expect(history.mostRecent?.suraNumber, 1);
    });
  });

  group('ReadingHistory uniqueness and ordering', () {
    test('never holds the same sura twice', () {
      ReadingHistory history = ReadingHistory.empty()
        ..recordOpened(1, openingVerse: 1);
      history = history.recordOpened(2, openingVerse: 1).recordOpened(3, openingVerse: 1);
      history = history.recordOpened(1, openingVerse: 5);

      final List<int> numbers = history.entries
          .map((ReadingHistoryEntry e) => e.suraNumber)
          .toList();
      expect(numbers.toSet().length, numbers.length, reason: 'no duplicates');
      expect(numbers.first, 1, reason: 're-opened sura is promoted to newest');
    });

    test('re-opening preserves the other entries and their verses', () {
      ReadingHistory history = ReadingHistory.empty();
      history = history.recordOpened(2, openingVerse: 12);
      history = history.recordOpened(36, openingVerse: 5);
      history = history.recordOpened(1, openingVerse: 1);
      history = history.recordOpened(2, openingVerse: 30);

      expect(history.length, 3);
      expect(history.mostRecent?.suraNumber, 2);
      expect(history.mostRecent?.lastVerse, 30);
      expect(history.entryFor(36)?.lastVerse, 5);
      expect(history.entryFor(1)?.lastVerse, 1);
    });

    test('stays ordered most recently opened first', () {
      ReadingHistory history = ReadingHistory.empty();
      for (final int n in <int>[10, 20, 30]) {
        history = history.recordOpened(n, openingVerse: 1);
      }
      expect(
        history.entries.map((ReadingHistoryEntry e) => e.suraNumber).toList(),
        <int>[30, 20, 10],
      );
    });
  });

  group('ReadingHistory immutability', () {
    test('recordOpened returns a new instance and leaves the original intact', () {
      final ReadingHistory original = ReadingHistory.empty();
      final ReadingHistory updated = original.recordOpened(2, openingVerse: 7);

      expect(identical(original, updated), isFalse);
      expect(original.isEmpty, isTrue);
      expect(updated.length, 1);
    });

    test('recordVerseViewed returns a new instance and leaves the original intact', () {
      final ReadingHistory original = ReadingHistory.empty().recordOpened(2, openingVerse: 7);
      final ReadingHistory updated = original.recordVerseViewed(2, 40);

      expect(identical(original, updated), isFalse);
      expect(original.mostRecent?.lastVerse, 7);
      expect(updated.mostRecent?.lastVerse, 40);
    });

    test('the exposed entries list cannot be mutated', () {
      final ReadingHistory history = ReadingHistory.empty().recordOpened(2, openingVerse: 1);
      expect(() => history.entries.add(entry(3)), throwsUnsupportedError);
    });
  });

  group('ReadingHistory lookups and updates', () {
    test('entryFor returns null for an absent sura', () {
      final ReadingHistory history = ReadingHistory.empty().recordOpened(2, openingVerse: 1);
      expect(history.entryFor(99), isNull);
    });

    test('recordVerseViewed is a no-op for an absent sura', () {
      final ReadingHistory history = ReadingHistory.empty().recordOpened(2, openingVerse: 1);
      final ReadingHistory updated = history.recordVerseViewed(55, 9);

      expect(identical(history, updated), isTrue);
      expect(updated.length, 1, reason: 'must not resurrect an unremembered sura');
    });

    test('recordVerseViewed changes only the touched entry', () {
      ReadingHistory history = ReadingHistory.empty();
      history = history.recordOpened(2, openingVerse: 12).recordOpened(
        36,
        openingVerse: 5,
      );
      // Sura 36 is newest, so updating sura 2 must not disturb it.
      final ReadingHistory updated = history.recordVerseViewed(2, 99);

      expect(updated.entryFor(2)?.lastVerse, 99);
      expect(updated.mostRecent?.suraNumber, 36);
      expect(updated.mostRecent?.lastVerse, 5);
      expect(
        updated.entries.map((ReadingHistoryEntry e) => e.suraNumber).toList(),
        history.entries.map((ReadingHistoryEntry e) => e.suraNumber).toList(),
        reason: 'order unchanged',
      );
    });

    test('recordOpened with a null verse records an unopened position', () {
      final ReadingHistory history = ReadingHistory.empty().recordOpened(2);
      expect(history.mostRecent?.lastVerse, isNull);
    });

    test('mostRecent and isEmpty behave on an empty history', () {
      final ReadingHistory history = ReadingHistory.empty();
      expect(history.isEmpty, isTrue);
      expect(history.isNotEmpty, isFalse);
      expect(history.mostRecent, isNull);
    });
  });

  group('ReadingHistory.retainingWhere', () {
    test('drops rejected entries and preserves order', () {
      final ReadingHistory history = ReadingHistory.empty();
      ReadingHistory built = history;
      for (final int n in <int>[1, 2, 3, 4]) {
        built = built.recordOpened(n, openingVerse: 1);
      }

      final ReadingHistory filtered = built.retainingWhere(
        (ReadingHistoryEntry e) => e.suraNumber.isEven,
      );
      expect(
        filtered.entries.map((ReadingHistoryEntry e) => e.suraNumber).toList(),
        <int>[4, 2],
      );
    });
  });
}
