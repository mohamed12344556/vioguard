import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/colors.dart';
import '../../../core/routes/routes.dart';
import '../../auth/presentation/bloc/auth_cubit.dart';
import '../presentation/cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
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
        String fullName = '';
        String email = '';

        if (state is ProfileLoaded) {
          fullName = state.profile.fullName;
          email = state.profile.email;
        }

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
                    Text(state.message,
                        style: TextStyle(
                            color: AppColors.textSecondaryColor(context), fontSize: 14.sp),
                        textAlign: TextAlign.center),
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
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imagePath != null
                            ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                            : Icon(Icons.person_outline,
                                color: AppColors.primary, size: 40.sp),
                      ),
                      SizedBox(height: 20.h),
                      _ProfileField(label: 'Full Name', value: fullName),
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
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.borderColor(context)),
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
                // Log Out
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: Icon(Icons.logout, size: 20.sp),
                    label: Text('Log Out',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w500)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimaryColor(context),
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
                    label: Text('Delete Account',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w600)),
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
        Text(label,
            style:
                TextStyle(color: AppColors.textSecondaryColor(context), fontSize: 13.sp)),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.borderColor(context)),
          ),
          child: Text(value,
              style: TextStyle(
                  color: AppColors.textPrimaryColor(context), fontSize: 15.sp)),
        ),
      ],
    );
  }
}
