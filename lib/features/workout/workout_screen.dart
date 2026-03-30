import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/premium_card.dart';
import '../../shared/widgets/animated_progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/providers/workout_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/models/exercise.dart';
import '../../shared/models/set_log.dart';
import 'exercise_history_sheet.dart';
import 'session_guard_sheet.dart';
import 'widgets/exercise_hero_card.dart';
import 'widgets/set_bubble_row.dart';
import 'widgets/log_set_panel.dart';
import 'widgets/rest_timer_sheet.dart';

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

  late List<double> _setWeights;
  late List<int> _setReps;
  late List<bool> _setsDone;
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
    _initSetState(0);
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  void _initSetState(int exerciseIndex) {
    final exercises = ref.read(workoutProvider).exercises;
    if (exerciseIndex >= exercises.length) return;
    final exercise = exercises[exerciseIndex];
    _setWeights = List.generate(exercise.sets, (_) => exercise.defaultKg);
    _setReps = List.generate(exercise.sets, (_) => exercise.reps);
    _setsDone = List.generate(exercise.sets, (_) => false);
    _showRestTimer = false;
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

  int get _currentSetIndex => _setsDone.indexWhere((d) => !d);
  bool get _allSetsDone => _setsDone.every((d) => d);

  void _logSet() {
    final setIndex = _currentSetIndex;
    if (setIndex < 0) return;

    final workoutState = ref.read(workoutProvider);
    final exercise = workoutState.currentExercise;
    if (exercise == null) return;

    final setLog = SetLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutLogId: workoutState.activeLog?.id ?? '',
      exerciseId: exercise.id,
      setNumber: setIndex + 1,
      weightKg: _setWeights[setIndex],
      reps: _setReps[setIndex],
      completed: true,
      createdAt: DateTime.now(),
    );

    ref.read(workoutProvider.notifier).logSet(setLog);

    setState(() {
      _setsDone[setIndex] = true;
      _lastCompletedSet = setIndex + 1;
      _showRestTimer = !_allSetsDone;
    });

    if (_allSetsDone) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _advanceExercise();
      });
    }
  }

  void _advanceExercise() {
    final workoutState = ref.read(workoutProvider);
    if (workoutState.isLastExercise) {
      _endWorkout();
    } else {
      ref.read(workoutProvider.notifier).nextExercise();
      setState(() {
        _initSetState(workoutState.currentExerciseIndex + 1);
      });
    }
  }

  Future<void> _endWorkout() async {
    _elapsedTimer?.cancel();
    await ref.read(workoutProvider.notifier).completeWorkout();
    if (mounted) context.push('/workout/complete');
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
    final exerciseIndex = workoutState.currentExerciseIndex;
    final totalExercises = workoutState.exercises.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (exercise == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bg : AppColors.bgLight,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final completedExercises =
        workoutState.completedSets.map((s) => s.exerciseId).toSet().length;
    final totalSets = workoutState.exercises.fold<int>(0, (s, e) => s + e.sets);
    final completedSets = workoutState.completedSets.where((s) => s.completed).length;
    final overallProgress = totalExercises > 0
        ? completedExercises / totalExercises
        : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) async {
        if (!didPop) await _showGuard();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bg : AppColors.bgLight,
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
                          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isDark ? AppColors.border : AppColors.borderLight,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.dayName.toUpperCase(),
                        style: AppTextStyles.labelUppercase(
                          isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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
                                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                '/ $totalSets sets',
                                style: AppTextStyles.caption(
                                  isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                ),
                              ),
                              Text(
                                'TOTAL',
                                style: AppTextStyles.micro(
                                  isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── SET BUBBLES ────────────────────────────────────
                      SectionHeader('Sets'),
                      SetBubbleRow(
                        totalSets: exercise.sets,
                        currentSetIndex: _currentSetIndex,
                        setsDone: _setsDone,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── LOG SET PANEL ──────────────────────────────────
                      if (!_allSetsDone)
                        LogSetPanel(
                          setNumber: _lastCompletedSet + 1,
                          weightKg: _currentSetIndex >= 0
                              ? _setWeights[_currentSetIndex]
                              : exercise.defaultKg,
                          reps: _currentSetIndex >= 0
                              ? _setReps[_currentSetIndex]
                              : exercise.reps,
                          onWeightChanged: (w) {
                            if (_currentSetIndex >= 0) {
                              setState(() => _setWeights[_currentSetIndex] = w);
                            }
                          },
                          onRepsChanged: (r) {
                            if (_currentSetIndex >= 0) {
                              setState(() => _setReps[_currentSetIndex] = r);
                            }
                          },
                          onLogSet: _currentSetIndex >= 0 ? _logSet : null,
                          isEnabled: _currentSetIndex >= 0 && !_showRestTimer,
                        ),

                      // ── REST TIMER ─────────────────────────────────────
                      if (_showRestTimer) ...[
                        const SizedBox(height: AppSpacing.lg),
                        PremiumCard(
                          boxShadow: AppColors.fireGlow,
                          child: RestTimerSheet(
                            totalSeconds: 90,
                            onComplete: () =>
                                setState(() => _showRestTimer = false),
                            onSkip: () =>
                                setState(() => _showRestTimer = false),
                          ),
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
                              'Skip exercise',
                              style: AppTextStyles.body(AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          TextButton(
                            onPressed: _endWorkout,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stop_circle_outlined,
                                    color: AppColors.coral, size: 14),
                                const SizedBox(width: 4),
                                Text('End workout',
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
