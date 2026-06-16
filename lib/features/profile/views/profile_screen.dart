import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/api/token_storage.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/routes/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../auth/presentation/bloc/auth_cubit.dart';
import '../presentation/cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imagePath;
  bool _isDeleting = false;

  /// Mirrors [ThemeCubit] for the Dark mode switch; the cubit stays the source
  /// of truth and the backend preference is updated alongside it.
  bool _darkModeEnabled = false;

  /// Last loaded profile values. Kept in state so the fields stay populated even
  /// when the shared [ProfileCubit] later emits a non-[ProfileLoaded] state
  /// (e.g. ProfileUpdating / PreferencesUpdateSuccess after toggling Dark mode),
  /// which would otherwise blank the form until the next loadProfile().
  String _fullName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = context.read<ThemeCubit>().isDarkMode;
    context.read<ProfileCubit>().loadProfile();
    // Restore the previously-saved profile image so it survives an app restart.
    final savedPath = sl<TokenStorage>().getProfileImagePath();
    if (savedPath != null && File(savedPath).existsSync()) {
      _imagePath = savedPath;
    }
  }

  void _applyDarkMode(bool isDark) {
    setState(() => _darkModeEnabled = isDark);
    context.read<ThemeCubit>().setDarkMode(isDark);
    // Persist alongside the existing monthly-report preference.
    context.read<ProfileCubit>().updatePreferences(
      isDarkMode: isDark,
      isMonthlyReportEnabled: _isMonthlyReportEnabled,
    );
  }

  bool _isMonthlyReportEnabled = false;

  /// Splits a full name into first/last parts for display. The first word is
  /// the first name; everything after it is the last name.
  static (String, String) _splitName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return ('', '');
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex == -1) return (trimmed, '');
    return (
      trimmed.substring(0, spaceIndex),
      trimmed.substring(spaceIndex + 1).trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          context.read<ThemeCubit>().hydrateFromBackend(
            state.profile.isDarkMode,
          );
          setState(() {
            _darkModeEnabled = context.read<ThemeCubit>().isDarkMode;
            _isMonthlyReportEnabled = state.profile.isMonthlyReportEnabled;
            _fullName = state.profile.fullName;
            _email = state.profile.email;
          });
          return;
        }
        if (!_isDeleting) return;
        if (state is AccountDeleteSuccess) {
          _isDeleting = false;
          context.read<AuthCubit>().logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been deleted.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        } else if (state is ProfileError) {
          _isDeleting = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Use the last loaded values (kept in state) rather than only the
        // current state, so the form stays populated across non-loaded states.
        final fullName = state is ProfileLoaded
            ? state.profile.fullName
            : _fullName;
        final email = state is ProfileLoaded ? state.profile.email : _email;

        final (firstName, lastName) = _splitName(fullName);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor(context),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              if (state is ProfileLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )
              else if (state is ProfileError)
                Column(
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () =>
                          context.read<ProfileCubit>().loadProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else ...[
                // Profile Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor(context)),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _imagePath != null
                                ? Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                    size: 40.sp,
                                  ),
                          ),
                          if (_imagePath != null)
                            Positioned(
                              right: -4.w,
                              bottom: -4.h,
                              child: GestureDetector(
                                onTap: _showDeletePhotoDialog,
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surfaceColor(context),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      _ProfileField(label: 'First Name', value: firstName),
                      // SizedBox(height: 16.h),
                      // _ProfileField(label: 'Last Name', value: lastName),
                      SizedBox(height: 16.h),
                      _ProfileField(label: 'Email', value: email),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: 160.w,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final profileCubit = context.read<ProfileCubit>();
                            final result = await Navigator.pushNamed(
                              context,
                              Routes.editProfile,
                            );
                            if (!mounted) return;
                            if (result is String && result.isNotEmpty) {
                              setState(() => _imagePath = result);
                            }
                            profileCubit.loadProfile();
                          },
                          icon: Icon(Icons.edit_outlined, size: 16.sp),
                          label: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.borderColor(context),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Account Settings
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.borderColor(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Settings',
                        style: TextStyle(
                          color: AppColors.textPrimaryColor(context),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _AccountRow(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondaryColor(context),
                          size: 22.sp,
                        ),
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.changePassword),
                      ),
                      Divider(
                        height: 24.h,
                        color: AppColors.borderColor(context),
                      ),
                      _AccountRow(
                        icon: Icons.dark_mode_outlined,
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
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Log Out
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: Icon(Icons.logout, size: 20.sp),
                    label: Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.borderColor(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Delete Account
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteAccountDialog(context),
                    icon: Icon(Icons.delete_outline, size: 20.sp),
                    label: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.login,
                (route) => false,
              );
            },
            child: Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeletePhotoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text(
          'Are you sure you want to remove your profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePhoto();
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto() async {
    await sl<TokenStorage>().clearProfileImagePath();
    if (!mounted) return;
    setState(() => _imagePath = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile photo removed.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _isDeleting = true;
              profileCubit.deleteAccount();
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondaryColor(context),
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.borderColor(context)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimaryColor(context),
              fontSize: 15.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  const _AccountRow({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimaryColor(context), size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimaryColor(context),
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
