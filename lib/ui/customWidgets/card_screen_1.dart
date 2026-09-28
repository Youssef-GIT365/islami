import 'package:flutter/material.dart';
import 'package:islami/core/colors/appColors.dart';
import 'package:islami/core/gen/assets.gen.dart';

class CustomCard extends StatelessWidget {
  final String arabicSuraName;
  final String englishSuraName;
  final String verses;

  /// Width of the visible card box, and [outerWidth] including its padding.
  ///
  /// Exposed so a caller can position the card by its true extent. Centring needs the outer
  /// width, not the viewport width: using half the viewport alone would park the card's left
  /// edge on the centre line and clip the card itself (FR-007).
  static const double contentWidth = 320;
  static const double _padding = 8.0;

  /// Total horizontal space a card occupies in a row, padding included.
  static const double outerWidth = contentWidth + _padding * 2;

  /// 1-based ordinal of the sura, rendered as a badge. Required so a card can never be
  /// shown without it (FR-006).
  final int suraNumber;

  const CustomCard({
    super.key,
    required this.arabicSuraName,
    required this.englishSuraName,
    required this.verses,
    required this.suraNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      // The badge is overlaid rather than added as a fourth row: the card is a fixed
      // 150px-tall box and a fourth child overflows it.
      child: Stack(
        children: [
          Container(
            width: contentWidth,
            height: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Gold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      englishSuraName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      arabicSuraName,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                    ),
                    Row(
                      children: [
                        Text("$verses"),
                        const SizedBox(width: 5),
                        const Text("verses"),
                      ],
                    ),
                  ],
                ),
                Assets.icons.mostRecentlyIcon.image(),
              ],
            ),
          ),
          Positioned(top: 0, right: 0, child: _SuraNumberBadge(suraNumber: suraNumber)),
        ],
      ),
    );
  }
}

/// The sura's ordinal number, overlaid on the card's corner (FR-006).
class _SuraNumberBadge extends StatelessWidget {
  const _SuraNumberBadge({required this.suraNumber});

  final int suraNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Text(
        "$suraNumber",
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
