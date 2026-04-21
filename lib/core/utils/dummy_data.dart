import '../../features/history/models/detection_history_item.dart';

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

  // ---------------------------------------------------------------------------
  // Sample analyzed texts (for TextDetectionScreen demos)
  // ---------------------------------------------------------------------------

  static const String sampleViolentText =
      'I will crush you and destroy everything you have. '
      "You better watch your back — you won't last long after this.";

  static const String sampleNeutralText =
      'The renovation project will improve community safety for all residents '
      'and provide a safer environment for everyone.';
}
