import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/auth/domain/usecase/login_usecase.dart';
import 'package:stockex/features/auth/domain/usecase/register_usecase.dart';
import 'package:stockex/features/auth/presentation/state/auth_state.dart';

//provider for auth view model
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUseCase _registerUseCase;
  late final LoginUsecase _loginUsecase;

  @override
  build() {
    _registerUseCase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    final result = await _registerUseCase.call(params);
    result.fold(
      (failure) {
        print('Register failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        print('Register success: $isRegistered');
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  //login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
}
