// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      muscle: fields[2] as String,
      equipment: fields[3] as String,
      sets: fields[4] as int,
      reps: fields[5] as int,
      defaultKg: fields[6] as double,
      formCues: (fields[7] as List).cast<String>(),
      targetMuscles: (fields[8] as List).cast<String>(),
      swapAlternatives: (fields[9] as List).cast<String>(),
      videoUrl: fields[10] as String,
      category: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.muscle)
      ..writeByte(3)
      ..write(obj.equipment)
      ..writeByte(4)
      ..write(obj.sets)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.defaultKg)
      ..writeByte(7)
      ..write(obj.formCues)
      ..writeByte(8)
      ..write(obj.targetMuscles)
      ..writeByte(9)
      ..write(obj.swapAlternatives)
      ..writeByte(10)
      ..write(obj.videoUrl)
      ..writeByte(11)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseImpl _$$ExerciseImplFromJson(Map<String, dynamic> json) =>
    _$ExerciseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      muscle: json['muscle'] as String,
      equipment: json['equipment'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      defaultKg: (json['defaultKg'] as num).toDouble(),
      formCues:
          (json['formCues'] as List<dynamic>).map((e) => e as String).toList(),
      targetMuscles: (json['targetMuscles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      swapAlternatives: (json['swapAlternatives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      videoUrl: json['videoUrl'] as String? ?? '',
      category: json['category'] as String,
    );

Map<String, dynamic> _$$ExerciseImplToJson(_$ExerciseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'muscle': instance.muscle,
      'equipment': instance.equipment,
      'sets': instance.sets,
      'reps': instance.reps,
      'defaultKg': instance.defaultKg,
      'formCues': instance.formCues,
      'targetMuscles': instance.targetMuscles,
      'swapAlternatives': instance.swapAlternatives,
      'videoUrl': instance.videoUrl,
      'category': instance.category,
    };
