# Implementation Plan: Detection Results Refinement & Dummy Data Layer

**Branch**: `main` | **Date**: 2026-04-15 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-detection-results-dummy-data/spec.md`

## Summary

Three targeted changes to the VioGuard Flutter app:
1. Remove confidence score UI from `VideoDetectionResultScreen` (violent path only).
2. Collapse `TextDetectionResultScreen` from 3 result states to exactly 2 — remove the
   "Against Violent" branch and all keyword-based label/bullet branching logic.
3. Create `lib/core/utils/dummy_data.dart` — a centralized dummy data file — and migrate all
   inline mock literals from widget files into it.

## Technical Context

**Language/Version**: Dart (Flutter SDK — existing project)
**Primary Dependencies**: flutter_screenutil (responsive sizing), easy_localization
**Storage**: N/A — no persistence layer involved
**Testing**: Manual visual QA in both ThemeMode.light and ThemeMode.dark
**Target Platform**: Mobile (iOS + Android)
**Project Type**: Mobile app — single Flutter project
**Performance Goals**: No performance impact — UI-only and data-layer changes
**Constraints**: Must respect `AppColors` theming system; no hardcoded color literals in widgets
**Scale/Scope**: 3 files modified, 1 file created

## Constitution Check

*GATE: Must pass before implementation. Re-check after Phase 1 design.*

| Principle | Check | Result |
|-----------|-------|--------|
| I. Project Unity | All changes stay within `lib/`; no new features split off | ✅ PASS |
| II. Responsive UI | No new dimensions introduced; existing `.r/.w/.h/.sp` preserved | ✅ PASS |
| III. Dark & Light Mode | Removing hardcoded color-adjacent logic; dummy data has no color literals | ✅ PASS |
| IV. Clean Architecture | No layer boundary violations — this is presentation + utils only | ✅ PASS |
| V. Quality-First | Zero confidence-score UI remaining; exactly 2 text result states; all screens populated | ✅ PASS |

**Gate result: ALL PASS — proceed.**

## Project Structure

### Documentation (this feature)

```text
specs/001-detection-results-dummy-data/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code — files to change

```text
lib/
├── core/
│   └── utils/
│       └── dummy_data.dart          ← NEW FILE (US3)
└── features/
    └── detection/
        └── views/
            ├── video_detection_result_screen.dart   ← MODIFY (US1)
            └── text_detection_result_screen.dart    ← MODIFY (US2)
```

Files that consume dummy data (read-only in this plan — migrated in tasks):
```text
lib/features/home/views/dashboard_screen.dart
lib/features/history/views/history_screen.dart
```

**Structure Decision**: Single Flutter project. All changes inside `lib/`. No new packages,
no new modules, no new routes.

---

## Phase 0: Research

*All decisions derived from reading the existing codebase — no external research needed.*

### research.md

See [research.md](research.md) below (written inline for executor convenience).

---

## Phase 1: Design

### Data Model

See [data-model.md](data-model.md) below.

### Contracts

No external contracts — purely internal widget and data-layer changes.

---

## Detailed Implementation Instructions

> These instructions are written for a code-execution LLM. Follow them exactly.
> Each task maps to one file edit. Do not make changes outside the listed files.
> Read each file before editing it.

---

### TASK 1 — Remove confidence score from VideoDetectionResultScreen

**File**: `lib/features/detection/views/video_detection_result_screen.dart`

**What to remove**: The entire `if (isViolent) ...[ ... ] else ...[ ... ]` block in the
`build` method that renders the Confidence Level row, the `LinearProgressIndicator`, and the
disclaimer text beneath it.

Currently at approximately lines 229–287, the code reads:

```dart
if (isViolent) ...[
  Row(  // "Confidence Level" label + percentage
    ...
  ),
  SizedBox(height: 10.h),
  ClipRRect(  // LinearProgressIndicator
    ...
  ),
  SizedBox(height: 10.h),
  Row(  // Disclaimer text with info icon
    ...
  ),
] else ...[
  _buildNonViolentBullets(),
],
```

**Replace the entire block with**:

```dart
_buildResultBullets(),
```

**Then add this new private method** to the class (after `_buildNonViolentBullets`):

```dart
Widget _buildResultBullets() {
  if (isViolent) {
    final bullets = [
      'High-impact physical actions detected',
      'Aggressive postures and gestures identified',
      'Rapid forceful movements consistent with aggression',
    ];
    return Column(
      children: bullets.map((b) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  b,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  final bullets = [
    'Normal activity detected',
    'No threat indicators found',
    'Standard behavioral patterns',
  ];
  return Column(
    children: bullets.map((b) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              b,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
```

**Also remove**: The `confidenceScore` parameter from the constructor and class fields entirely:
- Remove `final int confidenceScore;` field
- Remove `this.confidenceScore = 0,` from the constructor
- The `_buildNonViolentBullets()` method can be deleted since it is now merged into
  `_buildResultBullets()`

**Also update** `lib/core/routes/app_router.dart` line ~55:
Remove `confidenceScore: args?['confidenceScore'] ?? 0,` from the `VideoDetectionResultScreen`
constructor call.

**Verify**: After edit, `VideoDetectionResultScreen` has no `confidenceScore` field, no
`LinearProgressIndicator`, no "Confidence Level" text, no percentage display.

---

### TASK 2 — Consolidate TextDetectionResultScreen to two states

**File**: `lib/features/detection/views/text_detection_result_screen.dart`

**Goal**: Remove all keyword-based branching. The screen has exactly two states based on
`isViolent`. Simplify two methods: `_getNeutralLabel()` and `_buildBulletPoints()`.

**Step 2a — Replace `_getNeutralLabel()`**:

Remove the entire `_getNeutralLabel()` method and replace its call site in `build`.

In the `Text(...)` widget that currently calls `_getNeutralLabel()` (line ~128), replace:
```dart
isViolent
    ? 'Violent Content\nDetected'
    : _getNeutralLabel(),
```
with:
```dart
isViolent
    ? 'Violent Content\nDetected'
    : 'No Violence Detected',
```

Then delete the `_getNeutralLabel()` method entirely.

**Step 2b — Replace `_buildBulletPoints()`**:

Replace the entire `_buildBulletPoints()` method with this simplified version:

```dart
List<Widget> _buildBulletPoints() {
  final List<Map<String, dynamic>> points;

  if (isViolent) {
    points = [
      {
        'title': 'Aggressive Tone Detected',
        'subtitle': 'The text contains direct threats and assertive hostile language.',
        'isViolent': true,
      },
      {
        'title': 'Contextual Reasoning',
        'subtitle': 'Inference suggests a sequence of future harmful actions.',
        'isViolent': true,
      },
    ];
  } else {
    points = [
      {
        'title': 'No aggressive tone detected',
        'subtitle': null,
        'isViolent': false,
      },
      {
        'title': 'Informational or neutral language',
        'subtitle': null,
        'isViolent': false,
      },
      {
        'title': 'No harmful intent identified',
        'subtitle': null,
        'isViolent': false,
      },
    ];
  }

  return points.map((p) {
    final bool violent = p['isViolent'] as bool;
    final String? subtitle = p['subtitle'] as String?;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            child: Icon(
              violent ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: violent ? AppColors.error : AppColors.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['title'] as String,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }).toList();
}
```

**Verify**: After edit, `TextDetectionResultScreen` has no `_getNeutralLabel()` method, no
`positiveKeywords` list, no keyword-based branching in any method. The label and bullets are
determined solely by `isViolent`.

---

### TASK 3 — Create centralized dummy data file

**File to create**: `lib/core/utils/dummy_data.dart`

Create this file with the following exact content:

```dart
import '../../../features/history/models/detection_history_item.dart';

/// Centralized dummy data for all screens.
/// Import this file wherever mock/demo data is needed.
/// Do NOT hardcode mock values directly in widget files.
class DummyData {
  DummyData._();

  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------

  static const String userName = 'John Doe';
  static const String userFirstName = 'John';
  static const String userLastName = 'Doe';
  static const String userEmail = 'john.doe@example.com';
  static const String userJoinDate = 'January 2024';
  static const int userTotalScans = 248;

  // ---------------------------------------------------------------------------
  // Recent Links (Dashboard)
  // ---------------------------------------------------------------------------

  static const List<Map<String, dynamic>> recentLinks = [
    {
      'url': 'youtube.com/watch?v=dQv...',
      'timeAgo': '2 hours ago',
      'isVideo': true,
      'isFlagged': false,
    },
    {
      'url': 'reddit.com/r/technology/cc...',
      'timeAgo': '5 hours ago',
      'isVideo': false,
      'isFlagged': false,
    },
    {
      'url': 'vimeo.com/channels/staff/...',
      'timeAgo': 'Yesterday',
      'isVideo': true,
      'isFlagged': true,
    },
  ];

  // ---------------------------------------------------------------------------
  // Report Statistics
  // ---------------------------------------------------------------------------

  static const int reportTotalScans = 2745;
  static const int reportTotalVideos = 1245;
  static const int reportTotalTexts = 1500;
  static const int reportViolentAll = 84;
  static const int reportNonViolentAll = 1203;
  static const int reportViolentVideo = 42;
  static const int reportNonViolentVideo = 1203;
  static const int reportViolentText = 42;
  static const int reportNonViolentText = 1458;
  static const double reportViolenceRatio = 0.34;
  static const String reportTimeRange = 'Jan 1 – Jan 30';

  // ---------------------------------------------------------------------------
  // Detection History
  // ---------------------------------------------------------------------------

  static List<DetectionHistoryItem> get historyItems => [
    DetectionHistoryItem(
      id: '1',
      type: DetectionType.video,
      result: DetectionResult.nonViolent,
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      sourceUrl: 'youtube.com/watch?v=dQv...',
    ),
    DetectionHistoryItem(
      id: '2',
      type: DetectionType.text,
      result: DetectionResult.nonViolent,
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      sourceUrl: 'reddit.com/r/technology/cc...',
      content: 'The renovation project will improve community safety for all residents.',
    ),
    DetectionHistoryItem(
      id: '3',
      type: DetectionType.video,
      result: DetectionResult.violent,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      sourceUrl: 'vimeo.com/channels/staff/...',
      flagReasons: [
        'Identified high-impact physical actions in the video.',
        'Detected rapid and forceful movements consistent with aggression.',
        'Presence of aggressive postures and gestures between individuals.',
      ],
    ),
    DetectionHistoryItem(
      id: '4',
      type: DetectionType.video,
      result: DetectionResult.nonViolent,
      dateTime: DateTime(2025, 5, 10),
      sourceUrl: 'youtube.com/watch?v=dQv...',
    ),
    DetectionHistoryItem(
      id: '5',
      type: DetectionType.text,
      result: DetectionResult.nonViolent,
      dateTime: DateTime(2024, 4, 28),
      sourceUrl: 'reddit.com/r/technology/cc...',
      content: 'Breaking news: local government announces new public parks initiative.',
    ),
    DetectionHistoryItem(
      id: '6',
      type: DetectionType.video,
      result: DetectionResult.violent,
      dateTime: DateTime(2024, 4, 19),
      sourceUrl: 'vimeo.com/channels/staff/...',
      flagReasons: [
        'Identified high-impact physical actions in the video.',
        'Detected rapid and forceful movements consistent with aggression.',
      ],
    ),
    DetectionHistoryItem(
      id: '7',
      type: DetectionType.video,
      result: DetectionResult.violent,
      dateTime: DateTime(2024, 4, 10),
      sourceUrl: 'vimeo.com/channels/staff/...',
      flagReasons: [
        'Presence of aggressive postures and gestures between individuals.',
      ],
    ),
    DetectionHistoryItem(
      id: '8',
      type: DetectionType.video,
      result: DetectionResult.violent,
      dateTime: DateTime(2024, 4, 9),
      sourceUrl: 'vimeo.com/channels/staff/...',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Sample analyzed texts (for TextDetectionScreen demos)
  // ---------------------------------------------------------------------------

  static const String sampleViolentText =
      'I will crush you and destroy everything you have. '
      'You better watch your back — you won\'t last long after this.';

  static const String sampleNeutralText =
      'The renovation project will improve community safety for all residents '
      'and provide a safer environment for everyone.';
}
```

---

### TASK 4 — Migrate inline dummy data in HistoryScreen

**File**: `lib/features/history/views/history_screen.dart`

**Add import** at the top of the file (after existing imports):
```dart
import '../../../core/utils/dummy_data.dart';
```

**Replace** the inline `_historyItems` list initialization in `_HistoryScreenState`:

Find:
```dart
final List<DetectionHistoryItem> _historyItems = [
  DetectionHistoryItem(
    id: '1',
    ...
  ),
  // ... all 8 items ...
];
```

Replace with:
```dart
final List<DetectionHistoryItem> _historyItems = DummyData.historyItems;
```

**Verify**: The `_historyItems` field is now a one-liner. No inline `DetectionHistoryItem`
constructors remain in this file.

---

### TASK 5 — Migrate inline dummy data in DashboardScreen

**File**: `lib/features/home/views/dashboard_screen.dart`

**Add import** at the top (after existing imports):
```dart
import '../../../core/utils/dummy_data.dart';
```

**Replace** the inline `_recentLinks` list in `_HomeContentState`:

Find:
```dart
final List<_RecentLinkItem> _recentLinks = [
  _RecentLinkItem(
    url: 'youtube.com/watch?v=dQv...',
    timeAgo: '2 hours ago',
    isVideo: true,
    status: _LinkStatus.safe,
  ),
  _RecentLinkItem(
    url: 'reddit.com/r/technology/cc...',
    timeAgo: '5 hours ago',
    isVideo: false,
    status: _LinkStatus.safe,
  ),
  _RecentLinkItem(
    url: 'vimeo.com/channels/staff/...',
    timeAgo: 'Yesterday',
    isVideo: true,
    status: _LinkStatus.flagged,
  ),
];
```

Replace with:
```dart
final List<_RecentLinkItem> _recentLinks = DummyData.recentLinks
    .map((e) => _RecentLinkItem(
          url: e['url'] as String,
          timeAgo: e['timeAgo'] as String,
          isVideo: e['isVideo'] as bool,
          status: (e['isFlagged'] as bool)
              ? _LinkStatus.flagged
              : _LinkStatus.safe,
        ))
    .toList();
```

**Verify**: No inline `_RecentLinkItem(...)` constructors remain in `dashboard_screen.dart`.

---

## Complexity Tracking

> No constitution violations. No entries needed.
