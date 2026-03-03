// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdateHiveModelAdapter extends TypeAdapter<UpdateHiveModel> {
  @override
  final int typeId = 1;

  @override
  UpdateHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdateHiveModel(
      userId: fields[0] as String?,
      name: fields[1] as String?,
      email: fields[2] as String?,
      profilePicture: fields[3] as String?,
      updatedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UpdateHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.profilePicture)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
