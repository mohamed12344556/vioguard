import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String email);
  Future<void> updateProfile(String email, UserProfileModel profile);
  Future<void> updatePreferences(
      String email, UpdatePreferencesRequest request);
  Future<void> changePassword(String email, ChangePasswordRequest request);
  Future<void> deleteAccount(String email);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiConsumer api;

  ProfileRemoteDataSourceImpl({required this.api});

  // The backend resolves the current user from the bearer token, so [email]
  // is unused in the path — these are fixed root routes.

  @override
  Future<UserProfileModel> getUserProfile(String email) async {
    final response = await api.get(ServerStrings.profile);
    return UserProfileModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateProfile(String email, UserProfileModel profile) async {
    await api.put(
      ServerStrings.profile,
      body: profile.toJson(),
    );
  }

  @override
  Future<void> updatePreferences(
      String email, UpdatePreferencesRequest request) async {
    await api.put(
      ServerStrings.preferences,
      body: request.toJson(),
    );
  }

  @override
  Future<void> changePassword(
      String email, ChangePasswordRequest request) async {
    await api.post(
      ServerStrings.changePassword,
      body: request.toJson(),
    );
  }

  @override
  Future<void> deleteAccount(String email) async {
    await api.delete(ServerStrings.deleteAccount);
  }
}
