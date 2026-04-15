# Research: Detection Results Refinement & Dummy Data Layer

**Date**: 2026-04-15
**Feature**: `specs/001-detection-results-dummy-data`

## Decision 1: Confidence Score Removal Strategy

**Decision**: Delete the `confidenceScore` constructor parameter and field from
`VideoDetectionResultScreen` entirely — not just hide it conditionally.

**Rationale**: The field is only used in one render block. Keeping a dead parameter
increases maintenance confusion and violates YAGNI. Removing it also cleans up
`app_router.dart` where `args?['confidenceScore']` is passed unnecessarily.

**Alternatives considered**:
- Keep field but don't render it — rejected: dead parameters create false API surface.
- Keep field, add a `showConfidence` flag — rejected: adds complexity for zero benefit.

---

## Decision 2: Text Result State Consolidation

**Decision**: Remove `_getNeutralLabel()` entirely and hardcode `'No Violence Detected'`
as the non-violent label. Remove keyword scanning from `_buildBulletPoints()`.

**Rationale**: Keyword-based UI branching in a result screen couples business logic
(what text means) to presentation (how to render it). The screen should only know
`isViolent: true/false`. Any richer classification belongs in the detection logic layer,
not the result widget.

**Alternatives considered**:
- Keep "Against Violent" as a third `isViolent` value — rejected: spec explicitly
  says two states only; the model enum has `againstViolent` and `neutral` but those
  are history-layer concerns, not result-screen concerns.
- Pass a `label` string from the caller — rejected: over-engineering for two states.

---

## Decision 3: Dummy Data Placement

**Decision**: `lib/core/utils/dummy_data.dart` — a plain Dart class with static
constants/getters.

**Rationale**: `lib/core/utils/` already contains `app_strings.dart`, `constants.dart`,
and `validators.dart`. A `dummy_data.dart` file fits this pattern exactly. Static
members make access trivial (`DummyData.historyItems`) without DI or instantiation.

**Alternatives considered**:
- Separate `lib/core/mock/` directory — rejected: overkill for one file.
- Inline constants in each widget — rejected: that's the current problem being fixed.
- JSON asset file — rejected: adds asset loading complexity; Dart constants are instant.

---

## Decision 4: DetectionHistoryItem — no model changes needed

**Decision**: Use `DetectionHistoryItem` as-is. The `againstViolent` and `neutral`
enum values in `DetectionResult` are kept in the model — they are valid for history
classification. Only the result *screen* is being simplified to two visual states.

**Rationale**: The model and the screen are separate concerns. History items can
have richer classification; the result screen shows a simplified verdict.

---

## Decision 5: DashboardScreen migration approach

**Decision**: Map `DummyData.recentLinks` (a `List<Map<String, dynamic>>`) to
`_RecentLinkItem` at construction time in `_HomeContentState`.

**Rationale**: `_RecentLinkItem` is a private widget-level class. We cannot move it
to `dummy_data.dart` without making it public. The mapping keeps widget internals
private and dummy data format simple (plain maps).

**Alternatives considered**:
- Make `_RecentLinkItem` public and use it directly in `DummyData` — rejected:
  creates a dependency from `core/` on a feature-level widget class, violating
  clean architecture direction.
- Create a separate `RecentLinkData` model in core — rejected: over-engineering;
  the map approach is sufficient for demo data.
