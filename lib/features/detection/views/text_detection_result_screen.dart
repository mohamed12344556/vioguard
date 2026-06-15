import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vioguard/core/routes/routes.dart';

import '../../../core/theme/colors.dart';
import '../widgets/source_content_card.dart';

class TextDetectionResultScreen extends StatelessWidget {
  final String analyzedText;
  final String? cleanedText;
  final bool isViolent;
  final List<String>? highlightedWords;
  final String? sourceUrl;

  const TextDetectionResultScreen({
    super.key,
    required this.analyzedText,
    this.cleanedText,
    required this.isViolent,
    this.highlightedWords,
    this.sourceUrl,
  });

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textPrimaryColor(context),
              size: 22.sp,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source card (only present when analysis came from a URL)
            if (sourceUrl != null && sourceUrl!.isNotEmpty) ...[
              SourceContentCard(url: sourceUrl, isVideo: false),
              SizedBox(height: 20.h),
            ],
            // Analyzed Text Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'ANALYZED TEXT',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildHighlightedText(context),
                ],
              ),
            ),
            // Processed (cleaned) text card — what the model actually analyzed
            if (cleanedText != null &&
                cleanedText!.trim().isNotEmpty &&
                cleanedText!.trim() != analyzedText.trim()) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_fix_high,
                          color: AppColors.textSecondaryColor(context),
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'PROCESSED TEXT',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor(context),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      cleanedText!.trim(),
                      style: TextStyle(
                        color: AppColors.textPrimaryColor(context),
                        fontSize: 14.sp,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                        : 'No Violence Detected',
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
                  ? 'Our AI detected language that implies physical threat or aggressive intent.'
                  : 'Our AI engine has verified this content as safe, informative, and free of harmful intent.',
              style: TextStyle(
                color: AppColors.textSecondaryColor(context),
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            ..._buildBulletPoints(context),
            SizedBox(height: 32.h),
            // Analyze Another Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  // Return to the Home/dashboard (the first route) rather than
                  // opening a separate detection screen.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.home,
                    (route) => false,
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

  Widget _buildHighlightedText(BuildContext context) {
    final effectiveHighlightedWords =
        highlightedWords ??
        (isViolent
            ? [
                'kill',
                'crush',
                'destroy',
                'threat',
                'attack',
                'hurt',
                'enemies',
                'revenge',
                'regret',
                'pay',
                'watch your back',
                "don't last long",
              ]
            : []);

    if (effectiveHighlightedWords.isEmpty) {
      return Text(
        '"$analyzedText"',
        style: TextStyle(
          color: AppColors.textPrimaryColor(context),
          fontSize: 14.sp,
          height: 1.6,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final words = analyzedText.split(' ');
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textPrimaryColor(context),
          fontSize: 14.sp,
          height: 1.6,
          fontStyle: FontStyle.italic,
        ),
        children: [
          const TextSpan(text: '"'),
          ...words.map((word) {
            final cleanWord = word
                .replaceAll(RegExp(r'[^\w]'), '')
                .toLowerCase();
            final isHighlighted = effectiveHighlightedWords.any(
              (hw) => cleanWord.contains(hw.toLowerCase()),
            );
            return TextSpan(
              text: '$word ',
              style: isHighlighted
                  ? TextStyle(
                      backgroundColor: AppColors.error.withValues(alpha: 0.15),
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    )
                  : null,
            );
          }),
          const TextSpan(text: '"'),
        ],
      ),
    );
  }

  List<Widget> _buildBulletPoints(BuildContext context) {
    final List<Map<String, dynamic>> points;

    if (isViolent) {
      points = [
        {
          'title': 'Aggressive Tone Detected',
          'subtitle':
              'The text contains direct threats and assertive hostile language.',
          'isViolent': true,
        },
        {
          'title': 'Contextual Reasoning',
          'subtitle':
              'Inference suggests a sequence of future harmful actions.',
          'isViolent': true,
        },
      ];
    } else {
      points = [
        {
          'title': 'No aggressive tone detected',
          'subtitle': null,
          'isViolent': false,
        },
        {
          'title': 'Informational or neutral language',
          'subtitle': null,
          'isViolent': false,
        },
        {
          'title': 'No harmful intent identified',
          'subtitle': null,
          'isViolent': false,
        },
      ];
    }

    return points.map((p) {
      final bool violent = p['isViolent'] as bool;
      final String? subtitle = p['subtitle'] as String?;
      return Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 2.h),
              child: Icon(
                violent
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: violent ? AppColors.error : AppColors.primary,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['title'] as String,
                    style: TextStyle(
                      color: AppColors.textPrimaryColor(context),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
