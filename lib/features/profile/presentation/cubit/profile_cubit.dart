import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/token_storage.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  final TokenStorage tokenStorage;

  ProfileCubit({required this.repository, required this.tokenStorage})
      : super(const ProfileInitial());

  String get _email => tokenStorage.getUserEmail() ?? '';

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await repository.getUserProfile(_email);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
  }) async {
    emit(const ProfileUpdating());
    final profile = UserProfileModel(fullName: fullName, email: email);
    final result = await repository.updateProfile(_email, profile);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        tokenStorage.saveUserName(fullName);
        emit(const ProfileUpdateSuccess());
        loadProfile();
      },
    );
  }

  Future<void> updatePreferences({
    required bool isDarkMode,
    required bool isMonthlyReportEnabled,
  }) async {
    emit(const ProfileUpdating());
    final request = UpdatePreferencesRequest(
      isDarkMode: isDarkMode,
      isMonthlyReportEnabled: isMonthlyReportEnabled,
    );
    final result = await repository.updatePreferences(_email, request);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const PreferencesUpdateSuccess()),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const ProfileUpdating());
    final request = ChangePasswordRequest(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    final result = await repository.changePassword(_email, request);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const PasswordChangeSuccess()),
    );
  }
}
