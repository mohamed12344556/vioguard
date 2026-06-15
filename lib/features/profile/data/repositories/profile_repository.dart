import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile(String email);
  Future<Either<Failure, void>> updateProfile(
      String email, UserProfileModel profile);
  Future<Either<Failure, void>> updatePreferences(
      String email, UpdatePreferencesRequest request);
  Future<Either<Failure, void>> changePassword(
      String email, ChangePasswordRequest request);
  Future<Either<Failure, void>> deleteAccount(String email);
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile(
      String email) async {
    try {
      final result = await remoteDataSource.getUserProfile(email);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
      String email, UserProfileModel profile) async {
    try {
      await remoteDataSource.updateProfile(email, profile);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
      String email, UpdatePreferencesRequest request) async {
    try {
      await remoteDataSource.updatePreferences(email, request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      String email, ChangePasswordRequest request) async {
    try {
      await remoteDataSource.changePassword(email, request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String email) async {
    try {
      await remoteDataSource.deleteAccount(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
