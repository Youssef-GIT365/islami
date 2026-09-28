import 'package:flutter/material.dart';

/// Builds the per-verse vertical offset table for a sura's reading view
/// (research.md R-001).
///
/// The reading view renders a whole sura as one `Text.rich`, so there is no per-verse widget
/// to measure. This lays the identical span tree out off-screen with a `TextPainter` at the
/// scroll view's content width and records the vertical offset of every verse start, which
/// `VerseAnchorResolver` later turns into a visible verse from a scroll offset.
///
/// [buildSuraTextSpan] is the single source of the span tree: the reading view renders with
/// it and the painter measures with it, so the two cannot drift apart. A mismatched layout
/// width would silently produce wrong offsets, because Arabic text re-wraps.
abstract final class VerseOffsetTableBuilder {
  /// The exact span tree the reading view renders for [verses].
  static TextSpan buildSuraTextSpan({
    required List<String> verses,
    required TextStyle? style,
  }) {
    return TextSpan(
      children: <InlineSpan>[
        for (int index = 0; index < verses.length; index++)
          TextSpan(
            text: " [${index + 1}] ${verses[index]}",
            style: style,
          ),
      ],
    );
  }

  /// The vertical offset at which each verse begins, in verses order.
  ///
  /// [maxWidth] MUST be the scroll view's content width, not its full width. Throws a
  /// [StateError] if the produced table decreases, which can only be a build bug and must
  /// fail loudly rather than be silently repaired.
  static List<double> build({
    required List<String> verses,
    required TextStyle? style,
    required double maxWidth,
    required TextDirection textDirection,
    required TextAlign textAlign,
  }) {
    if (verses.isEmpty) return const <double>[];

    final TextSpan span = buildSuraTextSpan(verses: verses, style: style);
    final TextPainter painter = TextPainter(
      text: span,
      textDirection: textDirection,
      textAlign: textAlign,
    )..layout(maxWidth: maxWidth);

    try {
      // Character offset at which each verse's span begins. TextSpan children are
      // concatenated with no separator, so the offsets are the running text lengths.
      final List<double> offsets = <double>[];
      int characterOffset = 0;
      for (int index = 0; index < verses.length; index++) {
        final String text = " [${index + 1}] ${verses[index]}";
        final Offset caret = painter.getOffsetForCaret(
          TextPosition(offset: characterOffset),
          Rect.zero,
        );
        offsets.add(caret.dy);
        if (index > 0 && caret.dy < offsets[index - 1]) {
          throw StateError(
            'Verse offset table is not non-decreasing at verse ${index + 1}: '
            '${offsets[index - 1]} then ${caret.dy}. This is a build bug.',
          );
        }
        characterOffset += text.length;
      }
      return offsets;
    } finally {
      painter.dispose();
    }
  }
}
