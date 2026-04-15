import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';

class VideoDetectionResultScreen extends StatelessWidget {
  final String? videoPath;
  final bool isViolent;
  final String? thumbnailPath;

  const VideoDetectionResultScreen({
    super.key,
    this.videoPath,
    required this.isViolent,
    this.thumbnailPath,
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
          'Detection Result',
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
            // Source Video Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SOURCE VIDEO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Video row
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.videocam_outlined,
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
                                videoPath ??
                                    'https://storage.cloud.api/v/sec...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                'Uploaded 2 mins ago',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Open Video button
                  SizedBox(
                    width: double.infinity,
                    height: 42.h,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.open_in_new,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Open Video',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Result Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: isViolent
                    ? AppColors.error.withValues(alpha: 0.06)
                    : AppColors.success.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: isViolent
                          ? AppColors.error.withValues(alpha: 0.12)
                          : AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isViolent ? Icons.warning_rounded : Icons.shield,
                      color: isViolent ? AppColors.error : AppColors.success,
                      size: 30.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isViolent
                        ? 'Violent Content\nDetected'
                        : 'Non-Violent Content\nDetected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isViolent ? AppColors.error : AppColors.success,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Analysis Summary
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'ANALYSIS SUMMARY',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              isViolent
                  ? 'Our AI engine identified specific sequences in the uploaded media that violate safety guidelines regarding harmful behavior.'
                  : 'Our AI engine has verified this video content as safe and free of harmful behavior.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            _buildResultBullets(),
            SizedBox(height: 32.h),
            // Analyze Another Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    Routes.videoDetection,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Analyze Another Content',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBullets() {
    final List<String> bullets;
    final bool violent = isViolent;

    if (violent) {
      bullets = [
        'High-impact physical actions detected',
        'Aggressive postures and gestures identified',
        'Rapid forceful movements consistent with aggression',
      ];
    } else {
      bullets = [
        'Normal activity detected',
        'No threat indicators found',
        'Standard behavioral patterns',
      ];
    }

    return Column(
      children: bullets.map((b) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Icon(
                violent
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: violent ? AppColors.error : AppColors.success,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  b,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
