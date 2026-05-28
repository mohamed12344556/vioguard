class FindingModel {
  final String title;
  final String description;
  final bool isViolated;

  const FindingModel({
    required this.title,
    required this.description,
    required this.isViolated,
  });

  factory FindingModel.fromJson(Map<String, dynamic> json) {
    return FindingModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isViolated: json['isViolated'] as bool? ?? false,
    );
  }
}

class AnalyzeResponse {
  final String id;
  final String sourceUrl;
  final String contentType;
  final bool isViolent;
  final DateTime processedAt;
  final String statusText;
  final String contextText;
  final List<FindingModel> findings;

  const AnalyzeResponse({
    required this.id,
    required this.sourceUrl,
    required this.contentType,
    required this.isViolent,
    required this.processedAt,
    required this.statusText,
    required this.contextText,
    required this.findings,
  });

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      id: json['id'] as String? ?? '',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      isViolent: json['isViolent'] as bool? ?? false,
      processedAt: DateTime.tryParse(json['processedAt'] as String? ?? '') ??
          DateTime.now(),
      statusText: json['statusText'] as String? ?? '',
      contextText: json['contextText'] as String? ?? '',
      findings: (json['findings'] as List<dynamic>?)
              ?.map((e) => FindingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
