import 'package:equatable/equatable.dart';

/// Typed argument for the reading view route (contracts/reading_view_route.md).
///
/// Replaces the untyped `ModalRoute.settings.arguments as SuraModel` cast that previously
/// crossed this route boundary. The reading view clamps [startVerse] into the sura's valid
/// range, so callers need not pre-validate (FR-010, FR-020).
class SuraReaderArgs extends Equatable {
  const SuraReaderArgs({required this.suraNumber, this.startVerse = 1});

  /// 1-based ordinal of the sura to open, matching the sura catalogue's ordering.
  final int suraNumber;

  /// 1-based ordinal of the verse to open at.
  final int startVerse;

  @override
  List<Object?> get props => <Object?>[suraNumber, startVerse];
}
