// // test/unit/auth_test.dart

// import 'package:dartz/dartz.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:stockex/core/error/faliures.dart';
// import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
// import 'package:stockex/features/auth/domain/repository/auth_repository.dart';
// import 'package:stockex/features/auth/domain/usecase/login_usecase.dart';
// import 'package:stockex/features/auth/domain/usecase/register_usecase.dart';
// import 'package:stockex/features/auth/presentation/state/auth_state.dart';
// import 'package:stockex/features/auth/presentation/view_model/auth_view_model.dart';

// // Mocks 
// class MockAuthRepository extends Mock implements IAuthRepository {}

// // Helpers 
// const tAuthEntity = AuthEntity(
//   authId: 'user_123',
//   name: 'Test User',
//   email: 'test@example.com',
//   password: 'password123',
//   role: 'user',
// );

// const tServerFailure = ServerFailure(message: 'Server error');

// // ── AuthEntity Tests ──────────────────────────────────────────────────────────
// void main() {
//   group('AuthEntity', () {
//     test('25. two entities with same props are equal', () {
//       const entity1 = AuthEntity(name: 'Alice', email: 'alice@test.com');
//       const entity2 = AuthEntity(name: 'Alice', email: 'alice@test.com');
//       expect(entity1, equals(entity2));
//     });

//     test('26. two entities with different emails are not equal', () {
//       const entity1 = AuthEntity(name: 'Alice', email: 'alice@test.com');
//       const entity2 = AuthEntity(name: 'Alice', email: 'bob@test.com');
//       expect(entity1, isNot(equals(entity2)));
//     });

//     test('27. default role is user', () {
//       const entity = AuthEntity(name: 'Alice', email: 'alice@test.com');
//       expect(entity.role, equals('user'));
//     });

//     test('28. authId can be null', () {
//       const entity = AuthEntity(name: 'Alice', email: 'alice@test.com');
//       expect(entity.authId, isNull);
//     });

//     test('29. imageUrl defaults to null', () {
//       const entity = AuthEntity(name: 'Alice', email: 'alice@test.com');
//       expect(entity.imageUrl, isNull);
//     });
//   });

//   // ── AuthState Tests ─────────────────────────────────────────────────────────
//   group('AuthState', () {
//     test('30. initial state has AuthStatus.initial', () {
//       const state = AuthState();
//       expect(state.status, equals(AuthStatus.initial));
//     });

//     test('31. copyWith updates status correctly', () {
//       const state = AuthState();
//       final updated = state.copyWith(status: AuthStatus.loading);
//       expect(updated.status, equals(AuthStatus.loading));
//     });

//     test('32. copyWith preserves unchanged fields', () {
//       const state = AuthState(authEntity: tAuthEntity);
//       final updated = state.copyWith(status: AuthStatus.loading);
//       expect(updated.authEntity, equals(tAuthEntity));
//     });

//     test('33. copyWith with error updates errorMessage', () {
//       const state = AuthState();
//       final updated = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: 'Login failed',
//       );
//       expect(updated.errorMessage, equals('Login failed'));
//       expect(updated.status, equals(AuthStatus.error));
//     });

//     test('34. two identical states are equal', () {
//       const s1 = AuthState(status: AuthStatus.loading);
//       const s2 = AuthState(status: AuthStatus.loading);
//       expect(s1, equals(s2));
//     });
//   });

//   // ── LoginUsecase Tests ──────────────────────────────────────────────────────
//   group('LoginUsecase', () {
//     late MockAuthRepository mockRepo;
//     late LoginUsecase usecase;

//     setUp(() {
//       mockRepo = MockAuthRepository();
//       usecase = LoginUsecase(authRepository: mockRepo);
//     });

//     test('35. returns AuthEntity on successful login', () async {
//       when(() => mockRepo.login(any(), any()))
//           .thenAnswer((_) async => const Right(tAuthEntity));

//       final result = await usecase(
//         const LoginUsecaseParams(email: 'test@example.com', password: 'pass'),
//       );

//       expect(result, equals(const Right(tAuthEntity)));
//     });

//     test('36. returns Failure on failed login', () async {
//       when(() => mockRepo.login(any(), any()))
//           .thenAnswer((_) async => const Left(tServerFailure));

//       final result = await usecase(
//         const LoginUsecaseParams(email: 'bad@example.com', password: 'wrong'),
//       );

//       expect(result.isLeft(), isTrue);
//     });

//     test('37. passes email and password to repository', () async {
//       when(() => mockRepo.login('test@example.com', 'pass123'))
//           .thenAnswer((_) async => const Right(tAuthEntity));

//       await usecase(
//         const LoginUsecaseParams(email: 'test@example.com', password: 'pass123'),
//       );

//       verify(() => mockRepo.login('test@example.com', 'pass123')).called(1);
//     });
//   });

//   // ── RegisterUsecase Tests ───────────────────────────────────────────────────
//   group('RegisterUsecase', () {
//     late MockAuthRepository mockRepo;
//     late RegisterUseCase usecase;

//     setUp(() {
//       mockRepo = MockAuthRepository();
//       usecase = RegisterUseCase(authRepository: mockRepo);
//     });

//     test('38. returns true on successful registration', () async {
//       when(() => mockRepo.register(any(), confirmPassword: any(named: 'confirmPassword')))
//           .thenAnswer((_) async => const Right(true));

//       final result = await usecase(
//         const RegisterUsecaseParams(
//           name: 'Test User',
//           email: 'test@example.com',
//           password: 'pass123',
//           confirmPassword: 'pass123',
//         ),
//       );

//       expect(result, equals(const Right(true)));
//     });

//     test('39. returns Failure on failed registration', () async {
//       when(() => mockRepo.register(any(), confirmPassword: any(named: 'confirmPassword')))
//           .thenAnswer((_) async => const Left(tServerFailure));

//       final result = await usecase(
//         const RegisterUsecaseParams(
//           name: 'Test User',
//           email: 'test@example.com',
//           password: 'pass123',
//           confirmPassword: 'pass123',
//         ),
//       );

//       expect(result.isLeft(), isTrue);
//     });

//     test('40. passes confirmPassword to repository', () async {
//       when(() => mockRepo.register(any(), confirmPassword: 'pass123'))
//           .thenAnswer((_) async => const Right(true));

//       await usecase(
//         const RegisterUsecaseParams(
//           name: 'Test',
//           email: 'test@example.com',
//           password: 'pass123',
//           confirmPassword: 'pass123',
//         ),
//       );

//       verify(() => mockRepo.register(any(), confirmPassword: 'pass123')).called(1);
//     });
//   });

//   // ── AuthViewModel Tests ─────────────────────────────────────────────────────
//   group('AuthViewModel', () {
//     late MockAuthRepository mockRepo;

//     setUp(() {
//       mockRepo = MockAuthRepository();
//     });

//     ProviderContainer buildContainer() {
//       return ProviderContainer(
//         overrides: [
//           loginUsecaseProvider.overrideWith(
//             (ref) => LoginUsecase(authRepository: mockRepo),
//           ),
//           registerUsecaseProvider.overrideWith(
//             (ref) => RegisterUseCase(authRepository: mockRepo),
//           ),
//         ],
//       );
//     }

//     test('41. initial state is AuthStatus.initial', () {
//       final container = buildContainer();
//       addTearDown(container.dispose);
//       final state = container.read(authViewModelProvider);
//       expect(state.status, equals(AuthStatus.initial));
//     });

//     test('42. login success sets status to authenticated', () async {
//       when(() => mockRepo.login(any(), any()))
//           .thenAnswer((_) async => const Right(tAuthEntity));

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       await container
//           .read(authViewModelProvider.notifier)
//           .login(email: 'test@example.com', password: 'pass');

//       expect(
//         container.read(authViewModelProvider).status,
//         equals(AuthStatus.authenticated),
//       );
//     });

//     test('43. login success stores authEntity in state', () async {
//       when(() => mockRepo.login(any(), any()))
//           .thenAnswer((_) async => const Right(tAuthEntity));

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       await container
//           .read(authViewModelProvider.notifier)
//           .login(email: 'test@example.com', password: 'pass');

//       expect(
//         container.read(authViewModelProvider).authEntity,
//         equals(tAuthEntity),
//       );
//     });

//     test('44. login failure sets status to error', () async {
//       when(() => mockRepo.login(any(), any()))
//           .thenAnswer((_) async => const Left(tServerFailure));

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       await container
//           .read(authViewModelProvider.notifier)
//           .login(email: 'bad@example.com', password: 'wrong');

//       expect(
//         container.read(authViewModelProvider).status,
//         equals(AuthStatus.error),
//       );
//     });

//     test('45. login failure stores error message', () async {
//       when(() => mockRepo.login(any(), any()))
//           .thenAnswer((_) async => const Left(ServerFailure(message: 'Invalid credentials')));

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       await container
//           .read(authViewModelProvider.notifier)
//           .login(email: 'bad@example.com', password: 'wrong');

//       expect(
//         container.read(authViewModelProvider).errorMessage,
//         equals('Invalid credentials'),
//       );
//     });

//     test('46. register success sets status to registered', () async {
//       when(() => mockRepo.register(any(), confirmPassword: any(named: 'confirmPassword')))
//           .thenAnswer((_) async => const Right(true));

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       await container.read(authViewModelProvider.notifier).register(
//             name: 'Test',
//             email: 'test@example.com',
//             password: 'pass123',
//             confirmPassword: 'pass123',
//           );

//       expect(
//         container.read(authViewModelProvider).status,
//         equals(AuthStatus.registered),
//       );
//     });

//     test('47. register failure sets status to error', () async {
//       when(() => mockRepo.register(any(), confirmPassword: any(named: 'confirmPassword')))
//           .thenAnswer((_) async => const Left(tServerFailure));

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       await container.read(authViewModelProvider.notifier).register(
//             name: 'Test',
//             email: 'test@example.com',
//             password: 'pass123',
//             confirmPassword: 'pass123',
//           );

//       expect(
//         container.read(authViewModelProvider).status,
//         equals(AuthStatus.error),
//       );
//     });

//     test('48. logout resets state to initial', () async {
//       when(() => mockRepo.login(any(), any()))
//           .thenAnswer((_) async => const Right(tAuthEntity));

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       await container
//           .read(authViewModelProvider.notifier)
//           .login(email: 'test@example.com', password: 'pass');

//       container.read(authViewModelProvider.notifier).logout();

//       final state = container.read(authViewModelProvider);
//       expect(state.status, equals(AuthStatus.initial));
//       expect(state.authEntity, isNull);
//     });

//     test('49. loading state is set during login', () async {
//       when(() => mockRepo.login(any(), any())).thenAnswer((_) async {
//         await Future.delayed(const Duration(milliseconds: 10));
//         return const Right(tAuthEntity);
//       });

//       final container = buildContainer();
//       addTearDown(container.dispose);

//       final future = container
//           .read(authViewModelProvider.notifier)
//           .login(email: 'test@example.com', password: 'pass');

//       // Check loading immediately
//       expect(
//         container.read(authViewModelProvider).status,
//         equals(AuthStatus.loading),
//       );

//       await future;
//     });
//   });
// }