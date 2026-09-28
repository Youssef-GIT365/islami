# Quickstart: Validating the Quran Last-Read Sura Cache

**Feature**: [001-quran-last-read-cache](spec.md) | **Date**: 2026-09-28

A runnable guide for confirming the feature works end to end. It validates behaviour only —
implementation steps belong in [tasks.md](tasks.md), which `/speckit.tasks` will generate.

## Prerequisites

- Flutter 3.47.1 (Dart 3.13.1) on `PATH`; the repo's `pubspec.yaml` pins SDK `^3.10.1`
- `flutter pub get` completed
- A device or emulator with **no network** for validation V5

## Setup

```bash
flutter pub get
```

`shared_preferences` is the only added dependency; the Android and iOS platform projects
need no manual changes because the plugin ships first-party support for all six targets this
repo builds.

## Test commands

```bash
# Static analysis must report zero issues (constitution, quality gate 4)
flutter analyze

# Full suite
flutter test

# This feature only
flutter test test/modules/quran

# Verbose, for confirming which cases ran
flutter test test/modules/quran --reporter expanded
```

## Expected outcomes

| Check | Expected result |
|-------|-----------------|
| `flutter analyze` | `No issues found!` — zero errors, warnings, and lints |
| `flutter test` | All tests pass. The suite must grow beyond the single pre-existing `widget_test.dart` |
| New tests present | `reading_history_test.dart`, `verse_anchor_resolver_test.dart`, `reading_history_model_test.dart`, `quran_history_cubit_test.dart`, `most_recently_strip_test.dart` |
| Zero lints suppressed | No `// ignore:` or `// ignore_for_file:` added anywhere in the new code |
| No test-only escape hatches | Cubit and use case tests construct their subjects with hand-written fakes, passing no `null` and using no test-only constructors |

## Manual validation scenarios

Run the app with `flutter run` and walk these in order. Each maps to the spec.

### V1 — First-time reader sees the default

1. Launch the app on a device with no prior history.
2. Open the Quran tab.

**Expect**: the "Most Recently" area shows a single **Al-Fatihah** card, centred, fully
visible, not blank and not spinning. The sura list below is unchanged and complete.
*(FR-003, FR-006, SC-002)*

### V2 — Resume after one sura

1. Scroll the sura list, tap **Al-Baqarah**.
2. Press back to the Quran screen.

**Expect**: the strip now shows Al-Baqah centred, no longer Al-Fatihah. Tapping it reopens
Al-Baqarah. *(FR-002, FR-007, FR-009, SC-001)*

### V3 — Newest stays centred with neighbours

1. Open three more suras from the list, for example Ya-Sin, An-Nas, and Al-Kahf.
2. Return to the Quran screen each time.

**Expect**: after each return the newest sura is centred with no scrolling, and the
previously read suras sit beside it in recency order. The strip never exceeds 5 cards.
*(FR-004, FR-008, SC-005, SC-006)*

### V4 — Capacity and de-duplication

1. Open six different suras in total.
2. Return to the Quran screen.

**Expect**: exactly 5 cards. The very first sura opened is gone. *(FR-004)*
3. Re-open Al-Baqarah, which is already in the history.

**Expect**: Al-Baqarah becomes the centred newest entry, the other 4 are still present, and
no duplicate card appears. *(FR-005, SC-006)*

### V5 — Offline and survives a restart

1. With the app open, enable airplane mode.
2. Force-close the app and relaunch it.
3. Open the Quran tab.

**Expect**: the strip is fully populated with the same 5 suras, newest centred, and it
appears immediately with no spinner and no network access. *(FR-011, FR-013, FR-014,
SC-003, SC-004)*

### V6 — Resume at the last verse

1. Open a long sura, such as Al-Baqarah (286 verses).
2. Scroll down to roughly verse 12 and leave the screen via back.
3. Return to the Quran screen and tap Al-Baqarah.

**Expect**: the reading view opens at approximately verse 12, not at verse 1. Because verse
heights vary, "approximately" is expected — it must be close, not exact.
*(FR-009, SC-007)*

### V7 — Fallback to the first verse

1. Open a sura and do **not** scroll at all.
2. Leave and reopen it from the strip.

**Expect**: the reading view opens at verse 1. *(FR-010)*

### V8 — Corrupt stored data

1. With the app closed, corrupt the stored `quran_reading_history_v1` value (via
   `adb shell` on an emulator, or by editing app storage on a device).
2. Relaunch and open the Quran tab.

**Expect**: no crash, no error banner, and a single centred Al-Fatihah card. The app remains
fully usable. *(FR-015, SC-008)*

### V9 — Stale sura number

1. Store a history whose `suraNumber` is beyond 114, for example `999`.
2. Relaunch and open the Quran tab.

**Expect**: the impossible entry is discarded, the valid entries still appear, and if none
are valid the strip falls back to Al-Fatihah. *(FR-015)*

### V10 — Out-of-range verse

1. Store a `lastVerse` larger than the sura's real verse count.
2. Relaunch, open the Quran tab, and tap that sura.

**Expect**: the reading view opens at the sura's **last** verse, not past the end and not
crashing. *(FR-020)*

### V11 — Regressions the spec forbids

1. Search the sura list for a name and open a result.

**Expect**: the search still filters as before, the opened sura becomes the newest in the
strip, and nothing about the list's ordering or behaviour changed.
*(FR-012, FR-016, FR-018)*

2. Read through a sura normally, scrolling the full text.

**Expect**: rendering, wrapping, and scroll feel are unchanged. The only difference is
where it opens when you return. *(FR-019)*

## Traceability

| Scenario | Requirements |
|----------|--------------|
| V1 | FR-003, FR-006, SC-002 |
| V2 | FR-002, FR-007, FR-009, SC-001 |
| V3 | FR-004, FR-008, SC-005, SC-006 |
| V4 | FR-004, FR-005, SC-006 |
| V5 | FR-011, FR-013, FR-014, SC-003, SC-004 |
| V6 | FR-009, SC-007 |
| V7 | FR-010 |
| V8 | FR-015, SC-008 |
| V9 | FR-015 |
| V10 | FR-020 |
| V11 | FR-012, FR-016, FR-018, FR-019 |

## Reference

- Entities, invariants, and reconciliation rules: [data-model.md](data-model.md)
- Technical decisions and rejected alternatives: [research.md](research.md)
- Interfaces: [contracts/](contracts/)
