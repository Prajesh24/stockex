// test/unit/auth/usecase/login_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/repository/auth_repository.dart';
import 'package:stockex/features/auth/domain/usecase/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUsecase loginUsecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUsecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  const tUser = AuthEntity(
    name: 'Test User',
    email: tEmail,
    role: 'user',
  );

  group('Login UseCase', () {
    test('should return AuthEntity when login is successful', () async {
      // Arrange
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when login fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Invalid credentials');
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when there is no internet', () async {
      // Arrange
      const failure = ServerFailure(message: 'No internet connection');
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test('should pass correct email and password to repository', () async {
      // Arrange
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tUser));

      // Act
      await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test('should succeed with correct credentials and fail with wrong credentials', () async {
      // Arrange
      const wrongEmail = 'wrong@example.com';
      const wrongPassword = 'wrongpassword';
      const failure = ServerFailure(message: 'Invalid credentials');

      when(() => mockRepository.login(any(), any())).thenAnswer((invocation) async {
        final email = invocation.positionalArguments[0] as String;
        final password = invocation.positionalArguments[1] as String;
        if (email == tEmail && password == tPassword) {
          return const Right(tUser);
        }
        return const Left(failure);
      });

      // Act & Assert - correct credentials should succeed
      final successResult = await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );
      expect(successResult, const Right(tUser));

      // Act & Assert - wrong email should fail
      final wrongEmailResult = await loginUsecase(
        const LoginUsecaseParams(email: wrongEmail, password: tPassword),
      );
      expect(wrongEmailResult, const Left(failure));

      // Act & Assert - wrong password should fail
      final wrongPasswordResult = await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: wrongPassword),
      );
      expect(wrongPasswordResult, const Left(failure));
    });
  });

  group('LoginParams', () {
    test('should have correct props', () {
      // Arrange
      const params = LoginUsecaseParams(email: tEmail, password: tPassword);

      // Assert
      expect(params.props, [tEmail, tPassword]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      const params1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParams(email: tEmail, password: tPassword);

      // Assert
      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      // Arrange
      const params1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParams(email: 'other@email.com', password: tPassword);

      // Assert
      expect(params1, isNot(params2));
    });
  });
}