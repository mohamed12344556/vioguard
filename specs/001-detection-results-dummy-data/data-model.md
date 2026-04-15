# Data Model: Detection Results Refinement & Dummy Data Layer

**Date**: 2026-04-15
**Feature**: `specs/001-detection-results-dummy-data`

## Entities

### DummyData (new — `lib/core/utils/dummy_data.dart`)

A utility class with only static members. No instances.

| Member | Type | Description |
| ------ | ---- | ----------- |
| `userName` | `String` | Full display name |
| `userFirstName` | `String` | First name for profile fields |
| `userLastName` | `String` | Last name for profile fields |
| `userEmail` | `String` | Email address for profile |
| `userJoinDate` | `String` | Human-readable join date |
| `userTotalScans` | `int` | Lifetime scan count |
| `recentLinks` | `List<Map<String, dynamic>>` | Dashboard recent links (url, timeAgo, isVideo, isFlagged) |
| `reportTotalScans` | `int` | Total analyses (all types) |
| `reportTotalVideos` | `int` | Total video analyses |
| `reportTotalTexts` | `int` | Total text analyses |
| `reportViolentAll` | `int` | Violent detections (all) |
| `reportNonViolentAll` | `int` | Non-violent (all) |
| `reportViolentVideo` | `int` | Violent video detections |
| `reportNonViolentVideo` | `int` | Non-violent video |
| `reportViolentText` | `int` | Violent text detections |
| `reportNonViolentText` | `int` | Non-violent text |
| `reportViolenceRatio` | `double` | 0.0–1.0 ratio for progress bar |
| `reportTimeRange` | `String` | Display string for date range |
| `historyItems` | `List<DetectionHistoryItem>` | 8 demo history entries |
| `sampleViolentText` | `String` | Sample text with violent keywords |
| `sampleNeutralText` | `String` | Sample safe/neutral text |

### DetectionHistoryItem (existing — no changes to model)

Located at `lib/features/history/models/detection_history_item.dart`.
No field additions or removals. The `confidenceScore` field stays in the model
(used by history/details screens) but is no longer passed from the video result screen.

### VideoDetectionResultScreen (modified — field removed)

| Field | Before | After |
| ----- | ------ | ----- |
| `videoPath` | `String?` | `String?` (unchanged) |
| `isViolent` | `bool` | `bool` (unchanged) |
| `confidenceScore` | `int` (default 0) | **REMOVED** |
| `thumbnailPath` | `String?` | `String?` (unchanged) |

### TextDetectionResultScreen (modified — method removed)

No field changes. The `isViolent` bool remains the sole branching condition.
Methods `_getNeutralLabel()` and keyword scanning in `_buildBulletPoints()` are removed.

## State Transitions

### VideoDetectionResultScreen

```
isViolent: true  → red icon + "Violent Content Detected" + 3 violent bullets
isViolent: false → green icon + "Non-Violent Content Detected" + 3 safe bullets
```

No intermediate states. No percentage display.

### TextDetectionResultScreen

```
isViolent: true  → red icon + "Violent Content Detected" + 2 violent bullets
isViolent: false → green icon + "No Violence Detected" + 3 safe bullets
```

No keyword scanning. No third state.
