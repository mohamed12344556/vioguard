class AppConfig {
  AppConfig._();

  static const String appName = 'Vioguard';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  static const bool isProduction = false;
  static const bool enableLogging = true;

  static String get baseUrl {
    return isProduction
        ? 'https://vioguard.runasp.net'
        : 'https://vioguard.runasp.net';
  }

  /// Sentiment / text-analysis AI model (separate FastAPI service)
  static const String sentimentBaseUrl =
      'https://web-production-d5338.up.railway.app';

  /// Video violence-detection AI model (separate service).
  static const String videoModelBaseUrl =
      'https://rod-streptococcal-hyperphysically.ngrok-free.dev';
}
