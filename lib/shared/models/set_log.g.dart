// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetLogAdapter extends TypeAdapter<SetLog> {
  @override
  final int typeId = 2;

  @override
  SetLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetLog(
      id: fields[0] as String,
      workoutLogId: fields[1] as String,
      exerciseId: fields[2] as String,
      setNumber: fields[3] as int,
      weightKg: fields[4] as double,
      reps: fields[5] as int,
      completed: fields[6] as bool,
      failed: fields[7] as bool,
      skipped: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      syncStatus: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SetLog obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutLogId)
      ..writeByte(2)
      ..write(obj.exerciseId)
      ..writeByte(3)
      ..write(obj.setNumber)
      ..writeByte(4)
      ..write(obj.weightKg)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.failed)
      ..writeByte(8)
      ..write(obj.skipped)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetLogImpl _$$SetLogImplFromJson(Map<String, dynamic> json) => _$SetLogImpl(
      id: json['id'] as String,
      workoutLogId: json['workoutLogId'] as String,
      exerciseId: json['exerciseId'] as String,
      setNumber: (json['setNumber'] as num).toInt(),
      weightKg: (json['weightKg'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      completed: json['completed'] as bool? ?? false,
      failed: json['failed'] as bool? ?? false,
      skipped: json['skipped'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$SetLogImplToJson(_$SetLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workoutLogId': instance.workoutLogId,
      'exerciseId': instance.exerciseId,
      'setNumber': instance.setNumber,
      'weightKg': instance.weightKg,
      'reps': instance.reps,
      'completed': instance.completed,
      'failed': instance.failed,
      'skipped': instance.skipped,
      'createdAt': instance.createdAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
