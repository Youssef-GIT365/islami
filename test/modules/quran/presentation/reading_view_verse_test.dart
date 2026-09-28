import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islami/core/di/injection.dart';
import 'package:islami/core/theme/app_theme.dart';
import 'package:islami/modules/quran/data/models/reading_history_model.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/services/sura_catalogue.dart';
import 'package:islami/modules/quran/domain/usecases/record_sura_opened.dart';
import 'package:islami/modules/quran/domain/usecases/record_verse_viewed.dart';
import 'package:islami/modules/quran/presentation/ui/sura_reader_args.dart';
import 'package:islami/modules/quran/suras/sura_details.dart';

import '../fakes/fake_reading_history_store.dart';

/// Pushes the reading view onto a real navigator with [args] on its route, the way the
/// sura list and the strip actually reach it.
class _ReaderHost extends StatefulWidget {
  const _ReaderHost({this.args, this.loadSuraText});

  /// Null arguments, to exercise the untyped-route fallback.
  final SuraReaderArgs? args;

  final SuraTextLoader? loadSuraText;

  @override
  State<_ReaderHost> createState() => _ReaderHostState();
}

class _ReaderHostState extends State<_ReaderHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: '/sura', arguments: widget.args),
          builder: (BuildContext context) =>
              SuraDetails(loadSuraText: widget.loadSuraText),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

/// Synthetic sura text: one numbered line per verse, matching the real asset's shape.
///
/// Real `rootBundle` reads do not complete inside the test zone's fake clock, so the reader's
/// own behaviour is exercised against an injected loader instead.
Future<String> _syntheticSuraText(String id) async {
  final int verseCount = SuraCatalogue.verseCountOf(int.parse(id));
  return List<String>.generate(
    verseCount,
    (int i) => ' [${i + 1}] verse ${i + 1} of sura $id ',
  ).join('\n');
}

void main() {
  late FakeReadingHistoryStore store;

  setUp(() {
    store = FakeReadingHistoryStore();
    if (sl.isRegistered<RecordSuraOpened>()) sl.unregister<RecordSuraOpened>();
    if (sl.isRegistered<RecordVerseViewed>()) sl.unregister<RecordVerseViewed>();
    sl.registerFactory<RecordSuraOpened>(() => RecordSuraOpened(store));
    sl.registerFactory<RecordVerseViewed>(() => RecordVerseViewed(store));
  });

  tearDown(() {
    if (sl.isRegistered<RecordSuraOpened>()) sl.unregister<RecordSuraOpened>();
    if (sl.isRegistered<RecordVerseViewed>()) sl.unregister<RecordVerseViewed>();
  });

  /// The history the fake actually persisted, parsed back through the real model.
  ReadingHistory persisted() {
    return ReadingHistoryModel.fromJsonString(
      store.savedDocuments.last,
    ).toDomain();
  }

  /// Pumps until the sura body has rendered.
  ///
  /// `pumpAndSettle` alone is not enough: the body text arrives from an asynchronous asset
  /// load, and until that future resolves no frame is scheduled, so settling returns early
  /// against a still-empty reading view.
  Future<void> pumpUntilSuraTextRendered(WidgetTester tester) async {
    await tester.pumpAndSettle();
    if (find.textContaining('[1]').evaluate().isEmpty) {
      fail('the sura body never rendered');
    }
  }

  Future<void> openSura(WidgetTester tester, SuraReaderArgs? args) async {
    await tester.pumpWidget(
      MaterialApp(
        // Each test gets its own store, so a per-store key forces a fresh navigator. Without
        // it the previous test's pushed reader route survives on the reused navigator's stack.
        key: ValueKey<Object>(store),
        theme: AppTheme.getThemeData(),
        home: _ReaderHost(args: args, loadSuraText: _syntheticSuraText),
      ),
    );
    await pumpUntilSuraTextRendered(tester);
  }

  group('SuraDetails records the open (FR-012, FR-016)', () {
    testWidgets('an unrecorded sura opens at verse 1 and is recorded', (
      WidgetTester tester,
    ) async {
      await openSura(tester, const SuraReaderArgs(suraNumber: 1));

      expect(store.savedDocuments, hasLength(1));
      expect(persisted().mostRecent?.suraNumber, 1);
      expect(persisted().mostRecent?.lastVerse, 1);
    });

    testWidgets('an unknown sura falls back to Al-Fatihah (FR-015)', (
      WidgetTester tester,
    ) async {
      await openSura(tester, const SuraReaderArgs(suraNumber: 9999));

      expect(find.text(SuraCatalogue.englishNameOf(1)), findsOneWidget);
      expect(find.text('9999'), findsNothing);
      expect(persisted().mostRecent?.suraNumber, SuraCatalogue.defaultSuraNumber);
    });

    testWidgets('missing arguments fall back to Al-Fatihah (FR-015)', (
      WidgetTester tester,
    ) async {
      await openSura(tester, null);

      expect(find.text(SuraCatalogue.englishNameOf(1)), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SuraDetails clamps the start verse (FR-010, FR-020)', () {
    testWidgets('a startVerse beyond the verse count opens at the last verse', (
      WidgetTester tester,
    ) async {
      // Al-Fatihah has 7 verses.
      expect(SuraCatalogue.verseCountOf(1), 7);

      await openSura(tester, const SuraReaderArgs(suraNumber: 1, startVerse: 5000));

      expect(persisted().mostRecent?.lastVerse, 7);
    });

    testWidgets('a startVerse below 1 is clamped to verse 1', (
      WidgetTester tester,
    ) async {
      await openSura(tester, const SuraReaderArgs(suraNumber: 1, startVerse: 0));

      expect(persisted().mostRecent?.lastVerse, 1);
    });

    testWidgets('a recorded verse in a long sura is restored, not reset to 1', (
      WidgetTester tester,
    ) async {
      // Al-Baqarah has 286 verses, so a mid-sura start is meaningful.
      expect(SuraCatalogue.verseCountOf(2), greaterThan(50));

      await openSura(tester, const SuraReaderArgs(suraNumber: 2, startVerse: 100));

      expect(persisted().mostRecent?.suraNumber, 2);
      expect(persisted().mostRecent?.lastVerse, 100);
    });

    testWidgets('a sura opened without a recorded verse starts at 1 (FR-010)', (
      WidgetTester tester,
    ) async {
      await openSura(tester, const SuraReaderArgs(suraNumber: 36));

      expect(persisted().mostRecent?.suraNumber, 36);
      expect(persisted().mostRecent?.lastVerse, 1);
    });
  });

  group('SuraDetails scroll recording (FR-012)', () {
    testWidgets('the sura body is rendered, not left empty', (
      WidgetTester tester,
    ) async {
      await openSura(tester, const SuraReaderArgs(suraNumber: 1));

      // Al-Fatihah has 7 verses; every one is numbered in the body.
      for (int verse = 1; verse <= 7; verse++) {
        expect(find.textContaining('[$verse]'), findsOneWidget);
      }
    });

    testWidgets('scrolling records the verse reached', (
      WidgetTester tester,
    ) async {
      // A sura long enough to be scrollable, but small enough for the test asset bundle to
      // load quickly. Al-Fatihah's 7 verses fit on one screen and cannot be scrolled at all.
      await openSura(tester, const SuraReaderArgs(suraNumber: 78));
      expect(SuraCatalogue.verseCountOf(78), greaterThan(30));

      final Finder scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);
      expect(
        tester.state<ScrollableState>(find.byType(Scrollable)).position.maxScrollExtent,
        greaterThan(0),
        reason: 'the reading view is genuinely scrollable',
      );

      for (int i = 0; i < 6; i++) {
        await tester.drag(scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      expect(
        persisted().mostRecent!.lastVerse,
        greaterThan(1),
        reason: 'the reader moved, so the recorded verse advanced',
      );
    });

    testWidgets('a failed write does not surface an error (FR-015)', (
      WidgetTester tester,
    ) async {
      store.failOnSave = true;

      await openSura(tester, const SuraReaderArgs(suraNumber: 1));

      expect(tester.takeException(), isNull);
      expect(find.text(SuraCatalogue.englishNameOf(1)), findsOneWidget);
    });

    testWidgets('the restore jump does not itself record a verse (FR-012)', (
      WidgetTester tester,
    ) async {
      // Opening at a mid-sura verse records that verse. The programmatic jump to it emits
      // scroll notifications of its own, and those must not be mistaken for the reader
      // scrolling and overwrite the entry with a different verse.
      await openSura(tester, const SuraReaderArgs(suraNumber: 78, startVerse: 20));
      expect(persisted().mostRecent?.lastVerse, 20);

      // Any further work in the reading view, with no user scrolling at all.
      await tester.pumpAndSettle();
      expect(
        persisted().mostRecent?.lastVerse,
        20,
        reason: 'the entry the reader arrived at is preserved until they actually scroll',
      );
    });

    testWidgets('a pending verse write is awaitable before teardown (FR-011)', (
      WidgetTester tester,
    ) async {
      await openSura(tester, const SuraReaderArgs(suraNumber: 78));

      final Finder scrollable = find.byType(SingleChildScrollView);
      for (int i = 0; i < 6; i++) {
        await tester.drag(scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      final SuraDetailsState state = tester.state(
        find.byType(SuraDetails),
      ) as SuraDetailsState;

      // The write started by the last scroll end is tracked so the lifecycle and dispose
      // paths can wait for it. Draining it here is what a real app does on backgrounding.
      await state.flushPendingWrite();

      expect(
        persisted().mostRecent?.lastVerse,
        greaterThan(1),
        reason: 'the flushed write reached storage',
      );
    });
  });
}
