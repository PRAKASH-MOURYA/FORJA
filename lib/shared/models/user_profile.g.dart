// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 4;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      goal: fields[2] as String,
      experience: fields[3] as String,
      daysPerWeek: fields[4] as int,
      equipment: fields[5] as String,
      injuries: (fields[6] as List).cast<String>(),
      currentProgramId: fields[7] as String,
      xp: fields[8] as int,
      level: fields[9] as String,
      streakWeeks: fields[10] as int,
      streakShields: fields[11] as int,
      createdAt: fields[12] as DateTime,
      onboardingComplete: fields[13] as bool,
      customSplitId: fields[14] as String?,
      heightCm: fields[15] as double?,
      bodyWeightKg: fields[16] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.goal)
      ..writeByte(3)
      ..write(obj.experience)
      ..writeByte(4)
      ..write(obj.daysPerWeek)
      ..writeByte(5)
      ..write(obj.equipment)
      ..writeByte(6)
      ..write(obj.injuries)
      ..writeByte(7)
      ..write(obj.currentProgramId)
      ..writeByte(8)
      ..write(obj.xp)
      ..writeByte(9)
      ..write(obj.level)
      ..writeByte(10)
      ..write(obj.streakWeeks)
      ..writeByte(11)
      ..write(obj.streakShields)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.onboardingComplete)
      ..writeByte(14)
      ..write(obj.customSplitId)
      ..writeByte(15)
      ..write(obj.heightCm)
      ..writeByte(16)
      ..write(obj.bodyWeightKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      goal: json['goal'] as String,
      experience: json['experience'] as String,
      daysPerWeek: (json['daysPerWeek'] as num).toInt(),
      equipment: json['equipment'] as String,
      injuries: (json['injuries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentProgramId: json['currentProgramId'] as String,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: json['level'] as String? ?? 'novice',
      streakWeeks: (json['streakWeeks'] as num?)?.toInt() ?? 0,
      streakShields: (json['streakShields'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      customSplitId: json['customSplitId'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'goal': instance.goal,
      'experience': instance.experience,
      'daysPerWeek': instance.daysPerWeek,
      'equipment': instance.equipment,
      'injuries': instance.injuries,
      'currentProgramId': instance.currentProgramId,
      'xp': instance.xp,
      'level': instance.level,
      'streakWeeks': instance.streakWeeks,
      'streakShields': instance.streakShields,
      'createdAt': instance.createdAt.toIso8601String(),
      'onboardingComplete': instance.onboardingComplete,
      'customSplitId': instance.customSplitId,
      'heightCm': instance.heightCm,
      'bodyWeightKg': instance.bodyWeightKg,
    };
