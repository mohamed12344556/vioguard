import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

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
            color: AppColors.textPrimary,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to exit VioGuard?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
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
        backgroundColor: AppColors.surface,
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
        color: AppColors.surface,
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
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
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

enum _DetectMode { video, text }

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  _DetectMode _mode = _DetectMode.video;
  File? _selectedVideo;
  String? _fileName;

  /// Cached so dispose() can reset the cubits without an unsafe context lookup
  /// on a deactivated widget.
  late VideoPredictionCubit _videoCubit;
  late TextPredictionCubit _textCubit;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoCubit = context.read<VideoPredictionCubit>();
    _textCubit = context.read<TextPredictionCubit>();
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _videoCubit.reset();
    _textCubit.reset();
    super.dispose();
  }

  void _selectMode(_DetectMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? video = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
        _fileName = video.name;
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.video_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: AppColors.primary),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _detectViolence() {
    if (_mode == _DetectMode.video) {
      if (_selectedVideo == null) return;
      context.read<VideoPredictionCubit>().predict(_selectedVideo!.path);
    } else {
      final text = _textController.text.trim();
      if (text.isEmpty) return;
      context.read<TextPredictionCubit>().predict(text);
    }
  }

  bool get _canDetect => _mode == _DetectMode.video
      ? _selectedVideo != null
      : _textController.text.trim().isNotEmpty;

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
                arguments: state.response,
              );
              setState(() {
                _selectedVideo = null;
                _fileName = null;
              });
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
                  'text': _textController.text,
                  'cleanedText': state.response.cleanedText,
                  'isViolent': state.response.isViolent,
                },
              );
              _textController.clear();
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
              _mode == _DetectMode.video
                  ? 'Upload a video to analyze its content for potential violence or harmful themes.'
                  : 'Paste or type text to analyze it for potential violence or harmful themes.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            // Mode selector (Video / Text)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _ModeTab(
                    label: 'Video',
                    icon: Icons.videocam_outlined,
                    isSelected: _mode == _DetectMode.video,
                    onTap: () => _selectMode(_DetectMode.video),
                  ),
                  _ModeTab(
                    label: 'Text',
                    icon: Icons.description_outlined,
                    isSelected: _mode == _DetectMode.text,
                    onTap: () => _selectMode(_DetectMode.text),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Input area: video picker or text field
            if (_mode == _DetectMode.video)
              GestureDetector(
                onTap: _showPickerOptions,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _selectedVideo != null
                          ? AppColors.primary
                          : AppColors.border,
                      width: _selectedVideo != null ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedVideo != null
                            ? Icons.videocam
                            : Icons.cloud_upload_outlined,
                        color: _selectedVideo != null
                            ? AppColors.primary
                            : AppColors.textLight,
                        size: 40.sp,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        _selectedVideo != null
                            ? _fileName ?? 'Video selected'
                            : 'Tap to select a video',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedVideo != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: _selectedVideo != null
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                      if (_selectedVideo == null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'Gallery or Camera',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                      if (_selectedVideo != null) ...[
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: _showPickerOptions,
                          child: Text(
                            'Change video',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              // Text input
              TextField(
                controller: _textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Enter text here...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.primary.withValues(alpha: 0.03),
                ),
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
              ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _mode == _DetectMode.video
                        ? 'Our AI will analyze the video content and classify it as violent or non-violent with a confidence score.'
                        : 'Our AI will analyze the text and classify it as violent or non-violent. Supported languages: English.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Detect Button
            BlocBuilder<VideoPredictionCubit, VideoPredictionState>(
              builder: (context, videoState) {
                final isLoading =
                    videoState is VideoPredictionLoading ||
                    context.watch<TextPredictionCubit>().state
                        is TextPredictionLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _canDetect && !isLoading
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
                              color: AppColors.textPrimary,
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
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
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
                      color: AppColors.textSecondary,
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

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
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
                      color: AppColors.textPrimary,
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
