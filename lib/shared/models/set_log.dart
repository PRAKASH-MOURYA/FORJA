import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'set_log.freezed.dart';
part 'set_log.g.dart';

@freezed
@HiveType(typeId: 2)
class SetLog with _$SetLog {
  const factory SetLog({
    @HiveField(0) required String id,
    @HiveField(1) required String workoutLogId,
    @HiveField(2) required String exerciseId,
    @HiveField(3) required int setNumber,
    @HiveField(4) required double weightKg,
    @HiveField(5) required int reps,
    @HiveField(6) @Default(false) bool completed,
    @HiveField(7) @Default(false) bool failed,
    @HiveField(8) @Default(false) bool skipped,
    @HiveField(9) required DateTime createdAt,
    @HiveField(10) @Default('pending') String syncStatus,
  }) = _SetLog;

  factory SetLog.fromJson(Map<String, dynamic> json) => _$SetLogFromJson(json);
}
