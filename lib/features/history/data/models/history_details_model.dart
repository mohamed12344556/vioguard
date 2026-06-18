/// Full details of a history record, as returned by
/// `GET /api/History/{id}/details` (HistoryDetailsDto).
class HistoryDetailsModel {
  final String id;
  final String url;
  final String contentType;
  final String formattedDate;
  final String formattedTime;
  final String currentStatus;
  final String confidenceText;
  final String extractedTextContext;

  /// Words/phrases to highlight in [extractedTextContext] (violent text records).
  final List<String> violentWords;

  /// Violence percentage for video records (0–100); 0 for non-video.
  final double violentPercent;

  final List<String> analysisSummary;

  const HistoryDetailsModel({
    required this.id,
    required this.url,
    required this.contentType,
    required this.formattedDate,
    required this.formattedTime,
    required this.currentStatus,
    required this.confidenceText,
    required this.extractedTextContext,
    required this.violentWords,
    required this.violentPercent,
    required this.analysisSummary,
  });

  factory HistoryDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['formattedDate'] as String? ?? '';
    final rawTime = json['formattedTime'] as String? ?? '';

    // The backend pre-formats the timestamp in UTC (e.g. "June 16, 2026" /
    // "7:36 PM") without converting to the viewer's zone. Re-interpret those
    // strings as a UTC instant and convert to local time. If parsing fails we
    // keep the backend strings as-is.
    final localDate = _toLocal(rawDate, rawTime);

    return HistoryDetailsModel(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      formattedDate: localDate != null ? _formatDate(localDate) : rawDate,
      formattedTime: localDate != null ? _formatTime(localDate) : rawTime,
      currentStatus: json['currentStatus'] as String? ?? '',
      confidenceText: json['confidenceText'] as String? ?? '',
      extractedTextContext: json['extractedTextContext'] as String? ?? '',
      violentWords: (json['violentWords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const [],
      violentPercent: (json['violentPercent'] as num?)?.toDouble() ?? 0.0,
      analysisSummary: (json['analysisSummary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Parses the backend's UTC "June 16, 2026" + "7:36 PM" strings into a local
  /// [DateTime]. Returns null when either string isn't in the expected shape.
  static DateTime? _toLocal(String date, String time) {
    // Date: "June 16, 2026"
    final dateMatch =
        RegExp(r'^(\w+)\s+(\d{1,2}),\s+(\d{4})$').firstMatch(date.trim());
    // Time: "7:36 PM" / "11:05 AM"
    final timeMatch = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$')
        .firstMatch(time.trim());
    if (dateMatch == null || timeMatch == null) return null;

    final month = _months.indexWhere(
          (m) => m.toLowerCase() == dateMatch.group(1)!.toLowerCase(),
        ) +
        1;
    if (month == 0) return null;
    final day = int.tryParse(dateMatch.group(2)!);
    final year = int.tryParse(dateMatch.group(3)!);

    var hour = int.tryParse(timeMatch.group(1)!);
    final minute = int.tryParse(timeMatch.group(2)!);
    final isPm = timeMatch.group(3)!.toLowerCase() == 'pm';
    if (day == null || year == null || hour == null || minute == null) {
      return null;
    }
    if (hour == 12) hour = 0;
    if (isPm) hour += 12;

    return DateTime.utc(year, month, day, hour, minute).toLocal();
  }

  /// Formats a local [DateTime] as 'Month d, yyyy' (matching the backend).
  static String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// Formats a local [DateTime] as a 12-hour 'h:mm AM/PM' time.
  static String _formatTime(DateTime d) {
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    final displayHour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    return '$displayHour:$minute $period';
  }
}
