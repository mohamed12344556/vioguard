import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/detection_remote_datasource.dart';
import '../models/analyze_request.dart';
import '../models/analyze_response.dart';

abstract class DetectionRepository {
  Future<Either<Failure, AnalyzeResponse>> analyze(String url);
}

class DetectionRepositoryImpl implements DetectionRepository {
  final DetectionRemoteDataSource remoteDataSource;

  DetectionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AnalyzeResponse>> analyze(String url) async {
    try {
      final result = await remoteDataSource.analyze(
        AnalyzeRequest(url: url),
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
