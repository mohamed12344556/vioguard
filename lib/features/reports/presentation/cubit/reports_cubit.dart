import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_report_model.dart';
import '../../data/repositories/reports_repository.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository repository;

  ReportsCubit({required this.repository}) : super(const ReportsInitial());

  Future<void> loadDashboard() async {
    emit(const ReportsLoading());
    final result = await repository.getMonthlyDashboard();
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (report) => emit(ReportsLoaded(report)),
    );
  }

  Future<void> updateSettings({required bool enableMonthlyReports}) async {
    final result = await repository.updateReportSettings(
      enableMonthlyReports: enableMonthlyReports,
    );
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (_) => loadDashboard(),
    );
  }
}
