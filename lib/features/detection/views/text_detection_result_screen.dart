import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';

class TextDetectionResultScreen extends StatelessWidget {
  final String analyzedText;
  final bool isViolent;
  final List<String>? highlightedWords;

  const TextDetectionResultScreen({
    super.key,
    required this.analyzedText,
    required this.isViolent,
    this.highlightedWords,
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
            // Result Badge
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isViolent ? AppColors.error : AppColors.success,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isViolent ? Icons.warning_rounded : Icons.check_circle,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      isViolent ? 'Violent Content' : 'Non-Violent Content',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Description
            Center(
              child: Text(
                isViolent
                    ? 'The provided text contains potentially harmful language.'
                    : 'The provided text does not contain patterns associated with violent or harmful language.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Divider
            Container(
              height: 1,
              color: AppColors.border,
            ),
            SizedBox(height: 24.h),
            // Analyzed Text Section
            if (isViolent) ...[
              Text(
                'Analyzed Text',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: _buildHighlightedText(),
              ),
              SizedBox(height: 24.h),
            ],
            // Divider
            Container(
              height: 1,
              color: AppColors.border,
            ),
            SizedBox(height: 24.h),
            // Feedback & Suggestions Section
            Text(
              'Feedback & Suggestions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            ..._buildSuggestions(),
            SizedBox(height: 32.h),
            // Analyze Another Text Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Routes.textDetection);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Analyze Another Text',
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

  Widget _buildHighlightedText() {
    if (highlightedWords == null || highlightedWords!.isEmpty) {
      return _buildDefaultHighlightedText();
    }

    final words = analyzedText.split(' ');
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          height: 1.6,
        ),
        children: words.map((word) {
          final isHighlighted = highlightedWords!.any(
            (hw) => word.toLowerCase().contains(hw.toLowerCase()),
          );
          return TextSpan(
            text: '$word ',
            style: TextStyle(
              backgroundColor:
                  isHighlighted ? AppColors.error.withValues(alpha: 0.2) : null,
              color: isHighlighted ? AppColors.error : AppColors.textPrimary,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDefaultHighlightedText() {
    // Default highlighted words for violent content demo
    final violentKeywords = [
      'crush',
      'enemies',
      'pay',
      'regret',
      'crossing',
      'threat',
      'kill',
      'destroy',
      'attack',
      'hurt',
    ];

    final words = analyzedText.split(' ');
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          height: 1.6,
        ),
        children: words.map((word) {
          final cleanWord =
              word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
          final isHighlighted = violentKeywords.contains(cleanWord);
          return TextSpan(
            text: '$word ',
            style: TextStyle(
              backgroundColor:
                  isHighlighted ? AppColors.error.withValues(alpha: 0.2) : null,
              color: isHighlighted ? AppColors.error : AppColors.textPrimary,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildSuggestions() {
    final suggestions = isViolent
        ? [
            'Review the highlighted sections for specific keywords and phrases.',
            'Consider rephrasing aggressive statements to maintain a constructive tone.',
            'Ensure content adheres to community guidelines for respectful communication.',
          ]
        : [
            'No violent language detected. Content is safe for broad distribution.',
            'Consider maintaining a respectful tone for wider appeal.',
            'Ensure clarity in your message to prevent misinterpretation.',
          ];

    return suggestions.map((suggestion) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primary,
              size: 18.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  color: AppColors.textSecondary,
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
}
