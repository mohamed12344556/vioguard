class LoginResponse {
  final String token;
  final String expiration;
  final String email;
  final String fullName;
  final bool isMonthlyReportEnabled;
  final bool isTwoStepEnabled;
  final bool isDarkMode;

  const LoginResponse({
    required this.token,
    this.expiration = '',
    required this.email,
    required this.fullName,
    this.isMonthlyReportEnabled = false,
    this.isTwoStepEnabled = false,
    this.isDarkMode = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // The API nests the user object: { token, expiration, user: { ... } }.
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return LoginResponse(
      token: json['token'] as String? ?? '',
      expiration: json['expiration'] as String? ?? '',
      email: user['email'] as String? ?? json['email'] as String? ?? '',
      fullName:
          user['fullName'] as String? ?? json['fullName'] as String? ?? '',
      isMonthlyReportEnabled: user['isMonthlyReportEnabled'] as bool? ?? false,
      isTwoStepEnabled: user['isTwoStepEnabled'] as bool? ?? false,
      isDarkMode: user['isDarkMode'] as bool? ?? false,
    );
  }
}
