part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class LoginSuccess extends AuthState {
  final String email;
  final String fullName;
  const LoginSuccess({required this.email, required this.fullName});

  @override
  List<Object> get props => [email, fullName];
}

class RegisterSuccess extends AuthState {
  const RegisterSuccess();
}

class ForgotPasswordSuccess extends AuthState {
  final String email;
  const ForgotPasswordSuccess({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetPasswordSuccess extends AuthState {
  const ResetPasswordSuccess();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
