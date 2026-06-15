import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';

/// The "SOURCE VIDEO / SOURCE CONTENT" card shown at the top of a detection
/// result. Displays the analyzed source URL with an action to open it
/// externally. Renders nothing when there is no URL (e.g. raw text analysis).
class SourceContentCard extends StatelessWidget {
  final String? url;
  final bool isVideo;

  const SourceContentCard({super.key, required this.url, this.isVideo = false});

  Future<void> _open() async {
    final raw = url;
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final link = url;
    if (link == null || link.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isVideo ? 'SOURCE VIDEO' : 'SOURCE CONTENT',
          style: TextStyle(
            color: AppColors.textSecondaryColor(context),
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.borderColor(context)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(12.r),
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
                            ? Icons.videocam_outlined
                            : Icons.description_outlined,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimaryColor(context),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton.icon(
                  onPressed: _open,
                  icon: Icon(Icons.open_in_new, size: 16.sp),
                  label: Text(
                    isVideo ? 'Open Video' : 'Open Source',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
