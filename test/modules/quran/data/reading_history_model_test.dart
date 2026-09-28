import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:islami/modules/quran/data/models/reading_history_model.dart';
import 'package:islami/modules/quran/domain/entities/reading_history.dart';
import 'package:islami/modules/quran/domain/entities/reading_history_entry.dart';

void main() {
  group('ReadingHistoryModel reconciliation', () {
    test('missing or empty document yields an empty history', () {
      expect(ReadingHistoryModel.fromJsonString(null).entries, isEmpty);
      expect(ReadingHistoryModel.fromJsonString('').entries, isEmpty);
      expect(ReadingHistoryModel.fromJsonString('   ').entries, isEmpty);
    });

    test('malformed JSON yields an empty history without throwing', () {
      expect(ReadingHistoryModel.fromJsonString('{not json').entries, isEmpty);
      expect(ReadingHistoryModel.fromJsonString('[]').entries, isEmpty);
      expect(ReadingHistoryModel.fromJsonString('42').entries, isEmpty);
      expect(ReadingHistoryModel.fromJsonString('"a string"').entries, isEmpty);
    });

    test('absent or unrecognised version is discarded, not guessed at', () {
      expect(
        ReadingHistoryModel.fromJsonString('{"entries":[]}').entries,
        isEmpty,
      );
      expect(
        ReadingHistoryModel.fromJsonString('{"version":99,"entries":[]}').entries,
        isEmpty,
      );
      expect(
        ReadingHistoryModel.fromJsonString('{"version":"1","entries":[]}').entries,
        isEmpty,
      );
    });

    test('a non-list entries field yields an empty history', () {
      expect(
        ReadingHistoryModel.fromJsonString('{"version":1,"entries":{}}').entries,
        isEmpty,
      );
    });

    test('a sura number beyond the catalogue is dropped, the rest survive', () {
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          <String, Object?>{'suraNumber': 999, 'lastVerse': 3},
          <String, Object?>{'suraNumber': 2, 'lastVerse': 12},
        ],
      });

      final ReadingHistory history =
          ReadingHistoryModel.fromJsonString(document).toDomain();

      expect(history.length, 1);
      expect(history.mostRecent?.suraNumber, 2);
    });

    test('every entry discarded yields an empty history (FR-015)', () {
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          <String, Object?>{'suraNumber': 500},
          <String, Object?>{'suraNumber': 0},
          <String, Object?>{'suraNumber': -1},
        ],
      });

      expect(ReadingHistoryModel.fromJsonString(document).toDomain().isEmpty, isTrue);
    });

    test('a duplicate suraNumber keeps its first occurrence (FR-005)', () {
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          <String, Object?>{'suraNumber': 2, 'lastVerse': 12},
          <String, Object?>{'suraNumber': 2, 'lastVerse': 99},
        ],
      });

      final ReadingHistory history =
          ReadingHistoryModel.fromJsonString(document).toDomain();

      expect(history.length, 1);
      expect(history.mostRecent?.lastVerse, 12);
    });

    test('a lastVerse beyond the sura clamps to the last verse (FR-020)', () {
      // Al-Fatihah has 7 verses; Al-Baqarah has 286.
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          <String, Object?>{'suraNumber': 1, 'lastVerse': 5000},
        ],
      });

      expect(
        ReadingHistoryModel.fromJsonString(document).toDomain().mostRecent?.lastVerse,
        7,
      );
    });

    test('a lastVerse below 1 is treated as unrecorded (FR-010)', () {
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          <String, Object?>{'suraNumber': 2, 'lastVerse': 0},
          <String, Object?>{'suraNumber': 3, 'lastVerse': -5},
        ],
      });

      final ReadingHistory history =
          ReadingHistoryModel.fromJsonString(document).toDomain();

      expect(history.entryFor(2)?.lastVerse, isNull);
      expect(history.entryFor(3)?.lastVerse, isNull);
    });

    test('a malformed or missing lastVerse is treated as unrecorded', () {
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          <String, Object?>{'suraNumber': 2, 'lastVerse': 'twelve'},
          <String, Object?>{'suraNumber': 3},
        ],
      });

      final ReadingHistory history =
          ReadingHistoryModel.fromJsonString(document).toDomain();

      expect(history.entryFor(2)?.lastVerse, isNull);
      expect(history.entryFor(3)?.lastVerse, isNull);
    });

    test('more than 5 entries are truncated to the first 5 (FR-004)', () {
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          for (int i = 1; i <= 8; i++)
            <String, Object?>{'suraNumber': i, 'lastVerse': 1},
        ],
      });

      final ReadingHistory history =
          ReadingHistoryModel.fromJsonString(document).toDomain();

      expect(history.length, ReadingHistory.maxEntries);
      expect(
        history.entries.map((ReadingHistoryEntry e) => e.suraNumber).toList(),
        <int>[1, 2, 3, 4, 5],
      );
    });

    test('entries with a non-map or missing suraNumber are skipped', () {
      final String document = jsonEncode(<String, Object?>{
        'version': 1,
        'entries': <Object?>[
          'nonsense',
          42,
          <String, Object?>{'lastVerse': 5},
          <String, Object?>{'suraNumber': 2, 'lastVerse': 8},
        ],
      });

      final ReadingHistory history =
          ReadingHistoryModel.fromJsonString(document).toDomain();

      expect(history.length, 1);
      expect(history.mostRecent?.suraNumber, 2);
    });
  });

  group('ReadingHistoryModel serialisation', () {
    test('round-trips a history through the stored document', () {
      final ReadingHistory original = ReadingHistory.empty()
          .recordOpened(2, openingVerse: 12)
          .recordOpened(1, openingVerse: 7)
          .recordOpened(36);

      final String document = ReadingHistoryModel.fromDomain(original).toJsonString();
      final ReadingHistory restored = ReadingHistoryModel.fromJsonString(
        document,
      ).toDomain();

      expect(restored.entries, original.entries);
      expect(restored.mostRecent?.suraNumber, 36);
      expect(restored.mostRecent?.lastVerse, isNull);
      expect(restored.entryFor(2)?.lastVerse, 12);
    });

    test('writes a versioned document under the documented key', () {
      final String document = ReadingHistoryModel.fromDomain(
        ReadingHistory.empty().recordOpened(2, openingVerse: 12),
      ).toJsonString();

      final Map<String, dynamic> decoded =
          jsonDecode(document) as Map<String, dynamic>;

      expect(ReadingHistoryModel.storageKey, 'quran_reading_history_v1');
      expect(decoded['version'], 1);
      final List<Object?> entries = decoded['entries'] as List<Object?>;
      expect(entries.single, <String, Object?>{
        'suraNumber': 2,
        'lastVerse': 12,
      });
    });
  });
}
