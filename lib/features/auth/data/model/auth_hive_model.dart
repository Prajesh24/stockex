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
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String phoneNumber;
  @HiveField(4)
  final String? password;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password,
  }) : authId = authId ?? Uuid().v4();

  //From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }

  //To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
