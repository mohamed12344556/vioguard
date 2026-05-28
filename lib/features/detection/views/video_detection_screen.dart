import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../presentation/cubit/video_prediction_cubit.dart';

class VideoDetectionScreen extends StatefulWidget {
  const VideoDetectionScreen({super.key});

  @override
  State<VideoDetectionScreen> createState() => _VideoDetectionScreenState();
}

class _VideoDetectionScreenState extends State<VideoDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedVideo;
  String? _fileName;

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

  void _analyzeVideo() {
    if (_selectedVideo == null) return;
    context.read<VideoPredictionCubit>().predict(_selectedVideo!.path);
  }

  @override
  void dispose() {
    context.read<VideoPredictionCubit>().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoPredictionCubit, VideoPredictionState>(
      listener: (context, state) {
        if (state is VideoPredictionLoaded) {
          Navigator.pushNamed(
            context,
            Routes.videoDetectionResult,
            arguments: state.response,
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
            'Analyze Video',
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
              Text(
                'Select a video to analyze for potential violence using our AI model.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              // Video picker area
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
              ),
              SizedBox(height: 12.h),
              // Info Note
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Our AI will analyze the video content and classify it as violent or non-violent with a confidence score.',
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
              // Analyze Button
              BlocBuilder<VideoPredictionCubit, VideoPredictionState>(
                builder: (context, state) {
                  final isLoading = state is VideoPredictionLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _selectedVideo != null && !isLoading
                          ? _analyzeVideo
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.4),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
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
              const Spacer(),
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
      ),
    );
  }
}
