import 'package:json_annotation/json_annotation.dart';
import 'package:stockex/features/update/domain/entities/update_entity.dart';

part 'update_api_model.g.dart';

@JsonSerializable()
class UpdateApiModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'username')
  final String? fullName;

  final String? email;

  @JsonKey(defaultValue: '')
  final String? phoneNumber;

  @JsonKey(defaultValue: '')
  final String? profilePicture;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  UpdateApiModel({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber = '',
    this.profilePicture = '',
    this.updatedAt,
  });

  /// JSON Serialization
  factory UpdateApiModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateApiModelToJson(this);

  /// API Model → Domain Entity
  UpdateEntity toEntity() {
    return UpdateEntity(
      userId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      updatedAt: updatedAt,
    );
  }

  /// Domain Entity → API Model
  factory UpdateApiModel.fromEntity(UpdateEntity entity) {
    return UpdateApiModel(
      id: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber ?? '',
      profilePicture: entity.profilePicture ?? '',
      updatedAt: entity.updatedAt,
    );
  }
}
