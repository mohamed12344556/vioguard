<!--
SYNC IMPACT REPORT
==================
Version change: [INITIAL] → 1.0.0
Modified principles: N/A (initial fill from template)
Added sections:
  - Core Principles (5 principles defined)
  - UI & Responsiveness Standards
  - Development Workflow
  - Governance
Removed sections: N/A
Templates reviewed:
  - .specify/templates/plan-template.md ✅ (Constitution Check section present, compatible)
  - .specify/templates/spec-template.md ✅ (sections align with principles)
  - .specify/templates/tasks-template.md ✅ (phase structure compatible)
Deferred items: None
-->

# VioGuard Constitution

## Core Principles

### I. Project Unity (NON-NEGOTIABLE)

The VioGuard codebase MUST remain a single, unified Flutter project. All features — authentication,
detection (text & video), history, reports, and profile — are part of one application and MUST share
the same design system, theming tokens, routing, localization, and utility layers. No feature silo
may define its own isolated colors, text styles, or navigation patterns that diverge from the shared
core. Cross-feature code reuse through `lib/core/` is REQUIRED; duplication of core logic is
forbidden.

**Rationale**: A fractured codebase leads to inconsistent UX, inflated maintenance cost, and
conflicting behaviors across screens. Unity ensures every screen feels like the same product.

### II. Responsive UI (NON-NEGOTIABLE)

Every screen and widget MUST render correctly across all supported form factors: phones (small/large),
tablets, and split-screen modes. Layout MUST use `flutter_screenutil` responsive sizing (`.r`, `.w`,
`.h`, `.sp`) — no hardcoded pixel values in widget dimensions or font sizes. Breakpoints for tablet
vs. phone layouts MUST be defined in `lib/core/` and referenced consistently. All screens MUST be
tested at a minimum of two viewport sizes before a feature is considered done.

**Rationale**: VioGuard targets multiple device categories. Hardcoded layouts produce broken UIs on
devices outside the design baseline.

### III. Dark & Light Mode (NON-NEGOTIABLE)

Every widget MUST consume colors exclusively from `Theme.of(context).colorScheme` or named tokens
from `AppColors` that have both light and dark variants. Direct use of hardcoded color literals (e.g.,
`Colors.white`, `Color(0xFF...)`) in widget files is forbidden unless the color is explicitly
theme-independent (e.g., a brand logo background that never changes). Theme switching MUST be instant,
with no flash or visual glitch. New UI components MUST be verified in both `ThemeMode.light` and
`ThemeMode.dark` before merging.

**Rationale**: Users expect seamless dark/light mode support. Hardcoded colors break one mode
silently and erode trust in the app quality.

### IV. Clean Architecture Discipline

The feature layer structure `data → domain → presentation` MUST be respected for all features. Domain
entities MUST NOT depend on data models. Presentation (BLoC/Cubit) MUST NOT directly call data
sources — all access goes through domain repositories. Business logic MUST live in use cases under
`domain/usecases/`, not in Cubits or widgets. Cross-feature dependencies MUST be mediated through
interfaces, not concrete implementations.

**Rationale**: Clean Architecture enables independent testing of each layer and prevents spaghetti
coupling that makes features impossible to maintain or replace.

### V. Quality-First Delivery

Every delivered feature MUST satisfy its acceptance criteria before being considered complete.
"Working" means: no console errors, no visual overflow, no broken navigation, responsive on all
targets, correct in both themes, and localized where applicable. Code MUST NOT be merged if it
introduces regressions in existing features. Simplicity is preferred — complexity MUST be justified.
YAGNI (You Aren't Gonna Need It) applies to all abstractions.

**Rationale**: Shipping broken or half-finished features damages user trust and compounds technical
debt faster than it delivers value.

## UI & Responsiveness Standards

All UI work in VioGuard MUST comply with these non-negotiable standards:

- **Design tokens**: Use `AppColors`, `AppTypography`, and `AppTheme` as the single source of truth.
  Never define colors or text styles inline in widget files.
- **Responsive sizing**: All dimensions MUST use `flutter_screenutil` extensions (`.r`, `.w`, `.h`,
  `.sp`). The canonical design size is `375 × 812` (defined in `main.dart`).
- **Theme compliance**: All widgets MUST be visually verified in both light and dark modes before
  delivery. Screenshots or manual QA in both modes is required.
- **Localization**: All user-facing strings MUST be externalized via `easy_localization`. No
  hard-coded display strings in widget files.
- **Accessibility**: Interactive elements MUST meet minimum touch target sizes (48×48 logical pixels).
  Semantic labels MUST be provided for non-text interactive widgets.
- **No layout overflow**: Widgets MUST NOT produce `RenderFlex` overflow errors under any tested
  viewport. Use `Flexible`, `Expanded`, or `SingleChildScrollView` appropriately.

## Development Workflow

- **Feature branches**: All work MUST happen on a feature branch created by `/speckit.git.feature`.
  Direct commits to `main` are forbidden.
- **Specification first**: Every non-trivial feature MUST have a completed spec (`/speckit.specify`)
  and plan (`/speckit.plan`) before implementation begins.
- **Incremental delivery**: Features MUST be delivered in independently testable user story increments.
  Each story must be demonstrable before the next begins.
- **Commit discipline**: Commits MUST be small, focused, and describe the "why" not just the "what".
  Commits are auto-triggered at key workflow stages via git hooks in `.specify/extensions.yml`.
- **Constitution compliance gate**: Every implementation plan MUST include a Constitution Check section
  verifying compliance with all five core principles before Phase 0 research is approved.
- **No speculative abstractions**: New helpers, utilities, or base classes require justification tied
  to two or more concrete usages. Single-use abstractions are forbidden.

## Governance

This constitution supersedes all other informal practices, verbal agreements, or prior conventions in
the VioGuard project. It represents the binding contract for all contributors and AI agents working
on this codebase.

**Amendment procedure**:

1. Propose the amendment with a written rationale.
2. Identify which templates or commands are affected and list them.
3. Update this file with a version bump following semantic versioning:
   - MAJOR: Principle removal or redefinition with backward-incompatible implications.
   - MINOR: New principle or section added; material expansion of existing guidance.
   - PATCH: Clarifications, wording improvements, typo fixes.
4. Update the Sync Impact Report comment at the top of this file.
5. Propagate required changes to affected templates in `.specify/templates/`.

**Compliance review**: Every PR/implementation plan review MUST include a constitution compliance
check. Violations block merge. Justified exceptions MUST be documented in the plan's Complexity
Tracking table.

**Runtime guidance**: For AI agent development guidance, see `.specify/memory/` for context files
updated per session.

---

**Version**: 1.0.0 | **Ratified**: 2026-04-15 | **Last Amended**: 2026-04-15
