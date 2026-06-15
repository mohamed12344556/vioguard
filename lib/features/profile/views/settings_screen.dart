import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/routes/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../presentation/cubit/profile_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _twoStepEnabled = false;
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = context.read<ThemeCubit>().isDarkMode;
    context.read<ProfileCubit>().loadProfile();
  }

  void _applyDarkMode(bool isDark) {
    setState(() => _darkModeEnabled = isDark);
    context.read<ThemeCubit>().setDarkMode(isDark);
    _savePreferences();
  }

  /// Persists the dark-mode / monthly-report preferences to the backend.
  /// [_notificationsEnabled] maps to the backend's `isMonthlyReportEnabled`.
  void _savePreferences() {
    context.read<ProfileCubit>().updatePreferences(
      isDarkMode: _darkModeEnabled,
      isMonthlyReportEnabled: _notificationsEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          context.read<ThemeCubit>().hydrateFromBackend(
            state.profile.isDarkMode,
          );
          setState(() {
            _darkModeEnabled = context.read<ThemeCubit>().isDarkMode;
            _notificationsEnabled = state.profile.isMonthlyReportEnabled;
            _twoStepEnabled = state.profile.isTwoStepEnabled;
          });
        } else if (state is PreferencesUpdateSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Preferences updated')));
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
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
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimaryColor(context),
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
              // Account Settings
              _SectionTitle(title: 'Account Settings'),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondaryColor(context),
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.changePassword),
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.borderColor(context),
                      indent: 52.w,
                    ),
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Two-step verification',
                      trailing: Switch(
                        value: _twoStepEnabled,
                        onChanged: (v) => setState(() => _twoStepEnabled = v),
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      onTap: () =>
                          setState(() => _twoStepEnabled = !_twoStepEnabled),
                    ),
                  ],
                ),
              ),
              // SizedBox(height: 24.h),

              // // Privacy & Security
              // _SectionTitle(title: 'Privacy & Security'),
              // SizedBox(height: 10.h),
              // Container(
              //   decoration: BoxDecoration(
              //     color: AppColors.surfaceColor(context),
              //     borderRadius: BorderRadius.circular(12.r),
              //     border: Border.all(color: AppColors.borderColor(context)),
              //   ),
              //   child: Column(
              //     children: [
              //       _SettingsTile(
              //         title: 'Data usage information',
              //         trailing: Icon(
              //           Icons.chevron_right,
              //           color: AppColors.textSecondaryColor(context),
              //         ),
              //         onTap: () {},
              //       ),
              //       Divider(height: 1, color: AppColors.borderColor(context)),
              //       _SettingsTile(
              //         title: 'Privacy policy',
              //         trailing: Icon(
              //           Icons.chevron_right,
              //           color: AppColors.textSecondaryColor(context),
              //         ),
              //         onTap: () {},
              //       ),
              //       Divider(height: 1, color: AppColors.borderColor(context)),
              //       _SettingsTile(
              //         title: 'Terms of service',
              //         trailing: Icon(
              //           Icons.chevron_right,
              //           color: AppColors.textSecondaryColor(context),
              //         ),
              //         onTap: () {},
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 24.h),

              // // Linked Accounts
              // _SectionTitle(title: 'Linked Accounts'),
              // SizedBox(height: 10.h),
              // Container(
              //   decoration: BoxDecoration(
              //     color: AppColors.surface,
              //     borderRadius: BorderRadius.circular(12.r),
              //     border: Border.all(color: AppColors.border),
              //   ),
              //   child: _SettingsTile(
              //     leading: Container(
              //       width: 32.w,
              //       height: 32.h,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         border: Border.all(color: AppColors.border),
              //       ),
              //       child: Center(
              //         child: Text(
              //           'G',
              //           style: TextStyle(
              //             color: const Color(0xFF4285F4),
              //             fontSize: 16.sp,
              //             fontWeight: FontWeight.w700,
              //           ),
              //         ),
              //       ),
              //     ),
              //     title: 'Google',
              //     subtitle: 'Connected',
              //     trailing: TextButton(
              //       onPressed: () {},
              //       style: TextButton.styleFrom(
              //         minimumSize: Size.zero,
              //         padding: EdgeInsets.symmetric(
              //           horizontal: 8.w,
              //           vertical: 4.h,
              //         ),
              //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //       ),
              //       child: Text(
              //         'Disconnect',
              //         style: TextStyle(
              //           color: AppColors.primary,
              //           fontSize: 13.sp,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //     onTap: () {},
              //   ),
              // ),
              SizedBox(height: 24.h),

              // App Preferences
              _SectionTitle(title: 'App Preferences'),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.settings_outlined,
                      title: 'Dark mode',
                      trailing: Switch(
                        value: _darkModeEnabled,
                        onChanged: _applyDarkMode,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      onTap: () => _applyDarkMode(!_darkModeEnabled),
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.borderColor(context),
                      indent: 52.w,
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notification preferences',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (v) {
                          setState(() => _notificationsEnabled = v);
                          _savePreferences();
                        },
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      onTap: () {
                        setState(
                          () => _notificationsEnabled = !_notificationsEnabled,
                        );
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimaryColor(context),
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: 12.w),
            ] else if (icon != null) ...[
              Icon(
                icon,
                color: AppColors.textSecondaryColor(context),
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimaryColor(context),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
