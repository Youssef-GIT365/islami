import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/di/injection.dart';
import 'package:islami/core/gen/assets.gen.dart';
import 'package:islami/modules/quran/domain/services/sura_catalogue.dart';
import 'package:islami/modules/quran/domain/services/verse_anchor_resolver.dart';
import 'package:islami/modules/quran/domain/usecases/record_sura_opened.dart';
import 'package:islami/modules/quran/domain/usecases/record_verse_viewed.dart';
import 'package:islami/modules/quran/presentation/services/verse_offset_table_builder.dart';
import 'package:islami/modules/quran/presentation/ui/sura_reader_args.dart';

/// Loads the raw numbered text of a sura asset, one line per verse.
typedef SuraTextLoader = Future<String> Function(String id);

class SuraDetails extends StatefulWidget {
  const SuraDetails({super.key, this.loadSuraText});

  /// Overrides how sura text is read, so widget tests can supply verses without depending on
  /// real asset-bundle I/O, which does not complete inside the test zone's fake clock.
  ///
  /// Production always leaves this null and reads `assets/suras/<id>.txt` from the bundle.
  @visibleForTesting
  final SuraTextLoader? loadSuraText;

  @override
  State<SuraDetails> createState() => SuraDetailsState();
}

/// Public so tests can drive [flushPendingWrite] on a state they found in the tree. The class
/// is otherwise an implementation detail of [SuraDetails].
@visibleForTesting
class SuraDetailsState extends State<SuraDetails> with WidgetsBindingObserver {
  List<String> fullSura = [];

  /// Ordinal of the sura actually being read, after the Al-Fatihah fallback (FR-015).
  int _suraNumber = SuraCatalogue.defaultSuraNumber;

  /// 1-based verse the reading view opened at, already clamped (FR-010, FR-020).
  int _startVerse = 1;

  bool _argumentsResolved = false;

  final ScrollController _scrollController = ScrollController();

  /// Vertical offset of every verse start, built once per sura load (research.md R-001).
  List<double> _verseOffsets = const <double>[];

  /// Whether the initial jump to [startVerse] has already been performed. The target is
  /// only computable once the text is laid out, so this happens after the first frame.
  bool _initialScrollDone = false;

  /// True only while this widget is performing its own restore jump, so the resulting scroll
  /// notifications are not mistaken for the reader scrolling.
  bool _isRestoring = false;

  /// Content width the offset table was measured at; a change invalidates the table.
  double? _measuredWidth;

  /// The in-flight verse write, if any, so it can be awaited before teardown (FR-011).
  Future<void>? _pendingWrite;

  static const EdgeInsets _readingPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentsResolved) return;
    _argumentsResolved = true;
    WidgetsBinding.instance.addObserver(this);

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final SuraReaderArgs args = arguments is SuraReaderArgs
        ? arguments
        : const SuraReaderArgs(suraNumber: SuraCatalogue.defaultSuraNumber);

    // An unknown or mistyped sura falls back to Al-Fatihah rather than throwing (FR-015).
    _suraNumber = SuraCatalogue.contains(args.suraNumber)
        ? args.suraNumber
        : SuraCatalogue.defaultSuraNumber;
    _startVerse = SuraCatalogue.clampVerse(_suraNumber, args.startVerse);

    readFile('$_suraNumber');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A write started by a scroll end is still in flight when the reader backgrounds the app
    // or closes the reading view. Waiting for it here is what makes the recorded verse
    // survive the process ending (FR-011, SC-003). The callback cannot await, so the wait is
    // started and deliberately not awaited; the use case cannot fail, and the app is by then
    // already on its way down.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_awaitPendingWrite());
    }
  }

  /// Completes once the in-flight verse write has landed, if there is one.
  @visibleForTesting
  Future<void> flushPendingWrite() => _awaitPendingWrite();

  Future<void> _awaitPendingWrite() async {
    final Future<void>? pending = _pendingWrite;
    _pendingWrite = null;
    if (pending == null) return;
    await pending;
  }

  @override
  void dispose() {
    // `dispose` cannot await either. Kicking the wait off here lets an in-flight write land
    // while the engine is still draining its microtask queue on a normal pop.
    unawaited(_awaitPendingWrite());
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.Gold),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          SuraCatalogue.englishNameOf(_suraNumber),
          style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.Gold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Assets.images.leftCorner.image(color: AppColors.Gold),
                Text(
                  SuraCatalogue.arabicNameOf(_suraNumber),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.Gold,
                  ),
                ),
                Assets.images.rightCorner.image(color: AppColors.Gold),
              ],
            ),
          ),
          Expanded(
            // Records the reader's position on scroll END rather than per frame, so a drag
            // across a long sura does not produce a write per frame (FR-012, R-004).
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  _buildOffsetTableIfNeeded(constraints.maxWidth, theme);
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: _readingPadding,
                    child: Text.rich(
                      // The same span tree the offset table was measured from, so rendering
                      // is unchanged (FR-019).
                      VerseOffsetTableBuilder.buildSuraTextSpan(
                        verses: fullSura,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.Gold,
                          height: 2.4,
                        ),
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the offset table once per sura load, at the scroll view's content width.
  ///
  /// A mismatched width would silently yield wrong offsets, because Arabic text re-wraps
  /// (research.md R-001), so the table is discarded and rebuilt if the width changes.
  void _buildOffsetTableIfNeeded(double viewportWidth, ThemeData theme) {
    if (fullSura.isEmpty) return;
    final double contentWidth = viewportWidth - _readingPadding.horizontal;
    if (contentWidth <= 0) return;
    if (_initialScrollDone && _measuredWidth == contentWidth) return;

    _measuredWidth = contentWidth;
    _verseOffsets = VerseOffsetTableBuilder.build(
      verses: fullSura,
      style: theme.textTheme.titleLarge?.copyWith(
        color: AppColors.Gold,
        height: 2.4,
      ),
      maxWidth: contentWidth,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    if (!_initialScrollDone) {
      _initialScrollDone = true;
      _restoreScrollToStartVerse();
    }
  }

  /// Jumps to the recorded verse once the text has been laid out.
  void _restoreScrollToStartVerse() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _verseOffsets.isEmpty) return;
      if (!_scrollController.hasClients) return;

      final int index = (_startVerse - 1).clamp(0, _verseOffsets.length - 1);
      // The table is in text coordinates, which begin below the scroll view's top padding.
      // Adding the same padding back that `_onScrollNotification` subtracts keeps the restore
      // and the subsequent read of the visible verse describing the same line.
      final double target = _verseOffsets[index] + _readingPadding.top;
      final double maxExtent = _scrollController.position.maxScrollExtent;
      // The jump below emits scroll notifications of its own. Those are this widget moving the
      // viewport, not the reader moving it, so recording is suppressed for them: otherwise the
      // restore would immediately overwrite the verse that was just recorded on entry, and a
      // reader who has not touched the screen would see their position move (FR-012).
      _isRestoring = true;
      try {
        _scrollController.jumpTo(target.clamp(0.0, maxExtent));
      } finally {
        _isRestoring = false;
      }
    });
  }

  /// Records the visible verse when scrolling stops (FR-012).
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollEndNotification) return false;
    if (_isRestoring) return false;
    if (_verseOffsets.isEmpty || !_scrollController.hasClients) return false;

    final int verse = VerseAnchorResolver.visibleVerse(
      offsets: _verseOffsets,
      // The table is measured in the text painter's own coordinate space, which starts at the
      // top of the text, while the scroll offset is measured from the top of the padded
      // content. Adding the top padding back is what makes the two comparable.
      scrollOffset:
          _scrollController.position.pixels - _readingPadding.top,
      verseCount: fullSura.length,
    );

    if (verse == _startVerse) return false;
    _startVerse = verse;
    _recordVerseViewed(verse);
    return false;
  }

  /// Persists the last-viewed verse, keeping the write reachable for a lifecycle flush.
  ///
  /// A scroll-end callback is synchronous, so the returned future cannot be awaited here. It
  /// is tracked so [dispose] and the app-lifecycle handler can wait for it before the process
  /// goes away, which is what makes the recorded position survive a restart (FR-011, SC-003).
  /// `RecordVerseViewed` already swallows storage failures, so a rejected write here is
  /// non-fatal by design (FR-015).
  void _recordVerseViewed(int verse) {
    _pendingWrite = sl<RecordVerseViewed>()(_suraNumber, verse);
  }

  /// Loads the sura text and records the open.
  ///
  /// Recording happens here, inside the reading view, rather than at each call site, so
  /// every entry point is covered by construction (FR-012, research.md R-004).
  void readFile(String id) async {
    // FR-012, FR-016: record the sura the reader opened, at the verse they opened at.
    await sl<RecordSuraOpened>()(_suraNumber, openingVerse: _startVerse);

    final sura = await (widget.loadSuraText ?? _loadSuraTextFromBundle)(id);
    if (!mounted) return;
    sura.trim();
    setState(() {
      fullSura = sura.split('\n');
    });
  }

  static Future<String> _loadSuraTextFromBundle(String id) {
    return rootBundle.loadString('assets/suras/$id.txt');
  }
}
