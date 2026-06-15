import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
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

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await api.post(
      ServerStrings.forgotPassword,
      body: request.toJson(),
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await api.post(
      ServerStrings.resetPassword,
      body: request.toJson(),
    );
  }
}
