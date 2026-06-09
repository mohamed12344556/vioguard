import 'package:dio/dio.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../../../../core/config/app_config.dart';
import '../models/text_prediction_response.dart';

abstract class TextPredictionDataSource {
  /// Calls the sentiment AI model directly to classify [text].
  Future<TextPredictionResponse> predict(String text);

  /// Persists the analysis result on the VioGuard backend
  /// (`POST /api/Content/text`). Best-effort: failures are swallowed so a
  /// backend hiccup never blocks showing the result to the user.
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
        ServerStrings.textContent,
        body: {
          'url': url,
          'userEmail': userEmail,
          'textContext': text,
          'violentWords': violentWords,
        },
      );
    } catch (_) {
      // Saving to history is best-effort; ignore failures.
    }
  }
}
