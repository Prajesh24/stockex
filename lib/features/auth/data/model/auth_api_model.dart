import 'package:stockex/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? password;

  AuthApiModel({
    this.authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  // 🔁 To JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
    };
  }

  // 🔁 From JSON (API response)
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json["_id"] as String?,
      fullName: json["fullName"] as String,
      email: json["email"] as String,
      phoneNumber: json["phoneNumber"] as String,
      password: json["password"] as String?,
    );
  }

  // 🔁 From Entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.authId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }

  // 🔁 To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  // 🔁 List conversion (API → Domain)
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
