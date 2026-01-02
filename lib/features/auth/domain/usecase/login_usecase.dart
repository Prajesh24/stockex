import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/core/usecases/usecase.dart';
import 'package:stockex/features/auth/data/repositories/auth_repository.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/repository/auth_repository.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

//provider for login usecase
final loginUsecaseProvider = 
    Provider<LoginUsecase>((ref) {
  final authRepository = ref.watch(AuthRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});
class LoginUsecase
    implements UseCaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;
  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
