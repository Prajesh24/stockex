import 'package:dartz/dartz.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/features/update/domain/entities/update_entity.dart';

abstract interface class IUpdateRepository {
  Future<Either<Failure, bool>> updateProfile(UpdateEntity entity);
  Future<Either<Failure, bool>> uploadProfilePicture(String imagePath);
  Future<Either<Failure, UpdateEntity>> getUserProfile();
}
