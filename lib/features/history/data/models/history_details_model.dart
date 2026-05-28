class AnalysisSummaryItem {
  final String description;
  final bool isViolentFlag;

  const AnalysisSummaryItem({
    required this.description,
    required this.isViolentFlag,
  });

  factory AnalysisSummaryItem.fromJson(Map<String, dynamic> json) {
    return AnalysisSummaryItem(
      description: json['description'] as String? ?? '',
      isViolentFlag: json['isViolentFlag'] as bool? ?? false,
    );
  }
}

class HistoryDetailsModel {
  final String id;
  final DateTime scannedAt;
  final String contentType;
  final bool isVerified;
  final String sourceUrl;
  final String currentStatus;
  final String statusBadgeColor;
  final List<AnalysisSummaryItem> analysisSummary;

  const HistoryDetailsModel({
    required this.id,
    required this.scannedAt,
    required this.contentType,
    required this.isVerified,
    required this.sourceUrl,
    required this.currentStatus,
    required this.statusBadgeColor,
    required this.analysisSummary,
  });

  factory HistoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return HistoryDetailsModel(
      id: json['id'] as String? ?? '',
      scannedAt: DateTime.tryParse(json['scannedAt'] as String? ?? '') ??
          DateTime.now(),
      contentType: json['contentType'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      sourceUrl: json['sourceUrl'] as String? ?? '',
      currentStatus: json['currentStatus'] as String? ?? '',
      statusBadgeColor: json['statusBadgeColor'] as String? ?? '',
      analysisSummary: (json['analysisSummary'] as List<dynamic>?)
              ?.map(
                  (e) => AnalysisSummaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
