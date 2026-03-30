// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckInAdapter extends TypeAdapter<CheckIn> {
  @override
  final int typeId = 3;

  @override
  CheckIn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckIn(
      id: fields[0] as String,
      userId: fields[1] as String,
      workoutLogId: fields[2] as String?,
      energy: fields[3] as int,
      soreness: fields[4] as int,
      mood: fields[5] as int,
      sleepHours: fields[6] as double?,
      stress: fields[7] as int?,
      createdAt: fields[8] as DateTime,
      syncStatus: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.workoutLogId)
      ..writeByte(3)
      ..write(obj.energy)
      ..writeByte(4)
      ..write(obj.soreness)
      ..writeByte(5)
      ..write(obj.mood)
      ..writeByte(6)
      ..write(obj.sleepHours)
      ..writeByte(7)
      ..write(obj.stress)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInImpl _$$CheckInImplFromJson(Map<String, dynamic> json) =>
    _$CheckInImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      workoutLogId: json['workoutLogId'] as String?,
      energy: (json['energy'] as num).toInt(),
      soreness: (json['soreness'] as num).toInt(),
      mood: (json['mood'] as num).toInt(),
      sleepHours: (json['sleepHours'] as num?)?.toDouble(),
      stress: (json['stress'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$CheckInImplToJson(_$CheckInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'workoutLogId': instance.workoutLogId,
      'energy': instance.energy,
      'soreness': instance.soreness,
      'mood': instance.mood,
      'sleepHours': instance.sleepHours,
      'stress': instance.stress,
      'createdAt': instance.createdAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
