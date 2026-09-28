# Phase 1 Data Model: Quran Last-Read Sura Cache

**Feature**: [001-quran-last-read-cache](spec.md) | **Date**: 2026-09-28

Entities are declared here in domain terms. Wire/storage shapes live in the `data` layer
models and are documented separately, so `domain/` stays free of `dart:convert` and
`flutter/` imports per constitution I.

---

## Reading History Entry

One sura the reader opened, together with the verse they last viewed in it.

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `suraNumber` | `int` | No | 1-based ordinal identifying the sura, matching the existing list's ordering. The stable identity used everywhere; names are display data and are looked up, never stored. |
| `lastVerse` | `int?` | Yes | 1-based ordinal of the last verse viewed. `null` means the reader never viewed a verse in this sura, which is distinct from verse 1. |

**Validation rules**

- `suraNumber` MUST be `>= 1`.
- `lastVerse`, when present, MUST be `>= 1`.
- `suraNumber` MUST correspond to an entry in the current sura catalogue. A mismatch is
  handled by resolution, not by rejecting storage — see [Reconciliation](#reconciliation).

**Relationships**: exactly one `ReadingHistoryEntry` per distinct sura within a
`ReadingHistory`; a `ReadingHistory` holds at most 5 of them.

---

## Reading History

The ordered set of suras the reader opened, most recently opened first, with a hard cap.

| Field | Type | Nullable | Notes |
|-------|------|----------|-------|
| `entries` | `List<ReadingHistoryEntry>` | No | Ordered most recent first. Never empty in a constructed instance; the empty case is represented by the fallback state, not by an empty list. |

**Invariants** (enforced by the entity, so no caller can build a history that breaks them)

| Rule | Requirement | Enforced by |
|------|-------------|-------------|
| Capacity | MUST hold at most 5 entries; the least recently opened is discarded beyond that (FR-004) | Constructor and `recordOpened` |
| Uniqueness | MUST NOT contain the same `suraNumber` twice (FR-005) | `recordOpened` promotes an existing entry instead of appending |
| Ordering | MUST be sorted most recently opened first (FR-001) | `recordOpened` places the touched entry at index 0 |
| Immutability | MUST be immutable once returned; updates produce a new instance | `final` fields, no mutating methods |

**Operations**

| Operation | Effect | Requirements |
|-----------|--------|--------------|
| `recordOpened(suraNumber, openingVerse)` | Returns a new history with the sura at index 0, demoting any previous entry for that sura rather than duplicating it, and dropping the last entry if the result would exceed 5. Preserves `lastVerse` for suras not being touched. | FR-001, FR-004, FR-005, FR-012, FR-013 |
| `recordVerseViewed(suraNumber, verse)` | Returns a new history with only that entry's `lastVerse` replaced, leaving order and capacity unchanged. A no-op if the sura is not present. | FR-009, FR-012 |
| `entryFor(suraNumber)` | Returns the entry for a sura, or `null`. | FR-009 |
| `mostRecent` | The entry at index 0. | FR-007 |

**State transitions**

```text
        (no history yet)
               |
   reader opens sura N
               v
        [N] ------------------------------------.
               |  reader opens sura N again       |
               v                                   |
        [N, N, ...] rejected; stays [N]           |
               |  reader opens sura M              |
               v                                   |
        [M, N] ......... reader opens sura P ......+
               |                                   |
               v                                   |
        [P, M, N]                                   |
               |  reader opens a 6th sura Q         |
               v                                   |
        [Q, P, M, N]  -- oldest (N) dropped         |
               |  7th sura R                       |
               v                                   |
        [R, Q, P, M]  -- oldest (N) already gone  --+
```

Re-opening a sura already in the history promotes it to index 0 and **keeps** the other
entries (FR-005), it does not reset the history to a single item.

---

## Verse Offset Table

A presentation-layer artefact, not a stored entity. It exists only while a reading view is
open, and is never persisted.

| Field | Type | Notes |
|-------|------|-------|
| `offsets` | `List<double>` | Vertical offset of each verse's start, index `i` holding verse `i + 1`. Ascending and non-empty for a non-empty sura. |
| `verseCount` | `int` | Length of `offsets`; equals the sura's verse count. |

Built once per sura load from the laid-out `TextSpan` tree (see research R-001), then
discarded when the reading view closes.

**Resolution rule**: given a scroll offset, the visible verse is the last entry whose
offset is `<= scrollOffset`, clamped into `1..verseCount`. A negative scroll offset resolves
to verse 1; an offset past the end resolves to `verseCount`.

**Validation rules**

- The table MUST be built at the same layout width the reading view renders at, otherwise
  Arabic re-wrapping invalidates every offset.
- `offsets` MUST be non-decreasing; a decreasing table is a build bug and MUST fail loudly
  in the builder rather than be silently repaired.

---

## Reconciliation

The stored document is untrusted input and can disagree with the current sura catalogue.
Reconciliation happens in one place, in the `data` layer, before an entity is constructed.

| Stored condition | Resolution | Requirement |
|------------------|------------|-------------|
| Document missing | Empty history; state resolves to the Al-Fatihah fallback | FR-003 |
| Document is not valid JSON | Same as missing; no error surfaced to the reader | FR-015 |
| `version` is absent or unsupported | Same as missing; no attempt to migrate a format this version does not know | FR-015 |
| An entry's `suraNumber` exceeds the catalogue size, or matches no known sura | That entry is discarded; surviving entries are kept | FR-015 |
| Every entry discarded | Empty history; Al-Fatihah fallback | FR-003, FR-015 |
| `lastVerse` exceeds the sura's verse count | Clamped to the sura's last verse | FR-020 |
| `lastVerse` absent or malformed | Treated as `null`; the reading view opens at verse 1 | FR-010 |
| Document contains more than 5 entries | Truncated to the first 5 after ordering | FR-004 |
| Document contains a duplicate `suraNumber` | First occurrence kept, later ones discarded | FR-005 |

The reader is never shown an error for any of these conditions. A storage read that
**throws** rather than returning bad data is a different path: it becomes a `Failure` in
`lib/core/errors/`, and the Cubit resolves to the same fallback state (FR-015).

---

## Storage Document

The `data`-layer shape written to the `quran_reading_history_v1` key. Recorded here for
reference; the parsing rules that produce it are in the Reconciliation table above.

```json
{
  "version": 1,
  "entries": [
    { "suraNumber": 2, "lastVerse": 12 },
    { "suraNumber": 1, "lastVerse": 7 },
    { "suraNumber": 36, "lastVerse": null }
  ]
}
```

| Key | Type | Notes |
|-----|------|-------|
| `version` | `int` | Schema version. Currently `1`. A stored value this build does not recognise is discarded rather than guessed at. |
| `entries` | `List<Object>` | Most recent first. Each object carries `suraNumber` (required) and `lastVerse` (optional, may be `null` or absent). |

`version` is written but never incremented by this feature. It exists so a future change
can migrate deliberately instead of crashing on an unrecognised shape, which is what
FR-015's stale-data guarantee depends on.
