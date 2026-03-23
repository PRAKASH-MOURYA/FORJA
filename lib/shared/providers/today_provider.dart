import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/programs.dart';
import '../constants/exercises.dart';
import '../models/exercise.dart';
import '../services/hive_service.dart';
import 'auth_provider.dart';

/// Typed result exposed by [todayProgramProvider].
class TodayPlan {
  final String dayName;
  final List<Exercise> exercises;
  const TodayPlan({required this.dayName, required this.exercises});
}

/// Resolves the current user's assigned program day into a [TodayPlan].
///
/// Returns null if the user has no profile or has not completed onboarding.
/// swapAlternatives are resolved from IDs to display names using [kExerciseData].
final todayProgramProvider = Provider<TodayPlan?>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || !profile.onboardingComplete) return null;

  // --- Custom split takes priority over program template ---
  final customSplitId = profile.customSplitId;
  if (customSplitId != null && customSplitId.isNotEmpty) {
    final split = HiveService.customSplits.get(customSplitId);
    if (split != null && split.days.isNotEmpty) {
      final dayIndex = (DateTime.now().weekday - 1) % split.days.length;
      final splitDay = split.days[dayIndex];

      final exercises = splitDay.exerciseIds
          .map((id) {
            final data = kExerciseData[id];
            if (data == null) return null;

            final rawSwaps = List<String>.from(
                (data['swapAlternatives'] as List?) ?? const []);
            final resolvedSwaps = rawSwaps.map((swapId) {
              final swapData = kExerciseData[swapId];
              return swapData != null ? swapData['name'] as String : swapId;
            }).toList();

            final resolvedData = Map<String, dynamic>.from(data)
              ..['swapAlternatives'] = resolvedSwaps;

            return Exercise.fromJson(resolvedData);
          })
          .whereType<Exercise>()
          .toList();

      return TodayPlan(dayName: splitDay.dayName, exercises: exercises);
    }
    // customSplitId set but split not found — fall through to program template
  }

  // Find the assigned program template (fall back to first if ID not found)
  final template = kPrograms.firstWhere(
    (p) => p.id == profile.currentProgramId,
    orElse: () => kPrograms.first,
  );

  // Cycle through days by calendar weekday (Monday = index 0)
  final dayIndex = (DateTime.now().weekday - 1) % template.days.length;
  final programDay = template.days[dayIndex];

  // Build Exercise list, skipping unknown IDs, resolving swapAlternatives to display names
  final exercises = programDay.exerciseIds
      .map((id) {
        final data = kExerciseData[id];
        if (data == null) return null;

        // Resolve swapAlternative IDs → display names
        final rawSwaps = List<String>.from(
            (data['swapAlternatives'] as List?) ?? const []);
        final resolvedSwaps = rawSwaps.map((swapId) {
          final swapData = kExerciseData[swapId];
          return swapData != null ? swapData['name'] as String : swapId;
        }).toList();

        // Build a modified data map with resolved swaps, then deserialise
        final resolvedData = Map<String, dynamic>.from(data)
          ..['swapAlternatives'] = resolvedSwaps;

        return Exercise.fromJson(resolvedData);
      })
      .whereType<Exercise>()
      .toList();

  return TodayPlan(dayName: programDay.name, exercises: exercises);
});
