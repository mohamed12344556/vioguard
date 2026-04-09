enum DetectionType { text, video }

enum DetectionResult { violent, nonViolent, againstViolent, neutral }

class DetectionHistoryItem {
  final String id;
  final DetectionType type;
  final DetectionResult result;
  final DateTime dateTime;
  final String? content;
  final String? thumbnailPath;
  final int? confidenceScore;
  final List<String>? flagReasons;
  final String? sourceUrl;

  DetectionHistoryItem({
    required this.id,
    required this.type,
    required this.result,
    required this.dateTime,
    this.content,
    this.thumbnailPath,
    this.confidenceScore,
    this.flagReasons,
    this.sourceUrl,
  });

  bool get isViolent => result == DetectionResult.violent;
  bool get isText => type == DetectionType.text;
  bool get isVideo => type == DetectionType.video;

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get formattedDateTime => '$formattedDate - $formattedTime';

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return formattedDate;
  }
}
