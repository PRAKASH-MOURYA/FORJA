import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/workout_provider.dart';

class ProfileStats {
  const ProfileStats({
    this.workoutCount = 0,
    this.totalVolumeKg = 0.0,
    this.streakWeeks = 0,
    this.level = 'novice',
    this.xp = 0,
  });

  final int workoutCount;
  final double totalVolumeKg;
  final int streakWeeks;
  final String level;
  final int xp;
}

final profileStatsProvider = Provider<ProfileStats>((ref) {
  final profile = ref.watch(userProfileProvider);
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final workouts = workoutRepo.getAll();

  return ProfileStats(
    workoutCount: workouts.length,
    totalVolumeKg: workouts.fold(0.0, (sum, w) => sum + w.totalVolumeKg),
    streakWeeks: profile?.streakWeeks ?? 0,
    level: profile?.level ?? 'novice',
    xp: profile?.xp ?? 0,
  );
});
