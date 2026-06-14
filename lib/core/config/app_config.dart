class AppConfig {
  AppConfig._();

  static const String appName = 'Vioguard';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  static const bool isProduction = false;
  static const bool enableLogging = true;

  static String get baseUrl {
    return isProduction
        ? 'https://asmaaelsayed-001-site1.ltempurl.com'
        : 'https://asmaaelsayed-001-site1.ltempurl.com';
  }

  /// HTTP Basic Auth credentials guarding the hosting environment.
  /// The host returns 401 on every request without these, so they must be
  /// sent on every call to [baseUrl] (see `AuthInterceptor`).
  static const String hostingBasicAuthUser = '11315760';
  static const String hostingBasicAuthPassword = '60-dayfreetrial';

  /// Sentiment / text-analysis AI model (separate FastAPI service)
  static const String sentimentBaseUrl =
      'https://web-production-d5338.up.railway.app';

  /// Video violence-detection AI model (separate service).
  static const String videoModelBaseUrl =
      'https://rod-streptococcal-hyperphysically.ngrok-free.dev';
}
