/// Application Routes
class Routes {
  Routes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Detection Routes
  static const String textDetection = '/text-detection';
  static const String textDetectionResult = '/text-detection-result';
  static const String videoDetection = '/video-detection';
  static const String videoDetectionResult = '/video-detection-result';

  // History Routes
  static const String detectionDetails = '/detection-details';

  // Profile Routes
  static const String editProfile = '/edit-profile';
}
