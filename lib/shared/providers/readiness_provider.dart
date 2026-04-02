import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/readiness_score.dart';
import '../repositories/checkin_repository.dart';
import '../repositories/workout_repository.dart';
import '../services/calculation_service.dart';

import '../providers/wearable_provider.dart';

final checkInRepositoryProvider = Provider((ref) => CheckInRepository());

final readinessProvider = Provider<ReadinessScore?>((ref) {
  final repo = ref.read(checkInRepositoryProvider);
  final latestCheckIn = repo.getLatest();

  final wearableAsync = ref.watch(wearableProvider);
  final wearable = wearableAsync.valueOrNull;

  if (latestCheckIn == null && wearable == null) return null;

  final workoutRepo = WorkoutRepository();
  final workouts = workoutRepo.getAll(); // sorted newest-first
  final daysSince = workouts.isEmpty
      ? 1
      : DateTime.now().difference(workouts.first.startedAt).inDays.clamp(0, 10);

  return CalculationService.readinessScore(latestCheckIn, daysSince,
      wearable: wearable);
});
