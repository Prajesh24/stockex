import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stockex/features/update/domain/usecase/update_profile_usecase.dart';
import 'package:stockex/features/update/presentation/state/update_state.dart';

/// 🔹 Provider for Update ViewModel
final updateViewModelProvider = NotifierProvider<UpdateViewModel, UpdateState>(
  () => UpdateViewModel(),
);

/// 🔹 ViewModel
class UpdateViewModel extends Notifier<UpdateState> {
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final UploadProfilePictureUsecase _uploadProfilePictureUsecase;
  late final GetUserProfileUsecase _getUserProfileUsecase;

  @override
  build() {
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _uploadProfilePictureUsecase =
        ref.read(uploadProfilePictureUsecaseProvider);
    _getUserProfileUsecase = ref.read(getUserProfileUsecaseProvider);
    return UpdateState();
  }

  /// ==================== UPDATE PROFILE ====================
  Future<void> updateProfile({
    required String? fullName,
    required String? email,
    required String? phoneNumber,
    required String? profilePicture,
  }) async {
    state = state.copyWith(status: UpdateStatus.loading, isLoading: true);

    final params = UpdateProfileUsecaseParams(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
    );

    final result = await _updateProfileUsecase.call(params);

    result.fold(
      (failure) {
        print('Update profile failed: ${failure.message}');
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (isSuccess) {
        print('Update profile success');
        state = state.copyWith(
          status: UpdateStatus.updateSuccess,
          isLoading: false,
        );
      },
    );
  }

  /// ==================== UPLOAD PROFILE PICTURE ====================
  Future<void> uploadProfilePicture({required String imagePath}) async {
    state = state.copyWith(status: UpdateStatus.loading, isLoading: true);

    final params = UploadProfilePictureUsecaseParams(imagePath: imagePath);
    final result = await _uploadProfilePictureUsecase.call(params);

    result.fold(
      (failure) {
        print('Upload profile picture failed: ${failure.message}');
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (isSuccess) {
        print('Upload profile picture success');
        state = state.copyWith(
          status: UpdateStatus.uploadSuccess,
          isLoading: false,
        );
      },
    );
  }

  /// ==================== GET USER PROFILE ====================
  Future<void> getUserProfile() async {
    state = state.copyWith(status: UpdateStatus.loading, isLoading: true);

    final result = await _getUserProfileUsecase.call();

    result.fold(
      (failure) {
        print('Get user profile failed: ${failure.message}');
        state = state.copyWith(
          status: UpdateStatus.error,
          errorMessage: failure.message,
          isLoading: false,
        );
      },
      (profile) {
        print('Get user profile success');
        state = state.copyWith(
          status: UpdateStatus.profileLoaded,
          profileEntity: profile,
          isLoading: false,
        );
      },
    );
  }

  /// ==================== RESET STATE ====================
  void resetState() {
    state = const UpdateState();
  }
}
