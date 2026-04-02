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
  /// True when today has no split day assigned (rest day) or the custom split
  /// has no weekdayMap entry for the current weekday.
  final bool isRest;

  const TodayPlan({
    required this.dayName,
    required this.exercises,
    this.isRest = false,
  });
}

/// Resolves the current user's assigned program day into a [TodayPlan].
///
/// Returns null if the user has no profile or has not completed onboarding.
/// swapAlternatives are resolved from IDs to display names using [kExerciseData].
final todayProgramProvider = Provider<TodayPlan?>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null || !profile.onboardingComplete) return null;

  // --- Custom split takes priority over program template ---
  // IMPORTANT: callers selecting a pre-built program must set customSplitId: null on UserProfile
  final customSplitId = profile.customSplitId;
  if (customSplitId != null && customSplitId.isNotEmpty) {
    final split = HiveService.customSplits.get(customSplitId);
    if (split != null && split.days.isNotEmpty) {
      // Use explicit weekday map: 1=Mon … 7=Sun → index into split.days.
      // An unmapped weekday means this is a rest day.
      final weekday = DateTime.now().weekday;
      final dayIndex = split.weekdayMap[weekday];
      if (dayIndex == null || dayIndex >= split.days.length) {
        return const TodayPlan(
          dayName: 'Rest Day',
          exercises: [],
          isRest: true,
        );
      }
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
