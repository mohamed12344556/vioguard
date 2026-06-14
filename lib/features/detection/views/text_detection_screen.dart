import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../presentation/cubit/text_prediction_cubit.dart';

class TextDetectionScreen extends StatefulWidget {
  const TextDetectionScreen({super.key});

  @override
  State<TextDetectionScreen> createState() => _TextDetectionScreenState();
}

class _TextDetectionScreenState extends State<TextDetectionScreen> {
  final TextEditingController _textController = TextEditingController();

  /// Cached so dispose() can reset the cubit without an unsafe context lookup
  /// on a deactivated widget.
  late TextPredictionCubit _cubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<TextPredictionCubit>();
  }

  @override
  void dispose() {
    _cubit.reset();
    _textController.dispose();
    super.dispose();
  }

  /// Treats the input as a URL when it starts with http(s); otherwise as
  /// raw text to analyze directly.
  bool _looksLikeUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  void _detectViolence() {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    final cubit = context.read<TextPredictionCubit>();
    if (_looksLikeUrl(input)) {
      cubit.predictFromUrl(input);
    } else {
      cubit.predict(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TextPredictionCubit, TextPredictionState>(
      listener: (context, state) {
        if (state is TextPredictionLoaded) {
          // When a URL was scraped, show the extracted text the model actually
          // analyzed rather than the raw URL the user typed.
          final input = _textController.text.trim();
          final analyzedText = _looksLikeUrl(input)
              ? (state.response.originalText.isNotEmpty
                  ? state.response.originalText
                  : input)
              : input;
          Navigator.pushNamed(
            context,
            Routes.textDetectionResult,
            arguments: {
              'text': analyzedText,
              'cleanedText': state.response.cleanedText,
              'isViolent': state.response.isViolent,
            },
          );
        } else if (state is TextPredictionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
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
          'Text Detection',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input Card
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
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Paste a link or type the text you want to analyze for violent content',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _textController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Enter text or paste a link (http://...)',
                      hintStyle: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: AppColors.primary.withValues(alpha: 0.03),
                    ),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Supported Languages Info
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Supported languages: English',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Detect Button
            BlocBuilder<TextPredictionCubit, TextPredictionState>(
              builder: (context, state) {
                final isLoading = state is TextPredictionLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _detectViolence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Detect Violence',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    ),
    );
  }
}
