// test/unit/auth/usecase/register_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/repository/auth_repository.dart';
import 'package:stockex/features/auth/domain/usecase/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUseCase(authRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        name: 'fallback',
        email: 'fallback@email.com',
      ),
    );
  });

  const tName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tConfirmPassword = 'password123';

  group('RegisterUseCase', () {
    test('should return true when registration is successful', () async {
      // Arrange
      when(() => mockRepository.register(any(), confirmPassword: any(named: 'confirmPassword')))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(const RegisterUsecaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      ));

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any(), confirmPassword: any(named: 'confirmPassword')))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass AuthEntity with correct values to repository', () async {
      // Arrange
      AuthEntity? capturedEntity;
      when(() => mockRepository.register(any(), confirmPassword: any(named: 'confirmPassword')))
          .thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      // Act
      await usecase(const RegisterUsecaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      ));

      // Assert
      expect(capturedEntity?.name, tName);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.password, tPassword);
    });

    test('should return failure when registration fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Email already exists');
      when(() => mockRepository.register(any(), confirmPassword: any(named: 'confirmPassword')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(const RegisterUsecaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      ));

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any(), confirmPassword: any(named: 'confirmPassword')))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when there is no internet', () async {
      // Arrange
      const failure = ServerFailure(message: 'No internet connection');
      when(() => mockRepository.register(any(), confirmPassword: any(named: 'confirmPassword')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(const RegisterUsecaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      ));

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any(), confirmPassword: any(named: 'confirmPassword')))
          .called(1);
    });
  });

  group('RegisterParams', () {
    test('should have correct props with all values', () {
      // Arrange
      const params = RegisterUsecaseParams(
        name: tName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      );

      // Assert
      expect(params.props, [tName, tEmail, tPassword, tConfirmPassword]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        name: tName, email: tEmail,
        password: tPassword, confirmPassword: tConfirmPassword,
      );
      const params2 = RegisterUsecaseParams(
        name: tName, email: tEmail,
        password: tPassword, confirmPassword: tConfirmPassword,
      );

      // Assert
      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        name: tName, email: tEmail,
        password: tPassword, confirmPassword: tConfirmPassword,
      );
      const params2 = RegisterUsecaseParams(
        name: 'Other User', email: tEmail,
        password: tPassword, confirmPassword: tConfirmPassword,
      );

      // Assert
      expect(params1, isNot(params2));
    });
  });
}