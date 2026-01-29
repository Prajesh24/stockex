import 'package:hive/hive.dart';
import 'package:stockex/core/constants/hive_table_constant.dart';
import 'package:stockex/features/update/domain/entities/update_entity.dart';
import 'package:uuid/uuid.dart';

part 'update_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.updateTypeId)
class UpdateHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String? fullName;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? profilePicture;

  @HiveField(5)
  final DateTime? updatedAt;

  UpdateHiveModel({
    String? userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.updatedAt,
  }) : userId = userId ?? const Uuid().v4();

  // 🔁 From Entity → Hive
  factory UpdateHiveModel.fromEntity(UpdateEntity entity) {
    return UpdateHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      updatedAt: entity.updatedAt,
    );
  }

  // 🔁 Hive → Entity
  UpdateEntity toEntity() {
    return UpdateEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      updatedAt: updatedAt,
    );
  }
}
