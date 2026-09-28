import 'package:flutter_test/flutter_test.dart';
import 'package:islami/modules/quran/domain/services/verse_anchor_resolver.dart';

void main() {
  // A table with uneven spacing, mirroring how Arabic verses actually wrap.
  const List<double> offsets = <double>[0, 20, 50, 90, 140, 200, 260];

  int verseAt(double scrollOffset, {int verseCount = 7}) {
    return VerseAnchorResolver.visibleVerse(
      offsets: offsets,
      scrollOffset: scrollOffset,
      verseCount: verseCount,
    );
  }

  group('VerseAnchorResolver', () {
    test('resolves the verse whose offset contains the scroll position', () {
      expect(verseAt(0), 1);
      expect(verseAt(19), 1);
      expect(verseAt(20), 2, reason: 'an offset exactly on the boundary');
      expect(verseAt(49), 2);
      expect(verseAt(50), 3);
      expect(verseAt(139), 4);
      expect(verseAt(140), 5);
      expect(verseAt(259), 6);
    });

    test('a negative scroll offset resolves to verse 1', () {
      expect(verseAt(-1), 1);
      expect(verseAt(-1000), 1);
    });

    test('an offset past the end resolves to the last verse', () {
      expect(verseAt(260), 7);
      expect(verseAt(100000), 7);
    });

    test('the result is clamped into 1..verseCount', () {
      expect(
        VerseAnchorResolver.visibleVerse(
          offsets: offsets,
          scrollOffset: 200,
          verseCount: 3,
        ),
        3,
        reason: 'a table longer than verseCount cannot report past the sura',
      );
      expect(
        VerseAnchorResolver.visibleVerse(
          offsets: const <double>[0, 10, 20],
          scrollOffset: 20,
          verseCount: 1,
        ),
        1,
      );
      expect(
        VerseAnchorResolver.visibleVerse(
          offsets: offsets,
          scrollOffset: 0,
          verseCount: 3,
        ),
        1,
        reason: 'clamping never pulls the result below verse 1',
      );
    });

    test('an empty table resolves to verse 1', () {
      expect(
        VerseAnchorResolver.visibleVerse(
          offsets: const <double>[],
          scrollOffset: 500,
          verseCount: 7,
        ),
        1,
      );
    });

    test('a non-positive verse count resolves to verse 1', () {
      expect(verseAt(100, verseCount: 0), 1);
      expect(verseAt(100, verseCount: -3), 1);
    });

    test('a single-verse sura always resolves to verse 1', () {
      expect(
        VerseAnchorResolver.visibleVerse(
          offsets: const <double>[0],
          scrollOffset: 0,
          verseCount: 1,
        ),
        1,
      );
    });

    test('a long uneven table resolves monotonically', () {
      final List<double> long = <double>[
        for (int i = 0; i < 286; i++) i * 12.5,
      ];
      int previous = 1;
      for (int i = 0; i < long.length; i += 7) {
        final int resolved = VerseAnchorResolver.visibleVerse(
          offsets: long,
          scrollOffset: long[i],
          verseCount: long.length,
        );
        expect(resolved, greaterThanOrEqualTo(previous));
        previous = resolved;
      }
      expect(previous, greaterThan(1), reason: 'the table really was traversed');
    });

    test('returns a verse that always exists in the sura', () {
      for (double offset = -50; offset < 400; offset += 7) {
        final int verse = verseAt(offset);
        expect(verse, inInclusiveRange(1, 7));
      }
    });
  });
}
