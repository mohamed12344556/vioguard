part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;
  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess();
}

class PasswordChangeSuccess extends ProfileState {
  const PasswordChangeSuccess();
}

class AccountDeleteSuccess extends ProfileState {
  const AccountDeleteSuccess();
}

class PreferencesUpdateSuccess extends ProfileState {
  const PreferencesUpdateSuccess();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
