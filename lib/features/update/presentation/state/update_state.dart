import 'package:equatable/equatable.dart';
import 'package:stockex/features/update/domain/entities/update_entity.dart';

enum UpdateStatus {
  initial,
  loading,
  profileLoaded,
  updateSuccess,
  uploadSuccess,
  error,
}

class UpdateState extends Equatable {
  final UpdateStatus status;
  final String? errorMessage;
  final UpdateEntity? profileEntity;
  final bool isLoading;

  const UpdateState({
    this.status = UpdateStatus.initial,
    this.errorMessage,
    this.profileEntity,
    this.isLoading = false,
  });

  /// CopyWith method
  UpdateState copyWith({
    UpdateStatus? status,
    String? errorMessage,
    UpdateEntity? profileEntity,
    bool? isLoading,
  }) {
    return UpdateState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      profileEntity: profileEntity ?? this.profileEntity,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, profileEntity, isLoading];
}
