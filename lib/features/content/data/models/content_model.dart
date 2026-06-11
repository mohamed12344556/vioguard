/// A content record persisted on the VioGuard backend, as returned by
/// `GET /api/Content`.
class ContentModel {
  final String url;
  final DateTime? detectionDate;
  final String userEmail;

  const ContentModel({
    required this.url,
    required this.userEmail,
    this.detectionDate,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      url: json['url'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? '',
      detectionDate: DateTime.tryParse(json['detectionDate']?.toString() ?? ''),
    );
  }
}
