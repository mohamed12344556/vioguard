class AppConfig {
  AppConfig._();

  static const String appName = 'Vioguard';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  static const bool isProduction = false;
  static const bool enableLogging = true;

  static String get baseUrl {
    return isProduction
        ? 'https://vioguard-api.runasp.net'
        : 'https://vioguard-api.runasp.net';
  }
}
