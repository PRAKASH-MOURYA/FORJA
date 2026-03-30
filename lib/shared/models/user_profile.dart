import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
@HiveType(typeId: 4)
class UserProfile with _$UserProfile {
  const factory UserProfile({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2)
    required String goal, // lose_fat | build_muscle | get_stronger | general
    @HiveField(3) required String experience, // beginner | some | intermediate
    @HiveField(4) required int daysPerWeek,
    @HiveField(5)
    required String
        equipment, // full_gym | home_dumbbells | home_bodyweight | hybrid
    @HiveField(6) @Default([]) List<String> injuries,
    @HiveField(7) required String currentProgramId,
    @HiveField(8) @Default(0) int xp,
    @HiveField(9) @Default('novice') String level,
    @HiveField(10) @Default(0) int streakWeeks,
    @HiveField(11) @Default(1) int streakShields,
    @HiveField(12) required DateTime createdAt,
    @HiveField(13) @Default(false) bool onboardingComplete,
    @HiveField(14) String? customSplitId,
    @HiveField(15) double? heightCm,
    @HiveField(16) double? bodyWeightKg,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
