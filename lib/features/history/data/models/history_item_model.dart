/// A single history record, as returned by `GET /api/History`
/// (HistoryListItemDto).
class HistoryItemModel {
  final String id;
  final String url;
  final String contentType;
  final String timeAgo;
  final String status;
  final DateTime? detectionDate;

  const HistoryItemModel({
    required this.id,
    required this.url,
    required this.contentType,
    required this.timeAgo,
    required this.status,
    this.detectionDate,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? '',
      status: json['status'] as String? ?? '',
      detectionDate:
          DateTime.tryParse(json['detectionDate']?.toString() ?? ''),
    );
  }
}
