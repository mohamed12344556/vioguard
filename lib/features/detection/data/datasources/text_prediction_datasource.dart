import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../../../../core/config/app_config.dart';
import '../models/scraped_text_response.dart';
import '../models/text_prediction_response.dart';

abstract class TextPredictionDataSource {
  /// Asks the VioGuard backend to scrape text from a source [url]
  /// (`POST /api/v1/content/scrape-text`). Returns the extracted text content.
  Future<ScrapedTextResponse> scrapeText(String url);

  /// Calls the sentiment AI model directly to classify [text].
  Future<TextPredictionResponse> predict(String text);

  /// Persists the analysis result on the VioGuard backend
  /// (`POST /api/Detection/save-text-result`). Best-effort: failures are
  /// swallowed so a backend hiccup never blocks showing the result.
  Future<void> saveTextContent({
    required String text,
    required String result,
    required String userEmail,
    List<String> violentWords,
    String? url,
  });
}

class TextPredictionDataSourceImpl implements TextPredictionDataSource {
  /// Plain Dio for the standalone sentiment model.
  final Dio dio;

  /// Shared API consumer for the VioGuard backend (handles base URL + token).
  final ApiConsumer api;

  static const String _baseUrl = AppConfig.sentimentBaseUrl;

  TextPredictionDataSourceImpl({required this.dio, required this.api});

  @override
  Future<ScrapedTextResponse> scrapeText(String url) async {
    // The endpoint expects the URL as a raw JSON string body.
    final response = await api.post(
      ServerStrings.scrapeText,
      body: url,
    );

    return ScrapedTextResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TextPredictionResponse> predict(String text) async {
    final response = await dio.post(
      '$_baseUrl/sentiment',
      data: {'text': text},
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    // TEMP: inspect exactly what the sentiment model returns for an input.
    debugPrint('🧠 SENTIMENT raw response for "$text": ${response.data}');

    return TextPredictionResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveTextContent({
    required String text,
    required String result,
    required String userEmail,
    List<String> violentWords = const [],
    String? url,
  }) async {
    try {
      await api.post(
        ServerStrings.saveTextResult,
        body: {
          'url': url,
          'detectionDate': DateTime.now().toUtc().toIso8601String(),
          'userEmail': userEmail,
          'textContext': text,
          'violentResult': result,
          'violentWords': violentWords,
        },
      );
    } catch (_) {
      // Saving to history is best-effort; ignore failures.
    }
  }
}
