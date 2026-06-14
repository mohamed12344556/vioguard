import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../../../../core/config/app_config.dart';
import '../models/scraped_video_response.dart';
import '../models/video_prediction_response.dart';
import '../models/video_binary_dto.dart';

abstract class VideoPredictionDataSource {
  /// Asks the VioGuard backend to scrape a video from a source [url]
  /// (`POST /api/v1/content/scrape-video`). Returns the video as a base64
  /// binary ready to be forwarded to the video AI model.
  Future<ScrapedVideoResponse> scrapeVideo(String url);

  /// Calls the video AI model directly to classify the file at [filePath].
  Future<VideoPredictionResponse> predict(String filePath);

  /// Calls the video AI model directly to classify in-memory video [bytes]
  /// (e.g. a scraped video that was never written to disk).
  Future<VideoPredictionResponse> predictBytes(
    Uint8List bytes,
    String fileName,
  );

  /// Persists the analysis result on the VioGuard backend
  /// (`POST /api/Detection/save-video-result`). Best-effort: failures are
  /// swallowed so a backend hiccup never blocks showing the result.
  Future<void> saveVideoContent({
    required String userEmail,
    required double violentPercent,
    String? url,
  });

  /// Uploads a raw video file to the VioGuard backend
  /// (`POST /api/Content/upload-video`) and returns the stored binary metadata.
  Future<VideoBinaryDto> uploadVideo(String filePath);
}

class VideoPredictionDataSourceImpl implements VideoPredictionDataSource {
  /// Plain Dio for the standalone video model.
  final Dio dio;

  /// Shared API consumer for the VioGuard backend (handles base URL + token).
  final ApiConsumer api;

  static const String _baseUrl = AppConfig.videoModelBaseUrl;

  VideoPredictionDataSourceImpl({required this.dio, required this.api});

  @override
  Future<ScrapedVideoResponse> scrapeVideo(String url) async {
    // The endpoint expects the URL as a raw JSON string body.
    final response = await api.post(
      ServerStrings.scrapeVideo,
      body: url,
    );

    return ScrapedVideoResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<VideoPredictionResponse> predict(String filePath) async {
    final fileName = filePath.split('/').last.split('\\').last;
    final file = await MultipartFile.fromFile(filePath, filename: fileName);
    return _runModel(file);
  }

  @override
  Future<VideoPredictionResponse> predictBytes(
    Uint8List bytes,
    String fileName,
  ) async {
    final file = MultipartFile.fromBytes(bytes, filename: fileName);
    return _runModel(file);
  }

  /// Posts [file] to the video AI model and parses its prediction.
  Future<VideoPredictionResponse> _runModel(MultipartFile file) async {
    final formData = FormData.fromMap({'file': file});

    final response = await dio.post(
      '$_baseUrl/predict',
      data: formData,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'multipart/form-data',
          'ngrok-skip-browser-warning': 'true',
        },
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
      ),
    );

    return VideoPredictionResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<void> saveVideoContent({
    required String userEmail,
    required double violentPercent,
    String? url,
  }) async {
    try {
      await api.post(
        ServerStrings.saveVideoResult,
        body: {
          'url': url,
          'detectionDate': DateTime.now().toUtc().toIso8601String(),
          'userEmail': userEmail,
          'violentPercent': violentPercent,
        },
      );
    } catch (_) {
      // Saving to history is best-effort; ignore failures.
    }
  }

  @override
  Future<VideoBinaryDto> uploadVideo(String filePath) async {
    final fileName = filePath.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'Video': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await api.post(
      ServerStrings.uploadVideo,
      body: formData,
    );

    return VideoBinaryDto.fromJson(response as Map<String, dynamic>);
  }
}
