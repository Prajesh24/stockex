

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/auth/data/datascources/auth_datascource.dart';
import 'package:stockex/features/auth/data/datascources/local/auth_local_datascource.dart';
import 'package:stockex/features/auth/data/model/auth_hive_model.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/repository/auth_repository.dart';

//Provider
final AuthRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositories(authDataSource: authDataSource);
});

class AuthRepositories implements IAuthRepository {
  final IAuthDataSource _authDataSource;
  AuthRepositories({required IAuthDataSource authDataSource})
    : _authDataSource = authDataSource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser('current_user_id' );
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      } else {
        return Left(LocalDatabaseFailue(message: 'No current user found'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDataSource.login(email, password);
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      } else {
        return Left(LocalDatabaseFailue(message: 'Login failed'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return Right(true);
      } else {
        return Left(LocalDatabaseFailue(message: 'Logout failed'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDataSource.register(model);
      if (result) {
        return Right(true);
      } else {
        return Left(LocalDatabaseFailue(message: 'Registration failed'));
      }
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }
}
