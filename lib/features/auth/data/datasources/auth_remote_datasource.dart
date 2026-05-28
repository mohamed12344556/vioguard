import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer api;

  AuthRemoteDataSourceImpl({required this.api});

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await api.post(
      ServerStrings.login,
      body: request.toJson(),
    );
    return LoginResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> register(RegisterRequest request) async {
    await api.post(
      ServerStrings.register,
      body: request.toJson(),
    );
  }
}
