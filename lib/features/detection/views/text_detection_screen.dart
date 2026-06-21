import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import '../../../core/theme/colors.dart';
import '../presentation/cubit/text_prediction_cubit.dart';
import '../presentation/cubit/video_prediction_cubit.dart';
import 'text_detection_result_screen.dart';
import 'video_detection_result_screen.dart';

class TextDetectionScreen extends StatefulWidget {
  const TextDetectionScreen({super.key});

  @override
  State<TextDetectionScreen> createState() => _TextDetectionScreenState();
}

/// Max characters allowed in the analysis input.
const int _kMaxTextLength = 1500;

class _TextDetectionScreenState extends State<TextDetectionScreen> {
  final TextEditingController _textController = TextEditingController();

  /// On-device language identifier used to gate the input to English only.
  final LanguageIdentifier _languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  /// True when the current input is detected as Arabic. While true the Detect
  /// button is disabled (the model is English-only).
  bool _isArabic = false;

  /// Guards against overlapping async language-ID calls so a slower earlier
  /// result can't overwrite a newer one.
  int _detectSeq = 0;

  /// Cached so dispose() can reset the cubits without an unsafe context lookup
  /// on a deactivated widget.
  late TextPredictionCubit _cubit;
  late VideoPredictionCubit _videoCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit = context.read<TextPredictionCubit>();
    _videoCubit = context.read<VideoPredictionCubit>();
  }

  @override
  void dispose() {
    _cubit.reset();
    _videoCubit.reset();
    _textController.dispose();
    _languageIdentifier.close();
    super.dispose();
  }

  /// Identifies the input language on every change and flips [_isArabic] so the
  /// button enables/disables. URLs and empty input are never treated as Arabic.
  Future<void> _onTextChanged(String value) async {
    final text = value.trim();
    final seq = ++_detectSeq;

    if (text.isEmpty || _looksLikeUrl(text)) {
      if (_isArabic) setState(() => _isArabic = false);
      return;
    }

    try {
      final code = await _languageIdentifier.identifyLanguage(text);
      // A newer keystroke superseded this lookup — drop the stale result.
      if (seq != _detectSeq || !mounted) return;
      final isArabic = code == 'ar';
      if (isArabic != _isArabic) setState(() => _isArabic = isArabic);
    } catch (_) {
      // 'und' (undetermined) or any error: don't block the user.
      if (seq == _detectSeq && mounted && _isArabic) {
        setState(() => _isArabic = false);
      }
    }
  }

  /// Treats the input as a URL when it starts with http(s); otherwise as
  /// raw text to analyze directly.
  bool _looksLikeUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  /// A URL that points at a video stream/file, by extension. Such links must go
  /// to the video pipeline (scrape-video); the text pipeline rejects them (415).
  bool _looksLikeVideoUrl(String value) {
    // Drop any query string / fragment before checking the extension.
    final path = value.toLowerCase().split('?').first.split('#').first;
    const videoExtensions = [
      '.m3u8', '.mp4', '.mkv', '.webm', '.avi', '.mov',
    ];
    return videoExtensions.any(path.endsWith);
  }

  void _detectViolence() {
    final input = _textController.text.trim();
    if (input.isEmpty || _isArabic) return;

    if (_looksLikeUrl(input)) {
      // Route video links to the video pipeline; everything else stays text.
      if (_looksLikeVideoUrl(input)) {
        _videoCubit.predictFromUrl(input);
      } else {
        _cubit.predictFromUrl(input);
      }
    } else {
      _cubit.predict(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Navigate to the video result screen when a video URL was routed to
        // the video pipeline from this (text) screen.
        BlocListener<VideoPredictionCubit, VideoPredictionState>(
          listener: (context, state) {
            if (state is VideoPredictionLoaded) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: _videoCubit,
                    child: VideoDetectionResultScreen(response: state.response),
                  ),
                ),
              );
            } else if (state is VideoPredictionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
        BlocListener<TextPredictionCubit, TextPredictionState>(
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
          // Provide the existing cubit to the result screen so the Gemini
          // second-opinion card can update live when verification completes.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: _cubit,
                child: TextDetectionResultScreen(
                  analyzedText: analyzedText,
                  cleanedText: state.response.cleanedText,
                  isViolent: state.response.isViolent,
                  // Highlight the exact words Gemini flagged (when it ran).
                  highlightedWords: state.verification?.violentWords,
                ),
              ),
            ),
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
        ),
      ],
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
          'Text Detection',
          style: TextStyle(
            color: AppColors.textPrimaryColor(context),
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
                color: AppColors.surfaceColor(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: AppColors.textSecondaryColor(context),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Paste a link or type the text you want to analyze for violent content',
                          style: TextStyle(
                            color: AppColors.textSecondaryColor(context),
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
                    maxLength: _kMaxTextLength,
                    onChanged: _onTextChanged,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_kMaxTextLength),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter text or paste a link (http://...)',
                      hintStyle: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.borderColor(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.borderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: AppColors.primary.withValues(alpha: 0.03),
                    ),
                    style: TextStyle(
                      color: AppColors.textPrimaryColor(context),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Supported Languages Info / Arabic warning
            Row(
              children: [
                Icon(
                  _isArabic ? Icons.error_outline : Icons.info_outline,
                  color: _isArabic ? AppColors.error : AppColors.primary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _isArabic
                        ? 'Arabic is not supported. Please enter English text only.'
                        : 'Supported languages: English',
                    style: TextStyle(
                      color: _isArabic
                          ? AppColors.error
                          : AppColors.textSecondaryColor(context),
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Detect Button
            BlocBuilder<TextPredictionCubit, TextPredictionState>(
              builder: (context, state) {
                // A video URL is analyzed via the video cubit, so reflect either
                // pipeline's loading state on the button.
                final videoLoading = context
                    .watch<VideoPredictionCubit>()
                    .state is VideoPredictionLoading;
                final isLoading =
                    state is TextPredictionLoading || videoLoading;
                // English-only: block while Arabic is detected.
                final disabled = isLoading || _isArabic;
                return SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: disabled ? null : _detectViolence,
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
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 22.w,
                                height: 22.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Analyzing...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
