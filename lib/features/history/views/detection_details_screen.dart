import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/colors.dart';
import '../data/models/history_details_model.dart';
import '../presentation/cubit/history_cubit.dart';

class DetectionDetailsScreen extends StatelessWidget {
  final String historyId;

  const DetectionDetailsScreen({super.key, required this.historyId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryDetailsCubit>()..loadDetails(historyId),
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.bg(context),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimaryColor(context),
              size: 20.sp,
            ),
          ),
          centerTitle: true,
          title: Text(
            'Detection Details',
            style: TextStyle(
              color: AppColors.textPrimaryColor(context),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<HistoryDetailsCubit, HistoryDetailsState>(
          builder: (context, state) {
            if (state is HistoryDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HistoryDetailsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () => context
                          .read<HistoryDetailsCubit>()
                          .loadDetails(historyId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is HistoryDetailsLoaded) {
              return _DetailsContent(
                details: state.details,
                historyId: historyId,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final HistoryDetailsModel details;
  final String historyId;

  const _DetailsContent({required this.details, required this.historyId});

  /// A violent/flagged status renders red; everything else renders green.
  Color _statusColor() {
    final status = details.currentStatus.toLowerCase();
    if (status.contains('violent') && !status.contains('non')) {
      return AppColors.error;
    }
    if (status.contains('flagged')) return AppColors.error;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final isVideo = details.contentType.toLowerCase().contains('video');
    final formattedDate = details.formattedDate;
    final formattedTime = details.formattedTime;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // METADATA
          _SectionLabel(label: 'METADATA'),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderColor(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textSecondaryColor(context),
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DATE',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: AppColors.textPrimaryColor(context),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 36.h,
                  color: AppColors.borderColor(context),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.textSecondaryColor(context),
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TIME',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: AppColors.textPrimaryColor(context),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // SOURCE INVESTIGATION
          _SectionLabel(label: 'SOURCE INVESTIGATION'),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        isVideo
                            ? Icons.videocam_outlined
                            : Icons.description_outlined,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content Type',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor(context),
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            details.contentType,
                            style: TextStyle(
                              color: AppColors.textPrimaryColor(context),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Only show a source link when the content actually came from a URL.
                // Manually-typed text has no source, so we don't fake one here.
                if (details.url.startsWith('http')) ...[
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: () => _openUrl(context, details.url),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: AppColors.primary,
                            size: 14.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              details.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13.sp,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.open_in_new,
                            color: AppColors.primary,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ANALYZED CONTENT (the text the user actually typed/analyzed)
          if (!isVideo && details.extractedTextContext.trim().isNotEmpty) ...[
            _SectionLabel(label: 'ANALYZED CONTENT'),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderColor(context)),
              ),
              child: Text(
                details.extractedTextContext,
                style: TextStyle(
                  color: AppColors.textPrimaryColor(context),
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // CURRENT STATUS
          _SectionLabel(label: 'CURRENT STATUS'),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusColor == AppColors.error
                      ? Icons.warning_rounded
                      : Icons.shield,
                  color: Colors.white,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  details.currentStatus,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ANALYSIS SUMMARY
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ANALYSIS SUMMARY',
                  style: TextStyle(
                    color: AppColors.textSecondaryColor(context),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 14.h),
                ...details.analysisSummary.map(
                  (line) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Container(
                            width: 7.w,
                            height: 7.h,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            line,
                            style: TextStyle(
                              color: AppColors.textPrimaryColor(context),
                              fontSize: 14.sp,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Delete button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(context),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18.sp,
                      color: AppColors.error,
                    ),
                    label: Text(
                      'Delete Report',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.borderColor(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// Opens [url] in an external browser, matching the result screen's
  /// SourceContentCard behavior. Shows a snackbar if it can't be opened.
  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    bool opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open the link'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<HistoryDetailsCubit>();
              // Use the parent history cubit to delete & go back
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textSecondaryColor(context),
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}
