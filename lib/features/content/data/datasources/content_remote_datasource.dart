import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/content_model.dart';

abstract class ContentRemoteDataSource {
  /// `GET /api/Content` — lists content records, optionally scoped to a user.
  Future<List<ContentModel>> getContent({String? userEmail});
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final ApiConsumer api;

  ContentRemoteDataSourceImpl({required this.api});

  @override
  Future<List<ContentModel>> getContent({String? userEmail}) async {
    final response = await api.get(
      ServerStrings.content,
      queryParameters: userEmail == null ? null : {'userEmail': userEmail},
    );
    return (response as List<dynamic>)
        .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
