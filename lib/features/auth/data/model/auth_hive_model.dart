import 'package:stockex/core/constants/hive_table_constant.dart';
import 'package:hive/hive.dart';
import 'package:stockex/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? imageUrl;

  AuthHiveModel({
    String? authId,
    required this.name,
    required this.email,
    this.password,
    this.imageUrl,
  }) : authId = authId ?? const Uuid().v4();

  // 🔁 From Entity → Hive
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
      imageUrl: entity.imageUrl,
    );
  }

  // 🔁 Hive → Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      name: name,
      email: email,
      password: password,
      imageUrl: imageUrl,
    );
  }

  // 🔁 List Conversion
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
