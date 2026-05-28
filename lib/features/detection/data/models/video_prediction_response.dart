class VideoPredictionResponse {
  final String label;
  final double confidence;
  final double violence;
  final double nonViolence;

  const VideoPredictionResponse({
    required this.label,
    required this.confidence,
    required this.violence,
    required this.nonViolence,
  });

  bool get isViolent => label.toLowerCase() == 'violence';

  factory VideoPredictionResponse.fromJson(Map<String, dynamic> json) {
    return VideoPredictionResponse(
      label: json['label'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      violence: (json['violence'] as num?)?.toDouble() ?? 0.0,
      nonViolence: (json['non_violence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
