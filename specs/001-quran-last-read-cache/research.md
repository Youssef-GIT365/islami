# Phase 0 Research: Quran Last-Read Sura Cache

**Feature**: [001-quran-last-read-cache](spec.md) | **Date**: 2026-09-28

All `NEEDS CLARIFICATION` items raised in the Technical Context section of
[plan.md](plan.md) are resolved below. No clarifications remain open.

---

## R-001: How is the reading position tracked, given the reading view has no per-verse widgets?

**Unknown**: The spec requires recording "the last verse the reader viewed"
(FR-009, FR-012) and resuming there. The current reading view,
`lib/modules/quran/suras/sura_details.dart:64-78`, renders an entire sura as **one**
`Text.rich` whose children are `TextSpan`s generated in a loop. There is no list of verse
widgets, no keys, and no per-verse geometry, so the current verse cannot be read off the
widget tree.

**Decision**: Build a per-sura **verse offset table** once when a sura loads, using
`TextPainter`, and resolve the visible verse from the scroll offset with a pure
binary search.

Method: build the same `TextSpan` tree the widget renders, tracking the character offset
at which each verse's span begins. Lay it out with `TextPainter` at the same width the
widget has, then call `getOffsetForCaret(TextPosition(offset: verseStartOffset),
Rect.zero)` for each verse to obtain its vertical offset. Store the resulting sorted
`List<double>`. On scroll, binary-search that list for the last offset `<= scrollOffset`,
clamped to the valid verse range.

- `TextPainter` construction and `layout({maxWidth})` are the documented usage sequence.
- `getOffsetForCaret(TextPosition, Rect caretPrototype) -> Offset` is the API that maps a
  character position to a paint offset; it is RTL-aware, which matters because the text is
  Arabic.
- The `TextPainter` must be `dispose()`d after the table is built.
- The layout width must be the scroll view's content width, i.e. viewport width minus the
  `EdgeInsets.symmetric(horizontal: 16)` padding at `sura_details.dart:61`. Using a
  mismatched width silently produces wrong offsets, because Arabic text re-wraps.

The pure lookup half is split out into `domain/services/verse_anchor_resolver.dart`, which
takes `List<double>` and a `double` and imports neither `flutter/` nor `dart:ui`, so it is
unit-testable without a widget tree (constitution I and V).

**Rationale**: This is the only approach that satisfies FR-019 — the reading view's
rendering is untouched, only the opening offset and a scroll listener are added.

**Alternatives considered**:
- *Restructure the body into a `ListView.builder` of one widget per verse.* Rejected:
  changes the reading view's layout and build behaviour, which FR-019 forbids, and alters
  text wrapping for a reader mid-read.
- *Assume uniform per-verse height and divide total height by verse count.* Rejected:
  Arabic verses vary from a few words to several lines, so a uniform estimate drifts badly
  in long suras such as Al-Baqarah (286 verses) and would resume at the wrong verse.
- *Record only the opening verse and never update on scroll.* Rejected: fails FR-012 and
  FR-009 for any reader who scrolls before leaving.
- *Use `getBoxesForSelection` per verse instead of `getOffsetForCaret`.* Rejected: it
  returns a list per selection and costs more per verse; one caret query per verse start is
  sufficient and cheaper.

---

## R-002: Where is the reading history persisted?

**Unknown**: FR-011 requires the history to survive app restarts, and the project has no
storage dependency at all. `pubspec.yaml` contains no `shared_preferences`, `hive`,
`sqflite`, or `path_provider`.

**Decision**: Add `shared_preferences` and use the **`SharedPreferencesAsync`** API, storing
one key, `quran_reading_history_v1`, whose value is a single JSON document.

Why `SharedPreferencesAsync` specifically: the package documentation states that
`SharedPreferences` is a legacy API that "will be deprecated in the future", and that new
users are encouraged to use `SharedPreferencesAsync` or `SharedPreferencesWithCache`.
Writing new code against an API already slated for deprecation would create immediate
migration debt, so the async API is chosen.

`SharedPreferencesWithCache` was considered and rejected: its allowlist and in-memory cache
add no value for a five-entry document, and the extra initialisation step buys nothing at
this size.

Shape of the stored document — see [data-model.md](data-model.md):

```json
{ "version": 1, "entries": [ { "suraNumber": 2, "lastVerse": 12 } ] }
```

A single key means one atomic write, so a reader can never observe a half-updated history.
The `version` field lets a future schema change migrate or discard rather than crash, which
is what FR-015's stale-data requirement needs.

**Rationale**: The payload is a handful of integers, well under any storage limit, needs no
queries, and is read once per app start. A relational or document store would be
disproportionate and would add a dependency the constitution forbids without justification.

**Alternatives considered**:
- *`hive`.* Rejected: brings a code-generation step and its own type adapters for what is
  five integer pairs.
- *`sqflite`.* Rejected: a SQL database for a single unqueried key is unjustifiable.
- *A JSON file under the documents directory via `path_provider`.* Rejected: needs a second
  dependency, needs its own atomic-write and corruption handling, and gains nothing.
- *Keeping the history in memory only.* Rejected: directly violates FR-011 and SC-003.

---

## R-003: How is the newest sura centred without a scrolling gesture?

**Unknown**: FR-007 requires the most recently opened sura to be centred and fully visible
with no manual scrolling. `CustomCard` in `lib/ui/customWidgets/card_screen_1.dart:12-13`
is a fixed 320x150 box, so on a typical phone only about one card fits across the width.

**Decision**: Render the strip as a horizontal list ordered most-recent-first, preceded by
a spacer of half the viewport width. The newest card is the first real item, so the leading
spacer parks it in the middle of the visible area on arrival, and the remaining cards
extend to its right as a peek affordance. The viewport width is obtained at layout time, so
the spacer is always exactly half of it.

**Rationale**: It needs no controller, no initial-page calculation, and no reverse
ordering, so the newest card is centred on the very first frame — which is what SC-005's
"100% of visits, with no partially clipped or off-screen entry" requires. Ordering stays
monotonic by recency, so the strip reads naturally to a right-to-left audience.

**Alternatives considered**:
- *`PageView` with the newest at a centre page index.* Rejected: requires padding the list
  to an odd length and computing an initial page from an unknown-at-build-time child count;
  the result jumps once children are built, which risks violating SC-005.
- *Reordering so the newest sits between neighbours, e.g. `[n3, n2, newest, n4, n5]`.* 
  Rejected: recency is no longer monotonic left to right, which is confusing in an RTL
  layout.
- *A `ScrollController` with an initial `jumpTo`.* Rejected: the content width is unknown
  until after layout, so the jump has to be deferred to a post-frame callback, leaving a
  visible snap.

---

## R-004: Where is a sura "opened" recorded?

**Unknown**: FR-016 requires recording a sura only when the reader navigates into the
reading view, and FR-012 requires every entry point to be covered, including search results
and the new strip.

**Decision**: Record on entry **inside the reading view**, not at each call site. The
reading view records `(suraNumber, openingVerse)` when it mounts and then updates
`lastVerse` on scroll end.

**Rationale**: There is one place the reader can arrive, so one place owns the behaviour.
Recording at tap sites would mean every future entry point — a deep link, a notification, a
new screen — has to remember to call the recorder, and a missed call silently breaks
FR-012. The reading-view approach cannot be forgotten.

Updates are written on scroll **end** (a scroll-end notification), not on every frame, so a
drag across a long sura does not produce a write per frame.

**Alternatives considered**:
- *Recording in `SuraItem.onTap` and in the strip's tap.* Rejected: two call sites today,
  and it does not cover the reading view being opened by any future route.
- *Writing on every scroll frame.* Rejected: a sura like Al-Baqarah can generate hundreds
  of writes per gesture, for state that only matters at the moment the reader leaves.

---

## R-005: How does the Cubit know the history before the first frame?

**Unknown**: FR-014 forbids an indefinite loading state and requires the area to be
presented as soon as the screen appears, but reading from storage is asynchronous.

**Decision**: `main()` awaits dependency configuration, which performs the initial read
once at startup and registers the already-loaded value. `QuranHistoryCubit` therefore
starts from a synchronous, already-resolved state and never renders a spinner. Later reads
and writes are asynchronous and non-blocking.

**Rationale**: The payload is tiny and the read is a single key lookup, so doing it during
startup is imperceptible, and it removes the loading state that FR-014 and SC-004 would
otherwise have to account for.

**Alternatives considered**:
- *Loading inside the Cubit and emitting a loading state.* Rejected: guarantees at least one
  spinner frame on every visit, which is exactly what SC-004's one-second budget and FR-014
  are trying to avoid.
- *Showing the Al-Fatihah fallback until the read completes, then swapping.* Rejected:
  causes a visible content flicker, and momentarily shows a sura the reader did not choose.

---

## R-006: How are the strip's states shaped?

**Unknown**: Constitution IV requires distinct loading, success, empty, and error states
rather than nullable fields on one blended state, while FR-003 and FR-015 both resolve to a
single presentable outcome.

**Decision**: A `QuranHistoryState` with an explicit status: `resolved` when one or more
suras are present, and `fallback` when the Al-Fatihah default is being shown. Fallback
covers both "the reader has never opened a sura" (FR-003) and "nothing readable was stored,
or nothing matched the current sura catalogue" (FR-015) — the reader-visible result is
identical, so the two are not distinguished. Every state carries the entries to render, so
the widget never has to decide what to display.

**Rationale**: Keeps the widget free of fallback logic while satisfying constitution IV's
demand for explicit states, and keeps FR-015's corruption and stale-surah paths from
leaking error handling into the UI.

**Alternatives considered**:
- *Three separate states for empty, corrupt, and unmatched.* Rejected: all three render
  identically, so distinguishing them would add branches with no reader-visible difference.
- *A nullable `List<Entry>?` with the widget applying the default.* Rejected: exactly the
  blended nullable state constitution IV prohibits, and it pushes fallback logic into the
  widget.

---

## Dependency justification (constitution VI)

| Dependency | New? | Justification |
|------------|------|---------------|
| `shared_preferences` | **Yes** | FR-011 and SC-003 require the history to survive app restarts, and the project has no storage layer. The payload is five integer pairs in a single key, which is exactly the key-value shape this first-party plugin targets. No existing dependency provides persistence. |
| `mocktail` or `mockito` | No — **not added** | Constitution V requires Cubits and use cases to be constructible with fakes. The interfaces in this feature are small (load, save), so hand-written in-memory fakes satisfy the requirement with no new dependency, honouring VI's prohibition on unnecessary packages. |
| `path_provider` | No — **not added** | An alternative storage path, rejected in R-002. Adding it would be a second new dependency for a rejected approach. |

## Open items

None. Every unknown raised in the Technical Context of [plan.md](plan.md) is resolved above,
and no new `NEEDS CLARIFICATION` marker was introduced by this research.
