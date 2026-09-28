# Implementation Plan: Quran Last-Read Sura Cache

**Branch**: `001-quran-last-read-cache` | **Date**: 2026-09-28 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-quran-last-read-cache/spec.md`

## Summary

Turn the Quran screen's "Most Recently" strip — which today renders all 114 suras and
therefore remembers nothing — into a persisted reading history of the last 5 opened suras
with the newest centred on arrival. Tapping an entry opens that sura at the last verse the
reader viewed, falling back to its first verse. State lives in a Cubit, the history is
persisted as a single JSON blob through a domain repository contract, and the verse
position is derived from the existing `Text.rich` layout without changing how the reading
view renders.

## Technical Context

**Language/Version**: Dart 3.13.1 (SDK constraint `^3.10.1`), Flutter 3.47.1 (stable)

**Primary Dependencies**: `flutter_bloc` 9.1.1 (Cubit), `get_it` 9.2.1 (DI),
`equatable` 2.0.8, `intl` 0.20.3, and **`shared_preferences` (new)** using the
`SharedPreferencesAsync` API

**Storage**: On-device key-value store via `shared_preferences`. One key,
`quran_reading_history_v1`, holding a single JSON document. A single-key write means a
partial or torn history cannot be observed.

**Testing**: `flutter_test` + `package:test` (both already available via the Flutter SDK).
Hand-written in-memory fakes are used in place of a mocking library, so no new test
dependency is added.

**Target Platform**: Android and iOS as the primary targets; the project also carries web,
Windows, macOS, and Linux targets, all of which `shared_preferences` supports.

**Project Type**: Cross-platform mobile application

**Performance Goals**: The "Most Recently" area must be fully presented within 1 second of
the Quran screen appearing, on every visit and offline (SC-004). The reading view must
keep 60 fps while scrolling; verse tracking must not add per-frame work. The per-sura verse
offset table is computed at most once per sura load and reused.

**Constraints**: Must work with no network (FR-013). Must not alter the sura list, its
ordering, or its search behaviour (FR-018). Apart from the verse it opens at, the reading
view must keep its current rendering and behaviour (FR-019). At most 5 suras retained
(FR-004).

**Scale/Scope**: 114 suras, at most 5 remembered. 7 new source files, 4 modified, 1 new
dependency, 3 test files.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Evidence |
|-----------|------|----------|
| I. Layered Clean Architecture | PASS with documented deviation | New code lands in `lib/modules/quran/{domain,data,presentation}/` with an inward dependency rule. `domain/` imports neither `dart:ui` nor `flutter/painting`; the `TextPainter` measurement stays in `presentation/`. The pre-existing flat files (`quran_view.dart`, `suras/`) are **not** migrated — see Complexity Tracking. |
| II. SOLID | PASS | One reason to change per class. The history entity owns the 5-cap and no-duplicate invariants (SRP). `ReadingHistoryStore` is a narrow contract so a new storage backend needs no change to callers (ISP, DIP). Corrupt or stale data is handled in the model, not spread across callers (OCP). |
| III. Repository Pattern & Dio Networking | PASS | No network access is introduced. The data layer owns all persistence and converts storage exceptions into `Failure` subtypes from `lib/core/errors/`; nothing about storage escapes into Cubits or widgets. No `Dio` instance is created and no endpoint is touched. |
| IV. Cubit State Management | PASS with documented deviation | `QuranHistoryCubit` holds the strip's state with one immutable `Equatable` state class and distinct loading/success/fallback values. It does not touch `BuildContext` or `Navigator`. The pre-existing `setState` search in `QuranView` is **not** touched — see Complexity Tracking. |
| V. Dependency Injection & Testability | PASS | Every Cubit, use case, and repository takes its dependencies through the constructor. A single `SharedPreferencesAsync` instance is created in the composition root, never inside a feature. `main.dart` awaits the initial read so a Cubit never has to render a loading spinner (satisfies FR-014). No `DateTime.now()` or locale read happens at construction. |
| VI. Dart Conventions & Scope Discipline | PASS | `lower_snake_case` files and members, `UpperCamelCase` types. One new dependency (`shared_preferences`) with justification recorded in research.md; no mocking library added because hand-written fakes cover the surface. Lints stay enabled, no `// ignore:` added. Diffs stay inside the Quran feature — no drive-by renames of the misspelled legacy directories (`servies`, `widgtes`, `cutomWidget`, `repositery`). |

**Gate result: PASS.** No unjustified violations. Three deviations are pre-existing and
documented in Complexity Tracking rather than silently absorbed.

### Post-design re-check (after Phase 1)

Re-evaluated once the Phase 0 research and Phase 1 design existed. Findings:

| Principle | Re-check | What the design changed |
|-----------|----------|-------------------------|
| I. Layered Clean Architecture | PASS | The verse-offset logic is the risk: `TextPainter` lives in `flutter/painting` and must not reach `domain/`. The design therefore splits it in two — `presentation/services/verse_offset_table_builder.dart` measures the laid-out text with `TextPainter`, while `domain/services/verse_anchor_resolver.dart` holds only the pure offset-to-verse lookup over a `List<double>`. `domain/` imports neither `flutter/` nor `dart:ui` and stays unit-testable without a widget tree. |
| II. SOLID | PASS | The `ReadingHistoryStore` contract exposes exactly `load` and `save`, keeping the Cubit and use cases ignorant of storage. The entity owns every invariant, so no caller can construct a history violating FR-004 or FR-005. |
| III. Repository Pattern & Dio Networking | PASS | Confirmed no network dependency. Every storage exception is converted to a `Failure` inside `data/`; reconciliation of corrupt and stale data also lives there, so neither the Cubit nor the widget sees a raw exception or a raw JSON value. |
| IV. Cubit State Management | PASS | `QuranHistoryState` exposes `resolved` and `fallback` rather than a nullable list, and has no `loading` state, since startup preloading removes it. The widget holds no fallback branch. Documented deviation for the pre-existing search `setState` stands unchanged. |
| V. Dependency Injection & Testability | PASS | Tightened by the design. `main()` awaits configuration, so the Cubit starts from resolved state and never needs a loading path. `ReadingHistoryStore` is substitutable by a hand-written in-memory fake, and the verse lookup is a pure function over a `List<double>` — both testable with no mocking library and no widget tree, satisfying constitution VI's no-unnecessary-dependency rule. |
| VI. Dart Conventions & Scope Discipline | PASS | The route change from an untyped `SuraModel` cast to a typed `SuraReaderArgs` touches only two call sites, both inside the Quran feature, so FR-018's list and search behaviour stays intact and the diff stays scoped. One new dependency, justified in research.md. |

**Post-design result: PASS.** No gate failure, and no unresolved
`NEEDS CLARIFICATION` remains. One open implementation question is recorded in
[contracts/most_recently_strip_ui.md](contracts/most_recently_strip_ui.md): `CustomCard`
renders the verse count but not the sura's ordinal number, which FR-006 requires. Whether
to extend the shared widget or render the number in a feature-local strip is a task-level
decision, flagged rather than silently decided here, because the widget is shared.

## Project Structure

### Documentation (this feature)

```text
specs/001-quran-last-read-cache/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── reading_history_repository.md
│   ├── reading_view_route.md
│   └── most_recently_strip_ui.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── di/
│       └── injection.dart              # NEW: central composition root (constitution V)
│
├── main.dart                            # MODIFIED: await configureDependencies()
│
└── modules/quran/
    ├── domain/                          # NEW (layered, flutter-free)
    │   ├── entities/
    │   │   ├── reading_history_entry.dart
    │   │   └── reading_history.dart
    │   ├── repositories/
    │   │   └── reading_history_store.dart
    │   ├── services/
    │   │   └── verse_anchor_resolver.dart
    │   └── usecases/
    │       ├── get_reading_history.dart
    │       ├── record_sura_opened.dart
    │       └── record_verse_viewed.dart
    │
    ├── data/                            # NEW
    │   ├── models/
    │   │   └── reading_history_model.dart
    │   ├── datasources/
    │   │   └── reading_history_local_datasource.dart
    │   └── repositories/
    │       └── reading_history_store_impl.dart
    │
    ├── presentation/                    # NEW
    │   ├── controller/
    │   │   ├── quran_history_cubit.dart
    │   │   └── quran_history_state.dart
    │   ├── services/
    │   │   └── verse_offset_table_builder.dart
    │   └── ui/
    │       └── most_recently_strip.dart
    │
    ├── quran_view.dart                  # MODIFIED: host the strip Cubit + new widget
    └── suras/
        ├── sura_item.dart               # MODIFIED: typed route argument
        └── sura_details.dart            # MODIFIED: restore + track verse
```

```text
test/
└── modules/quran/
    ├── domain/
    │   ├── reading_history_test.dart
    │   └── verse_anchor_resolver_test.dart
    ├── data/
    │   └── reading_history_model_test.dart
    └── presentation/
        ├── quran_history_cubit_test.dart
        └── most_recently_strip_test.dart
```

**Structure Decision**: Chosen structure is Option 1 (single project) adapted to an existing
Flutter codebase — the standard `lib/` + `test/` layout, extended with a `core/di/`
composition root. The feature is added to the existing `lib/modules/quran/` feature module
rather than a new module, because it changes that screen's behaviour and shares that
module's sura catalogue. New code is layered per constitution I; the module's pre-existing
flat files are left in place (see Complexity Tracking). No platform-directory changes are
needed because `shared_preferences` ships first-party support for all six targets.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| New code is layered inside `lib/modules/quran/` while the module's existing files (`quran_view.dart`, `suras/*.dart`) stay flat and unlayered | Constitution I requires layering, but the spec's FR-015 and FR-018 forbid altering the sura list, its ordering, or its search, and constitution VI forbids out-of-scope edits. Restructuring the existing flat files would produce a diff spanning files the feature does not need to touch. | Migrating the whole module to three layers in one change — rejected: large unreviewable diff, high merge-conflict risk, and no reader-visible value for this feature. Recorded as a separate refactor change. |
| `QuranView` keeps its existing `setState`-driven search alongside the new Cubit | Constitution IV prefers Cubit, but converting the search would change search behaviour, which FR-018 forbids. | Replacing the search `setState` with a Cubit in this change — rejected: out of scope by FR-018, and it is the exact drive-by refactor constitution VI prohibits. |
| A central `lib/core/di/injection.dart` is introduced alongside the two existing per-feature service locators in `lib/modules/radio/` | Constitution V requires a single composition root and forbids service locators inside feature folders. The new registrations need a compliant home. | Adding this feature's registrations to a third feature-local service locator — rejected: it would compound the violation. Migrating the radio locators is rejected as out of scope. |
