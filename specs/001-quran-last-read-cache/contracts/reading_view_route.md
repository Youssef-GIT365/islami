# Contract: Reading View Route

**Layer**: `presentation` | **Status**: agreed

Replaces the current untyped `ModalRoute.settings.arguments as SuraModel` cast used at
`lib/modules/quran/suras/sura_item.dart:24` and
`lib/modules/quran/suras/sura_details.dart:19,23`.

## Why this changes

Passing a whole model as an untyped route argument is what makes the new feature awkward:
the reading view needs a **verse to open at**, and it must record what the reader views
(FR-009, FR-012). Extending the existing argument with a field would keep an untyped
contract and couple the route to a `data`-layer model. A small typed argument keeps the
contract explicit, testable, and independent of how sura data happens to be shaped.

## SuraReaderArgs

```dart
class SuraReaderArgs {
  const SuraReaderArgs({required this.suraNumber, this.startVerse = 1});

  /// 1-based ordinal of the sura to open. Matches the sura catalogue's ordering.
  final int suraNumber;

  /// 1-based ordinal of the verse to open at. Clamped into `1..verseCount` by the
  /// reading view, so callers need not pre-validate (FR-010, FR-020).
  final int startVerse;
}
```

## Producers

| Producer | Supplies | Requirement |
|----------|----------|-------------|
| `MostRecentlyStrip` | the entry's `suraNumber` and its `lastVerse ?? 1` | FR-007, FR-009, FR-010 |
| `SuraItem` (existing sura list, including search results) | `suraNumber` and the default `startVerse` | FR-012, FR-016, FR-018 |

Both producers push the existing `AppRoutesName.qurandetails` route. The route table itself
is unchanged, so no entry in `lib/core/routes/` needs editing.

## Consumer obligations

`SuraDetails` MUST, on entry:

1. Read its arguments as `SuraReaderArgs` and resolve the sura from the catalogue by
   `suraNumber`. If the sura cannot be resolved, it MUST fall back to the Al-Fatihah default
   rather than throwing on a bad cast (FR-015).
2. Clamp `startVerse` into `1..verseCount` before use (FR-010, FR-020).
3. Scroll to `startVerse` after the sura text has loaded, since the target offset is only
   computable once the text is laid out.
4. Record `(suraNumber, startVerse)` as the reading history's most recent entry with the
   current verse (FR-012, FR-016).
5. Update the recorded verse as the reader scrolls, on scroll **end** rather than per frame
   (FR-012; see research R-004).

## Compatibility

The old `SuraModel` argument is replaced, not extended. Both existing call sites are inside
the Quran feature and are touched by this change anyway, so no third-party caller is left
holding the old shape. This keeps FR-018 intact: the list, its ordering, and its search
behaviour are unchanged — only the type crossing the route boundary differs.
