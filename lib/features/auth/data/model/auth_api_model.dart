import 'package:json_annotation/json_annotation.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  @JsonKey(name: '_id', includeIfNull: false)  // Don't send null _id
  final String? id;

  final String name;              // Matches web schema
  final String email;
  final String? password;
  
  @JsonKey(name: 'imageUrl', includeIfNull: false)
  final String? imageUrl;         // Matches web schema
  
  final String? role;

  AuthApiModel({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.imageUrl,
    this.role = 'user',
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      name: name,
      email: email,
      password: password,
      imageUrl: imageUrl,
      role: role,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
      imageUrl: entity.imageUrl,
      role: entity.role,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}