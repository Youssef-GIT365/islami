# Contract: "Most Recently" Strip

**Layer**: `presentation` | **Status**: agreed

Reader-visible contract for the strip at `lib/modules/quran/quran_view.dart:84-116`. The
existing markup already carries the heading "Most Recently"; this defines what the strip
under it presents and guarantees.

## Reader-visible guarantees

| # | Guarantee | Requirement |
|---|-----------|-------------|
| 1 | The most recently opened sura is centred and fully visible when the screen appears, with no scrolling gesture needed. | FR-007 |
| 2 | The cards either side of the centre are the next most recently opened suras, in recency order. | FR-008 |
| 3 | At most 5 cards are ever shown. | FR-004 |
| 4 | No sura appears twice. | FR-005 |
| 5 | Each card shows the sura's number, Arabic name, and English name. | FR-006 |
| 6 | With no remembered sura, Al-Fatihah is shown, centred. | FR-003 |
| 7 | With unreadable or unusable stored data, Al-Fatihah is shown — never an error, a blank card, or a spinner. | FR-014, FR-015 |
| 8 | The strip renders within 1 second of the screen appearing, offline included. | SC-004 |
| 9 | Tapping a card opens that sura at its recorded verse, or at verse 1 when none is recorded. | FR-009, FR-010 |

## Layout approach

Horizontal list, ordered most recent first, preceded by a spacer of half the viewport width
so the newest card lands in the centre on the first frame. Neighbours extend to its right as
a peek affordance. Chosen over a pager and over a scroll-controller jump — see
[research.md R-003](../research.md#r-003-how-is-the-newest-sura-centred-without-a-scrolling-gesture)
for why.

## Presentation rule

The widget MUST render whatever its state hands it and MUST NOT contain fallback logic. The
Al-Fatihah default is resolved into the state by the Cubit, so the widget has no branch that
decides what to show when data is missing. This is what keeps FR-015's error and empty paths
out of the UI layer (constitution I and IV).

## States

| State | When | What the reader sees |
|-------|------|----------------------|
| `resolved` | One or more remembered suras | 1 to 5 cards, newest centred |
| `fallback` | No remembered sura, unreadable data, or no catalogue match | One card: Al-Fatihah, centred |

There is no `loading` state. The history is loaded during startup, so the strip never
renders one — this is what satisfies FR-014 and SC-004 (research R-005).

## Reuse of `CustomCard`

The existing `lib/ui/customWidgets/card_screen_1.dart` already renders exactly the three
fields guarantee 5 requires (English name, Arabic name, verse count) at 320x150. It is
reused unchanged.

One gap worth flagging for the task list: `CustomCard` shows the **verse count** but not
the **sura's ordinal number**, which guarantee 5 requires. Adding a number to the card is a
visual change to a shared widget that other screens may use, so it must be confirmed
against its other call sites before being modified, or satisfied by a feature-local
presentation of the strip instead. This is the one place where the contract and the
existing widget do not line up.

## Not in scope

The strip does not render an empty state, a clear-history control, or a "see all" link.
FR-004 caps the history rather than exposing a management screen, and adding one is a
separate feature.
