import '../models/readiness_score.dart';
import '../models/workout_log.dart';
import '../models/set_log.dart';
import '../models/check_in.dart';
import '../models/exercise.dart';

const int kHighSorenessThreshold = 4;  // soreness >= this = "high"
const int kDeloadLookback = 3;          // must be ALL 3 consecutive check-ins
const double kProgressiveOverloadKg = 2.5;
const double kDeloadFactor = 0.10;      // 10% weight reduction
const int kGapDaysThreshold = 4;

class ExerciseModification {
  final String exerciseId;
  final double weightAdjustmentKg; // positive=increase, negative=decrease, 0=hold
  final String reason;
  const ExerciseModification({
    required this.exerciseId,
    required this.weightAdjustmentKg,
    required this.reason,
  });
}

class AdaptiveResult {
  final List<ExerciseModification> modifications;
  final String? whyBannerMessage;
  final bool isRestDay;
  const AdaptiveResult({
    this.modifications = const [],
    this.whyBannerMessage,
    this.isRestDay = false,
  });
}

class AdaptiveEngine {
  /// Evaluate 7 adaptive rules in priority order.
  ///
  /// [lastCheckIns] — up to 3 most recent CheckIn records (newest first).
  /// [daysSinceLastWorkout] — 0 means workout today; >= 4 triggers volume reduction.
  /// [recentWorkouts] — sorted newest-first; first entry = last session.
  /// [lastSessionSets] — all SetLogs for the most recent WorkoutLog.
  /// [todayExercises] — the exercise list from todayProgramProvider (NOT mutated).
  ///
  /// Returns an AdaptiveResult with modifications and an optional WHY banner message.
  /// Modifications are delta adjustments only — apply to base weights at render time.
  static AdaptiveResult evaluate({
    required ReadinessScore readiness,
    required List<WorkoutLog> recentWorkouts,
    required List<SetLog> lastSessionSets,
    required List<Exercise> todayExercises,
    required List<CheckIn> lastCheckIns,
    required int daysSinceLastWorkout,
  }) {
    // Rule 1: Red zone → rest day (short-circuit)
    if (readiness.zone == 'red') {
      return const AdaptiveResult(
        isRestDay: true,
        whyBannerMessage: 'High fatigue detected — recovery day.',
      );
    }

    final modifications = <ExerciseModification>[];
    String? whyMessage;

    // Rule 2: 3 consecutive high-soreness check-ins → deload -10%
    if (lastCheckIns.length >= kDeloadLookback) {
      final last3 = lastCheckIns.take(kDeloadLookback).toList();
      final allHighSoreness = last3.every((c) => c.soreness >= kHighSorenessThreshold);
      if (allHighSoreness) {
        for (final exercise in todayExercises) {
          final deloadKg = -(exercise.defaultKg * kDeloadFactor);
          modifications.add(ExerciseModification(
            exerciseId: exercise.id,
            weightAdjustmentKg: deloadKg,
            reason: 'deload',
          ));
        }
        whyMessage = 'Soreness is high — lighter session today.';
        // Rule 2 takes priority over weight rules below — return early
        return AdaptiveResult(
          modifications: modifications,
          whyBannerMessage: whyMessage,
        );
      }
    }

    // Rule 4: Gap >= 4 days since last workout → reduce volume (remove last exercise)
    if (recentWorkouts.isNotEmpty && daysSinceLastWorkout >= kGapDaysThreshold) {
      if (todayExercises.isNotEmpty) {
        modifications.add(ExerciseModification(
          exerciseId: todayExercises.last.id,
          weightAdjustmentKg: 0,
          reason: 'volume_reduced',
        ));
      }
      whyMessage = 'Gap since last session — easing back in.';
    }

    // Rule 5: Yellow zone → no overload
    if (readiness.zone == 'yellow') {
      // Only set WHY if Rule 4 did not already set one
      whyMessage ??= 'Moderate recovery — keep weights the same.';
      // Return now — do not apply Rule 3 or 7 weight changes
      return AdaptiveResult(
        modifications: modifications,
        whyBannerMessage: whyMessage,
      );
    }

    // Rules 3 & 7: Green zone — per-exercise overload or hold
    // Check if any set failed in the last session (Rule 7 signal)
    final hasAnyFailure = lastSessionSets.any((s) => s.failed);

    for (final exercise in todayExercises) {
      final exerciseSets = lastSessionSets
          .where((s) => s.exerciseId == exercise.id)
          .toList();

      if (exerciseSets.isEmpty) continue;

      // Rule 7: any failed set for this exercise → hold weight
      final hasFailedSet = exerciseSets.any((s) => s.failed);
      if (hasFailedSet) {
        modifications.add(ExerciseModification(
          exerciseId: exercise.id,
          weightAdjustmentKg: 0,
          reason: 'hold_failed',
        ));
        continue;
      }

      // Rule 3: all sets completed AND none skipped → progressive overload
      final allCompleted = exerciseSets.every((s) => s.completed);
      final noneSkipped = exerciseSets.every((s) => !s.skipped);
      if (allCompleted && noneSkipped) {
        modifications.add(ExerciseModification(
          exerciseId: exercise.id,
          weightAdjustmentKg: kProgressiveOverloadKg,
          reason: 'progressive_overload',
        ));
      }
    }

    // Set WHY message for Rule 3 or 7 (if any modification applied)
    if (whyMessage == null) {
      final hasOverload = modifications.any((m) => m.weightAdjustmentKg > 0);
      final hasHold = modifications.any((m) => m.reason == 'hold_failed');
      if (hasAnyFailure || hasHold) {
        whyMessage = 'Struggled last session — hold weight today.';
      } else if (hasOverload) {
        whyMessage = 'Crushed it last time — time to go heavier.';
      }
    }

    return AdaptiveResult(
      modifications: modifications,
      whyBannerMessage: whyMessage,
    );
  }
}
