import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'workout_log.freezed.dart';
part 'workout_log.g.dart';

@freezed
@HiveType(typeId: 1)
class WorkoutLog with _$WorkoutLog {
  const factory WorkoutLog({
    @HiveField(0) required String id,
    @HiveField(1) required String userId,
    @HiveField(2) required String programDayName,
    @HiveField(3) required DateTime startedAt,
    @HiveField(4) DateTime? completedAt,
    @HiveField(5) @Default(0.0) double totalVolumeKg,
    @HiveField(6) @Default(0) int totalSets,
    @HiveField(7) @Default(0) int durationSeconds,
    @HiveField(8) int? readinessScore,
    @HiveField(9)
    @Default('pending')
    String syncStatus, // synced | pending | failed
  }) = _WorkoutLog;

  factory WorkoutLog.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogFromJson(json);
}
