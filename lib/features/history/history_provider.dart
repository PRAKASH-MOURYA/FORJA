import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/workout_log.dart';
import '../../shared/providers/workout_provider.dart';
import '../../shared/repositories/workout_repository.dart';
import '../../shared/repositories/pr_repository.dart';

class HistoryState {
  const HistoryState({
    this.workouts = const [],
    this.recentPRs = const [],
    this.isLoading = false,
  });

  final List<WorkoutLog> workouts;
  final List<Map<String, dynamic>> recentPRs;
  final bool isLoading;

  HistoryState copyWith({
    List<WorkoutLog>? workouts,
    List<Map<String, dynamic>>? recentPRs,
    bool? isLoading,
  }) => HistoryState(
    workouts: workouts ?? this.workouts,
    recentPRs: recentPRs ?? this.recentPRs,
    isLoading: isLoading ?? this.isLoading,
  );
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._workoutRepo, this._prRepo) : super(const HistoryState()) {
    _load();
  }

  final WorkoutRepository _workoutRepo;
  final PrRepository _prRepo;

  void _load() {
    state = state.copyWith(isLoading: true);
    final workouts = _workoutRepo.getAll();
    final prs = _prRepo.getRecentPRs(limit: 10);
    // Convert generic Map to Map<String, dynamic>
    final typedPrs = prs.map((e) => Map<String, dynamic>.from(e)).toList();
    
    state = state.copyWith(workouts: workouts, recentPRs: typedPrs, isLoading: false);
  }

  void refresh() => _load();
}

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(
    ref.watch(workoutRepositoryProvider),
    ref.watch(prRepositoryProvider),
  );
});
