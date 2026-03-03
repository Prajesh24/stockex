// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateApiModel _$UpdateApiModelFromJson(Map<String, dynamic> json) =>
    UpdateApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UpdateApiModelToJson(UpdateApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'imageUrl': instance.imageUrl,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
