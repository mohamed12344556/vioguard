/// Response from `POST /api/v1/content/scrape-text`.
///
/// The backend fetches the source URL and returns the extracted text ready
/// to be sent to the sentiment AI model.
class ScrapedTextResponse {
  final String sourceUrl;
  final String directUrl;
  final String contentType;
  final String textContent;

  const ScrapedTextResponse({
    required this.sourceUrl,
    required this.directUrl,
    required this.contentType,
    required this.textContent,
  });

  factory ScrapedTextResponse.fromJson(Map<String, dynamic> json) {
    return ScrapedTextResponse(
      sourceUrl: json['sourceUrl'] as String? ?? '',
      directUrl: json['directUrl'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      textContent: json['textContent'] as String? ?? '',
    );
  }
}
