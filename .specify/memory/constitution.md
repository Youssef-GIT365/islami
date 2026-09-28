# Islami Constitution

## Core Principles

### I. Layered Clean Architecture
Every feature is a self-contained module under `lib/modules/<feature>/` and is split into exactly three layers: `data/` (datasources, models, repository implementations), `domain/` (entities, repository contracts, use cases), and `presentation/` (Cubits, states, screens, widgets). Dependencies MUST point inward only: `presentation` → `domain` → `data`, and `data` MAY depend on `domain` contracts but never the reverse. `domain/` MUST NOT import `flutter/`, `dio`, `http`, or any `data/` or `presentation/` file. Cross-feature reuse goes in `lib/core/` or `lib/ui/`; features MUST NOT import each other's internals — shared contracts are extracted first. Rationale: the dependency rule is the only mechanism that keeps the domain testable without Flutter and prevents the layer collapse that makes refactors expensive.

### II. SOLID Principles
All five principles are binding on every new and modified code.
- **SRP** — a file, class, or Cubit changes for one reason; a screen file holds no business logic and a data file holds no widgets.
- **OCP** — new behaviour is added by new subclasses or new use cases, never by editing a chain of `if`/`switch` branches in existing closed types.
- **LSP** — every repository implementation must be substitutable for its domain contract, including on failure paths.
- **ISP** — domain contracts stay narrow; prefer several small use-case contracts over one fat repository interface.
- **DIP** — high-level policy (domain, presentation) depends on abstractions; concrete `Dio`, storage, and platform plugins are injected, never instantiated inside domain or Cubit code.
Rationale: SOLID is what keeps features independently testable and is a prerequisite for the layered rule in Principle I to actually hold in code.

### III. Repository Pattern & Dio Networking
Presentation code MUST reach data only through a use case backed by a domain repository contract. A `data/` repository implementation owns its datasource, translates `Dio` responses into entities, and converts transport errors (`DioException`, timeouts, malformed payloads) into `Failure` subtypes defined under `lib/core/errors/`; `DioException` MUST NOT escape the `data/` layer, and raw JSON maps MUST NOT reach a Cubit or a widget. All network calls MUST use a single centrally configured `Dio` instance with base URL, headers, and timeouts registered in DI; feature code MUST NOT create its own `Dio`, call `http`, or hardcode full endpoint URLs with inline query secrets. Wire models extend `Equatable` and keep parsing in the model, never in the entity or Cubit. Rationale: centralising transport keeps credentials and timeouts in one auditable place and makes every data path reproducible in tests.

### IV. Cubit State Management
`flutter_bloc`'s `Cubit` is the mandated state holder for all feature state; feature code MUST NOT use `Bloc`-with-events, `setState`, `ValueNotifier`, or third-party state packages unless the feature's spec justifies the deviation. Each Cubit owns exactly one immutable state class, states extend `Equatable` with complete `props`, and every state transition MUST go through an `emit`. `BuildContext` MUST NOT cross layer boundaries and MUST NOT be read after `await` without a mounted check; Cubits MUST NOT call `Navigator` directly — they emit a state and the widget navigates. Loading, success, empty, and error states are distinct state values, not nullable fields on one blended state. Rationale: a single state-transition mechanism is what makes widget tests able to assert on emitted states without pumping the whole tree.

### V. Dependency Injection & Testability
All external dependencies are provided by constructor injection and registered centrally in the DI container (`get_it`) in one composition root; service locators MUST NOT be declared inside feature folders, and the DI module graph MUST be free of circular registrations. Every Cubit, use case, and repository implementation MUST be constructible in a test with hand-written fakes, so none of them may depend on `BuildContext`, a static singleton, a top-level mutable global, or `DateTime.now()`/locale read at construction time — ambient time and locale MUST be passed in. Each feature MUST ship unit tests for its Cubits and use cases, and widget tests for its screens. `flutter analyze` MUST report zero issues and `flutter test` MUST pass before a change is considered complete. Rationale: DI and testability are the same requirement seen from two sides — a test cannot substitute a fake for something it cannot inject.

### VI. Dart Conventions & Scope Discipline
Names MUST be descriptive and unambiguous: `UpperCamelCase` for types, `lower_snake_case` for files, directories, fields, and locals; `_` for private members. `const` is used wherever values permit, and `final` is preferred over `var` for fields. Analyzer output is the source of truth for style — the project lints (`flutter_lints` plus `analysis_options.yaml`) MUST stay enabled rather than being silenced file-by-file, and `// ignore:` is permitted only with a stated reason. New packages MUST NOT be added to `pubspec.yaml` unless the feature's spec names them and no existing dependency covers the need; a new dependency needs a one-line justification in the pull request. A change MUST stay inside the requested feature: unrelated refactors, drive-by renames, formatting sweeps, and reformatting of untouched files are out of scope and belong in their own change. Rationale: review cost and merge conflict rate grow with diff size, so scope discipline is enforced as a hard rule rather than a preference.

## Architecture & Technology Constraints

- **Required stack** — Flutter/Dart per the SDK constraint in `pubspec.yaml`; `get_it` for DI, `flutter_bloc` Cubits for state, `dio` for networking, `equatable` for value equality, `intl` for formatting. `dartz` MAY be used for `Either`-based results where it removes nested null checks, but it is not mandatory and MUST NOT be the only error channel alongside `Failure`.
- **Layering** — `lib/core/` holds cross-cutting infrastructure only: `api/`, `errors/`, `routes/`, `theme/`, `colors/`, and generated assets under `gen/` (generated code is never hand-edited). `lib/modules/` holds features. `lib/screens/` and `lib/ui/` are legacy shared-UI locations; new code does not expand them, and existing top-level feature files are migrated into `lib/modules/<feature>/` only when that feature is already being changed.
- **Generated code** — `build_runner` output is committed for asset and font generation, regenerated only via its declared commands, and excluded from analysis and review noise.
- **Configuration and secrets** — API base URLs and environment values live in `lib/core/api/`; API keys are declared as named constants in a single file and never inlined at call sites, embedded in widget code, or committed in per-feature files.
- **Platform directories** — `android/`, `ios/`, `web/`, `windows/`, `macos/`, and `linux/` are changed only when a feature genuinely requires a platform capability, and such a change is called out explicitly in the pull request description.
- **Disallowed without a spec** — global mutable state, `print`-based logging in release paths, `dynamic` across layer boundaries, and god-object or god-widget files.

## Development Workflow & Quality Gates

1. **Specify first** — every feature or change starts as a spec, then a plan, then tasks. Work that is not described in a spec MUST NOT be started.
2. **Layered implementation order** — domain contracts and entities, then use cases, then data implementations and DI registrations, then presentation (Cubit, states, widgets), then navigation wiring. Code is written bottom-up so inward-facing layers exist before the widgets that consume them.
3. **Small cohesive changes** — one feature per change. Unrelated fixes, renames, and formatting are split out rather than bundled.
4. **Gates before merge** — `flutter analyze` reports zero issues; `flutter test` passes; new logic carries unit tests; new screens carry widget tests; DI registrations for the feature are present in the composition root.
5. **Review checklist** — the reviewer confirms: no `DioException` above the data layer, no `BuildContext` in a Cubit or use case, no feature-to-feature internal imports, no new dependency without justification, no out-of-scope edits in the diff, and no unexplained `// ignore:`.
6. **Refactoring is separate** — renaming public symbols, moving files between layers, or reformatting is its own change with its own justification, even when it is motivated by adjacent work.
7. **Deviation handling** — any rule in this constitution that a change cannot satisfy MUST be recorded in the feature spec with the reason and an explicit approval, rather than left as an undocumented exception in the diff.

## Governance

This constitution supersedes conflicting conventions in the repository. Where an existing file, an established habit, or an AI tool's default suggestion disagrees with this document, this document wins; the change is made to conform the code, not the other way around.

**Amendment procedure** — amendments are proposed by editing `.specify/memory/constitution.md`, stating what changed and why, and are approved by the project owner before taking effect. An amendment that removes or redefines an existing principle requires a stated migration plan for code that already violates it. Amendments that touch Principles I–VI are reviewed against the architecture they govern, since they invalidate the structure of existing features.

**Versioning policy** — the constitution is versioned MAJOR.MINOR.PATCH. MAJOR for backward-incompatible removals or redefinitions of a principle; MINOR for a new principle or section, or a materially expanded rule; PATCH for clarifications, wording fixes, and other non-semantic refinements. The version line is updated in the same edit as the text, and `Last Amended` is set to the date of the change while `Ratified` keeps the original adoption date.

**Compliance review** — every change is reviewed against this constitution before merge, using the workflow checklist above. Compliance gaps are fixed in the change that introduced them rather than deferred. This constitution is the single source of runtime development guidance for both humans and AI tooling; if a separate agent-guidance file (for example `AGENTS.md`) is introduced later, it MUST NOT restate or contradict these rules — it points back here and carries tooling configuration only.

**Version**: 1.0.0 | **Ratified**: 2026-09-28 | **Last Amended**: 2026-09-28
