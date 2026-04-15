import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/dummy_data.dart';
import '../models/detection_history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Text', 'Video'];

  final List<DetectionHistoryItem> _historyItems = DummyData.historyItems;

  List<DetectionHistoryItem> get _filteredItems {
    if (_selectedTabIndex == 0) return _historyItems;
    if (_selectedTabIndex == 1) {
      return _historyItems.where((item) => item.isText).toList();
    }
    return _historyItems.where((item) => item.isVideo).toList();
  }

  String _formatItemDate(DetectionHistoryItem item) {
    final now = DateTime.now();
    final diff = now.difference(item.dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    // Otherwise show date
    return '${item.dateTime.day}/${item.dateTime.month}/${item.dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        // Title
        Text(
          'History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20.h),
        // Tab Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = index),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Text(
                        _tabs[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _filteredItems.length,
            separatorBuilder: (context, i) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return _HistoryItemCard(
                item: item,
                displayDate: _formatItemDate(item),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.detectionDetails,
                    arguments: item,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final DetectionHistoryItem item;
  final String displayDate;
  final VoidCallback onTap;

  const _HistoryItemCard({
    required this.item,
    required this.displayDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                item.isVideo
                    ? Icons.play_circle_outline
                    : Icons.description_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // URL + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.sourceUrl ?? (item.isVideo ? 'video_sample.mp4' : 'Text content'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.textLight,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        displayDate,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Status badge
            _StatusBadge(isViolent: item.isViolent),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isViolent;

  const _StatusBadge({required this.isViolent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isViolent
            ? AppColors.error.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isViolent
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: isViolent ? AppColors.error : AppColors.success,
            size: 12.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            isViolent ? 'Flagged' : 'Safe',
            style: TextStyle(
              color: isViolent ? AppColors.error : AppColors.success,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
