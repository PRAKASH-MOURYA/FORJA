import 'dart:math';
import '../models/set_log.dart';
import '../models/check_in.dart';
import '../models/readiness_score.dart';
import '../models/wearable_snapshot.dart';

class CalculationService {
  /// Epley formula: weight × (1 + reps/30)
  static double oneRepMax(double weightKg, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps / 30);
  }

  /// Sum of (weight × reps) for completed sets
  static double totalVolume(List<SetLog> sets) {
    return sets
        .where((s) => s.completed)
        .fold(0.0, (sum, s) => sum + s.weightKg * s.reps);
  }

  /// True if this set's estimated 1RM beats all historical sets for same exercise
  static bool isPersonalRecord(SetLog newSet, List<SetLog> history) {
    final newEstimate = oneRepMax(newSet.weightKg, newSet.reps);
    final bestPrevious = history
        .where((s) =>
            s.exerciseId == newSet.exerciseId &&
            s.completed &&
            s.id != newSet.id)
        .map((s) => oneRepMax(s.weightKg, s.reps))
        .fold(0.0, max);
    return newEstimate > bestPrevious;
  }

  /// Weighted readiness: Energy(30) + Soreness inverted(25) + Sleep(20) + Rest days(15) + Mood(10)
  static ReadinessScore readinessScore(
    CheckIn? lastCheckIn,
    int daysSinceWorkout, {
    WearableSnapshot? wearable,
  }) {
    // Energy: wearable-derived beats manual slider
    final double energyNorm = (wearable?.energyScore != null)
        ? wearable!.energyScore!
        : ((lastCheckIn?.energy ?? 3) / 5.0);
    final energy = energyNorm * 30;

    // Sleep: CheckIn slider wins if present (user override); wearable pre-fills otherwise
    final sleepHours = lastCheckIn?.sleepHours ?? wearable?.sleepHours ?? 7.0;
    final sleep = (sleepHours.clamp(0.0, 9.0) / 9.0) * 20;

    // Remaining fall back to neutral (3/5) if no checkIn
    final soreness = ((6 - (lastCheckIn?.soreness ?? 3)) / 5) * 25;
    final rest = (daysSinceWorkout.clamp(1, 3) / 3) * 15;
    final mood = ((lastCheckIn?.mood ?? 3) / 5) * 10;
    final score =
        (energy + soreness + sleep + rest + mood).round().clamp(0, 100);

    String zone, message, description;
    if (score >= 70) {
      zone = 'green';
      message = 'Ready to go';
      description = 'Recovery looking great. Push hard today.';
    } else if (score >= 40) {
      zone = 'yellow';
      message = 'Take it steady';
      description = 'Moderate recovery. Listen to your body.';
    } else {
      zone = 'red';
      message = 'Recovery day';
      description = 'High fatigue detected. Consider rest or light activity.';
    }

    return ReadinessScore(
      score: score,
      zone: zone,
      message: message,
      description: description,
      sources: wearable?.sources,
    );
  }

  /// Weekly volume from a list of (weight, reps) pairs
  static double weeklyVolume(List<Map<String, dynamic>> entries) {
    return entries.fold(0.0, (sum, e) {
      final w = (e['weight'] as num?)?.toDouble() ?? 0.0;
      final r = (e['reps'] as int?) ?? 0;
      return sum + w * r;
    });
  }
}
