import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
@HiveType(typeId: 0)
class Exercise with _$Exercise {
  const factory Exercise({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String muscle, // primary muscle group
    @HiveField(3)
    required String
        equipment, // full_gym | home_dumbbells | home_bodyweight | hybrid
    @HiveField(4) required int sets,
    @HiveField(5) required int reps,
    @HiveField(6) required double defaultKg,
    @HiveField(7) required List<String> formCues,
    @HiveField(8) required List<String> targetMuscles,
    @HiveField(9) required List<String> swapAlternatives,
    @HiveField(10) @Default('') String videoUrl,
    @HiveField(11)
    required String category, // push | pull | legs | core | cardio
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}
