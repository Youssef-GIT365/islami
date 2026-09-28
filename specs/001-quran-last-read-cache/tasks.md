---
description: "Task list for the Quran last-read sura cache feature"
---

# Tasks: Quran Last-Read Sura Cache

**Input**: Design documents from `/specs/001-quran-last-read-cache/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md,
data-model.md, contracts/, quickstart.md

**Tests**: Test tasks are INCLUDED. The task template treats tests as optional, but
constitution Principle V mandates unit tests for Cubits and use cases and widget tests for
screens, and the plan's quality gate 4 requires tests for new logic and new screens. This
constitution requirement is the basis for including them.

**Organization**: Tasks are grouped by user story to enable independent implementation and
testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single Flutter project**: `lib/` and `test/` at repository root, mirroring the
  existing layout in plan.md
- Feature code lives in `lib/modules/quran/{domain,data,presentation}/` per constitution I
- Shared infrastructure in `lib/core/`
- Test paths mirror source paths under `test/modules/quran/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Add `shared_preferences` to the `dependencies:` block in pubspec.yaml and run `flutter pub get`. Use the `SharedPreferencesAsync` API; the package documentation states the `SharedPreferences` class is a legacy API that "will be deprecated in the future". This is the only new dependency for the feature
- [X] T002 [P] Create the layer directories `lib/modules/quran/domain/{entities,repositories,services,usecases}`, `lib/modules/quran/data/{models,datasources,repositories}`, `lib/modules/quran/presentation/{controller,services,ui}`, `lib/core/di`, and `test/modules/quran/{domain,data,presentation,fakes}`
- [X] T003 [P] Create a read-only sura catalogue facade in lib/modules/quran/domain/services/sura_catalogue.dart exposing unmodifiable views of `arabicAuranSuras`, `englishQuranSurahs`, and `AyaNumber`, plus `verseCountOf(int suraNumber)` and `namesOf(int suraNumber)`. Do NOT expose the mutable top-level lists, and do NOT modify lib/modules/quran/suras/sura_model.dart in this change — the raw lists stay put per the plan's Complexity Tracking

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

The `ReadingHistoryEntry` and `ReadingHistory` entities serve US1, US2, and US3, so they
are placed here rather than in a story phase. Constraints quoted below are verbatim from
data-model.md and must not be relaxed at implementation time.

- [X] T004 [P] Create the `ReadingHistoryEntry` entity in lib/modules/quran/domain/entities/reading_history_entry.dart as an immutable `Equatable` class with `suraNumber` (`int`, required) and `lastVerse` (`int?`, nullable). Enforce: "`suraNumber` MUST be `>= 1`" and "`lastVerse`, when present, MUST be `>= 1`". Document that `lastVerse` being `null` "means the reader never viewed a verse in this sura, which is distinct from verse 1"
- [X] T005 Create the `ReadingHistory` entity in lib/modules/quran/domain/entities/reading_history.dart as immutable with a single `entries` field that is "Ordered most recent first. Never empty in a constructed instance; the empty case is represented by the fallback state, not by an empty list". Implement `recordOpened`, `recordVerseViewed`, `entryFor`, and `mostRecent`. Enforce all four invariants: "MUST hold at most 5 entries; the least recently opened is discarded beyond that (FR-004)", "MUST NOT contain the same `suraNumber` twice (FR-005)", "MUST be sorted most recently opened first (FR-001)", and "MUST be immutable once returned; updates produce a new instance". No mutating methods
- [X] T006 [P] Declare the `ReadingHistoryStore` contract in lib/modules/quran/domain/repositories/reading_history_store.dart with `Future<ReadingHistory> load()` and `Future<void> save(ReadingHistory history)`, per contracts/reading_history_repository.md. Document that `load` returns an empty history — not a `Failure` — when the document is "missing, or when the stored document is unreadable, malformed, of an unrecognised version, or fully irreconcilable with the current sura catalogue". This file MUST NOT import `flutter/`, `dart:ui`, or `shared_preferences`
- [X] T007 [P] Create the hand-written in-memory fake at test/modules/quran/fakes/fake_reading_history_store.dart backed by a mutable string, with a `seedRaw(String?)` hook to pre-seed corrupt bytes and a `savedDocuments` list to assert what was written. Do NOT add a mocking library — constitution VI forbids unnecessary dependencies and this surface needs only load and save
- [X] T008 [P] Create the `GetReadingHistory` use case in lib/modules/quran/domain/usecases/get_reading_history.dart, taking a `ReadingHistoryStore` through its constructor and returning the loaded history
- [X] T009 [P] Create the `RecordSuraOpened` use case in lib/modules/quran/domain/usecases/record_sura_opened.dart. It loads, applies `recordOpened(suraNumber, openingVerse)`, and saves. A failed save MUST be swallowed as non-fatal: "the in-memory history stays correct for the current session and the reader is not shown an error (FR-015)"
- [X] T010 [P] Write unit tests in test/modules/quran/domain/reading_history_test.dart covering the capacity cap, the no-duplicate promotion, recency ordering, immutability, `entryFor` returning `null` for an absent sura, and `lastVerse` being `null` versus `1` as distinct values
- [X] T011 [P] Create the `ReadingHistoryModel` in lib/modules/quran/data/models/reading_history_model.dart. Serialise to the shape documented in data-model.md: key `quran_reading_history_v1`, value `{"version": 1, "entries": [{"suraNumber": int, "lastVerse": int?}]}`. Implement every row of the data-model Reconciliation table: missing or invalid JSON, absent or unrecognised `version`, `suraNumber` beyond the catalogue, all entries discarded, `lastVerse` beyond the verse count clamped to the last verse (FR-020), malformed `lastVerse` treated as `null` (FR-010), more than 5 entries truncated, and duplicate `suraNumber` keeping the first occurrence
- [X] T012 [P] Create the local data source in lib/modules/quran/data/datasources/reading_history_local_datasource.dart wrapping a single injected `SharedPreferencesAsync` instance. Read and write exactly one key. MUST NOT instantiate `SharedPreferencesAsync` inside the class — it is constructed in the composition root per constitution V
- [X] T013 Create `ReadingHistoryStoreImpl` in lib/modules/quran/data/repositories/reading_history_store_impl.dart implementing `ReadingHistoryStore` over the data source. Convert any thrown storage exception into a `Failure` subtype from lib/core/errors/; no raw exception may escape the data layer (constitution III)
- [X] T014 [P] Write tests in test/modules/quran/data/reading_history_model_test.dart covering each Reconciliation row, using `FakeReadingHistoryStore.seedRaw` to supply corrupt input. Also write test/modules/quran/data/reading_history_store_impl_test.dart asserting the exact serialised document written to a single key, and that a throwing data source surfaces a `Failure` rather than an exception
- [X] T015 [P] Write use case tests in test/modules/quran/domain/recording_usecases_test.dart asserting `RecordSuraOpened` promotes without duplicating and preserves other entries' `lastVerse`, and that a failed save does not throw
- [X] T016 Create the central composition root in lib/core/di/injection.dart per constitution V: register the single `SharedPreferencesAsync` instance, `ReadingHistoryStore`, and the use cases. `configureDependencies()` MUST be `async` and MUST perform the initial history read once during startup, per research.md R-005, so the Cubit starts from resolved state and never renders a loading state (FR-014). Do NOT touch the two existing per-feature service locators in lib/modules/radio/
- [X] T017 Modify lib/main.dart to `await configureDependencies()` after `WidgetsFlutterBinding.ensureInitialized()` and before `runApp`, leaving the existing `setupServiceLocator()` and `setupServiceLocator2()` calls in place

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Resume my last surah (Priority: P1) - MVP

**Goal**: The Quran screen remembers the sura the reader opened most recently, offers it
in the "Most Recently" area for one-tap resume, falls back to Al-Fatihah when nothing is
remembered, and remembers across app restarts.

**Independent Test**: Open a sura from the list, go back, and confirm the strip offers that
sura; force-close and relaunch and confirm it is still offered; open a fresh install's
Quran screen and confirm a single centred Al-Fatihah card. Covers FR-001, FR-002, FR-003,
FR-006, FR-011 through FR-018, SC-001, SC-002, SC-003.

### Tests for User Story 1

> **NOTE**: Write these tests FIRST, ensure they FAIL before implementation

- [X] T018 [P] [US1] Write Cubit tests in test/modules/quran/presentation/quran_history_cubit_test.dart using `FakeReadingHistoryStore`. Cover: resolved state when the store returns entries, `fallback` state when the store is empty, `fallback` state when the store throws, the absence of any `loading` state, and that the Cubit never touches `BuildContext` or `Navigator`
- [X] T019 [P] [US1] Write a widget test in test/modules/quran/presentation/most_recently_strip_test.dart asserting the remembered sura's ordinal number, Arabic name, and English name are all rendered (FR-006), and that a single Al-Fatihah card is rendered for the `fallback` state

### Implementation for User Story 1

- [X] T020 [P] [US1] Create `QuranHistoryState` in lib/modules/quran/presentation/controller/quran_history_state.dart as an immutable `Equatable` class with an explicit status of `resolved` or `fallback` and a non-nullable entries list, per research.md R-006. Do NOT use a nullable list or a blended loading state
- [X] T021 [US1] Create `QuranHistoryCubit` in lib/modules/quran/presentation/controller/quran_history_cubit.dart taking `GetReadingHistory` through its constructor. It MUST start from already-resolved state and MUST NOT emit a loading state. Resolve an empty or failed load to `fallback` carrying the Al-Fatihah entry
- [X] T022 [P] [US1] Create the `SuraReaderArgs` route argument class in lib/modules/quran/presentation/ui/sura_reader_args.dart per contracts/reading_view_route.md, with required `suraNumber` and `startVerse` defaulting to 1
- [X] T023 [US1] Create `MostRecentlyStrip` in lib/modules/quran/presentation/ui/most_recently_strip.dart rendering exactly the entries its state provides and containing NO fallback logic — "the Al-Fatihah default is resolved into the state by the Cubit, so the widget has no branch that decides what to show when data is missing". Reuse `CustomCard` from lib/ui/customWidgets/card_screen_1.dart unchanged. Centre placement is NOT part of this story
- [X] T024 [US1] Modify lib/modules/quran/suras/sura_item.dart to push `SuraReaderArgs(suraNumber: sura.surahNumber)` on `AppRoutesName.qurandetails` instead of passing `SuraModel` through untyped route arguments. Search results must keep behaving exactly as before (FR-018)
- [X] T025 [US1] Modify lib/modules/quran/suras/sura_details.dart to read its argument as `SuraReaderArgs`, resolve the sura through `SuraCatalogue`, fall back to Al-Fatihah rather than throwing on an unresolvable sura (FR-015), clamp `startVerse` into `1..verseCount` (FR-010, FR-020), and call `RecordSuraOpened` on entry (FR-012, FR-016). Record inside the reading view, not at tap sites, per research.md R-004, so every future entry point is covered
- [X] T026 [US1] Modify lib/modules/quran/quran_view.dart to delete the `SizedBox(width: 500, height: 150)` block that currently renders all 114 suras under the "Most Recently" heading, and mount `MostRecentlyStrip` fed by `QuranHistoryCubit` instead. Leave the sura list, its ordering, and the `setState` search untouched (FR-018)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - A short history, newest in the centre (Priority: P2)

**Goal**: Up to 5 remembered suras are shown as a strip with the newest centred on the
first frame and no scrolling required, eviction at the cap, and no duplicates.

**Independent Test**: Open six different suras, return to the Quran screen after each, and
confirm the newest is always centred, the neighbours sit around it in recency order, the
strip never exceeds 5 cards, and re-opening an older sura promotes it without duplicating
or discarding the others. Covers FR-004, FR-005, FR-007, FR-008, SC-005, SC-006.

### Tests for User Story 2

- [X] T027 [P] [US2] Extend test/modules/quran/domain/reading_history_test.dart with cap and promotion cases: opening a 6th sura discards the least recently opened; re-opening a sura already present promotes it to index 0 while preserving the other entries and their `lastVerse` values
- [X] T028 [P] [US2] Extend test/modules/quran/presentation/most_recently_strip_test.dart to assert the newest entry is rendered at the centre of the strip's visible width, and that exactly 5 cards render when 6 suras have been opened

### Implementation for User Story 2

- [X] T029 [US2] Add the centred layout to lib/modules/quran/presentation/ui/most_recently_strip.dart per research.md R-003: render entries most-recent-first preceded by a leading spacer of half the viewport width, obtained at layout time, so the newest card is centred on the first frame and neighbours extend to its right
- [X] T030 [US2] Resolve the `CustomCard` ordinal-number gap in lib/ui/customWidgets/card_screen_1.dart per contracts/most_recently_strip_ui.md. FR-006 requires the sura's ordinal number, which `CustomCard` does not render. FIRST search the codebase for all other call sites of `CustomCard`; only if it is used solely by this strip, add the number to the shared widget. If it is used elsewhere, render the number in a feature-local strip presentation instead and leave the shared widget untouched
- [X] T031 [US2] Feed all resolved entries from `QuranHistoryState` into `MostRecentlyStrip` in lib/modules/quran/quran_view.dart, confirming the strip renders 1 to 5 cards with no padding, placeholder, or duplicate entries when fewer than 5 are remembered

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Resume at the verse I stopped at (Priority: P3)

**Goal**: Tapping a remembered sura opens it at the last verse the reader viewed, falling
back to its first verse when none is recorded, and an out-of-range stored verse clamps to
the sura's last verse.

**Independent Test**: Read to a known verse in a long sura, leave, return, and tap that
sura; confirm the reading view opens near that verse. Then open a sura without scrolling
and confirm it opens at verse 1. Covers FR-009, FR-010, FR-020, SC-007.

### Tests for User Story 3

- [X] T032 [P] [US3] Write unit tests in test/modules/quran/domain/verse_anchor_resolver_test.dart for the pure lookup over `List<double>`: "the visible verse is the last entry whose offset is `<= scrollOffset`, clamped into `1..verseCount`", with "a negative scroll offset resolves to verse 1" and "an offset past the end resolves to `verseCount`". This file MUST NOT need a widget tree
- [X] T033 [P] [US3] Write tests in test/modules/quran/presentation/reading_view_verse_test.dart asserting that an unrecorded sura opens at verse 1, a recorded verse restores near that verse, and a `lastVerse` beyond the verse count opens at the last verse

### Implementation for User Story 3

- [X] T034 [P] [US3] Create `VerseAnchorResolver` in lib/modules/quran/domain/services/verse_anchor_resolver.dart as a pure function over `List<double>` offsets and a `double` scroll offset. This file MUST NOT import `flutter/` or `dart:ui`
- [X] T035 [P] [US3] Create `VerseOffsetTableBuilder` in lib/modules/quran/presentation/services/verse_offset_table_builder.dart per research.md R-001. Build the same `TextSpan` tree the reading view renders while tracking each verse's starting character offset, lay it out with `TextPainter` at the scroll view's content width, call `getOffsetForCaret` per verse start, and `dispose()` the painter. Enforce "`offsets` MUST be non-decreasing; a decreasing table is a build bug and MUST fail loudly in the builder rather than be silently repaired"
- [X] T036 [US3] Create `RecordVerseViewed` in lib/modules/quran/domain/usecases/record_verse_viewed.dart, which replaces only the touched entry's `lastVerse` and is a no-op when the sura is absent from the history
- [X] T037 [US3] Modify lib/modules/quran/suras/sura_details.dart to build the offset table once per sura load, restore the scroll position to `startVerse` after the text is laid out, and call `RecordVerseViewed` on scroll END rather than per frame, per research.md R-004. Do NOT change the reading view's rendering, text wrapping, or layout (FR-019)
- [X] T038 [US3] Update the strip's tap handler in lib/modules/quran/presentation/ui/most_recently_strip.dart to pass `SuraReaderArgs(suraNumber: entry.suraNumber, startVerse: entry.lastVerse ?? 1)` per contracts/reading_view_route.md

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T039 [P] Record the `shared_preferences` justification in the pull request description, as constitution VI requires for every new dependency
- [X] T040 [P] Verify no `// ignore:` or `// ignore_for_file:` was added anywhere in the new code, and that lints were silenced nowhere
- [X] T041 Confirm lib/modules/radio/, the two per-feature service locators, the misspelled legacy directories (`servies`, `widgtes`, `cutomWidget`, `repositery`), and test/widget_test.dart are all untouched by this change, per the plan's Complexity Tracking
- [X] T042 Run `flutter analyze` and confirm it reports zero issues
- [X] T043 Run `flutter test` and confirm the full suite passes
- [ ] T044 Walk the 11 manual validation scenarios V1 through V11 in quickstart.md, including the offline and corrupt-data cases V5 and V8
- [X] T045 Review `git diff` against the spec's FR-001 through FR-020 and SC-001 through SC-009 to confirm every requirement is implemented and that the diff contains no out-of-scope edits

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 -> P2 -> P3)
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - extends the entity and the strip built in US1, so it is practical only after US1 lands, but it adds no new blocking infrastructure
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - adds its own resolver and builder, but its `SuraDetails` and strip edits touch files US1 already edits, so sequence it after US1 to avoid conflicts

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Entities and models before services
- Services before UI
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Entities and use cases within a story marked [P] can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all tests and independent artifacts for User Story 1 together:
Task: "Write Cubit tests in test/modules/quran/presentation/quran_history_cubit_test.dart"
Task: "Write a widget test in test/modules/quran/presentation/most_recently_strip_test.dart"
Task: "Create SuraReaderArgs in lib/modules/quran/presentation/ui/sura_reader_args.dart"
Task: "Create QuranHistoryState in lib/modules/quran/presentation/controller/quran_history_state.dart"
```

## Parallel Example: Foundational

```bash
# Launch all entity, contract, and data scaffolding together:
Task: "Create the ReadingHistoryEntry entity in lib/modules/quran/domain/entities/reading_history_entry.dart"
Task: "Declare the ReadingHistoryStore contract in lib/modules/quran/domain/repositories/reading_history_store.dart"
Task: "Create the hand-written in-memory fake at test/modules/quran/fakes/fake_reading_history_store.dart"
Task: "Create the local data source in lib/modules/quran/data/datasources/reading_history_local_datasource.dart"
Task: "Create the ReadingHistoryModel in lib/modules/quran/data/models/reading_history_model.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently against quickstart V1, V2, and V5
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational -> Foundation ready
2. Add User Story 1 -> Test independently -> Deploy/Demo (MVP!)
3. Add User Story 2 -> Test independently -> Deploy/Demo
4. Add User Story 3 -> Test independently -> Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:
1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 3
   - Developer C: User Story 2, starting once US1's strip and entity work has landed, since it edits both

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All file paths are relative to the repository root
- Constraints quoted inside task descriptions are verbatim from data-model.md and must not be relaxed
