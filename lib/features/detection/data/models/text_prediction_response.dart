/// Response from the sentiment AI model (`/sentiment`).
///
/// Example body:
/// ```json
/// { "TEXT": "...", "Cleand_Text": "...", "Sentiment_Label": "0" }
/// ```
///
/// `Sentiment_Label`: "0" => violent, "1" => non-violent (safe/neutral).
class TextPredictionResponse {
  final String originalText;
  final String cleanedText;
  final String sentimentLabel;

  const TextPredictionResponse({
    required this.originalText,
    required this.cleanedText,
    required this.sentimentLabel,
  });

  bool get isViolent => sentimentLabel.trim() == '0';

  factory TextPredictionResponse.fromJson(Map<String, dynamic> json) {
    return TextPredictionResponse(
      originalText: json['TEXT'] as String? ?? '',
      cleanedText: json['Cleand_Text'] as String? ?? '',
      sentimentLabel: json['Sentiment_Label']?.toString() ?? '0',
    );
  }
}
