import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/core/usecases/usecase.dart';
import 'package:stockex/features/auth/data/repositories/auth_repository.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/repository/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [fullName, email, phoneNumber, password];
}

//provider for register usecase
final registerUsecaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.watch(AuthRepositoryProvider);
  return RegisterUseCase(authRepository: authRepository);
});

class RegisterUseCase
    implements UseCaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}
