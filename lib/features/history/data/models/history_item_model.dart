class HistoryItemModel {
  final String id;
  final String domainName;
  final String contentType;
  final String relativeTime;
  final String safetyStatus;

  const HistoryItemModel({
    required this.id,
    required this.domainName,
    required this.contentType,
    required this.relativeTime,
    required this.safetyStatus,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id'] as String? ?? '',
      domainName: json['domainName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      relativeTime: json['relativeTime'] as String? ?? '',
      safetyStatus: json['safetyStatus'] as String? ?? '',
    );
  }
}
