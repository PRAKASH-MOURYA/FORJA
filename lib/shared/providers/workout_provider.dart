import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_log.dart';
import '../models/set_log.dart';
import '../models/exercise.dart';
import '../repositories/workout_repository.dart';
import '../repositories/pr_repository.dart';
import '../services/calculation_service.dart';

final workoutRepositoryProvider = Provider((ref) => WorkoutRepository());
final prRepositoryProvider = Provider((ref) => PrRepository());

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(
    ref.read(workoutRepositoryProvider),
    ref.read(prRepositoryProvider),
  );
});

class WorkoutState {
  final WorkoutLog? activeLog;
  final List<Exercise> exercises;
  final String? activeExerciseId;
  final Set<String> skippedExerciseIds;
  final List<SetLog> completedSets;
  final int elapsedSeconds;
  final bool isActive;
  final List<String> newPRs; // exercise IDs that got a PR this session

  const WorkoutState({
    this.activeLog,
    this.exercises = const [],
    this.activeExerciseId,
    this.skippedExerciseIds = const {},
    this.completedSets = const [],
    this.elapsedSeconds = 0,
    this.isActive = false,
    this.newPRs = const [],
  });

  Exercise? get currentExercise => activeExerciseId == null
      ? null
      : exercises.firstWhere((e) => e.id == activeExerciseId,
          orElse: () => exercises.first);

  double get totalVolume => CalculationService.totalVolume(completedSets);
  int get totalSets => completedSets.where((s) => s.completed).length;
  bool get allResolved =>
      exercises.isNotEmpty &&
      exercises.every((e) =>
          completedSets.any((s) => s.exerciseId == e.id && s.completed) ||
          skippedExerciseIds.contains(e.id));

  WorkoutState copyWith({
    WorkoutLog? activeLog,
    List<Exercise>? exercises,
    String? activeExerciseId,
    Set<String>? skippedExerciseIds,
    List<SetLog>? completedSets,
    int? elapsedSeconds,
    bool? isActive,
    List<String>? newPRs,
  }) =>
      WorkoutState(
        activeLog: activeLog ?? this.activeLog,
        exercises: exercises ?? this.exercises,
        activeExerciseId: activeExerciseId ?? this.activeExerciseId,
        skippedExerciseIds: skippedExerciseIds ?? this.skippedExerciseIds,
        completedSets: completedSets ?? this.completedSets,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        isActive: isActive ?? this.isActive,
        newPRs: newPRs ?? this.newPRs,
      );
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final WorkoutRepository _workoutRepo;
  final PrRepository _prRepo;
  Timer? _timer;

  WorkoutNotifier(this._workoutRepo, this._prRepo)
      : super(const WorkoutState());

  void startWorkout(
      String programDayName, List<Exercise> exercises, String userId) {
    final log = WorkoutLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      programDayName: programDayName,
      startedAt: DateTime.now(),
    );
    state = state.copyWith(
      activeLog: log,
      exercises: exercises,
      activeExerciseId: exercises.isNotEmpty ? exercises.first.id : null,
      skippedExerciseIds: const {},
      completedSets: [],
      elapsedSeconds: 0,
      isActive: true,
      newPRs: [],
    );
    _startTimer();
    _workoutRepo.save(log);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  Future<void> logSet(SetLog set) async {
    final updatedSets = [...state.completedSets, set];
    await _workoutRepo.saveSet(set);

    final isPR = await _prRepo.saveIfPR(set);
    final newPRs = isPR ? [...state.newPRs, set.exerciseId] : state.newPRs;

    state = state.copyWith(completedSets: updatedSets, newPRs: newPRs);
    _updateWorkoutLog(updatedSets);
  }

  void jumpToExercise(String exerciseId) {
    if (state.exercises.any((e) => e.id == exerciseId)) {
      state = state.copyWith(activeExerciseId: exerciseId);
    }
  }

  void markSkipped(String exerciseId) {
    final updated = {...state.skippedExerciseIds, exerciseId};
    state = state.copyWith(skippedExerciseIds: updated);
  }

  void nextExercise() {
    final idx = state.exercises.indexWhere((e) => e.id == state.activeExerciseId);
    if (idx != -1 && idx < state.exercises.length - 1) {
      state = state.copyWith(activeExerciseId: state.exercises[idx + 1].id);
    }
  }

  Future<WorkoutLog?> completeWorkout() async {
    _timer?.cancel();
    final log = state.activeLog;
    if (log == null) return null;

    final completed = log.copyWith(
      completedAt: DateTime.now(),
      totalVolumeKg: state.totalVolume,
      totalSets: state.totalSets,
      durationSeconds: state.elapsedSeconds,
    );
    await _workoutRepo.save(completed);
    state = state.copyWith(activeLog: completed, isActive: false);
    return completed;
  }

  void _updateWorkoutLog(List<SetLog> sets) {
    final log = state.activeLog;
    if (log == null) return;
    final updated = log.copyWith(
      totalVolumeKg: CalculationService.totalVolume(sets),
      totalSets: sets.where((s) => s.completed).length,
      durationSeconds: state.elapsedSeconds,
    );
    state = state.copyWith(activeLog: updated);
    _workoutRepo.save(updated);
  }

  void reset() {
    _timer?.cancel();
    state = const WorkoutState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
