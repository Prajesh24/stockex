// test/widget/auth/login_page_test.dart

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/usecase/login_usecase.dart';
import 'package:stockex/features/auth/domain/usecase/register_usecase.dart';
import 'package:stockex/features/auth/presentation/pages/login_page.dart';

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

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = AuthEntity(name: 'Test User', email: tEmail, role: 'user');

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWith((ref) => mockLoginUsecase),
        registerUsecaseProvider.overrideWith((ref) => mockRegisterUsecase),
      ],
      child: MaterialApp(
        home: const LoginPage(),
        // Block navigation to real screens — prevents provider errors from
        // ButtonNavigatorScreen and RegisterPage during tests
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: SizedBox()),
        ),
      ),
    );
  }

  group('LoginPage UI Elements', () {
    testWidgets('should display Welcome to Stockex text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Welcome to Stockex'), findsOneWidget);
    });

    testWidgets('should display login to continue subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Login to continue'), findsOneWidget);
    });

    testWidgets('should display two text form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should display login button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('should display register link text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('should have black scaffold background', (tester) async {
      await tester.pumpWidget(createTestWidget());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.black));
    });
  });

  group('LoginPage Form Validation', () {
    testWidgets('should show error for empty email field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).last, tPassword);
      await tester.tap(find.text('Login').first);
      await tester.pump();
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('should show error for empty password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).first, tEmail);
      await tester.tap(find.text('Login').first);
      await tester.pump();
      expect(find.text('Enter password'), findsOneWidget);
    });

    
  });

  group('LoginPage Form Submission', () {
    testWidgets('should call loginUsecase when form is valid', (tester) async {
      // Arrange — Completer stays pending so navigation never fires
      final completer = Completer<Either<Failure, AuthEntity>>();
      // Complete with error in tearDown so the future resolves without
      // triggering navigation (error path = no pushReplacement)
      addTearDown(() {
        if (!completer.isCompleted) {
          completer.completeError('test teardown');
        }
      });
      when(() => mockLoginUsecase.call(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextFormField).first, tEmail);
      await tester.enterText(find.byType(TextFormField).last, tPassword);
      await tester.tap(find.text('Login').first);
      await tester.pump(); // trigger the call — future still pending

      // Assert — usecase was called, navigation never attempted
      verify(() => mockLoginUsecase.call(any())).called(1);
    });

    testWidgets('should show error snackbar when login fails', (tester) async {
      // Arrange
      const failure = ServerFailure(message: 'Invalid credentials');
      when(() => mockLoginUsecase.call(any()))
          .thenAnswer((_) async => const Left(failure));

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextFormField).first, tEmail);
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      await tester.tap(find.text('Login').first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should not call usecase when email is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextFormField).last, tPassword);
      await tester.tap(find.text('Login').first);
      await tester.pump();

      // Assert
      verifyNever(() => mockLoginUsecase.call(any()));
    });
  });
}