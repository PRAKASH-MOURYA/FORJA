import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'check_in.freezed.dart';
part 'check_in.g.dart';

@freezed
@HiveType(typeId: 3)
class CheckIn with _$CheckIn {
  const factory CheckIn({
    @HiveField(0) required String id,
    @HiveField(1) required String userId,
    @HiveField(2) String? workoutLogId,
    @HiveField(3) required int energy, // 1-5
    @HiveField(4) required int soreness, // 1-5
    @HiveField(5) required int mood, // 1-5
    @HiveField(6) double? sleepHours,
    @HiveField(7) int? stress, // 1-5
    @HiveField(8) required DateTime createdAt,
    @HiveField(9) @Default('pending') String syncStatus,
  }) = _CheckIn;

  factory CheckIn.fromJson(Map<String, dynamic> json) =>
      _$CheckInFromJson(json);
}
