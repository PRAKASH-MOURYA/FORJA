import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/workout_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/repositories/workout_repository.dart';
import '../../shared/repositories/pr_repository.dart';
import '../../shared/repositories/profile_repository.dart';

class ProgressState {
  const ProgressState({
    this.totalVolumeKg = 0.0,
    this.workoutCount = 0,
    this.streakWeeks = 0,
    this.prsThisWeek = 0,
    this.weeklyVolumes = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    this.liftTrends = const [],
    this.recentPRs = const [],
    this.isLoading = false,
  });

  final double totalVolumeKg;
  final int workoutCount;
  final int streakWeeks;
  final int prsThisWeek;
  final List<double> weeklyVolumes; // Mon–Sun, current week
  final List<LiftTrend> liftTrends; // Bench, Squat, Deadlift
  final List<Map<String, dynamic>> recentPRs;
  final bool isLoading;

  ProgressState copyWith({
    double? totalVolumeKg,
    int? workoutCount,
    int? streakWeeks,
    int? prsThisWeek,
    List<double>? weeklyVolumes,
    List<LiftTrend>? liftTrends,
    List<Map<String, dynamic>>? recentPRs,
    bool? isLoading,
  }) => ProgressState(
    totalVolumeKg: totalVolumeKg ?? this.totalVolumeKg,
    workoutCount: workoutCount ?? this.workoutCount,
    streakWeeks: streakWeeks ?? this.streakWeeks,
    prsThisWeek: prsThisWeek ?? this.prsThisWeek,
    weeklyVolumes: weeklyVolumes ?? this.weeklyVolumes,
    liftTrends: liftTrends ?? this.liftTrends,
    recentPRs: recentPRs ?? this.recentPRs,
    isLoading: isLoading ?? this.isLoading,
  );
}

class LiftTrend {
  const LiftTrend({
    required this.exerciseName,
    required this.currentOneRepMax,
    required this.previousOneRepMax, 
  });

  final String exerciseName;
  final double currentOneRepMax;
  final double previousOneRepMax;

  double get trendKg => currentOneRepMax - previousOneRepMax;
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier(this._workoutRepo, this._prRepo, this._profileRepo)
      : super(const ProgressState()) {
    _load();
  }

  final WorkoutRepository _workoutRepo;
  final PrRepository _prRepo;
  final ProfileRepository _profileRepo;

  void _load() {
    state = state.copyWith(isLoading: true);

    final allWorkouts = _workoutRepo.getAll();
    final totalVolume = allWorkouts.fold(0.0, (sum, w) => sum + w.totalVolumeKg);
    final profile = _profileRepo.get();

    // Weekly volume bar chart (Mon–Sun current week)
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1)); // Monday midnight
    final weekWorkouts = _workoutRepo.getForWeek(weekStart);
    final weeklyVolumes = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final workoutsOnDay = weekWorkouts.where((w) =>
        w.startedAt.year == day.year &&
        w.startedAt.month == day.month &&
        w.startedAt.day == day.day
      );
      return workoutsOnDay.fold(0.0, (sum, w) => sum + w.totalVolumeKg);
    });

    // PRs this week
    final weekStartTimestamp = weekStart.toIso8601String();
    final rawRecentPRs = _prRepo.getRecentPRs(limit: 20);
    final recentPRs = rawRecentPRs.map((e) => Map<String, dynamic>.from(e)).toList();
    
    final prsThisWeek = recentPRs.where((pr) {
      final achievedAt = pr['achieved_at'] as String?;
      return achievedAt != null && achievedAt.compareTo(weekStartTimestamp) >= 0;
    }).length;

    // 1RM trends for key lifts
    final keyLifts = [
      ('Bench Press', 'barbell_bench_press'),
      ('Squat', 'barbell_squat'),
      ('Deadlift', 'barbell_deadlift'),
    ];
    final liftTrends = keyLifts.map((lift) {
      final best = _prRepo.getBestOneRepMax(lift.$2);
      // previous: get all PRs for this exercise, take second-best
      final allPrsForLift = recentPRs
          .where((pr) => pr['exercise_id'] == lift.$2)
          .toList()
          ..sort((a, b) => (b['estimated_1rm'] as double)
              .compareTo(a['estimated_1rm'] as double));
      final prev = allPrsForLift.length > 1
          ? (allPrsForLift[1]['estimated_1rm'] as double)
          : 0.0;
      return LiftTrend(
        exerciseName: lift.$1,
        currentOneRepMax: best,
        previousOneRepMax: prev,
      );
    }).toList();

    state = state.copyWith(
      totalVolumeKg: totalVolume,
      workoutCount: allWorkouts.length,
      streakWeeks: profile?.streakWeeks ?? 0,
      prsThisWeek: prsThisWeek,
      weeklyVolumes: weeklyVolumes,
      liftTrends: liftTrends,
      recentPRs: recentPRs.take(5).toList(),
      isLoading: false,
    );
  }

  void refresh() => _load();
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier(
    ref.watch(workoutRepositoryProvider),
    ref.watch(prRepositoryProvider),
    ref.watch(profileRepositoryProvider),
  );
});
