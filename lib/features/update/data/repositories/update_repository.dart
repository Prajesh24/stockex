import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/core/services/connectivity/network_info.dart';
import 'package:stockex/features/update/data/datascources/local/update_local_datasource.dart';
import 'package:stockex/features/update/data/datascources/remote/update_remote_datasource.dart';
import 'package:stockex/features/update/data/datascources/update_datascource.dart';
import 'package:stockex/features/update/data/model/update_api_model.dart';
import 'package:stockex/features/update/data/model/update_hive_model.dart';
import 'package:stockex/features/update/domain/entities/update_entity.dart';
import 'package:stockex/features/update/domain/repository/update_repository.dart';

/// 🔹 Provider
final updateRepositoryProvider = Provider<IUpdateRepository>((ref) {
  return UpdateRepository(
    updateLocalDatasource: ref.read(updateLocalDatasourceProvider),
    updateRemoteDatasource: ref.read(updateRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

/// 🔹 Implementation
class UpdateRepository implements IUpdateRepository {
  final IUpdateLocalDatasource _updateLocalDatasource;
  final IUpdateRemoteDatasource _updateRemoteDatasource;
  final NetworkInfo _networkInfo;

  UpdateRepository({
    required IUpdateLocalDatasource updateLocalDatasource,
    required IUpdateRemoteDatasource updateRemoteDatasource,
    required NetworkInfo networkInfo,
  })  : _updateLocalDatasource = updateLocalDatasource,
        _updateRemoteDatasource = updateRemoteDatasource,
        _networkInfo = networkInfo;

  /// ==================== UPDATE PROFILE ====================
  @override
  Future<Either<Failure, bool>> updateProfile(UpdateEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = UpdateApiModel.fromEntity(entity);
        final success = await _updateRemoteDatasource.updateProfile(apiModel);

        if (success) {
          // Also save to local storage
          final hiveModel = UpdateHiveModel.fromEntity(entity);
          await _updateLocalDatasource.updateProfile(hiveModel);
          return const Right(true);
        }

        return Left(ServerFailure(message: 'Failed to update profile'));
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data['message'] ?? 'Update failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final hiveModel = UpdateHiveModel.fromEntity(entity);
        await _updateLocalDatasource.updateProfile(hiveModel);
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

  /// ==================== UPLOAD PROFILE PICTURE ====================
  @override
  Future<Either<Failure, bool>> uploadProfilePicture(String imagePath) async {
    if (await _networkInfo.isConnected) {
      try {
        final success =
            await _updateRemoteDatasource.uploadProfilePicture(imagePath);

        if (success) {
          return const Right(true);
        }

        return Left(ServerFailure(message: 'Failed to upload profile picture'));
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message:
                e.response?.data['message'] ?? 'Upload failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(
        LocalDatabaseFailue(
          message: 'No internet connection. Please upload later.',
        ),
      );
    }
  }

  /// ==================== GET USER PROFILE ====================
  @override
  Future<Either<Failure, UpdateEntity>> getUserProfile() async {
    if (await _networkInfo.isConnected) {
      try {
        final profile = await _updateRemoteDatasource.getUserProfile();

        if (profile != null) {
          // Save to local storage
          final hiveModel = UpdateHiveModel.fromEntity(profile.toEntity());
          await _updateLocalDatasource.updateProfile(hiveModel);
          return Right(profile.toEntity());
        }

        return Left(ServerFailure(message: 'Profile not found'));
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch profile',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        // Try to get from local storage (you would need to know the userId)
        // For now, returning an error
        return Left(
          LocalDatabaseFailue(
            message: 'No internet connection. Please try again later.',
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailue(message: e.toString()));
      }
    }
  }
}
