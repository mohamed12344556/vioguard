import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final TokenStorage tokenStorage;

  AuthCubit({required this.repository, required this.tokenStorage})
      : super(const AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await repository.login(email: email, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (response) async {
        await tokenStorage.saveToken(response.token);
        await tokenStorage.saveUserEmail(response.email);
        await tokenStorage.saveUserName(response.fullName);
        emit(LoginSuccess(email: response.email, fullName: response.fullName));
      },
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(const AuthLoading());
    final result = await repository.register(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const RegisterSuccess()),
    );
  }

  Future<void> logout() async {
    await tokenStorage.clearAll();
    emit(const AuthInitial());
  }
}
