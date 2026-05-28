import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/reports_remote_datasource.dart';
import '../models/dashboard_report_model.dart';

abstract class ReportsRepository {
  Future<Either<Failure, DashboardReportModel>> getMonthlyDashboard();
  Future<Either<Failure, void>> updateReportSettings({
    required bool enableMonthlyReports,
  });
}

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardReportModel>> getMonthlyDashboard() async {
    try {
      final result = await remoteDataSource.getMonthlyDashboard();
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
  Future<Either<Failure, void>> updateReportSettings({
    required bool enableMonthlyReports,
  }) async {
    try {
      await remoteDataSource.updateReportSettings(
        enableMonthlyReports: enableMonthlyReports,
      );
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
