import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:islami/core/routes/app_routes_name.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';
import 'package:islami/modules/quran/domain/services/sura_catalogue.dart';
import 'package:islami/modules/quran/presentation/ui/sura_reader_args.dart';
import 'package:islami/ui/customWidgets/card_screen_1.dart';

/// The "Most Recently" strip on the Quran screen.
///
/// Renders exactly the entries it is handed, in the order given, most recent first. It
/// contains no fallback logic and no emptiness check: the Al-Fatihah default is resolved
/// into the state by `QuranHistoryCubit`, so this widget has no branch that decides what to
/// show when data is missing (contracts/most_recently_strip_ui.md, constitution I and IV).
class MostRecentlyStrip extends StatelessWidget {
  const MostRecentlyStrip({super.key, required this.entries});

  /// One to five entries, most recently opened first.
  final List<ReadingHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    // The leading spacer of half the viewport width parks the newest card, the first real
    // entry, in the centre of the visible area on the very first frame, with the remaining
    // cards extending to its right as a peek affordance. This needs no controller and no
    // initial-page calculation (research.md R-003, FR-007, SC-005).
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Park the newest card's *centre* on the viewport's centre line, not its left edge:
        // the spacer is half the viewport minus half a card, so the card occupies the middle
        // and is fully visible on a first frame with no scrolling (FR-007, SC-005).
        //
        // A negative result means the card is wider than the viewport. Clamping to zero pins
        // it to the leading edge, which keeps it as visible as the width allows instead of
        // throwing on the negative size.
        final double leadingSpacer = math.max(
          0.0,
          constraints.maxWidth / 2 - CustomCard.outerWidth / 2,
        );
        // A single-child scroll view rather than a ListView: a sliver only instantiates the
        // children near the viewport, which would leave the neighbours of the newest card
        // without a laid-out position. The strip holds at most five cards, so building them
        // all up front costs nothing and guarantees the centred card is positioned on the
        // first frame (SC-005). The original markup used the same shape.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: <Widget>[
              SizedBox(width: leadingSpacer),
              for (final ReadingHistoryEntry entry in entries)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openReadingView(context, entry),
                  child: CustomCard(
                    suraNumber: entry.suraNumber,
                    arabicSuraName: SuraCatalogue.arabicNameOf(entry.suraNumber),
                    englishSuraName: SuraCatalogue.englishNameOf(entry.suraNumber),
                    verses: '${SuraCatalogue.verseCountOf(entry.suraNumber)}',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Opens the sura at its recorded verse, or at verse 1 when none is recorded
  /// (FR-009, FR-010).
  void _openReadingView(BuildContext context, ReadingHistoryEntry entry) {
    Navigator.pushNamed(
      context,
      AppRoutesName.qurandetails,
      arguments: SuraReaderArgs(
        suraNumber: entry.suraNumber,
        startVerse: entry.lastVerse ?? 1,
      ),
    );
  }
}
