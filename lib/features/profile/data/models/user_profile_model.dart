class UserProfileModel {
  final String fullName;
  final String email;

  const UserProfileModel({
    required this.fullName,
    required this.email,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
      };
}

class UpdatePreferencesRequest {
  final bool isDarkMode;
  final bool isMonthlyReportEnabled;

  const UpdatePreferencesRequest({
    required this.isDarkMode,
    required this.isMonthlyReportEnabled,
  });

  Map<String, dynamic> toJson() => {
        'isDarkMode': isDarkMode,
        'isMonthlyReportEnabled': isMonthlyReportEnabled,
      };
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
}
