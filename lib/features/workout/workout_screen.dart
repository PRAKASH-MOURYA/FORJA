import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/animated_progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/providers/workout_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/workout_provider.dart' show prRepositoryProvider;
import '../../shared/models/exercise.dart';
import '../../shared/models/set_log.dart';
import '../../shared/repositories/pr_repository.dart';
import 'exercise_history_sheet.dart';
import 'session_guard_sheet.dart';
import 'widgets/exercise_hero_card.dart';
import 'widgets/set_bubble_row.dart';
import 'widgets/log_set_panel.dart';
import 'widgets/rest_timer_sheet.dart';
import 'widgets/exercise_jump_sheet.dart';
import 'finish_up_screen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  final List<Exercise> exercises;
  final String dayName;

  const WorkoutScreen({
    super.key,
    required this.exercises,
    required this.dayName,
  });

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  bool _workoutStarted = false;

  // Map-based per-exercise set state
  final Map<String, List<double>> _setWeights = {};
  final Map<String, List<int>> _setReps = {};
  final Map<String, List<bool>> _setsDone = {};
  bool _showRestTimer = false;
  int _lastCompletedSet = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startWorkout());
  }

  void _startWorkout() {
    if (_workoutStarted) return;
    _workoutStarted = true;
    final profile = ref.read(userProfileProvider);
    ref.read(workoutProvider.notifier).startWorkout(
          widget.dayName,
          widget.exercises,
          profile?.id ?? 'guest',
        );
    // Initialise set state for all exercises
    final prRepo = ref.read(prRepositoryProvider);
    for (final exercise in widget.exercises) {
      _initSetStateForExercise(exercise, prRepo);
    }
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  void _initSetStateForExercise(Exercise exercise, PrRepository prRepo) {
    if (_setWeights.containsKey(exercise.id)) return; // already initialised

    // Start with 1 set, pre-fill from last PR if available
    final pr = prRepo.getLatestPRForExercise(exercise.id);
    final defaultWeight =
        pr != null ? (pr['weight_kg'] as num).toDouble() : exercise.defaultKg;
    final defaultReps =
        pr != null ? (pr['reps'] as num).toInt() : exercise.reps;

    _setWeights[exercise.id] = [defaultWeight];
    _setReps[exercise.id] = [defaultReps];
    _setsDone[exercise.id] = [false];
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  String get _elapsedFormatted {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int _currentSetIndex(String exerciseId) {
    final done = _setsDone[exerciseId] ?? [];
    return done.indexWhere((d) => !d);
  }

  bool _allSetsDoneForExercise(String exerciseId) {
    final done = _setsDone[exerciseId] ?? [];
    return done.isNotEmpty && done.every((d) => d);
  }

  void _addSet(String exerciseId) {
    setState(() {
      _setWeights[exerciseId]!.add(_setWeights[exerciseId]!.last);
      _setReps[exerciseId]!.add(_setReps[exerciseId]!.last);
      _setsDone[exerciseId]!.add(false);
    });
  }

  void _logSet() {
    final workoutState = ref.read(workoutProvider);
    final exercise = workoutState.currentExercise;
    if (exercise == null) return;

    final setIndex = _currentSetIndex(exercise.id);
    if (setIndex < 0) return;

    final setLog = SetLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutLogId: workoutState.activeLog?.id ?? '',
      exerciseId: exercise.id,
      setNumber: setIndex + 1,
      weightKg: _setWeights[exercise.id]![setIndex],
      reps: _setReps[exercise.id]![setIndex],
      completed: true,
      createdAt: DateTime.now(),
    );

    ref.read(workoutProvider.notifier).logSet(setLog);

    setState(() {
      _setsDone[exercise.id]![setIndex] = true;
      _lastCompletedSet = setIndex + 1;
      _showRestTimer = !_allSetsDoneForExercise(exercise.id);
    });

    if (_allSetsDoneForExercise(exercise.id)) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _advanceExercise();
      });
    }
  }

  void _advanceExercise() {
    final workoutState = ref.read(workoutProvider);
    if (workoutState.allResolved) {
      _endWorkout();
    } else {
      ref.read(workoutProvider.notifier).nextExercise();
      setState(() {
        _showRestTimer = false;
        final newExercise = ref.read(workoutProvider).currentExercise;
        if (newExercise != null) {
          _lastCompletedSet = 0;
        }
      });
    }
  }

  Future<void> _endWorkout() async {
    _elapsedTimer?.cancel();
    final workoutState = ref.read(workoutProvider);

    // Find incomplete exercises (0 completed sets, not skipped)
    final incompleteExercises = workoutState.exercises.where((e) {
      final hasCompletedSet = workoutState.completedSets
          .any((s) => s.exerciseId == e.id && s.completed);
      final isSkipped = workoutState.skippedExerciseIds.contains(e.id);
      return !hasCompletedSet && !isSkipped;
    }).toList();

    if (incompleteExercises.isNotEmpty) {
      // Push FinishUpScreen (keeps WorkoutScreen State alive)
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FinishUpScreen(
            incompleteExercises: incompleteExercises,
            onAddSets: (id) {
              ref.read(workoutProvider.notifier).jumpToExercise(id);
              setState(() => _showRestTimer = false);
            },
            onSkip: (id) {
              ref.read(workoutProvider.notifier).markSkipped(id);
            },
            onProceed: () async {
              await ref.read(workoutProvider.notifier).completeWorkout();
              if (mounted) context.go('/workout/complete');
            },
          ),
        ),
      );
    } else {
      await ref.read(workoutProvider.notifier).completeWorkout();
      if (mounted) context.push('/workout/complete');
    }
  }

  Future<void> _showGuard() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SessionGuardSheet(
        onResume: () => Navigator.of(ctx).pop(),
        onDiscard: () {
          Navigator.of(ctx).pop();
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutProvider);
    final exercise = workoutState.currentExercise;
    final exerciseIndex = workoutState.exercises
        .indexWhere((e) => e.id == workoutState.activeExerciseId);
    final totalExercises = workoutState.exercises.length;

    if (exercise == null) {
      return Scaffold(
        backgroundColor: context.appBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final exerciseWeights = _setWeights[exercise.id] ?? [];
    final exerciseReps = _setReps[exercise.id] ?? [];
    final exerciseDone = _setsDone[exercise.id] ?? [];
    final currentSet = _currentSetIndex(exercise.id);
    final allDone = _allSetsDoneForExercise(exercise.id);

    final completedExercises =
        workoutState.completedSets.map((s) => s.exerciseId).toSet().length;
    final completedSets =
        workoutState.completedSets.where((s) => s.completed).length;
    final overallProgress =
        totalExercises > 0 ? completedExercises / totalExercises : 0.0;

    // Completed exercise IDs for the jump sheet
    final completedExIds = workoutState.completedSets
        .where((s) => s.completed)
        .map((s) => s.exerciseId)
        .toSet();

    // PR / Last session info
    final prRepo = ref.read(prRepositoryProvider);
    final pr = prRepo.getLatestPRForExercise(exercise.id);
    final progressiveTarget = prRepo.getProgressiveTarget(exercise.id);
    String? lastSessionText;
    String? prText;
    if (pr != null) {
      final weightKg = (pr['weight_kg'] as num).toDouble();
      final reps = (pr['reps'] as num).toInt();
      lastSessionText = 'Last: ${weightKg.toStringAsFixed(0)}kg × $reps';
      final targetWeight =
          (progressiveTarget['targetWeightKg'] as num).toDouble();
      final targetReps = progressiveTarget['targetReps'] as int;
      final increasedWeight =
          progressiveTarget['increasedWeight'] as bool? ?? false;
      if (increasedWeight) {
        prText = 'Target: ${targetWeight.toStringAsFixed(1)}kg × $targetReps';
      } else {
        prText =
            'Target: ${targetWeight.toStringAsFixed(0)}kg × $targetReps (add reps)';
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) async {
        if (!didPop) await _showGuard();
      },
      child: Scaffold(
        backgroundColor: context.appBg,
        body: SafeArea(
          child: Column(
            children: [
              // ── TOP BAR ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showGuard,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.appBgCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: context.appBorder),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: context.appTextSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.dayName.toUpperCase(),
                        style: AppTextStyles.labelUppercase(
                            context.appTextTertiary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warmDim,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        _elapsedFormatted,
                        style: AppTextStyles.bodyStrong(AppColors.warm),
                      ),
                    ),
                  ],
                ),
              ),

              // ── SCROLLABLE BODY ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise hero card
                      ExerciseHeroCard(
                        exercise: exercise,
                        exerciseIndex: exerciseIndex,
                        totalExercises: totalExercises,
                        onHistoryTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ExerciseHistorySheet(
                            exerciseId: exercise.id,
                            exerciseName: exercise.name,
                          ),
                        ),
                      ),

                      // Last session + PR to beat
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastSessionText ??
                                  'Log a workout to see your PR to beat',
                              style:
                                  AppTextStyles.micro(context.appTextSecondary),
                            ),
                          ),
                          if (prText != null)
                            Text(
                              prText,
                              style:
                                  AppTextStyles.micro(context.appTextSecondary),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── OVERALL PROGRESS RING ─────────────────────────
                      Center(
                        child: AnimatedProgressRing(
                          progress: overallProgress,
                          size: ProgressRingSize.lg,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$completedSets',
                                style: AppTextStyles.dataLarge(
                                    context.appTextPrimary),
                              ),
                              Text(
                                '/ ${workoutState.exercises.fold<int>(0, (s, e) => s + (_setsDone[e.id]?.length ?? e.sets))} sets',
                                style: AppTextStyles.caption(
                                    context.appTextSecondary),
                              ),
                              Text(
                                'TOTAL',
                                style: AppTextStyles.micro(
                                    context.appTextTertiary),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── SET BUBBLES ────────────────────────────────────
                      const SectionHeader('Sets'),
                      SetBubbleRow(
                        totalSets: exerciseDone.length,
                        currentSetIndex: currentSet,
                        setsDone: exerciseDone,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── LOG SET PANEL ──────────────────────────────────
                      if (!allDone)
                        LogSetPanel(
                          setNumber: _lastCompletedSet + 1,
                          weightKg: currentSet >= 0 &&
                                  currentSet < exerciseWeights.length
                              ? exerciseWeights[currentSet]
                              : exercise.defaultKg,
                          reps: currentSet >= 0 &&
                                  currentSet < exerciseReps.length
                              ? exerciseReps[currentSet]
                              : exercise.reps,
                          onWeightChanged: (w) {
                            if (currentSet >= 0 &&
                                currentSet < exerciseWeights.length) {
                              setState(() =>
                                  _setWeights[exercise.id]![currentSet] = w);
                            }
                          },
                          onRepsChanged: (r) {
                            if (currentSet >= 0 &&
                                currentSet < exerciseReps.length) {
                              setState(
                                  () => _setReps[exercise.id]![currentSet] = r);
                            }
                          },
                          onLogSet: currentSet >= 0 ? _logSet : null,
                          isEnabled: currentSet >= 0 && !_showRestTimer,
                        ),

                      // ── ADD SET BUTTON ──────────────────────────────────
                      if (!allDone || exerciseDone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: TextButton.icon(
                            onPressed: () => _addSet(exercise.id),
                            icon: Icon(Icons.add,
                                size: 16, color: context.appTextSecondary),
                            label: Text(
                              'Add Set',
                              style:
                                  AppTextStyles.body(context.appTextSecondary),
                            ),
                          ),
                        ),

                      // ── REST TIMER ─────────────────────────────────────
                      if (_showRestTimer) ...[
                        const SizedBox(height: AppSpacing.lg),
                        RestTimerSheet(
                          totalSeconds: 90,
                          onComplete: () =>
                              setState(() => _showRestTimer = false),
                          onSkip: () => setState(() => _showRestTimer = false),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xxl),

                      // ── BOTTOM ACTIONS ────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _advanceExercise,
                            child: Text(
                              'Skip',
                              style:
                                  AppTextStyles.body(context.appTextSecondary),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          TextButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ExerciseJumpSheet(
                                exercises: workoutState.exercises,
                                completedExerciseIds: completedExIds,
                                onJump: (id) {
                                  ref
                                      .read(workoutProvider.notifier)
                                      .jumpToExercise(id);
                                  setState(() {
                                    _showRestTimer = false;
                                    _lastCompletedSet = 0;
                                  });
                                },
                              ),
                            ),
                            child: Text(
                              'Exercises',
                              style:
                                  AppTextStyles.body(context.appTextSecondary),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          TextButton(
                            onPressed: _endWorkout,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stop_circle_outlined,
                                    color: AppColors.coral, size: 14),
                                const SizedBox(width: 4),
                                Text('End',
                                    style: AppTextStyles.body(AppColors.coral)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
