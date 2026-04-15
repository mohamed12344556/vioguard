# Feature Specification: Detection Results Refinement & Dummy Data Layer

**Feature Branch**: `001-detection-results-dummy-data`
**Created**: 2026-04-15
**Status**: Draft
**Input**: User description: "Remove confidence percentage from video result screen; consolidate text result into two screens (Violent / Non-Violent) instead of three; add comprehensive dummy data layer simulating all features including tokens and navigation."

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Video Result Hides Confidence Score (Priority: P1)

A user submits a video for analysis. The result screen shows the detection verdict (Violent or
Non-Violent) cleanly, without any percentage bar or confidence score number. The result feels
decisive and clear — no ambiguity introduced by a probability figure.

**Why this priority**: The confidence percentage is currently only shown in the violent path and
creates confusion for non-technical users. Removing it simplifies the result and aligns with the
product's goal of a clear safety verdict.

**Independent Test**: Navigate to the video detection result screen with `isViolent: true` and verify
no percentage label, no progress bar, and no confidence-related text appears anywhere on the screen.
Repeat with `isViolent: false`. Both states must be free of any confidence score.

**Acceptance Scenarios**:

1. **Given** the video detection result screen opens with `isViolent: true`,
   **When** the user views the screen,
   **Then** no percentage number, no confidence label, and no progress bar are visible — only the
   verdict icon, title ("Violent Content Detected"), and the analysis summary bullets.

2. **Given** the video detection result screen opens with `isViolent: false`,
   **When** the user views the screen,
   **Then** the non-violent state renders identically without confidence elements, showing only the
   verdict icon, title, and the non-violent bullet points.

---

### User Story 2 - Text Result Consolidated to Two States Only (Priority: P1)

A user submits text for analysis. The result screen has exactly two possible states:
**Violent Content Detected** and **No Violence Detected**. The previous third state
("Against Violent Content") is merged into the non-violent state. The label, icon, and summary
bullets adapt accordingly to these two cases only.

**Why this priority**: Three result states for text adds UX complexity and inconsistency with the
video result (which has two states). Consolidating to two states creates parity across detection
types and simplifies the UI logic.

**Independent Test**: Navigate to the text detection result screen with `isViolent: true` and confirm
the violent state renders correctly. Navigate with `isViolent: false` and confirm only one non-violent
state renders — no "Against Violent" variant, no conditional keyword logic.

**Acceptance Scenarios**:

1. **Given** the text detection result screen opens with `isViolent: true`,
   **When** the user views the result,
   **Then** the screen displays "Violent Content Detected" with the warning icon, analysis summary,
   and the two violent bullet points (Aggressive Tone + Contextual Reasoning).

2. **Given** the text detection result screen opens with `isViolent: false`,
   **When** the user views the result,
   **Then** the screen displays a single non-violent label ("No Violence Detected"), the shield icon,
   and the non-violent bullet points — regardless of any keywords present in the analyzed text.

3. **Given** the text result screen is in the non-violent state,
   **When** the analyzed text contains words like "renovation" or "community",
   **Then** the result still shows the standard non-violent state — no special "Against Violent"
   branching occurs.

---

### User Story 3 - Full Dummy Data Layer Across All Features (Priority: P2)

A developer or reviewer opens the app and all screens — Dashboard, History, Reports, Profile,
Detection input, Detection result — are populated with realistic, consistent dummy data. No screen
shows an empty state due to lack of a real backend. All dummy data is centralized in a single
data layer so any screen can import it without duplicating constants.

**Why this priority**: The app is in demo/development phase. Realistic dummy data makes UI reviews,
demos, and stakeholder walkthroughs useful. Centralizing it prevents scattered inline literals
across widget files.

**Independent Test**: Launch the app cold. Navigate to every screen without performing any real
action. Every list, card, chart, stat, and avatar must be populated. Open the app in both light and
dark mode — dummy data renders correctly in both. All navigation from dummy data items (e.g., tapping
a history card) leads to a populated detail screen.

**Acceptance Scenarios**:

1. **Given** the app launches for the first time (no real API calls),
   **When** the user navigates to the Dashboard (Home tab),
   **Then** the Recent Links section shows at least 3 items with realistic URLs, timestamps, and
   status badges — all sourced from the centralized dummy data layer.

2. **Given** the user navigates to the History tab,
   **When** the history list is displayed,
   **Then** at least 5 detection history entries appear, each with a type (text/video), verdict,
   timestamp, and a short excerpt — all from the dummy data layer.

3. **Given** the user navigates to the Reports tab,
   **When** charts or stats are displayed,
   **Then** all metrics (total scans, violent count, safe count, trend data) are populated from the
   dummy data layer.

4. **Given** the user navigates to the Profile tab,
   **When** the profile is displayed,
   **Then** the user's name, email, avatar placeholder, and account stats are all populated from
   the dummy data layer.

5. **Given** the user taps any history item,
   **When** the detection details screen opens,
   **Then** the full detail view is populated from the matching dummy data entry.

6. **Given** the developer inspects any widget file using dummy content,
   **When** they trace the data source,
   **Then** all dummy values are imported from a single centralized location — no inline mock
   literals are hardcoded inside widget files.

---

### Edge Cases

- What happens when the text result receives an empty `analyzedText` string? The screen must
  still render without overflow or null errors.
- What happens if the dummy data history list is navigated before the detection flow? The history
  items must be tappable and open the details screen regardless of real analysis state.
- What happens in dark mode with dummy avatar/image placeholders? They must display a fallback
  icon using theme-aware colors, not hardcoded white/black.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The video detection result screen MUST NOT display a confidence score percentage,
  progress bar, or confidence label in any state (violent or non-violent).

- **FR-002**: The text detection result screen MUST render exactly two distinct visual states:
  Violent Content and No Violence Detected. The "Against Violent Content" branch MUST be removed.

- **FR-003**: The text detection result screen MUST NOT use keyword scanning of the analyzed text
  to conditionally choose a label or bullet set. The label and bullets MUST be determined solely
  by the `isViolent` boolean.

- **FR-004**: A centralized dummy data file MUST exist in `lib/core/` providing typed mock data
  for: detection history items, report statistics, recent links, and user profile details.

- **FR-005**: All screens that currently use inline dummy values (hardcoded strings in widget
  `build` methods or widget class fields) MUST import their dummy content from the centralized
  dummy data file.

- **FR-006**: The dummy data layer MUST include at least: 5 history entries (mix of text and video,
  mix of violent and non-violent), 3 recent link items, 1 user profile object, and report
  statistics (total, violent count, safe count, weekly trend as a list of integers).

- **FR-007**: All dummy data MUST be compatible with both light and dark themes (no hardcoded color
  literals within the data layer — colors are resolved by widgets via the theme system).

### Key Entities

- **DetectionHistoryItem**: Represents a past detection. Attributes: id, type (text/video), isViolent,
  timestamp, excerpt (text snippet or video URL), and verdict label.
- **RecentLinkItem**: Represents a recently analyzed URL. Attributes: url, timeAgo, isVideo, status
  (safe/flagged).
- **ReportStats**: Aggregated statistics. Attributes: totalScans, violentCount, safeCount,
  weeklyTrend (List of 7 integers).
- **DummyUser**: Mock user profile. Attributes: name, email, joinDate, totalScans.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The video detection result screen passes visual inspection in both violent and
  non-violent states with zero confidence-related UI elements visible.

- **SC-002**: The text detection result screen shows exactly two distinct rendered outcomes — one
  for `isViolent: true` and one for `isViolent: false` — with no branching on text content.

- **SC-003**: Every screen in the app displays populated content when launched without a real
  backend, with zero empty-state placeholders visible during a full navigation walkthrough.

- **SC-004**: All dummy data is traceable to a single import source — no widget file contains more
  than zero inline hardcoded mock values after this feature is complete.

- **SC-005**: The entire app navigates without runtime errors or visual overflow in both light and
  dark modes after the changes.

---

## Assumptions

- The app is in a demo/prototyping phase; no real API integration is required for this feature.
- The `DetectionHistoryItem` model already exists in `lib/features/history/models/`; the dummy
  data layer will use or extend this existing model structure.
- The `isViolent` boolean is the single source of truth for result screen rendering; no confidence
  score or secondary classification is needed in the current phase.
- Dummy data tokens (strings, numbers) do not require localization at this stage — English-only
  values are acceptable.
- The centralized dummy data file will live at `lib/core/utils/dummy_data.dart` unless a more
  appropriate location exists in the project structure.
