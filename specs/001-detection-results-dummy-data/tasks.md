# Tasks: Detection Results Refinement & Dummy Data Layer

**Input**: Design documents from `specs/001-detection-results-dummy-data/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

> **For the implementing LLM**: Read each listed file BEFORE editing it.
> Each task tells you exactly what file to touch and what to change.
> Do not change any file not listed in a task.
> Mark each task complete (`- [x]`) as you finish it.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel with other [P] tasks in the same phase
- **[Story]**: Which user story (US1, US2, US3)
- All file paths are relative to the Flutter project root (`d:/Flutter Projects/vioguard/`)

---

## Phase 1: Setup

**Purpose**: Verify the centralized dummy data file exists and is importable.

- [x] T001 Verify `lib/core/utils/dummy_data.dart` exists and has no Dart analyzer errors — open the file and confirm the import `../../features/history/models/detection_history_item.dart` resolves correctly

---

## Phase 2: Foundational

**Purpose**: All three user stories are independent UI edits — no shared blocking prerequisite beyond T001. Skip directly to user story phases.

*(No foundational tasks — each user story is independently modifiable)*

---

## Phase 3: User Story 1 — Remove Confidence Score from Video Result (Priority: P1)

**Goal**: `VideoDetectionResultScreen` shows no confidence percentage, no progress bar, no confidence label — in either the violent or non-violent state.

**Independent Test**: Run the app → tap any video detection flow → arrive at the result screen with `isViolent: true`. Confirm: no `%` number, no blue/red bar, no disclaimer text about "Statistical confidence". Repeat with `isViolent: false`. Both states must pass.

### Implementation for User Story 1

- [x] T002 [US1] Edit `lib/features/detection/views/video_detection_result_screen.dart` — remove the `final int confidenceScore;` field declaration and `this.confidenceScore = 0,` from the constructor. The constructor should only have `videoPath`, `isViolent`, `thumbnailPath`.

- [x] T003 [US1] Edit `lib/features/detection/views/video_detection_result_screen.dart` — in the `build` method, find the `if (isViolent) ...[ ... ] else ...[ _buildNonViolentBullets() ]` block that contains the `Row` with "Confidence Level", `ClipRRect` with `LinearProgressIndicator`, and the disclaimer `Row`. Replace the entire block with a single call: `_buildResultBullets()`

- [x] T004 [US1] Edit `lib/features/detection/views/video_detection_result_screen.dart` — delete the existing `_buildNonViolentBullets()` method entirely. Add this new method in its place:

  ```dart
  Widget _buildResultBullets() {
    final List<String> bullets;
    final bool violent = isViolent;

    if (violent) {
      bullets = [
        'High-impact physical actions detected',
        'Aggressive postures and gestures identified',
        'Rapid forceful movements consistent with aggression',
      ];
    } else {
      bullets = [
        'Normal activity detected',
        'No threat indicators found',
        'Standard behavioral patterns',
      ];
    }

    return Column(
      children: bullets.map((b) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Icon(
                violent
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: violent ? AppColors.error : AppColors.success,
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
  ```

- [x] T005 [US1] Edit `lib/core/routes/app_router.dart` — in the `case Routes.videoDetectionResult:` block, remove the line `confidenceScore: args?['confidenceScore'] ?? 0,` from the `VideoDetectionResultScreen(...)` constructor call.

**Checkpoint**: `VideoDetectionResultScreen` compiles with no errors. No `confidenceScore` references remain anywhere in the file. `_buildResultBullets()` is the only bullet-rendering method.

---

## Phase 4: User Story 2 — Consolidate Text Result to Two States (Priority: P1)

**Goal**: `TextDetectionResultScreen` has exactly two visual outcomes: violent (red, "Violent Content Detected") and non-violent (green, "No Violence Detected"). No keyword scanning, no third state.

**Independent Test**: Run the app → text detection flow → arrive at result with `isViolent: false`. Confirm: label is exactly "No Violence Detected", bullets are the three neutral ones (no aggressive tone, informational language, no harmful intent). Then test with `isViolent: true`. Confirm: label is "Violent Content Detected", bullets are the two violent ones (Aggressive Tone, Contextual Reasoning).

### Implementation for User Story 2

- [x] T006 [US2] Edit `lib/features/detection/views/text_detection_result_screen.dart` — delete the entire `_getNeutralLabel()` method (it returns keyword-based labels). It starts with `String _getNeutralLabel()` and ends at its closing `}`.

- [x] T007 [US2] Edit `lib/features/detection/views/text_detection_result_screen.dart` — in the `build` method, find the `Text(...)` widget whose content is `isViolent ? 'Violent Content\nDetected' : _getNeutralLabel()`. Replace `_getNeutralLabel()` with the string literal `'No Violence Detected'`. The result:

  ```dart
  Text(
    isViolent
        ? 'Violent Content\nDetected'
        : 'No Violence Detected',
    ...
  )
  ```

- [x] T008 [US2] Edit `lib/features/detection/views/text_detection_result_screen.dart` — replace the entire `_buildBulletPoints()` method body with this simplified version (no keyword scanning, no `isPositive` variable, no `positiveKeywords` list):

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
                violent
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
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

**Checkpoint**: `TextDetectionResultScreen` has no `_getNeutralLabel()` method, no `positiveKeywords` variable, no `isPositive` variable. The file compiles clean.

---

## Phase 5: User Story 3 — Centralized Dummy Data Layer (Priority: P2)

**Goal**: A single file `lib/core/utils/dummy_data.dart` holds all mock data. `HistoryScreen` and `DashboardScreen` import from it. No inline mock literals remain in widget files.

**Independent Test**: Open `lib/features/history/views/history_screen.dart` — search for any inline `DetectionHistoryItem(id:` constructor call. Zero results expected. Open `lib/features/home/views/dashboard_screen.dart` — search for any inline `_RecentLinkItem(url:` constructor. Zero results expected. Run the app and navigate to History tab — 8 items visible. Navigate to Home tab — 3 recent links visible.

### Implementation for User Story 3

- [x] T009 [P] [US3] Create `lib/core/utils/dummy_data.dart` with this exact content:

  ```dart
  import '../../features/history/models/detection_history_item.dart';

  /// Centralized dummy data for all screens.
  /// Import this file wherever mock/demo data is needed.
  /// Do NOT hardcode mock values directly in widget files.
  class DummyData {
    DummyData._();

    // -------------------------------------------------------------------------
    // User Profile
    // -------------------------------------------------------------------------

    static const String userName = 'John Doe';
    static const String userFirstName = 'John';
    static const String userLastName = 'Doe';
    static const String userEmail = 'john.doe@example.com';
    static const String userJoinDate = 'January 2024';
    static const int userTotalScans = 248;

    // -------------------------------------------------------------------------
    // Recent Links (Dashboard)
    // -------------------------------------------------------------------------

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

    // -------------------------------------------------------------------------
    // Report Statistics
    // -------------------------------------------------------------------------

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

    // -------------------------------------------------------------------------
    // Detection History
    // -------------------------------------------------------------------------

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
            content:
                'The renovation project will improve community safety for all residents.',
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
            content:
                'Breaking news: local government announces new public parks initiative.',
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

    // -------------------------------------------------------------------------
    // Sample analyzed texts (for TextDetectionScreen demos)
    // -------------------------------------------------------------------------

    static const String sampleViolentText =
        'I will crush you and destroy everything you have. '
        "You better watch your back — you won't last long after this.";

    static const String sampleNeutralText =
        'The renovation project will improve community safety for all residents '
        'and provide a safer environment for everyone.';
  }
  ```

- [x] T010 [P] [US3] Edit `lib/features/history/views/history_screen.dart`:
  1. Add import after the existing imports: `import '../../../core/utils/dummy_data.dart';`
  2. Replace the entire multi-line `_historyItems` list initialization (all 8 inline `DetectionHistoryItem(...)` constructors) with: `final List<DetectionHistoryItem> _historyItems = DummyData.historyItems;`

- [x] T011 [P] [US3] Edit `lib/features/home/views/dashboard_screen.dart`:
  1. Add import after the existing imports: `import '../../../core/utils/dummy_data.dart';`
  2. Replace the entire `_recentLinks` list initialization (3 inline `_RecentLinkItem(...)` constructors) with:
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

**Checkpoint**: Run `flutter analyze`. Zero errors. Navigate: Home tab shows 3 recent links, History tab shows 8 items. Tapping any history item opens the details screen without crash.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T012 [P] Run `flutter analyze` from the project root and fix any warnings or errors introduced by the changes in T001–T011. Expected: zero errors, zero new warnings.

- [x] T013 Visually verify all changed screens in both `ThemeMode.light` and `ThemeMode.dark`:
  - Video result screen: violent state → no percentage bar visible
  - Video result screen: non-violent state → green bullets visible
  - Text result screen: violent state → "Violent Content Detected" + 2 red bullets
  - Text result screen: non-violent state → "No Violence Detected" + 3 green bullets
  - History screen: 8 items listed, filter tabs (All/Text/Video) work correctly
  - Dashboard: 3 recent links visible in the "Recent Links" section

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 3)**: No dependency on US2 or US3 — touches only video result screen + router
- **US2 (Phase 4)**: No dependency on US1 or US3 — touches only text result screen
- **US3 (Phase 5)**: No dependency on US1 or US2 — touches only dummy data + consumers
- **Polish (Phase 6)**: Depends on all user story phases being complete

### User Story Dependencies

- **User Story 1 (P1)**: Touches `video_detection_result_screen.dart` + `app_router.dart` only
- **User Story 2 (P1)**: Touches `text_detection_result_screen.dart` only
- **User Story 3 (P2)**: Touches `dummy_data.dart` (new) + `history_screen.dart` + `dashboard_screen.dart`

### Parallel Opportunities

- T009, T010, T011 can all run in parallel (different files)
- T002, T003, T004, T005 are sequential (same file — `video_detection_result_screen.dart`)
- T006, T007, T008 are sequential (same file — `text_detection_result_screen.dart`)
- US1 and US2 can be worked in parallel (different files entirely)
- US3 can be started independently of US1 and US2

---

## Implementation Strategy

### MVP First (US1 + US2 Only — no dummy data migration)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 3: US1 — remove confidence score from video result (T002–T005)
3. Complete Phase 4: US2 — consolidate text result to two states (T006–T008)
4. **STOP and VALIDATE**: Verify both result screens render correctly in both themes
5. Proceed to US3 only after US1 and US2 pass visual validation

### Full Delivery

1. T001 (verify dummy_data.dart)
2. T002–T005 (US1: video result)
3. T006–T008 (US2: text result) — can run in parallel with US1
4. T009–T011 (US3: dummy data migration) — can run in parallel with US1 and US2
5. T012–T013 (polish: analyze + visual QA)

---

## Notes

- `[P]` tasks within US3 (T009, T010, T011) touch different files — safe to execute in parallel
- Tasks T002–T005 and T006–T008 touch different files — safe to parallelize across stories
- The `confidenceScore` field in `DetectionHistoryItem` model is NOT removed — it is still used in the history/details screen to display past records
- `DummyData` class uses `static const` for primitive values and `static get` for `historyItems` (because `DateTime.now()` cannot be `const`)
- After T010, the `DetectionHistoryItem` import in `history_screen.dart` may show "unused" warning if the analyzer resolves the type through `dummy_data.dart` — keep both imports; the model types (`DetectionType`, `DetectionResult`) are still referenced directly in the file's filter logic
