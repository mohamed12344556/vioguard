import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_cubit.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSavePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().resetPassword(
            email: widget.email,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimaryColor(context),
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: AppColors.textPrimaryColor(context),
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password has been reset successfully.'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: AppColors.borderColor(context), height: 1),
                    SizedBox(height: 60.h),
                    // Lock Icon
                    Center(
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: AppColors.primaryLight,
                          size: 48.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    // Description
                    Text(
                      'Create a new password for your account.',
                      style: TextStyle(
                        color: AppColors.textPrimaryColor(context),
                        fontSize: 16.sp,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    // New Password Field
                    CustomTextField(
                      label: 'New Password',
                      hint: 'Enter new password',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondaryColor(context),
                        size: 20.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondaryColor(context),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscureNewPassword = !_obscureNewPassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]')
                            .hasMatch(value)) {
                          return 'Password must include a number or symbol';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    // Confirm New Password Field
                    CustomTextField(
                      label: 'Confirm New Password',
                      hint: 'Confirm new password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.textSecondaryColor(context),
                        size: 20.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondaryColor(context),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    // Password Requirements
                    Text(
                      'Password must be at least 8 characters and include a number or symbol.',
                      style: TextStyle(
                        color: AppColors.textSecondaryColor(context),
                        fontSize: 12.sp,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    // Save Password Button
                    CustomButton(
                      text: 'Save Password',
                      onPressed: _onSavePassword,
                      isLoading: isLoading,
                      borderRadius: 30,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
