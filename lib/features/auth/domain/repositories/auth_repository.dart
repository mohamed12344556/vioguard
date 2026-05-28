import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/login_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  });
}
