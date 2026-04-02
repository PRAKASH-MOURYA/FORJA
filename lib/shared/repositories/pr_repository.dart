import '../services/hive_service.dart';
import '../services/calculation_service.dart';
import '../models/set_log.dart';
import 'workout_repository.dart';

class PrRepository {
  final _workoutRepo = WorkoutRepository();

  /// Returns best estimated 1RM for an exercise, or 0 if no history
  double getBestOneRepMax(String exerciseId) {
    final records = HiveService.prRecords.values
        .where((r) => r['exercise_id'] == exerciseId)
        .toList();
    if (records.isEmpty) return 0.0;
    return records
        .map((r) => (r['estimated_1rm'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  /// Save a new PR record if this set beats the previous best
  Future<bool> saveIfPR(SetLog set) async {
    if (!set.completed) return false;
    final estimated1rm = CalculationService.oneRepMax(set.weightKg, set.reps);
    final best = getBestOneRepMax(set.exerciseId);
    if (estimated1rm <= best) return false;

    final key = '${set.exerciseId}_${set.createdAt.millisecondsSinceEpoch}';

    await HiveService.prRecords.put(key, {
      'exercise_id': set.exerciseId,
      'weight_kg': set.weightKg,
      'reps': set.reps,
      'estimated_1rm': estimated1rm,
      'achieved_at': set.createdAt.toIso8601String(),
    });
    return true;
  }

  List<Map> getRecentPRs({int limit = 5}) {
    final all = HiveService.prRecords.values.toList();
    all.sort((a, b) =>
        (b['achieved_at'] as String).compareTo(a['achieved_at'] as String));
    return all.take(limit).map((e) => Map.from(e)).toList();
  }

  Map? getLatestPRForExercise(String exerciseId) {
    final records = HiveService.prRecords.values
        .where((r) => r['exercise_id'] == exerciseId)
        .toList();
    if (records.isEmpty) return null;
    records.sort((a, b) =>
        (b['achieved_at'] as String).compareTo(a['achieved_at'] as String));
    return Map.from(records.first);
  }

  /// Returns the recommended target to beat based on progressive overload:
  /// - If last 2+ workouts in 10-12 rep range → increase weight by 2.5kg
  /// - Otherwise → target same weight with more reps
  /// Returns: {targetWeightKg, targetReps, reason}
  Map<String, dynamic> getProgressiveTarget(String exerciseId) {
    final recentSets =
        _workoutRepo.getRecentWorkoutsForExercise(exerciseId, limit: 10);

    if (recentSets.isEmpty) {
      return {
        'targetWeightKg': 0.0,
        'targetReps': 10,
        'reason': 'No workout history yet',
      };
    }

    final workouts = _groupSetsByWorkout(recentSets);
    if (workouts.isEmpty) {
      return {
        'targetWeightKg': 0.0,
        'targetReps': 10,
        'reason': 'No completed workouts',
      };
    }

    final lastWorkout = workouts.first;
    final lastWeight = lastWorkout.first.weightKg;
    final lastReps = lastWorkout.first.reps;

    // Check if last 2+ workouts were in 10-12 rep range
    int consecutiveInRange = 0;
    for (final workout in workouts) {
      if (workout.isEmpty) continue;
      final avgReps =
          workout.map((s) => s.reps).reduce((a, b) => a + b) ~/ workout.length;
      if (avgReps >= 10 && avgReps <= 12) {
        consecutiveInRange++;
      } else {
        break;
      }
    }

    if (consecutiveInRange >= 2) {
      // Ready to increase weight
      final newWeight = lastWeight + 2.5;
      return {
        'targetWeightKg': newWeight,
        'targetReps': 8,
        'reason': 'Hit 10-12 reps for 2+ workouts → increase weight',
        'increasedWeight': true,
      };
    } else {
      // Build volume first - add reps
      final targetReps = lastReps + 2;
      return {
        'targetWeightKg': lastWeight,
        'targetReps': targetReps.clamp(8, 15),
        'reason': lastReps < 10
            ? 'Build to 10-12 reps first'
            : 'Maintain weight, add reps',
        'increasedWeight': false,
      };
    }
  }

  List<List<SetLog>> _groupSetsByWorkout(List<SetLog> sets) {
    final grouped = <String, List<SetLog>>{};
    for (final set in sets) {
      grouped.putIfAbsent(set.workoutLogId, () => []).add(set);
    }
    final workouts = grouped.values.toList();
    workouts.sort((a, b) => b.first.createdAt.compareTo(a.first.createdAt));
    return workouts;
  }
}
