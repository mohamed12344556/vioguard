import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../models/video_prediction_response.dart';

abstract class VideoPredictionDataSource {
  Future<VideoPredictionResponse> predict(String filePath);
}

class VideoPredictionDataSourceImpl implements VideoPredictionDataSource {
  final Dio dio;
  static const String _baseUrl = AppConfig.videoModelBaseUrl;

  VideoPredictionDataSourceImpl({required this.dio});

  @override
  Future<VideoPredictionResponse> predict(String filePath) async {
    final fileName = filePath.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

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
}
