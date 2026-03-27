import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/readiness_score.dart';
import '../repositories/checkin_repository.dart';
import '../repositories/workout_repository.dart';
import '../services/calculation_service.dart';

import '../providers/wearable_provider.dart';

/// Live readiness score derived from the latest CheckIn and workout gap.
///
/// Returns null when no check-in history exists (new user, first launch)
/// AND no wearable data is available.
/// Consumers must handle null gracefully — hide the banner, do not crash.
///
/// IMPORTANT: Call ref.invalidate(readinessProvider) after saving a new
/// CheckIn. This provider reads Hive directly (synchronous) so it will not
/// auto-recompute unless invalidated.
final readinessProvider = Provider<ReadinessScore?>((ref) {
  final latestCheckIn = CheckInRepository().getLatest();
  
  final wearableAsync = ref.watch(wearableProvider);
  final wearable = wearableAsync.valueOrNull;

  if (latestCheckIn == null && wearable == null) return null;

  final workouts = WorkoutRepository().getAll(); // sorted newest-first
  final daysSince = workouts.isEmpty
      ? 1
      : DateTime.now().difference(workouts.first.startedAt).inDays.clamp(0, 10);

  return CalculationService.readinessScore(latestCheckIn, daysSince, wearable: wearable);
});
