# Feature Specification: Quran Last-Read Sura Cache

**Feature Branch**: `001-quran-last-read-cache`

**Created**: 2026-09-28

**Status**: Draft

**Input**: User description: "add cach feature to quran screen that shows last quran sura in the middle like al-fatiha"

**Clarifications resolved**: Q1 = A (memory persists across app restarts), Q2 = B (ordered
history of the last 5 suras), Q3 = C (resume at the last-viewed verse, falling back to the
start of the sura when none is recorded).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Resume my last surah (Priority: P1)

A returning reader who opens the Quran screen finds the sura they read most recently
presented for them, without having to search the 114-entry list or remember which sura it
was. They tap it once and continue reading. This holds across app sessions: the reader
who closes the app and comes back tomorrow still finds their sura waiting.

**Why this priority**: This is the entire value of the feature. Without it the reader
gains nothing, and the current "Most Recently" strip is actively misleading because it
lists every sura rather than a remembered one.

**Independent Test**: Can be fully tested by opening a sura, leaving the Quran screen,
re-entering it, and confirming the last-read sura is offered for one-tap resume; then
closing and reopening the app and confirming it is still offered.

**Acceptance Scenarios**:

1. **Given** the reader previously opened Surah Al-Baqarah, **When** they return to the
   Quran screen, **Then** Al-Baqarah is shown in the "Most Recently" area and tapping it
   opens Al-Baqarah.
2. **Given** the reader has never opened any sura, **When** they first open the Quran
   screen, **Then** the "Most Recently" area shows Al-Fatihah and does not appear empty
   or broken.
3. **Given** the "Most Recently" area shows a remembered sura, **When** the reader views
   the screen, **Then** that sura's identifier, Arabic name, and English name are all
   visible on the presented entry.
4. **Given** the reader's last-read sura is remembered, **When** the app is closed and
   reopened, **Then** that sura is offered again on the Quran screen.

---

### User Story 2 - A short history, newest in the centre (Priority: P2)

The reader who has been moving between a few suras sees all of them offered together, with
the one they read most recent sitting in the middle of the strip and the earlier ones
arranged around it, exactly as Al-Fatihah sits in the middle by default. The strip never
grows without bound.

**Why this priority**: It removes recurring friction on every visit and makes the
"Most Recently" heading honest. The remembered sura is only useful if it is already
visibly centred when the reader arrives, so this depends on Story 1 but is separable
from it.

**Independent Test**: Can be fully tested by opening more suras than the strip can hold,
re-entering the Quran screen, and confirming the most recent sura is centred, that the
earliest ones have been dropped, and that no scrolling gesture is needed.

**Acceptance Scenarios**:

1. **Given** the reader's last-read sura, **When** the Quran screen opens, **Then** that
   sura is the centred, fully visible entry in the "Most Recently" area with no manual
   scrolling required.
2. **Given** the reader has opened 5 different suras, **When** the Quran screen opens,
   **Then** all 5 are shown, the most recent occupies the centre, and the other 4 fill the
   positions around it.
3. **Given** the reader opens a 6th sura, **When** the Quran screen opens, **Then** the
   strip shows the 5 most recent and the least recently read of the previous 5 is no
   longer shown.
4. **Given** the reader has opened only one sura, **When** the Quran screen opens, **Then**
   that single entry is still presented in the centre of the area.

---

### User Story 3 - Resume at the verse I stopped at (Priority: P3)

A reader who stopped partway through a sura returns to that sura and lands on the verse
they were last looking at, not at the top. A reader who never got past the beginning of a
sura still lands at the beginning, so the resume never fails.

**Why this priority**: It delivers the real "resume" benefit, but the feature already
delivers value with only the sura-level entry point wired up.

**Independent Test**: Can be fully tested by reading to a known verse in a sura, leaving,
returning, tapping that sura, and confirming the reading view opens at that verse; then
confirming a sura with no recorded verse opens at its first verse.

**Acceptance Scenarios**:

1. **Given** the reader last viewed verse 12 of Al-Baqarah, **When** they tap Al-Baqarah
   in the "Most Recently" area, **Then** the reading view opens at verse 12.
2. **Given** the reader has no recorded verse for a sura, **When** they tap it, **Then**
   the reading view opens at the first verse of that sura.
3. **Given** the reader has scrolled to a further verse since, **When** they tap the same
   sura again later, **Then** the reading view opens at that further verse.

---

### Edge Cases

- **No sura ever opened**: the "Most Recently" area falls back to Al-Fatihah rather than
  showing an empty strip, a spinner, or a broken layout.
- **Fewer suras than the strip can hold**: 1 to 4 remembered suras are shown without
  padding, blank placeholders, or duplicated entries, and the newest stays centred.
- **Remembered sura no longer exists in the sura list**: if a remembered entry cannot be
  matched to a known sura (for example after the sura data is updated), it is dropped and
  the remaining remembered suras are still shown; if none remain, the area falls back to
  Al-Fatihah. The screen must not crash or show a blank entry.
- **Remembered data is missing or unreadable**: the area falls back to Al-Fatihah with no
  error state.
- **More than 5 suras opened**: only the 5 most recent are retained; the oldest is
  discarded rather than the area growing.
- **The same sura opened repeatedly**: it is not duplicated, and it becomes the most
  recent entry.
- **An older remembered sura re-opened**: it moves to the centre as the most recent,
  without creating a duplicate and without dropping the other remembered suras.
- **Reader opens suras from both the "Most Recently" area and the main list**: the most
  recent open wins in both cases.
- **Reader enters the Quran screen repeatedly without opening a sura**: the remembered
  history is stable and does not drift, reorder, or reset.
- **Recorded verse is beyond the sura's current length**: if the stored verse no longer
  exists, the reading view opens at the sura's last verse.
- **Very long Arabic sura names**: the centred entry remains fully visible and its name is
  not clipped mid-word.
- **App is offline**: the "Most Recently" area is populated entirely from locally known
  sura data, with no network dependency.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST remember the suras the reader opened, ordered from most
  recently opened to least recently opened.
- **FR-002**: The system MUST present the remembered suras in the "Most Recently" area of
  the Quran screen.
- **FR-003**: The "Most Recently" area MUST present Al-Fatihah when there are no
  remembered suras available.
- **FR-004**: The system MUST retain at most the 5 most recently opened suras; opening a
  further sura MUST discard the least recently opened of the retained suras.
- **FR-005**: The remembered suras MUST NOT contain the same sura more than once;
  re-opening a remembered sura MUST make it the most recent entry without creating a
  duplicate and without discarding the other remembered suras.
- **FR-006**: Each presented entry MUST display the sura's identifier, Arabic name, and
  English name.
- **FR-007**: The most recently opened sura MUST be presented in the centre of the
  "Most Recently" area, fully visible, with no manual scrolling required to see it.
- **FR-008**: The remaining positions of the area MUST be filled with the next most
  recently opened suras, so that the centre always holds the most recently opened sura.
- **FR-009**: Tapping a presented entry MUST open that sura's reading view at the verse
  the reader last viewed in it.
- **FR-010**: When no verse has been recorded for a sura, its reading view MUST open at the
  first verse of that sura.
- **FR-011**: The remembered suras and their last-viewed verses MUST remain available to
  the reader after the app is closed and reopened.
- **FR-012**: Opening a sura from any entry point in the app MUST record that sura as the
  most recently opened and MUST record the verse being viewed at that moment.
- **FR-013**: The "Most Recently" area MUST be fully presented without network
  connectivity, since the remembered and default suras are locally known.
- **FR-014**: The "Most Recently" area MUST be presented as soon as the Quran screen is
  displayed, with no indefinite loading state and no user action required.
- **FR-015**: A remembered sura that cannot be matched to a known sura MUST be discarded;
  the remaining remembered suras MUST still be presented, falling back to Al-Fatihah only
  when none remain. The system MUST NOT show an error, a blank entry, or fail in this
  case.
- **FR-016**: The system MUST record a sura only when the reader navigates into that
  sura's reading view, and MUST NOT record one for viewing the Quran screen, viewing a
  sura's name, or using search.
- **FR-017**: The remembered suras and verses MUST be stored on the reader's own device
  and MUST NOT require an account or sign-in.
- **FR-018**: This feature MUST NOT alter the existing sura list, its ordering, or the
  behaviour of searching that list.
- **FR-019**: Apart from the verse it opens at, the reading view MUST retain its existing
  behaviour.
- **FR-020**: A recorded verse that no longer exists in the sura MUST cause the reading
  view to open at that sura's last verse.

### Key Entities

- **Reading History**: the ordered set of at most 5 suras the reader opened, ordered from
  most to least recently opened. There is exactly one per reader. Opening a sura adds it or
  promotes it to the front; opening a 6th sura discards the last entry. Identified by a
  reference to a sura.
- **Reading Position**: the verse the reader last viewed within a given sura. At most one
  per remembered sura; absent when the reader never viewed a verse in it. Recorded as the
  reader moves through the sura, and overwritten by later views.
- **Sura**: an entry in the Quran's list of 114 suras. Already exists in the app.
  Attributes used here: position/identifier, Arabic name, English name, verse count. The
  "Most Recently" area renders suras from this same set, and Al-Fatihah is the designated
  default.
- **Reading View**: the screen a sura opens into. Already exists in the app. Accepts the
  verse to open at; defaults to the first verse when none is given.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A returning reader reaches their last-read sura in a single tap from the
  Quran screen, with no searching and no scrolling, in 100% of repeat visits.
- **SC-002**: 100% of readers who have never opened a sura see a usable, tappable
  "Most Recently" entry on their first visit to the Quran screen.
- **SC-003**: 100% of readers who close and reopen the app find their remembered suras and
  their last-viewed verses still offered on the Quran screen.
- **SC-004**: The "Most Recently" area is fully presented within 1 second of the Quran
  screen appearing, on every visit and regardless of network connectivity.
- **SC-005**: The most recently opened sura is centred and fully visible on 100% of
  visits, with no partially clipped or off-screen entry and no scrolling gesture required.
- **SC-006**: On every visit the area shows no more than 5 remembered suras, shows the 5
  most recent after 6 or more have been opened, and shows no duplicate sura in 100% of
  cases.
- **SC-007**: Tapping a remembered sura opens its reading view at the last-viewed verse in
  100% of cases where one is recorded, and at the first verse in 100% of cases where none
  is recorded.
- **SC-008**: 0 crashes or error states attributable to this feature, including when
  remembered data is missing, unreadable, stale, or refers to a sura or verse that no
  longer exists.
- **SC-009**: Readers report reaching their last-read position without searching or manual
  scrolling in at least 90% of repeat visits.

## Assumptions

- The "Most Recently" area already exists on the Quran screen with a heading of
  "Most Recently"; this feature changes what it presents, not whether it exists.
- The full sura list, its search, and the sura reading view already work and are out of
  scope for this feature.
- Al-Fatihah is the intended default and centre reference, per the request.
- A sura counts as "opened" when the reader navigates into that sura's reading view.
- "Last-viewed verse" is recorded per sura and is granular to the verse, not to the exact
  scroll position within a verse.
- The reader is not required to sign in; remembered state is local to the device.
- Sura identity, names, verse counts, and verse order come from the same source the main
  list already uses, so no new sura data source is needed.
- A history of 5 is enough to cover a reader working through a handful of suras between
  visits; a longer history is not required for v1.
- Screen space is assumed to be a standard phone in portrait orientation; tablet and
  landscape-specific layout tuning is out of scope for v1.
