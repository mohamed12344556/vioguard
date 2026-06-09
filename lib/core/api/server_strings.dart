class ServerStrings {
  ServerStrings._();

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';

  // Detection
  static const String analyze = '/api/Detection/analyze';

  // Content (persistence of analysis results)
  static const String content = '/api/Content';
  static const String textContent = '/api/Content/text';
  static const String videoContent = '/api/Content/video';
  static const String uploadVideo = '/api/Content/upload-video';

  // History
  static const String history = '/api/History';
  static String historyDetails(String id) => '/api/History/$id/details';
  static String deleteHistory(String id) => '/api/History/$id';

  // Reports
  static const String monthlyDashboard = '/api/Reports/monthly-dashboard';
  static const String reportSettings = '/api/Reports/settings';

  // Users
  static String userProfile(String email) => '/api/users/$email';
  static String updateProfile(String email) => '/api/users/$email/profile';
  static String updatePreferences(String email) =>
      '/api/users/$email/preferences';
  static String changePassword(String email) =>
      '/api/users/$email/change-password';
}
