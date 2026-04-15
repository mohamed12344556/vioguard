import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../core/utils/dummy_data.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
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

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final TextEditingController _urlController = TextEditingController();

  final List<_RecentLinkItem> _recentLinks = DummyData.recentLinks
      .map((e) => _RecentLinkItem(
            url: e['url'] as String,
            timeAgo: e['timeAgo'] as String,
            isVideo: e['isVideo'] as bool,
            status: (e['isFlagged'] as bool)
                ? _LinkStatus.flagged
                : _LinkStatus.safe,
          ))
      .toList();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _detectViolence() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    Navigator.pushNamed(
      context,
      Routes.videoDetection,
      arguments: {'url': url},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                onPressed: () {},
                icon: Icon(
                  Icons.settings_outlined,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Subtitle
          Text(
            'Paste a link to analyze text or video content for potential violence or harmful themes.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          // URL Input
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Paste URL here...',
                      hintStyle: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                if (_urlController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _urlController.clear();
                      setState(() {});
                    },
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 18.sp,
                    ),
                  ),
              ],
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
                  'Our AI will automatically detect whether the content is text or video and scan for safety violations.',
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
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _urlController.text.trim().isNotEmpty
                  ? _detectViolence
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Detect Violence',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          // Recent Links
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${_recentLinks.length}',
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
          // Recent Links List
          ...List.generate(_recentLinks.length, (i) {
            final item = _recentLinks[i];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _RecentLinkCard(item: item),
            );
          }),
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
    );
  }
}

enum _LinkStatus { safe, flagged }

class _RecentLinkItem {
  final String url;
  final String timeAgo;
  final bool isVideo;
  final _LinkStatus status;

  const _RecentLinkItem({
    required this.url,
    required this.timeAgo,
    required this.isVideo,
    required this.status,
  });
}

class _RecentLinkCard extends StatelessWidget {
  final _RecentLinkItem item;

  const _RecentLinkCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              item.isVideo ? Icons.play_circle_outline : Icons.description_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          // URL + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.url,
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
                      item.timeAgo,
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
          // Status badge
          _StatusBadge(status: item.status),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right,
            color: AppColors.textLight,
            size: 18.sp,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _LinkStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSafe = status == _LinkStatus.safe;
    return Container(
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
            isSafe ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: isSafe ? AppColors.success : AppColors.error,
            size: 12.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            isSafe ? 'Safe' : 'Flagged',
            style: TextStyle(
              color: isSafe ? AppColors.success : AppColors.error,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
