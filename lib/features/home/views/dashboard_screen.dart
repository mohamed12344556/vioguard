import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routes/routes.dart';
import '../../../core/theme/colors.dart';
import '../../detection/presentation/cubit/text_prediction_cubit.dart';
import '../../detection/presentation/cubit/video_prediction_cubit.dart';
import '../../history/presentation/cubit/history_cubit.dart';
import '../../history/views/history_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../reports/views/reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

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

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: const [
              _HomeContent(),
              HistoryScreen(),
              ReportsScreen(),
              ProfileScreen(),
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
        onTap: (index) => setState(() => _currentIndex = index),
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
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final TextEditingController _inputController = TextEditingController();

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

  void _onInputChanged() => setState(() {});

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
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
    if (input.isEmpty) return;

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

  bool get _canDetect => _inputController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
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
                  'assets/images/app_logo.jpg',
                  width: 40.w,
                  height: 40.h,
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
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, Routes.settings),
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              'Paste a link to analyze text or video content for '
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
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  color: AppColors.textPrimaryColor(context),
                  fontSize: 15.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste URL or text here...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 15.sp,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 10.w),
                    child: Icon(
                      _isUrl ? Icons.link : Icons.notes_outlined,
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
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Our AI will automatically detect whether the content is '
                    'text or video and scan for safety violations.',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor(context),
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
                    final canDetect = value.text.trim().isNotEmpty;
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
