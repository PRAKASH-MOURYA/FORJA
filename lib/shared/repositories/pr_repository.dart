import '../services/hive_service.dart';
import '../services/calculation_service.dart';
import '../models/set_log.dart';

class PrRepository {
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
}
