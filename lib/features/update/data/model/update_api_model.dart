import 'package:json_annotation/json_annotation.dart';
import 'package:stockex/features/update/domain/entities/update_entity.dart';

part 'update_api_model.g.dart';

@JsonSerializable()
class UpdateApiModel {
  @JsonKey(name: '_id')
  final String? id;

  // ✅ Fixed: was 'username', backend uses 'name'
  @JsonKey(name: 'name')
  final String? name;

  final String? email;

  @JsonKey(defaultValue: '')
  final String? imageUrl;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  // ✅ Local file path for upload — never sent to server
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? imagePath;

  UpdateApiModel({
    this.id,
    this.name,
    this.email,
    this.imageUrl = '',
    this.updatedAt,
    this.imagePath, // local only
  });

  /// JSON Serialization
  factory UpdateApiModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateApiModelToJson(this);

  /// API Model → Domain Entity
  UpdateEntity toEntity() {
    return UpdateEntity(
      userId: id,
      name: name,
      email: email,
      profilePicture: imageUrl,
      updatedAt: updatedAt,
    );
  }

  /// Domain Entity → API Model
  factory UpdateApiModel.fromEntity(UpdateEntity entity) {
    return UpdateApiModel(
      id: entity.userId,
      name: entity.name,
      email: entity.email,
      imageUrl: entity.profilePicture ?? '',
      updatedAt: entity.updatedAt,
    );
  }
}