// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_split.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomSplitAdapter extends TypeAdapter<CustomSplit> {
  @override
  final int typeId = 6;

  @override
  CustomSplit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomSplit(
      id: fields[0] as String,
      name: fields[1] as String,
      daysCount: fields[2] as int,
      days: (fields[3] as List).cast<SplitDay>(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomSplit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.daysCount)
      ..writeByte(3)
      ..write(obj.days)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomSplitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SplitDayAdapter extends TypeAdapter<SplitDay> {
  @override
  final int typeId = 7;

  @override
  SplitDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitDay(
      dayName: fields[0] as String,
      exerciseIds: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SplitDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.dayName)
      ..writeByte(1)
      ..write(obj.exerciseIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomSplitImpl _$$CustomSplitImplFromJson(Map<String, dynamic> json) =>
    _$CustomSplitImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      daysCount: (json['daysCount'] as num).toInt(),
      days: (json['days'] as List<dynamic>)
          .map((e) => SplitDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CustomSplitImplToJson(_$CustomSplitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'daysCount': instance.daysCount,
      'days': instance.days,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$SplitDayImpl _$$SplitDayImplFromJson(Map<String, dynamic> json) =>
    _$SplitDayImpl(
      dayName: json['dayName'] as String,
      exerciseIds: (json['exerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SplitDayImplToJson(_$SplitDayImpl instance) =>
    <String, dynamic>{
      'dayName': instance.dayName,
      'exerciseIds': instance.exerciseIds,
    };
