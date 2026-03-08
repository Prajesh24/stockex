// test/widget/auth/register_page_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/auth/domain/usecase/login_usecase.dart';
import 'package:stockex/features/auth/domain/usecase/register_usecase.dart';
import 'package:stockex/features/auth/presentation/pages/singup_page.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUseCase mockRegisterUsecase;

  setUpAll(() {
    registerFallbackValue(
      const LoginUsecaseParams(email: 'fallback@email.com', password: 'fallback'),
    );
    registerFallbackValue(
      const RegisterUsecaseParams(
        name: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        confirmPassword: 'fallback',
      ),
    );
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUseCase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
      ],
      child: const MaterialApp(home: RegisterPage()),
    );
  }

  group('RegisterPage UI Elements', () {
    testWidgets('should display Create Account title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should display register to get started subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Register to get started'), findsOneWidget);
    });

    testWidgets('should display four text form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('should display register button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Register'), findsWidgets);
    });

    testWidgets('should display already have an account text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('should have black scaffold background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.black));
    });
  });

  group('RegisterPage Form Validation', () {
    testWidgets('should show error for empty name field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Register').first);
      await tester.pump();
      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('should show error for password less than 6 characters', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.tap(find.text('Register').first);
      await tester.pump();
      expect(find.text('Minimum 6 characters'), findsOneWidget);
    });

    testWidgets('should show error when passwords do not match', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'pass123');
      await tester.enterText(find.byType(TextFormField).at(3), 'different');
      await tester.tap(find.text('Register').first);
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('RegisterPage Form Submission', () {
    testWidgets('should call registerUsecase when form is valid', (tester) async {
      // Arrange
      when(() => mockRegisterUsecase.call(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'pass123');
      await tester.enterText(find.byType(TextFormField).at(3), 'pass123');
      await tester.tap(find.text('Register').first);
      await tester.pump();

      // Assert
      verify(() => mockRegisterUsecase.call(any())).called(1);
    });

    testWidgets('should show error snackbar when registration fails', (tester) async {
      // Arrange
      const failure = ServerFailure(message: 'Email already exists');
      when(() => mockRegisterUsecase.call(any()))
          .thenAnswer((_) async => const Left(failure));

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'pass123');
      await tester.enterText(find.byType(TextFormField).at(3), 'pass123');
      await tester.tap(find.text('Register').first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email already exists'), findsOneWidget);
    });

    testWidgets('should not call usecase when name is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Register').first);
      await tester.pump();

      // Assert
      verifyNever(() => mockRegisterUsecase.call(any()));
    });
  });
}