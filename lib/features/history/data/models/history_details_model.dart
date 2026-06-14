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
    required this.analysisSummary,
  });

  factory HistoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return HistoryDetailsModel(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      formattedDate: json['formattedDate'] as String? ?? '',
      formattedTime: json['formattedTime'] as String? ?? '',
      currentStatus: json['currentStatus'] as String? ?? '',
      confidenceText: json['confidenceText'] as String? ?? '',
      extractedTextContext: json['extractedTextContext'] as String? ?? '',
      analysisSummary: (json['analysisSummary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
