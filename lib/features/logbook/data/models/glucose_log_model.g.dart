// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glucose_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GlucoseLogModelAdapter extends TypeAdapter<GlucoseLogModel> {
  @override
  final int typeId = 0;

  @override
  GlucoseLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GlucoseLogModel(
      id: fields[0] as String,
      patientId: fields[1] as String,
      localTimestamp: fields[2] as DateTime,
      glucoseMgdl: fields[3] as int,
      insulinUnits: fields[4] as double,
      carbsGrams: fields[5] as int,
      contextTags: (fields[6] as List).cast<String>(),
      localPhotoPath: fields[7] as String?,
      cloudPhotoUrl: fields[8] as String?,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GlucoseLogModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.localTimestamp)
      ..writeByte(3)
      ..write(obj.glucoseMgdl)
      ..writeByte(4)
      ..write(obj.insulinUnits)
      ..writeByte(5)
      ..write(obj.carbsGrams)
      ..writeByte(6)
      ..write(obj.contextTags)
      ..writeByte(7)
      ..write(obj.localPhotoPath)
      ..writeByte(8)
      ..write(obj.cloudPhotoUrl)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlucoseLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
