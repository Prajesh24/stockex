import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/core/usecases/usecase.dart';
import 'package:stockex/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/repository/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String name; // Changed from fullName
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterUsecaseParams({
    required this.name, // Changed from fullName
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

//provider for register usecase
final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

class RegisterUseCase
    implements UseCaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    //debig
    print('UseCase - params.confirmPassword: ${params.confirmPassword}');
    final entity = AuthEntity(
      name: params.name, // Changed from fullName
      email: params.email,
      password: params.password,
      imageUrl: null, // Optional, can be set later
      role: 'user',
    );

    print('UseCase - passing confirmPassword: ${params.confirmPassword}');
    return _authRepository.register(
      entity,
      confirmPassword: params.confirmPassword,
    );
  }
}
