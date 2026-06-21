import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../../../core/api/token_storage.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/routes/routes.dart';
import '../../../core/theme/colors.dart';
import '../../detection/presentation/cubit/text_prediction_cubit.dart';
import '../../detection/presentation/cubit/video_prediction_cubit.dart';
import '../../history/presentation/cubit/history_cubit.dart';
import '../../history/views/history_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../reports/presentation/cubit/reports_cubit.dart';
import '../../reports/views/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  /// Index of the Reports tab in [IndexedStack] / the bottom nav.
  static const int _reportsTabIndex = 2;

  /// Index of the Home tab in [IndexedStack] / the bottom nav.
  static const int _homeTabIndex = 0;

  /// Path of the saved profile image shown in the Home header. Re-read whenever
  /// the Home tab is reopened so a newly-picked avatar shows up immediately
  /// (tabs live in an IndexedStack, so [_HomeContent] never re-runs initState).
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _profileImagePath = _readProfileImagePath();
  }

  String? _readProfileImagePath() {
    final path = sl<TokenStorage>().getProfileImagePath();
    if (path != null && File(path).existsSync()) return path;
    return null;
  }

  void _onTabSelected(int index) {
    // Tabs live in an IndexedStack, so their screens stay alive and never
    // re-run initState. Refresh the Reports dashboard each time it's opened so
    // it reflects the latest analyses.
    if (index == _reportsTabIndex) {
      context.read<ReportsCubit>().loadDashboard();
    }
    // Refresh the header avatar when returning to Home, in case it was changed
    // from the Profile tab.
    if (index == _homeTabIndex) {
      _profileImagePath = _readProfileImagePath();
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Exit App',
          style: TextStyle(
            color: AppColors.textPrimaryColor(context),
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to exit VioGuard?',
          style: TextStyle(
            color: AppColors.textSecondaryColor(context),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondaryColor(context),
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Exit',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      // Close the app entirely instead of just popping the Dashboard route.
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // If we're not on the Home tab, back returns to Home instead of exiting.
        if (_currentIndex != _homeTabIndex) {
          _onTabSelected(_homeTabIndex);
          return;
        }
        // Already on Home: confirm before leaving the app.
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _HomeContent(profileImagePath: _profileImagePath),
              const HistoryScreen(),
              const ReportsScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        backgroundColor: AppColors.surfaceColor(context),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryColor(context),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24.sp),
            activeIcon: Icon(Icons.home, size: 24.sp),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: 24.sp),
            activeIcon: Icon(Icons.history, size: 24.sp),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined, size: 24.sp),
            activeIcon: Icon(Icons.bar_chart, size: 24.sp),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24.sp),
            activeIcon: Icon(Icons.person, size: 24.sp),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({this.profileImagePath});

  /// Path of the saved profile image, shown in the header avatar. Null — or a
  /// missing file — falls back to a person icon. Provided (and refreshed) by the
  /// dashboard so it stays in sync with edits made in the Profile tab.
  final String? profileImagePath;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

/// Max characters allowed in the analysis input.
const int _kMaxTextLength = 1500;

class _HomeContentState extends State<_HomeContent> {
  final TextEditingController _inputController = TextEditingController();

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
  late VideoPredictionCubit _videoCubit;
  late TextPredictionCubit _textCubit;

  /// Matches a URL ending in a known video file extension (optionally followed
  /// by a query string), e.g. `https://cdn.media/clip.mp4?token=...`.
  static final RegExp _videoUrlPattern = RegExp(
    r'\.(mp4|mov|avi|mkv|webm|m4v|flv|wmv|3gp)(\?.*)?$',
    caseSensitive: false,
  );
  static final RegExp _urlPattern = RegExp(r'^https?://', caseSensitive: false);

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoCubit = context.read<VideoPredictionCubit>();
    _textCubit = context.read<TextPredictionCubit>();
  }

  void _onInputChanged() {
    // Repaint for the enabled/disabled + clear-button states.
    setState(() {});
    // Identify the language so the button can block Arabic input.
    _detectLanguage(_inputController.text);
  }

  /// Identifies the input language and flips [_isArabic] so the button
  /// enables/disables. URLs and empty input are never treated as Arabic.
  Future<void> _detectLanguage(String value) async {
    final text = value.trim();
    final seq = ++_detectSeq;

    if (text.isEmpty || _urlPattern.hasMatch(text)) {
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

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _languageIdentifier.close();
    _videoCubit.reset();
    _textCubit.reset();
    super.dispose();
  }

  /// Detects whether the input is a URL, and if so whether it points at a video.
  bool get _isUrl => _urlPattern.hasMatch(_inputController.text.trim());
  bool get _isVideoUrl =>
      _videoUrlPattern.hasMatch(_inputController.text.trim());

  /// The URL last submitted for analysis, forwarded to the result screen's
  /// "source" card. Null when the user analyzed raw (non-URL) text.
  String? _lastSourceUrl;

  /// Routes the input to the right model: a video URL is scraped + analyzed by
  /// the video model, any other URL is scraped + analyzed as text, and raw text
  /// goes straight to the text model. The AI decides the content type for us.
  void _detectViolence() {
    final input = _inputController.text.trim();
    if (input.isEmpty || _isArabic) return;

    if (_isUrl) {
      _lastSourceUrl = input;
      if (_isVideoUrl) {
        _videoCubit.predictFromUrl(input);
      } else {
        _textCubit.predictFromUrl(input);
      }
    } else {
      _lastSourceUrl = null;
      _textCubit.predict(input);
    }
  }

  bool get _canDetect =>
      _inputController.text.trim().isNotEmpty && !_isArabic;

  @override
  Widget build(BuildContext context) {
    final profileImagePath = widget.profileImagePath;
    return MultiBlocListener(
      listeners: [
        BlocListener<VideoPredictionCubit, VideoPredictionState>(
          listener: (context, state) {
            if (state is VideoPredictionLoaded) {
              Navigator.pushNamed(
                context,
                Routes.videoDetectionResult,
                arguments: {
                  'response': state.response,
                  'sourceUrl': _lastSourceUrl,
                },
              );
              _inputController.clear();
              context.read<HistoryCubit>().loadHistory();
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
              Navigator.pushNamed(
                context,
                Routes.textDetectionResult,
                arguments: {
                  'text': state.response.originalText.isNotEmpty
                      ? state.response.originalText
                      : _inputController.text,
                  'cleanedText': state.response.cleanedText,
                  'isViolent': state.response.isViolent,
                  'sourceUrl': _lastSourceUrl,
                },
              );
              _inputController.clear();
              context.read<HistoryCubit>().loadHistory();
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
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/logo-removebg-preview.png',
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.shield, color: Colors.white, size: 24.sp),
                  ),
                ),
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: profileImagePath != null
                      ? Image.file(File(profileImagePath), fit: BoxFit.cover)
                      : Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              'Paste a link or type text directly to analyze it for '
              'potential violence or harmful themes.',
              style: TextStyle(
                color: AppColors.textSecondaryColor(context),
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            // Unified input: paste a URL or type text. The AI auto-detects
            // whether it is a video link, an article link, or raw text.
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _canDetect
                      ? AppColors.primary
                      : AppColors.borderColor(context),
                  width: _canDetect ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 5,
                maxLength: _kMaxTextLength,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_kMaxTextLength),
                ],
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  color: AppColors.textPrimaryColor(context),
                  fontSize: 15.sp,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Paste URL here Or type text...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 15.sp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 10.w),
                    child: Icon(
                      Icons.link,
                      color: _canDetect
                          ? AppColors.primary
                          : AppColors.textLight,
                      size: 22.sp,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  suffixIcon: _canDetect
                      ? IconButton(
                          onPressed: () => _inputController.clear(),
                          icon: Icon(
                            Icons.close,
                            color: AppColors.textSecondaryColor(context),
                            size: 20.sp,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Character counter (n/1500).
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _inputController,
              builder: (context, value, _) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${value.text.characters.length}/$_kMaxTextLength',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor(context),
                      fontSize: 11.sp,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        ? 'Arabic is not supported. Please enter English '
                            'text only.'
                        : 'Our AI will automatically detect whether the '
                            'content is text or video and scan for safety '
                            'violations.',
                    style: TextStyle(
                      color: _isArabic
                          ? AppColors.error
                          : AppColors.textSecondaryColor(context),
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Detect Button — listens to the input controller directly so the
            // enabled/disabled state flips on every keystroke, and to both
            // cubits so it shows a spinner while analyzing.
            BlocBuilder<VideoPredictionCubit, VideoPredictionState>(
              builder: (context, videoState) {
                final isLoading =
                    videoState is VideoPredictionLoading ||
                    context.watch<TextPredictionCubit>().state
                        is TextPredictionLoading;
                return ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _inputController,
                  builder: (context, value, _) {
                    final canDetect =
                        value.text.trim().isNotEmpty && !_isArabic;
                    return SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: canDetect && !isLoading
                            ? _detectViolence
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.4,
                          ),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22.w,
                                height: 22.h,
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
                );
              },
            ),
            SizedBox(height: 32.h),
            // Recent History from API
            BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoaded && state.items.isNotEmpty) {
                  final recentItems = state.items.take(3).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Recent Links',
                            style: TextStyle(
                              color: AppColors.textPrimaryColor(context),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${state.items.length}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ...recentItems.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _RecentLinkCard(
                            domainName: item.url,
                            contentType: item.contentType,
                            relativeTime: item.timeAgo,
                            safetyStatus: item.status,
                            onTap: () => Navigator.pushNamed(
                              context,
                              Routes.detectionDetails,
                              arguments: item.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: 12.h),
            // Privacy Note
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderColor(context)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.textLight,
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your analysis history is encrypted and only\nvisible to you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondaryColor(context),
                      fontSize: 13.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _RecentLinkCard extends StatelessWidget {
  final String domainName;
  final String contentType;
  final String relativeTime;
  final String safetyStatus;
  final VoidCallback onTap;

  const _RecentLinkCard({
    required this.domainName,
    required this.contentType,
    required this.relativeTime,
    required this.safetyStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSafe =
        safetyStatus.toLowerCase() != 'flagged' &&
        safetyStatus.toLowerCase() != 'violent';
    final isVideo = contentType.toLowerCase().contains('video');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor(context)),
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
                    domainName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimaryColor(context),
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
                        relativeTime,
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSafe
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSafe
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    color: isSafe ? AppColors.success : AppColors.error,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    safetyStatus,
                    style: TextStyle(
                      color: isSafe ? AppColors.success : AppColors.error,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right, color: AppColors.textLight, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
