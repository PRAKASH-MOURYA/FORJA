import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/set_log.dart';
import '../repositories/workout_repository.dart';
import '../repositories/checkin_repository.dart';
import '../services/adaptive_engine.dart';
import 'readiness_provider.dart';
import 'today_provider.dart';

/// Extends [TodayPlan] with adaptive modifications and WHY message.
class AdaptiveTodayPlan {
  final TodayPlan basePlan;
  final List<ExerciseModification> modifications;
  final String? whyMessage;       // null = no WHY banner
  final bool isRestDay;
  final bool showReadinessBanner; // false = no check-in history yet
  final int workoutsThisWeek;
  final int setsThisWeek;
  final double volumeKgThisWeek;

  const AdaptiveTodayPlan({
    required this.basePlan,
    this.modifications = const [],
    this.whyMessage,
    this.isRestDay = false,
    this.showReadinessBanner = true,
    this.workoutsThisWeek = 0,
    this.setsThisWeek = 0,
    this.volumeKgThisWeek = 0.0,
  });

  /// Returns the adjusted weight for [exerciseId] given [baseWeight].
  /// Applies only delta modifications — never mutates Exercise constants.
  double sessionWeightFor(String exerciseId, double baseWeight) {
    final mod = modifications
        .where((m) => m.exerciseId == exerciseId)
        .firstOrNull;
    if (mod == null) return baseWeight;
    return (baseWeight + mod.weightAdjustmentKg).clamp(0.0, double.infinity);
  }

  /// Returns true if this exercise should be excluded from today's session
  /// (volume reduction rule — remove last exercise).
  bool isExerciseRemoved(String exerciseId) {
    return modifications.any(
      (m) => m.exerciseId == exerciseId && m.reason == 'volume_reduced',
    );
  }
}

/// Composes [todayProgramProvider] + [readinessProvider] through [AdaptiveEngine].
///
/// Returns null only when the base plan is null (user not onboarded).
/// When readiness is null (no check-ins), returns AdaptiveTodayPlan with
/// showReadinessBanner=false and no modifications — safe for first launch.
final adaptiveTodayProvider = Provider<AdaptiveTodayPlan?>((ref) {
  final basePlan = ref.watch(todayProgramProvider);
  if (basePlan == null) return null;

  final readiness = ref.watch(readinessProvider);
  if (readiness == null) {
    // No check-in history — show base plan, hide readiness banner
    return AdaptiveTodayPlan(
      basePlan: basePlan,
      showReadinessBanner: false,
    );
  }

  final workouts = WorkoutRepository().getAll();
  final lastWorkout = workouts.isNotEmpty ? workouts.first : null;
  final lastSessionSets = lastWorkout != null
      ? WorkoutRepository().getSetsForWorkout(lastWorkout.id)
      : <SetLog>[];
  final daysSince = lastWorkout == null
      ? 0
      : DateTime.now().difference(lastWorkout.startedAt).inDays.clamp(0, 30);
  final lastCheckIns = CheckInRepository().getLastN(3);

  final result = AdaptiveEngine.evaluate(
    readiness: readiness,
    recentWorkouts: workouts.take(7).toList(),
    lastSessionSets: lastSessionSets,
    todayExercises: basePlan.exercises,
    lastCheckIns: lastCheckIns,
    daysSinceLastWorkout: daysSince,
  );

  return AdaptiveTodayPlan(
    basePlan: basePlan,
    modifications: result.modifications,
    whyMessage: result.whyBannerMessage,
    isRestDay: result.isRestDay,
    showReadinessBanner: true,
  );
});
