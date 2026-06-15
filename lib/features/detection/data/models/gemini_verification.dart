/// The result of asking Gemini to verify (give a second opinion on) the
/// primary AI model's violence classification.
class GeminiVerification {
  /// Whether Gemini agrees with the primary model's `isViolent` verdict.
  final bool agrees;

  /// Gemini's own independent verdict (does IT think the content is violent?).
  final bool geminiSaysViolent;

  /// A short human-readable explanation of Gemini's reasoning.
  final String reason;

  /// Gemini's confidence in its own verdict, 0.0–1.0.
  final double confidence;

  const GeminiVerification({
    required this.agrees,
    required this.geminiSaysViolent,
    required this.reason,
    required this.confidence,
  });

  /// Minimum confidence at which Gemini's verdict overrides the primary model.
  static const double overrideThreshold = 0.8;

  /// Whether Gemini's verdict should override the primary model's: it disagrees
  /// AND is confident enough to be trusted over the model.
  bool get overridesModel => !agrees && confidence >= overrideThreshold;

  /// Builds a verification from Gemini's JSON reply, comparing its verdict to
  /// the [modelSaysViolent] verdict from the primary model.
  factory GeminiVerification.fromJson(
    Map<String, dynamic> json, {
    required bool modelSaysViolent,
  }) {
    final geminiViolent = json['is_violent'] == true;
    return GeminiVerification(
      agrees: geminiViolent == modelSaysViolent,
      geminiSaysViolent: geminiViolent,
      reason: (json['reason'] as String?)?.trim().isNotEmpty == true
          ? (json['reason'] as String).trim()
          : 'No explanation provided.',
      confidence: ((json['confidence'] as num?)?.toDouble() ?? 0.0)
          .clamp(0.0, 1.0),
    );
  }
}
