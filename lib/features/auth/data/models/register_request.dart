class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      };
}
