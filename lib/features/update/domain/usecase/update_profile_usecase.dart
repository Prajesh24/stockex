import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/core/error/faliures.dart';
import 'package:stockex/core/usecases/usecase.dart';
import 'package:stockex/features/update/data/repositories/update_repository.dart';
import 'package:stockex/features/update/domain/entities/update_entity.dart';
import 'package:stockex/features/update/domain/repository/update_repository.dart';

class UpdateProfileUsecaseParams extends Equatable {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;

  const UpdateProfileUsecaseParams({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, profilePicture];
}

class UploadProfilePictureUsecaseParams extends Equatable {
  final String imagePath;

  const UploadProfilePictureUsecaseParams({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

// Provider for update profile usecase
final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final updateRepository = ref.watch(updateRepositoryProvider);
  return UpdateProfileUsecase(updateRepository: updateRepository);
});

// Provider for upload profile picture usecase
final uploadProfilePictureUsecaseProvider =
    Provider<UploadProfilePictureUsecase>((ref) {
      final updateRepository = ref.watch(updateRepositoryProvider);
      return UploadProfilePictureUsecase(updateRepository: updateRepository);
    });

// Provider for get user profile usecase
final getUserProfileUsecaseProvider = Provider<GetUserProfileUsecase>((ref) {
  final updateRepository = ref.watch(updateRepositoryProvider);
  return GetUserProfileUsecase(updateRepository: updateRepository);
});

class UpdateProfileUsecase
    implements UseCaseWithParams<bool, UpdateProfileUsecaseParams> {
  final IUpdateRepository _updateRepository;

  UpdateProfileUsecase({required IUpdateRepository updateRepository})
    : _updateRepository = updateRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateProfileUsecaseParams params) {
    final entity = UpdateEntity(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      profilePicture: params.profilePicture,
    );
    return _updateRepository.updateProfile(entity);
  }
}

class UploadProfilePictureUsecase
    implements UseCaseWithParams<bool, UploadProfilePictureUsecaseParams> {
  final IUpdateRepository _updateRepository;

  UploadProfilePictureUsecase({required IUpdateRepository updateRepository})
    : _updateRepository = updateRepository;

  @override
  Future<Either<Failure, bool>> call(UploadProfilePictureUsecaseParams params) {
    return _updateRepository.uploadProfilePicture(params.imagePath);
  }
}

class GetUserProfileUsecase implements UseCaseWithoutParams<UpdateEntity> {
  final IUpdateRepository _updateRepository;

  GetUserProfileUsecase({required IUpdateRepository updateRepository})
    : _updateRepository = updateRepository;

  @override
  Future<Either<Failure, UpdateEntity>> call() {
    return _updateRepository.getUserProfile();
  }
}
