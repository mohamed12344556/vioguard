import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/dashboard_report_model.dart';

abstract class ReportsRemoteDataSource {
  Future<DashboardReportModel> getMonthlyDashboard();
  Future<void> updateReportSettings({required bool enableMonthlyReports});
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiConsumer api;

  ReportsRemoteDataSourceImpl({required this.api});

  @override
  Future<DashboardReportModel> getMonthlyDashboard() async {
    final response = await api.get(ServerStrings.monthlyDashboard);
    return DashboardReportModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateReportSettings({
    required bool enableMonthlyReports,
  }) async {
    await api.post(
      ServerStrings.reportSettings,
      body: {'enableMonthlyReports': enableMonthlyReports},
    );
  }
}
