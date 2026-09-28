import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';
import 'package:islami/modules/quran/domain/services/sura_catalogue.dart';

/// Serialised shape of the reading history stored under a single key.
///
/// Every untrusted-input rule from the data-model Reconciliation table is applied here,
/// so nothing above `data` ever sees a raw JSON value or a `FormatException` (constitution
/// III). A document that cannot be understood is never an error: it resolves to an empty
/// history, which the presentation layer shows as the Al-Fatihah default (FR-003, FR-015).
class ReadingHistoryModel extends Equatable {
  const ReadingHistoryModel({required this.entries});

  static const String storageKey = 'quran_reading_history_v1';
  static const int currentVersion = 1;

  final List<ReadingHistoryEntry> entries;

  factory ReadingHistoryModel.fromDomain(ReadingHistory history) {
    return ReadingHistoryModel(entries: history.entries);
  }

  /// Parses [raw], applying every reconciliation rule.
  ///
  /// Returns an empty model for a missing, malformed, version-mismatched, or fully
  /// irreconcilable document. Individual entries that fail validation are dropped while
  /// the rest survive.
  factory ReadingHistoryModel.fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const ReadingHistoryModel(entries: <ReadingHistoryEntry>[]);
    }

    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const ReadingHistoryModel(entries: <ReadingHistoryEntry>[]);
    }

    if (decoded is! Map<String, dynamic>) {
      return const ReadingHistoryModel(entries: <ReadingHistoryEntry>[]);
    }

    // An absent or unrecognised version is discarded rather than guessed at, so a future
    // schema change cannot be half-understood by an older build.
    final Object? version = decoded['version'];
    if (version is! int || version != currentVersion) {
      return const ReadingHistoryModel(entries: <ReadingHistoryEntry>[]);
    }

    final Object? rawEntries = decoded['entries'];
    if (rawEntries is! List) {
      return const ReadingHistoryModel(entries: <ReadingHistoryEntry>[]);
    }

    final List<ReadingHistoryEntry> accepted = <ReadingHistoryEntry>[];
    final Set<int> taken = <int>{};

    for (final Object? item in rawEntries) {
      if (item is! Map) continue;

      final Object? rawNumber = item['suraNumber'];
      if (rawNumber is! int) continue;

      // A sura number beyond the catalogue is discarded; the rest survive (FR-015).
      if (!SuraCatalogue.contains(rawNumber)) continue;

      // A duplicate keeps its first occurrence (FR-005).
      if (!taken.add(rawNumber)) continue;

      final Object? rawVerse = item['lastVerse'];

      // A verse below 1 is treated as unrecorded (FR-010); a verse beyond the sura's
      // length clamps to the last verse (FR-020), which `clampVerse` already applies.
      final int? lastVerse = (rawVerse is int && rawVerse < 1)
          ? null
          : (rawVerse is int ? SuraCatalogue.clampVerse(rawNumber, rawVerse) : null);

      accepted.add(ReadingHistoryEntry(suraNumber: rawNumber, lastVerse: lastVerse));
    }

    // Order and the cap are the entity's invariants, not the model's (FR-001, FR-004).
    return ReadingHistoryModel(
      entries: ReadingHistory.from(accepted).entries,
    );
  }

  String toJsonString() {
    final Map<String, dynamic> document = <String, dynamic>{
      'version': currentVersion,
      'entries': entries
          .map(
            (ReadingHistoryEntry e) => <String, dynamic>{
              'suraNumber': e.suraNumber,
              'lastVerse': e.lastVerse,
            },
          )
          .toList(growable: false),
    };
    return jsonEncode(document);
  }

  ReadingHistory toDomain() => ReadingHistory.from(entries);

  @override
  List<Object?> get props => [entries];
}
