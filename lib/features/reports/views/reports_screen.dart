import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _monthlyReportsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              'Reports',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Enable Monthly Reports toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable Monthly Reports',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Receive a summary of detected violent content every week',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Switch(
                  value: _monthlyReportsEnabled,
                  onChanged: (v) => setState(() => _monthlyReportsEnabled = v),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: 20.h),

            // Violence Detected %
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Violence Detected',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '34%',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: 0.34,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.success),
                minHeight: 10.h,
              ),
            ),
            SizedBox(height: 28.h),

            // Monthly Summary Preview
            _SummarySection(
              title: 'Monthly Summary Preview',
              description: 'Total analyses performed this months : 2,745',
              items: const [
                _SummaryItem(
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
                  label: 'Violent incidents:',
                  value: '84',
                  valueColor: AppColors.error,
                ),
                _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Non-violent analyses:',
                  value: '1,203',
                  valueColor: AppColors.success,
                ),
                _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Against violence analyses:',
                  value: '458',
                  valueColor: AppColors.success,
                ),
                _SummaryItem(
                  icon: Icons.info_outline,
                  color: AppColors.primary,
                  label: 'Neutral Text analyses:',
                  value: '1,000',
                  valueColor: AppColors.primary,
                ),
              ],
              timeRange: 'Time range: Jan 1 – Jan 30',
            ),
            SizedBox(height: 20.h),

            // Monthly Summary Preview For Videos
            _SummarySection(
              title: 'Monthly Summary Preview For Videos',
              description: 'Total analyzed videos performed this months : 1,245',
              items: const [
                _SummaryItem(
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
                  label: 'Violent incidents:',
                  value: '42',
                  valueColor: AppColors.error,
                ),
                _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Non-violent analyses:',
                  value: '1,203',
                  valueColor: AppColors.success,
                ),
              ],
              timeRange: 'Time range: Jan 1 – Jan 30',
            ),
            SizedBox(height: 20.h),

            // Monthly Summary Preview For Text
            _SummarySection(
              title: 'Monthly Summary Preview For Text',
              description: 'Total analyzed texts performed this months : 1,500',
              items: const [
                _SummaryItem(
                  icon: Icons.warning_rounded,
                  color: AppColors.error,
                  label: 'Violent incidents:',
                  value: '42',
                  valueColor: AppColors.error,
                ),
                _SummaryItem(
                  icon: Icons.shield,
                  color: AppColors.success,
                  label: 'Against violence analyses:',
                  value: '458',
                  valueColor: AppColors.success,
                ),
                _SummaryItem(
                  icon: Icons.info_outline,
                  color: AppColors.primary,
                  label: 'Neutral Text analyses:',
                  value: '1,000',
                  valueColor: AppColors.primary,
                ),
              ],
              timeRange: 'Time range: Jan 1 – Jan 30',
            ),
            SizedBox(height: 28.h),

            // Save Report Settings button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Report Settings',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
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
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          description,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            height: 1.4,
          ),
        ),
        SizedBox(height: 12.h),
        ...items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Icon(item.icon, color: item.color, size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  item.label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  item.value,
                  style: TextStyle(
                    color: item.valueColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 4.h),
        Text(
          timeRange,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
