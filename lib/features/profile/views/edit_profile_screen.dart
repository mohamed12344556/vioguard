import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/api/token_storage.dart';
import '../../../core/di/injection_container.dart';
import '../presentation/cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isInitialized = false;
  XFile? _pickedImage;
  // The already-saved profile image path, shown until the user picks a new one.
  String? _savedImagePath;

  @override
  void initState() {
    super.initState();
    final tokenStorage = sl<TokenStorage>();
    _fullNameController.text = tokenStorage.getUserName() ?? '';
    _emailController.text = tokenStorage.getUserEmail() ?? '';
    final savedPath = tokenStorage.getProfileImagePath();
    if (savedPath != null && File(savedPath).existsSync()) {
      _savedImagePath = savedPath;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final state = context.read<ProfileCubit>().state;
      if (state is ProfileLoaded) {
        _fullNameController.text = state.profile.fullName;
        _emailController.text = state.profile.email;
      }
      _isInitialized = true;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Copies the picked image into the app's documents directory (the picker's
  /// temp file is not guaranteed to survive) and persists its path per-user, so
  /// it stays after the app is closed and reopened.
  Future<void> _persistPickedImage() async {
    final picked = _pickedImage;
    if (picked == null) return;

    final tokenStorage = sl<TokenStorage>();
    final docsDir = await getApplicationDocumentsDirectory();
    final ext = picked.path.contains('.')
        ? picked.path.substring(picked.path.lastIndexOf('.'))
        : '.jpg';
    final destPath =
        '${docsDir.path}/profile_image_${DateTime.now().millisecondsSinceEpoch}$ext';

    await File(picked.path).copy(destPath);
    await tokenStorage.saveProfileImagePath(destPath);
    _savedImagePath = destPath;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    await _persistPickedImage();
    if (!mounted) return;
    context.read<ProfileCubit>().updateProfile(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimaryColor(context),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, _savedImagePath ?? '');
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _pickedImage != null
                                  ? Image.file(
                                      File(_pickedImage!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : (_savedImagePath != null
                                      ? Image.file(
                                          File(_savedImagePath!),
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.person_outline,
                                          color: AppColors.primary,
                                          size: 40.sp)),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 26.w,
                                height: 26.h,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor(context),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: AppColors.borderColor(context)),
                                ),
                                child: Icon(Icons.edit,
                                    color: AppColors.primary, size: 13.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          child: Text(
                            'Edit Picture',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor(context),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _EditableField(
                        label: 'Full Name',
                        controller: _fullNameController,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _ReadonlyField(
                        label: 'Email',
                        controller: _emailController,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileUpdating;
                    return SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
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
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.borderColor(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'Cancel Changes',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _EditableField({
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(color: AppColors.textSecondaryColor(context), fontSize: 13.sp)),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          validator: validator,
          style:
              TextStyle(color: AppColors.textPrimaryColor(context), fontSize: 15.sp),
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.borderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            suffixIcon:
                Icon(Icons.edit_outlined, color: AppColors.primary, size: 18.sp),
            filled: true,
            fillColor: AppColors.surfaceColor(context),
          ),
        ),
      ],
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ReadonlyField({required this.label, required this.controller});

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
            color: AppColors.bg(context),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.borderColor(context)),
          ),
          child: Text(controller.text,
              style: TextStyle(
                  color: AppColors.textSecondaryColor(context), fontSize: 15.sp)),
        ),
      ],
    );
  }
}
