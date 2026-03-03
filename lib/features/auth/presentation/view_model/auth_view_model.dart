import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/auth/domain/usecase/login_usecase.dart';
import 'package:stockex/features/auth/domain/usecase/register_usecase.dart';
import 'package:stockex/features/auth/presentation/state/auth_state.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/core/services/hive/hive_service.dart';

/// Provider for auth view model
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  // ✅ No late final fields — use cases are read directly when needed
  // ❌ REMOVED: late final RegisterUseCase _registerUseCase;
  // ❌ REMOVED: late final LoginUsecase _loginUsecase;
  // Using late final in a Notifier crashes if the provider is refreshed,
  // because build() is called again and Dart forbids reassigning late final fields.

  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = RegisterUsecaseParams(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword, // ✅ Fixed: was passing password twice
    );

    // ✅ Read use case directly — safe across rebuilds
    final result = await ref.read(registerUsecaseProvider).call(params);

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

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = LoginUsecaseParams(email: email, password: password);

    // ✅ Read use case directly — safe across rebuilds
    final result = await ref.read(loginUsecaseProvider).call(params);

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

  /// Update auth entity with new profile data and sync to local storage
  Future<void> updateAuthEntity({
    required String name,
    required String email,
  }) async {
    final currentEntity = state.authEntity;
    if (currentEntity == null || currentEntity.authId == null) return;

    final updatedEntity = AuthEntity(
      authId: currentEntity.authId,
      name: name,
      email: email,
    );

    state = state.copyWith(authEntity: updatedEntity);

    // Sync updated email to Hive so it's reflected on next local login
    await ref
        .read(hiveServiceProvider)
        .updateUserEmail(currentEntity.authId!, email);
  }

  /// Logout — reset state
  void logout() {
    state = AuthState();
  }
}