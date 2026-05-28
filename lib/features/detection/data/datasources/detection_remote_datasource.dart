import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/analyze_request.dart';
import '../models/analyze_response.dart';

abstract class DetectionRemoteDataSource {
  Future<AnalyzeResponse> analyze(AnalyzeRequest request);
}

class DetectionRemoteDataSourceImpl implements DetectionRemoteDataSource {
  final ApiConsumer api;

  DetectionRemoteDataSourceImpl({required this.api});

  @override
  Future<AnalyzeResponse> analyze(AnalyzeRequest request) async {
    final response = await api.post(
      ServerStrings.analyze,
      body: request.toJson(),
    );
    return AnalyzeResponse.fromJson(response as Map<String, dynamic>);
  }
}
