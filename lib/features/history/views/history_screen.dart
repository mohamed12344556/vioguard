import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../models/detection_history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Text', 'Video'];

  // Sample data
  final List<DetectionHistoryItem> _historyItems = [
    DetectionHistoryItem(
      id: '1',
      type: DetectionType.text,
      result: DetectionResult.nonViolent,
      dateTime: DateTime(2024, 7, 26, 16, 20),
      content: 'This is a sample text that contains no aggressive or harmful intent. It promotes clear, respectful communication.',
    ),
    DetectionHistoryItem(
      id: '2',
      type: DetectionType.video,
      result: DetectionResult.violent,
      dateTime: DateTime(2024, 6, 12, 10, 0),
      confidenceScore: 82,
      flagReasons: [
        'Identified high-impact physical actions in the video.',
        'Detected rapid and forceful movements consistent with aggression.',
        'Presence of aggressive postures and gestures between individuals.',
      ],
    ),
    DetectionHistoryItem(
      id: '3',
      type: DetectionType.text,
      result: DetectionResult.violent,
      dateTime: DateTime(2024, 5, 10, 20, 15),
      content: 'I will absolutely destroy them. They won\'t know what hit them. This is a crucial fight, and I plan to brutally win.',
      flagReasons: [
        'Threatening intent: Phrases like "destroy them" and "won\'t know what hit them" imply direct harm.',
        'Violent keywords: "Brutally" directly indicates violent action or manner.',
        'Context suggesting harm: The overall tone of a "fight" combined with aggressive language suggests intent for harm.',
      ],
    ),
    DetectionHistoryItem(
      id: '4',
      type: DetectionType.video,
      result: DetectionResult.violent,
      dateTime: DateTime(2024, 4, 28, 11, 30),
      confidenceScore: 75,
    ),
    DetectionHistoryItem(
      id: '5',
      type: DetectionType.text,
      result: DetectionResult.nonViolent,
      dateTime: DateTime(2024, 4, 19, 14, 0),
      content: 'Looking forward to our meeting tomorrow. Let\'s discuss the project updates.',
    ),
    DetectionHistoryItem(
      id: '6',
      type: DetectionType.video,
      result: DetectionResult.nonViolent,
      dateTime: DateTime(2024, 4, 10, 7, 45),
    ),
  ];

  List<DetectionHistoryItem> get _filteredItems {
    if (_selectedTabIndex == 0) return _historyItems;
    if (_selectedTabIndex == 1) {
      return _historyItems.where((item) => item.isText).toList();
    }
    return _historyItems.where((item) => item.isVideo).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        // Title
        Text(
          'History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 20.h),
        // Tab Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = index),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Text(
                        _tabs[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // History List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _filteredItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return _HistoryItemCard(
                item: item,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.detectionDetails,
                    arguments: item,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final DetectionHistoryItem item;
  final VoidCallback onTap;

  const _HistoryItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  item.isText ? Icons.description_outlined : Icons.videocam_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  item.isText ? 'Text Detection' : 'Video Detection',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Result Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: item.isViolent ? AppColors.error : AppColors.success,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    item.isViolent ? 'Violent' : 'Non-Violent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Date Time
                Text(
                  '${item.formattedDate} · ${item.formattedTime}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
