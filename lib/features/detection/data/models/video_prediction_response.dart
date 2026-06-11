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

  /// The model returns scores as whole percentages (e.g. `96.7` for 96.7%).
  /// Normalize to a 0–1 fraction so the UI can format and clamp them
  /// consistently (`* 100` for display, `clamp(0, 1)` for progress bars).
  static double _toFraction(num? value) => (value?.toDouble() ?? 0.0) / 100.0;

  factory VideoPredictionResponse.fromJson(Map<String, dynamic> json) {
    return VideoPredictionResponse(
      label: json['label'] as String? ?? '',
      confidence: _toFraction(json['confidence'] as num?),
      violence: _toFraction(json['violence'] as num?),
      nonViolence: _toFraction(json['non_violence'] as num?),
    );
  }
}
