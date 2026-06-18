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

  /// The exact words/phrases from the text that Gemini flagged as violent, for
  /// highlighting. Empty when Gemini found none (or considered the text safe).
  final List<String> violentWords;

  const GeminiVerification({
    required this.agrees,
    required this.geminiSaysViolent,
    required this.reason,
    required this.confidence,
    this.violentWords = const [],
  });

  /// Minimum confidence at which Gemini's verdict overrides the primary model.
  ///
  /// The primary sentiment model is currently unreliable (it returns the same
  /// label regardless of the input), so we trust Gemini's disagreement at a
  /// much lower bar than we would for a healthy model. As long as Gemini gives
  /// a reasonably confident verdict (≥ this), its call wins over the model.
  static const double overrideThreshold = 0.55;

  /// Whether Gemini's verdict should override the primary model's: it disagrees
  /// AND is confident enough to be trusted over the model.
  bool get overridesModel => !agrees && confidence >= overrideThreshold;

  /// The verdict to actually trust. Because the primary sentiment model is
  /// currently broken, Gemini IS the classifier: whenever a verification exists
  /// its verdict wins. Callers fall back to the model only when this is null
  /// (Gemini disabled or its call failed).
  bool get effectiveVerdict => geminiSaysViolent;

  /// Builds a verification from Gemini's JSON reply, comparing its verdict to
  /// the [modelSaysViolent] verdict from the primary model.
  factory GeminiVerification.fromJson(
    Map<String, dynamic> json, {
    required bool modelSaysViolent,
  }) {
    final geminiViolent = json['is_violent'] == true;
    // Only keep flagged words when Gemini's verdict is violent — a "safe"
    // verdict shouldn't carry highlight words.
    final words = geminiViolent
        ? ((json['violent_words'] as List?)
                ?.map((w) => w.toString().trim())
                .where((w) => w.isNotEmpty)
                .toList() ??
            const <String>[])
        : const <String>[];
    return GeminiVerification(
      agrees: geminiViolent == modelSaysViolent,
      geminiSaysViolent: geminiViolent,
      reason: (json['reason'] as String?)?.trim().isNotEmpty == true
          ? (json['reason'] as String).trim()
          : 'No explanation provided.',
      confidence: ((json['confidence'] as num?)?.toDouble() ?? 0.0)
          .clamp(0.0, 1.0),
      violentWords: words,
    );
  }
}
