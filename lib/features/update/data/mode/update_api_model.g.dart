// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateApiModel _$UpdateApiModelFromJson(Map<String, dynamic> json) =>
    UpdateApiModel(
      id: json['_id'] as String?,
      fullName: json['username'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profilePicture: json['profilePicture'] as String? ?? '',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UpdateApiModelToJson(UpdateApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.fullName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'profilePicture': instance.profilePicture,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
