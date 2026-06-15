import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../presentation/cubit/reports_cubit.dart';
import '../data/models/dashboard_report_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ReportsError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message,
                    style: TextStyle(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 14.sp),
                    textAlign: TextAlign.center),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () =>
                      context.read<ReportsCubit>().loadDashboard(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is ReportsLoaded) {
          return _ReportsContent(report: state.report);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ReportsContent extends StatefulWidget {
  final DashboardReportModel report;

  const _ReportsContent({required this.report});

  @override
  State<_ReportsContent> createState() => _ReportsContentState();
}

class _ReportsContentState extends State<_ReportsContent> {
  late bool _monthlyReportsEnabled;

  @override
  void initState() {
    super.initState();
    _monthlyReportsEnabled = widget.report.enableMonthlyReports;
  }

  @override
  void didUpdateWidget(covariant _ReportsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // After updateSettings -> loadDashboard, BlocBuilder rebuilds this widget
    // with a fresh report but reuses the same State, so initState never reruns.
    // Re-sync the toggle with the server's value so it reflects what was saved.
    if (oldWidget.report.enableMonthlyReports !=
        widget.report.enableMonthlyReports) {
      _monthlyReportsEnabled = widget.report.enableMonthlyReports;
    }
  }

  String _formatNumber(int n) => NumberFormat('#,###').format(n);

  String _formatDate(DateTime d) => DateFormat('MMM d').format(d);

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final percentage = r.violencePercentage.clamp(0, 100).toDouble();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('Reports',
                style: TextStyle(
                    color: AppColors.textPrimaryColor(context),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: 24.h),
          // Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enable Monthly Reports',
                        style: TextStyle(
                            color: AppColors.textPrimaryColor(context),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: 4.h),
                    Text(
                        'Receive a summary of detected violent content every month',
                        style: TextStyle(
                            color: AppColors.textSecondaryColor(context),
                            fontSize: 13.sp,
                            height: 1.4)),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Switch(
                value: _monthlyReportsEnabled,
                onChanged: (v) {
                  setState(() => _monthlyReportsEnabled = v);
                  context
                      .read<ReportsCubit>()
                      .updateSettings(enableMonthlyReports: v);
                },
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Divider(color: AppColors.borderColor(context), height: 1),
          SizedBox(height: 20.h),

          // Violence percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Violence Detected',
                  style: TextStyle(
                      color: AppColors.textSecondaryColor(context),
                      fontSize: 14.sp)),
              Text('${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: AppColors.textPrimaryColor(context),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.borderColor(context),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                    percentage > 50 ? AppColors.error : AppColors.success),
              minHeight: 10.h,
            ),
          ),
          SizedBox(height: 28.h),

          // Monthly Summary
          _SummarySection(
            title: 'Monthly Summary Preview',
            description:
                'Total analyses performed this month: ${_formatNumber(r.totalAnalyses)}',
            items: [
              _SummaryItem(
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
                  label: 'Violent incidents:',
                  value: _formatNumber(r.totalViolentIncidents),
                  valueColor: AppColors.error),
              _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Non-violent analyses:',
                  value: _formatNumber(r.totalNonViolentAnalyses),
                  valueColor: AppColors.success),
              _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Against violence:',
                  value: _formatNumber(r.totalAgainstViolenceAnalyses),
                  valueColor: AppColors.success),
              _SummaryItem(
                  icon: Icons.info_outline,
                  color: AppColors.primary,
                  label: 'Neutral text:',
                  value: _formatNumber(r.totalNeutralTextAnalyses),
                  valueColor: AppColors.primary),
            ],
            timeRange:
                'Time range: ${_formatDate(r.dateFrom)} – ${_formatDate(r.dateTo)}',
          ),
          SizedBox(height: 20.h),

          // Video Summary
          _SummarySection(
            title: 'Video Summary',
            description:
                'Total analyzed videos: ${_formatNumber(r.videoSummary.totalVideos)}',
            items: [
              _SummaryItem(
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
                  label: 'Violent incidents:',
                  value: _formatNumber(r.videoSummary.violentIncidents),
                  valueColor: AppColors.error),
              _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Non-violent:',
                  value: _formatNumber(r.videoSummary.nonViolentAnalyses),
                  valueColor: AppColors.success),
            ],
            timeRange:
                'Time range: ${_formatDate(r.dateFrom)} – ${_formatDate(r.dateTo)}',
          ),
          SizedBox(height: 20.h),

          // Text Summary
          _SummarySection(
            title: 'Text Summary',
            description:
                'Total analyzed texts: ${_formatNumber(r.textSummary.totalTexts)}',
            items: [
              _SummaryItem(
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
                  label: 'Violent incidents:',
                  value: _formatNumber(r.textSummary.violentIncidents),
                  valueColor: AppColors.error),
              _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Against violence:',
                  value: _formatNumber(r.textSummary.againstViolenceAnalyses),
                  valueColor: AppColors.success),
              _SummaryItem(
                  icon: Icons.info_outline,
                  color: AppColors.primary,
                  label: 'Neutral text:',
                  value: _formatNumber(r.textSummary.neutralTextAnalyses),
                  valueColor: AppColors.primary),
            ],
            timeRange:
                'Time range: ${_formatDate(r.dateFrom)} – ${_formatDate(r.dateTo)}',
          ),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.valueColor,
  });
}

class _SummarySection extends StatelessWidget {
  final String title;
  final String description;
  final List<_SummaryItem> items;
  final String timeRange;

  const _SummarySection({
    required this.title,
    required this.description,
    required this.items,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: AppColors.textPrimaryColor(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700)),
        SizedBox(height: 12.h),
        Text(description,
            style: TextStyle(
                color: AppColors.textSecondaryColor(context),
                fontSize: 14.sp,
                height: 1.4)),
        SizedBox(height: 12.h),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Icon(item.icon, color: item.color, size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(item.label,
                      style: TextStyle(
                          color: AppColors.textSecondaryColor(context),
                          fontSize: 14.sp)),
                  SizedBox(width: 4.w),
                  Text(item.value,
                      style: TextStyle(
                          color: item.valueColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            )),
        SizedBox(height: 4.h),
        Text(timeRange,
            style: TextStyle(color: AppColors.textLight, fontSize: 12.sp)),
      ],
    );
  }
}
