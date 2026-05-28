import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/server_strings.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String email);
  Future<void> updateProfile(String email, UserProfileModel profile);
  Future<void> updatePreferences(
      String email, UpdatePreferencesRequest request);
  Future<void> changePassword(String email, ChangePasswordRequest request);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiConsumer api;

  ProfileRemoteDataSourceImpl({required this.api});

  @override
  Future<UserProfileModel> getUserProfile(String email) async {
    final response = await api.get(ServerStrings.userProfile(email));
    return UserProfileModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateProfile(String email, UserProfileModel profile) async {
    await api.put(
      ServerStrings.updateProfile(email),
      body: profile.toJson(),
    );
  }

  @override
  Future<void> updatePreferences(
      String email, UpdatePreferencesRequest request) async {
    await api.put(
      ServerStrings.updatePreferences(email),
      body: request.toJson(),
    );
  }

  @override
  Future<void> changePassword(
      String email, ChangePasswordRequest request) async {
    await api.post(
      ServerStrings.changePassword(email),
      body: request.toJson(),
    );
  }
}
