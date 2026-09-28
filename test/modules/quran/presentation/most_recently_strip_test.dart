import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islami/core/theme/app_theme.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';
import 'package:islami/modules/quran/domain/services/sura_catalogue.dart';
import 'package:islami/modules/quran/presentation/controller/quran_history_state.dart';
import 'package:islami/modules/quran/presentation/ui/most_recently_strip.dart';
import 'package:islami/ui/customWidgets/card_screen_1.dart';

/// The test environment substitutes a font whose glyphs are square blocks, which makes
/// 24px text far wider than it is on a device and overflows the fixed-width card. Loading
/// the app's real font and applying the production theme makes these tests measure the
/// layout a reader actually sees.
Future<void> loadAppFonts() async {
  final FontLoader loader = FontLoader('jana')
    ..addFont(rootBundle.load('assets/fonts/ArbFONTS-Janna-LT-Regular.ttf'));
  await loader.load();
}

/// A realistic phone-width viewport, so the strip is measured against the width a reader
/// actually sees rather than the much wider default test surface.
const double viewportWidth = 400;

Widget wrap(Widget child, {double width = viewportWidth}) {
  return MaterialApp(
    theme: AppTheme.getThemeData(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

void main() {
  setUpAll(loadAppFonts);

  group('MostRecentlyStrip content (FR-006)', () {
    testWidgets('renders number, Arabic name and English name for an entry', (
      WidgetTester tester,
    ) async {
      const int suraNumber = 2;
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[
              ReadingHistoryEntry(suraNumber: suraNumber, lastVerse: 12),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('$suraNumber'), findsOneWidget, reason: 'ordinal number');
      expect(
        find.text(SuraCatalogue.arabicNameOf(suraNumber)),
        findsOneWidget,
        reason: 'Arabic name',
      );
      expect(
        find.text(SuraCatalogue.englishNameOf(suraNumber)),
        findsOneWidget,
        reason: 'English name',
      );
      expect(
        find.text('${SuraCatalogue.verseCountOf(suraNumber)}'),
        findsOneWidget,
      );
    });

    testWidgets('renders every entry it is given, in the order given', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[
              ReadingHistoryEntry(suraNumber: 36),
              ReadingHistoryEntry(suraNumber: 2, lastVerse: 12),
              ReadingHistoryEntry(suraNumber: 1),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('36'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders no card beyond the ones it is given', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[
              ReadingHistoryEntry(suraNumber: 18),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CustomCard), findsOneWidget);
    });
  });

  group('MostRecentlyStrip renders whatever the state hands it', () {
    testWidgets('a fallback state yields exactly one Al-Fatihah card', (
      WidgetTester tester,
    ) async {
      final QuranHistoryState state = QuranHistoryState.fallback();

      await tester.pumpWidget(wrap(MostRecentlyStrip(entries: state.entries)));
      await tester.pump();

      expect(find.byType(CustomCard), findsOneWidget);
      expect(find.text('${SuraCatalogue.defaultSuraNumber}'), findsOneWidget);
      expect(
        find.text(SuraCatalogue.arabicNameOf(SuraCatalogue.defaultSuraNumber)),
        findsOneWidget,
      );
      expect(
        find.text(SuraCatalogue.englishNameOf(SuraCatalogue.defaultSuraNumber)),
        findsOneWidget,
      );
    });

    testWidgets('a resolved state yields its entries, not Al-Fatihah', (
      WidgetTester tester,
    ) async {
      final QuranHistoryState state = QuranHistoryState.resolved(
        <ReadingHistoryEntry>[
          ReadingHistoryEntry(suraNumber: 2, lastVerse: 12),
        ],
      );

      await tester.pumpWidget(wrap(MostRecentlyStrip(entries: state.entries)));
      await tester.pump();

      expect(
        find.text(SuraCatalogue.englishNameOf(SuraCatalogue.defaultSuraNumber)),
        findsNothing,
      );
      expect(find.text(SuraCatalogue.englishNameOf(2)), findsOneWidget);
    });
  });

  group('MostRecentlyStrip centred layout (FR-007, SC-005)', () {
    testWidgets('the newest card starts at the centre of the visible width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[
              ReadingHistoryEntry(suraNumber: 36),
              ReadingHistoryEntry(suraNumber: 2, lastVerse: 12),
            ],
          ),
        ),
      );
      await tester.pump();

      final double stripLeft = tester.getTopLeft(find.byType(MostRecentlyStrip)).dx;
      final double stripWidth = tester.getSize(find.byType(MostRecentlyStrip)).width;
      final Rect newest = tester.getRect(find.byType(CustomCard).first);

      // The card's centre, not its left edge, sits on the strip's centre line. Asserting the
      // edge instead would pass while the card itself is clipped off-screen (FR-007, SC-005).
      final double newestCentre = newest.center.dx - stripLeft;
      expect(
        newestCentre,
        closeTo(stripWidth / 2, 0.5),
        reason: 'the newest card is centred on the first frame',
      );

      expect(
        newest.left,
        greaterThanOrEqualTo(stripLeft - 0.5),
        reason: 'the centred card does not overflow the leading edge',
      );
      expect(
        newest.right,
        lessThanOrEqualTo(stripLeft + stripWidth + 0.5),
        reason: 'the centred card does not overflow the trailing edge',
      );
    });

    testWidgets('the newest card is fully visible when the viewport is exactly its width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[ReadingHistoryEntry(suraNumber: 36)],
          ),
          // One pixel narrower than the card: the spacer clamps to zero instead of going
          // negative, and the card is pinned to the leading edge.
          width: CustomCard.outerWidth - 1,
        ),
      );
      await tester.pump();

      final double stripLeft = tester.getTopLeft(find.byType(MostRecentlyStrip)).dx;
      final Rect newest = tester.getRect(find.byType(CustomCard).first);
      expect(
        newest.left,
        closeTo(stripLeft, 0.5),
        reason: 'a card wider than the viewport pins to the leading edge',
      );
    });

    testWidgets('neighbours extend to the right of the newest, in recency order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[
              ReadingHistoryEntry(suraNumber: 36),
              ReadingHistoryEntry(suraNumber: 2, lastVerse: 12),
              ReadingHistoryEntry(suraNumber: 1),
            ],
          ),
        ),
      );
      await tester.pump();

      final double newestLeft = tester.getTopLeft(find.byType(CustomCard).at(0)).dx;
      final double secondLeft = tester.getTopLeft(find.byType(CustomCard).at(1)).dx;
      final double thirdLeft = tester.getTopLeft(find.byType(CustomCard).at(2)).dx;

      expect(secondLeft, greaterThan(newestLeft));
      expect(thirdLeft, greaterThan(secondLeft), reason: 'FR-008: recency order');
    });

    testWidgets('the newest card is centred with no manual scrolling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[
              ReadingHistoryEntry(suraNumber: 18),
            ],
          ),
        ),
      );
      await tester.pump();

      // Nothing was dragged, so the default scroll offset is still zero.
      expect(tester.widget<Scrollable>(find.byType(Scrollable)).controller?.offset ?? 0, 0);

      // Centred means the card's centre on the centre line, and the whole card on screen.
      // Placing the card's left edge on the centre line instead would leave roughly 42% of a
      // 336px card hanging off a 400px viewport.
      final double stripLeft = tester.getTopLeft(find.byType(MostRecentlyStrip)).dx;
      final double stripWidth = tester.getSize(find.byType(MostRecentlyStrip)).width;
      final Rect newest = tester.getRect(find.byType(CustomCard).first);

      expect(newest.center.dx - stripLeft, closeTo(stripWidth / 2, 0.5));
      expect(newest.left, greaterThanOrEqualTo(stripLeft - 0.5));
      expect(newest.right, lessThanOrEqualTo(stripLeft + stripWidth + 0.5));
    });
  });

  group('MostRecentlyStrip capacity (FR-004, FR-005)', () {
    testWidgets('exactly 5 cards render after 6 different suras are opened', (
      WidgetTester tester,
    ) async {
      ReadingHistory history = ReadingHistory.empty();
      for (final int suraNumber in <int>[1, 2, 3, 18, 36, 55]) {
        history = history.recordOpened(suraNumber);
      }
      expect(history.length, ReadingHistory.maxEntries);

      final QuranHistoryState state = QuranHistoryState.resolved(history.entries);
      await tester.pumpWidget(wrap(MostRecentlyStrip(entries: state.entries)));
      await tester.pump();

      expect(find.byType(CustomCard), findsNWidgets(ReadingHistory.maxEntries));
      expect(
        find.text(SuraCatalogue.englishNameOf(1)),
        findsNothing,
        reason: 'the least recently opened sura was evicted',
      );
    });

    testWidgets('no sura is rendered twice after a re-open', (
      WidgetTester tester,
    ) async {
      ReadingHistory history = ReadingHistory.empty();
      for (final int suraNumber in <int>[1, 2, 3, 18, 36, 2]) {
        history = history.recordOpened(suraNumber);
      }

      final QuranHistoryState state = QuranHistoryState.resolved(history.entries);
      await tester.pumpWidget(wrap(MostRecentlyStrip(entries: state.entries)));
      await tester.pump();

      expect(find.byType(CustomCard), findsNWidgets(5));
      expect(
        find.text(SuraCatalogue.englishNameOf(2)),
        findsOneWidget,
        reason: 'FR-005: promoted, not duplicated',
      );
      expect(
        tester.getRect(find.byType(CustomCard).first).center.dx -
            tester.getTopLeft(find.byType(MostRecentlyStrip)).dx,
        closeTo(
          tester.getSize(find.byType(MostRecentlyStrip)).width / 2,
          0.5,
        ),
        reason: 'the re-opened sura is the newest, so it is the centred one',
      );
    });

    testWidgets('a single remembered sura renders one card, no padding entries', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          MostRecentlyStrip(
            entries: <ReadingHistoryEntry>[
              ReadingHistoryEntry(suraNumber: 18),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CustomCard), findsOneWidget);
    });
  });
}
