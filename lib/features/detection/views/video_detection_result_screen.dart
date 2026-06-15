import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../data/models/video_prediction_response.dart';
import '../widgets/source_content_card.dart';

class VideoDetectionResultScreen extends StatelessWidget {
  final VideoPredictionResponse response;
  final String? sourceUrl;

  const VideoDetectionResultScreen({
    super.key,
    required this.response,
    this.sourceUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isViolent = response.isViolent;
    final confidencePct = (response.confidence * 100).toStringAsFixed(1);
    final violencePct = (response.violence * 100).toStringAsFixed(1);
    final nonViolencePct = (response.nonViolence * 100).toStringAsFixed(1);

    return Scaffold(
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
          'Detection Result',
          style: TextStyle(
            color: AppColors.textPrimaryColor(context),
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
            // Source card (only present when analysis came from a URL)
            if (sourceUrl != null && sourceUrl!.isNotEmpty) ...[
              SourceContentCard(url: sourceUrl, isVideo: true),
              SizedBox(height: 20.h),
            ],
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
                  SizedBox(height: 8.h),
                  Text(
                    'Label: ${response.label}',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor(context),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Confidence Score
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.textSecondaryColor(context),
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'CONFIDENCE SCORES',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor(context),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Overall Confidence
            _buildScoreBar(
              context,
              label: 'Overall Confidence',
              value: response.confidence,
              displayValue: '$confidencePct%',
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            // Violence Score
            _buildScoreBar(
              context,
              label: 'Violence',
              value: response.violence,
              displayValue: '$violencePct%',
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            // Non-Violence Score
            _buildScoreBar(
              context,
              label: 'Non-Violence',
              value: response.nonViolence,
              displayValue: '$nonViolencePct%',
              color: AppColors.success,
            ),
            SizedBox(height: 24.h),
            // Analysis Summary
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondaryColor(context),
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'ANALYSIS SUMMARY',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor(context),
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
                  ? 'Our AI model identified patterns in the video that are consistent with violent content with $confidencePct% confidence.'
                  : 'Our AI model has verified this video content as safe and free of violent behavior with $confidencePct% confidence.',
              style: TextStyle(
                color: AppColors.textSecondaryColor(context),
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            _buildResultBullets(context, isViolent),
            SizedBox(height: 32.h),
            // Analyze Another Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  // Return to the Home/dashboard (the first route) rather than
                  // opening a separate detection screen.
                  Navigator.popUntil(context, (route) => route.isFirst);
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
                  'Analyze Another Video',
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

  Widget _buildScoreBar(
    BuildContext context, {
    required String label,
    required double value,
    required String displayValue,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimaryColor(context),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              displayValue,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8.h,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBullets(BuildContext context, bool violent) {
    final List<String> bullets;

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
                    color: AppColors.textPrimaryColor(context),
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
