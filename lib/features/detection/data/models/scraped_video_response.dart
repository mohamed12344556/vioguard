import 'video_binary_dto.dart';

/// Response from `POST /api/v1/content/scrape-video`.
///
/// The backend fetches the source URL and returns the video as a base64
/// binary ([videoBinary]) ready to be forwarded to the video AI model.
class ScrapedVideoResponse {
  final String sourceUrl;
  final String directUrl;
  final String contentType;
  final VideoBinaryDto videoBinary;

  const ScrapedVideoResponse({
    required this.sourceUrl,
    required this.directUrl,
    required this.contentType,
    required this.videoBinary,
  });

  factory ScrapedVideoResponse.fromJson(Map<String, dynamic> json) {
    final binary = json['videoBinary'];
    return ScrapedVideoResponse(
      sourceUrl: json['sourceUrl'] as String? ?? '',
      directUrl: json['directUrl'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      videoBinary: binary is Map<String, dynamic>
          ? VideoBinaryDto.fromJson(binary)
          : const VideoBinaryDto(fileName: '', contentType: '', length: 0),
    );
  }
}
