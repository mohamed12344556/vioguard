import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../presentation/cubit/history_cubit.dart';
import '../data/models/history_item_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Text', 'Video'];

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadHistory();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    context.read<HistoryCubit>().loadHistory(type: _tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.h),
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
                    onTap: () => _onTabChanged(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.transparent,
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
          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HistoryError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () => context
                            .read<HistoryCubit>()
                            .loadHistory(type: _tabs[_selectedTabIndex]),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is HistoryLoaded) {
                if (state.items.isEmpty) {
                  return Center(
                    child: Text(
                      'No history found',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: state.items.length,
                  separatorBuilder: (context, i) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _HistoryItemCard(
                      item: item,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.detectionDetails,
                          arguments: item.id,
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final HistoryItemModel item;
  final VoidCallback onTap;

  const _HistoryItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isViolent = item.safetyStatus.toLowerCase() == 'flagged' ||
        item.safetyStatus.toLowerCase() == 'violent';
    final isVideo = item.contentType.toLowerCase().contains('video');

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
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                isVideo
                    ? Icons.play_circle_outline
                    : Icons.description_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.domainName,
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
                        item.relativeTime,
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
            _StatusBadge(isViolent: isViolent, label: item.safetyStatus),
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
  final String label;

  const _StatusBadge({required this.isViolent, required this.label});

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
            label,
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
