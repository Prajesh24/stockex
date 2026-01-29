import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/core/services/connectivity/network_info.dart';
import 'package:stockex/features/auth/data/datascources/auth_datascource.dart';

import 'package:stockex/features/auth/data/datascources/local/auth_local_datascource.dart';
import 'package:stockex/features/auth/data/datascources/remote/auth_remote_datasource.dart';
import 'package:stockex/features/auth/data/model/auth_api_model.dart';
import 'package:stockex/features/auth/data/model/auth_hive_model.dart';

import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:stockex/features/auth/domain/repository/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authLocalDatasource: ref.read(authLocalDataSourceProvider),
    authRemoteDatasource: ref.read(authRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authLocalDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authLocalDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authLocalDatasource = authLocalDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  // 🔐 LOGIN
  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _authRemoteDatasource.loginUser(email, password);

        if (user == null) {
           return Left(ServerFailure(message: 'Login failed'));
        }
        return Right(user.toEntity());


      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authLocalDatasource.loginUser(email, password);

        if (user != null) {
          return Right(user.toEntity());
        }

        return Left(LocalDatabaseFailue(message: 'Invalid email or password'));
      } catch (e) {
        return Left(LocalDatabaseFailue(message: e.toString()));
      }
    }
  }

  // 📝 REGISTER
  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(entity);
        await _authRemoteDatasource.registerUser(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModel = AuthHiveModel.fromEntity(entity);
        await _authLocalDatasource.registerUser(hiveModel);
        return const Right(true);
      } on HiveError catch (e) {
        return Left(LocalDatabaseFailue(message: e.message));
      } catch (e) {
        return Left(
          LocalDatabaseFailue(message: 'Unexpected error: ${e.toString()}'),
        );
      }
    }
  }

  // 👤 CURRENT USER (LOCAL ONLY)
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authLocalDatasource.getCurrentUser('current_user_id');

      if (user != null) {
        return Right(user.toEntity());
      }

      return Left(LocalDatabaseFailue(message: 'No current user found'));
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }

  // 🚪 LOGOUT
  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logoutUser();
      if (result) {
        return const Right(true);
      }
      return Left(LocalDatabaseFailue(message: 'Logout failed'));
    } catch (e) {
      return Left(LocalDatabaseFailue(message: e.toString()));
    }
  }
}
