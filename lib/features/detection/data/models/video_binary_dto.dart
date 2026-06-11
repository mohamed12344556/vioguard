/// Metadata for a video binary stored on the VioGuard backend, returned by
/// `POST /api/Content/upload-video`.
class VideoBinaryDto {
  final String fileName;
  final String contentType;
  final int length;

  /// Base64-encoded file bytes as returned by the backend (`format: byte`).
  final String? data;

  const VideoBinaryDto({
    required this.fileName,
    required this.contentType,
    required this.length,
    this.data,
  });

  factory VideoBinaryDto.fromJson(Map<String, dynamic> json) {
    return VideoBinaryDto(
      fileName: json['fileName'] as String? ?? '',
      contentType: json['contentType'] as String? ?? '',
      length: (json['length'] as num?)?.toInt() ?? 0,
      data: json['data'] as String?,
    );
  }
}
