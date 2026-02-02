enum DetectionType { text, video }

enum DetectionResult { violent, nonViolent }

class DetectionHistoryItem {
  final String id;
  final DetectionType type;
  final DetectionResult result;
  final DateTime dateTime;
  final String? content;
  final String? thumbnailPath;
  final int? confidenceScore;
  final List<String>? flagReasons;

  DetectionHistoryItem({
    required this.id,
    required this.type,
    required this.result,
    required this.dateTime,
    this.content,
    this.thumbnailPath,
    this.confidenceScore,
    this.flagReasons,
  });

  bool get isViolent => result == DetectionResult.violent;
  bool get isText => type == DetectionType.text;
  bool get isVideo => type == DetectionType.video;

  String get formattedDate {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get formattedDateTime => '$formattedDate - $formattedTime';
}
