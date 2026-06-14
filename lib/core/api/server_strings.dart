class ServerStrings {
  ServerStrings._();

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';

  // Detection
  static const String analyze = '/api/Detection/analyze';
  static const String saveTextResult = '/api/Detection/save-text-result';
  static const String saveVideoResult = '/api/Detection/save-video-result';

  // Content (scraping — fetch content from a source URL)
  static const String content = '/api/Content';
  static const String scrapeAny = '/api/v1/content/scrape-any';
  static const String scrapeText = '/api/v1/content/scrape-text';
  static const String scrapeVideo = '/api/v1/content/scrape-video';

  // Content (legacy persistence endpoints — kept for backward compatibility)
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

  // Users — the controller overrides routes to the root, and identity is
  // resolved from the bearer token (not the path).
  static const String profile = '/profile';
  static const String preferences = '/preferences';
  static const String changePassword = '/change-password';
}
