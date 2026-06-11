import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/content_remote_datasource.dart';
import '../models/content_model.dart';

abstract class ContentRepository {
  Future<Either<Failure, List<ContentModel>>> getContent({String? userEmail});
}

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remoteDataSource;

  ContentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ContentModel>>> getContent({
    String? userEmail,
  }) async {
    try {
      final result = await remoteDataSource.getContent(userEmail: userEmail);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
