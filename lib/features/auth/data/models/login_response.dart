class LoginResponse {
  final String token;
  final String email;
  final String fullName;

  const LoginResponse({
    required this.token,
    required this.email,
    required this.fullName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
    );
  }
}
