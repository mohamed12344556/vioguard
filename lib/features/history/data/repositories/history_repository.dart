import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/history_remote_datasource.dart';
import '../models/history_item_model.dart';
import '../models/history_details_model.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryItemModel>>> getHistory({String type = 'All'});
  Future<Either<Failure, HistoryDetailsModel>> getHistoryDetails(String id);
  Future<Either<Failure, void>> deleteHistory(String id);
}

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HistoryItemModel>>> getHistory({
    String type = 'All',
  }) async {
    try {
      final result = await remoteDataSource.getHistory(type: type);
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
  Future<Either<Failure, HistoryDetailsModel>> getHistoryDetails(
      String id) async {
    try {
      final result = await remoteDataSource.getHistoryDetails(id);
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
  Future<Either<Failure, void>> deleteHistory(String id) async {
    try {
      await remoteDataSource.deleteHistory(id);
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
