import 'package:json_annotation/json_annotation.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'username') // map API "username" to fullName
  final String fullName;

  final String email;

  @JsonKey(defaultValue: '') // API does not return phoneNumber
  final String phoneNumber;

  final String? password;

  @JsonKey(defaultValue: '') // API may not have profilePicture
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    this.password,
    this.profilePicture='',
  });

  /// JSON Serialization
  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  /// API Model → Domain Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      profilePicture: profilePicture,
    );
  }

  /// Domain Entity → API Model
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber ?? '',
      password: entity.password,
      profilePicture: entity.profilePicture ?? '',
    );
  }

  /// Convert list of API Models → Entities
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
