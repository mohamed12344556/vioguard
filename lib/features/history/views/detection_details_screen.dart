import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../models/detection_history_item.dart';

class DetectionDetailsScreen extends StatelessWidget {
  final DetectionHistoryItem item;

  const DetectionDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Detection Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // METADATA section
            _SectionLabel(label: 'METADATA'),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // DATE
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textSecondary,
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
                              item.formattedDate,
                              style: TextStyle(
                                color: AppColors.textPrimary,
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
                    color: AppColors.border,
                  ),
                  SizedBox(width: 16.w),
                  // TIME
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.textSecondary,
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
                              item.formattedTime,
                              style: TextStyle(
                                color: AppColors.textPrimary,
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

            // SOURCE INVESTIGATION section
            _SectionLabel(label: 'SOURCE INVESTIGATION'),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content Type row
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
                          item.isVideo
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
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              item.isVideo ? 'Video Stream (MP4)' : 'Text',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Verified badge
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // URL row
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: AppColors.primary,
                        size: 14.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          item.sourceUrl ?? 'https://storage.cdn.media/v/4921-prod-high',
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
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // CURRENT STATUS section
            _SectionLabel(label: 'CURRENT STATUS'),
            SizedBox(height: 10.h),
            _buildStatusBadge(),
            SizedBox(height: 20.h),

            // Confidence (violent video only)
            if (item.isVideo && item.isViolent && item.confidenceScore != null) ...[
              _SectionLabel(label: 'DETECTION CONFIDENCE', trailing: '${item.confidenceScore}%', trailingColor: AppColors.error),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: LinearProgressIndicator(
                  value: item.confidenceScore! / 100,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.error),
                  minHeight: 10.h,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'The AI model has high certainty regarding this classification based on visual and audio forensic analysis.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // ANALYSIS SUMMARY section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ANALYSIS SUMMARY',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ..._buildSummaryBullets(),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // View Source Content Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.open_in_new, size: 18.sp),
                label: Text(
                  'View Source Content',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Share + Delete buttons row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.share_outlined, size: 18.sp),
                      label: Text(
                        'Share Report',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(context),
                      icon: Icon(Icons.delete_outline, size: 18.sp, color: AppColors.error),
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
                        side: BorderSide(color: AppColors.border),
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
      ),
    );
  }

  Widget _buildStatusBadge() {
    final Color badgeColor;
    final IconData badgeIcon;
    final String badgeText;

    if (item.isViolent) {
      badgeColor = AppColors.error;
      badgeIcon = Icons.warning_rounded;
      badgeText = 'Violent Content';
    } else if (item.result == DetectionResult.againstViolent) {
      badgeColor = AppColors.success;
      badgeIcon = Icons.shield;
      badgeText = 'Against Violent Content';
    } else if (item.result == DetectionResult.neutral) {
      badgeColor = AppColors.primary;
      badgeIcon = Icons.info_outline;
      badgeText = 'Neutral Content';
    } else {
      badgeColor = AppColors.success;
      badgeIcon = Icons.shield;
      badgeText = 'Non-Violent Content';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: Colors.white, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            badgeText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSummaryBullets() {
    List<String> bullets;
    Color dotColor;

    if (item.flagReasons != null && item.flagReasons!.isNotEmpty) {
      bullets = item.flagReasons!;
      dotColor = item.isViolent ? AppColors.error : AppColors.success;
    } else if (item.isViolent) {
      dotColor = AppColors.error;
      if (item.isVideo) {
        bullets = [
          'Identified high-impact physical actions in the video.',
          'Detected rapid and forceful movements consistent with aggression.',
          'Presence of aggressive postures and gestures between individuals.',
        ];
      } else {
        bullets = [
          'Aggressive tone detected in middle paragraph',
          'Harmful intent identified against specific groups',
          'Threatening language found in closing statements',
        ];
      }
    } else if (item.result == DetectionResult.againstViolent) {
      dotColor = AppColors.success;
      bullets = [
        'Encourages safety and peace as a priority',
        'Anti-violence message detected in primary phrasing',
        'Positive intent identified throughout the context',
      ];
    } else if (item.result == DetectionResult.neutral) {
      dotColor = AppColors.primary;
      bullets = [
        'Informational and academic tone throughout the provided segment.',
        'No aggressive or inflammatory language detected in the context.',
        'No harmful intent or prohibited keywords identified by the engine.',
      ];
    } else {
      dotColor = AppColors.success;
      if (item.isVideo) {
        bullets = [
          'No harmful actions detected',
          'Content is safe and compliant',
          'Normal behavioral patterns',
        ];
      } else {
        bullets = [
          'No aggressive tone detected in the content.',
          'Informational or neutral language used throughout.',
          'No harmful intent identified.',
        ];
      }
    }

    return bullets.map((b) {
      return Padding(
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
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                b,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
  final String? trailing;
  final Color? trailingColor;

  const _SectionLabel({
    required this.label,
    this.trailing,
    this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: trailingColor ?? AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
