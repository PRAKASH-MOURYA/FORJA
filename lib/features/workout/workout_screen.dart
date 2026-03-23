import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_button.dart';
import '../../shared/widgets/forja_card.dart';
import '../../shared/widgets/set_row.dart';
import '../../shared/widgets/rest_timer.dart';
import '../../shared/providers/workout_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/models/exercise.dart';
import '../../shared/models/set_log.dart';
import 'exercise_history_sheet.dart';
import 'session_guard_sheet.dart';

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

  // Per-set state: weights and reps for current exercise
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

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _currentSetIndex => _setsDone.indexWhere((done) => !done);
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

    // Auto-advance when all sets done
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

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutProvider);
    final exercise = workoutState.currentExercise;
    final exerciseIndex = workoutState.currentExerciseIndex;
    final totalExercises = workoutState.exercises.length;

    if (exercise == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) async {
        if (didPop) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) => SessionGuardSheet(
            onResume: () => Navigator.of(sheetContext).pop(),
            onDiscard: () {
              Navigator.of(sheetContext).pop();
              context.pop();
            },
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textSecondary, size: 18),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (sheetContext) => SessionGuardSheet(
                  onResume: () => Navigator.of(sheetContext).pop(),
                  onDiscard: () {
                    Navigator.of(sheetContext).pop();
                    context.pop();
                  },
                ),
              );
            },
          ),
          title: Text(
            widget.dayName,
            style: AppTextStyles.heading(AppColors.textPrimary),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Text(
                _formatTime(_elapsedSeconds),
                style: AppTextStyles.bodyStrong(AppColors.warm),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header (tappable for history).
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ExerciseHistorySheet(
                      exerciseId: exercise.id,
                      exerciseName: exercise.name,
                    ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.history,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Exercise ${exerciseIndex + 1} of $totalExercises · ${exercise.muscle}',
                style: AppTextStyles.body(AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Set logging card
              ForjaCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text('SET',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.labelUppercase(
                                    AppColors.textSecondary)),
                          ),
                          Expanded(
                            child: Text('KG',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.labelUppercase(
                                    AppColors.textSecondary)),
                          ),
                          Expanded(
                            child: Text('REPS',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.labelUppercase(
                                    AppColors.textSecondary)),
                          ),
                          const SizedBox(width: 28),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    // Set rows
                    ...List.generate(exercise.sets, (i) {
                      final isActive = i == _currentSetIndex;
                      final isDone = i < exercise.sets && _setsDone[i];
                      return SetRow(
                        setNumber: i + 1,
                        weightKg: _setWeights[i],
                        reps: _setReps[i],
                        isActive: isActive,
                        isDone: isDone,
                        onWeightChanged: (w) =>
                            setState(() => _setWeights[i] = w),
                        onRepsChanged: (r) =>
                            setState(() => _setReps[i] = r),
                        onToggleDone: () {
                          if (!isDone && i == _currentSetIndex) {
                            _logSet();
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Rest timer
              if (_showRestTimer)
                RestTimer(
                  totalSeconds: 90,
                  onComplete: () =>
                      setState(() => _showRestTimer = false),
                  onSkip: () => setState(() => _showRestTimer = false),
                ),
              const SizedBox(height: AppSpacing.lg),
              // Log set button
              if (!_allSetsDone)
                ForjaButton(
                  label: 'Log Set $_lastCompletedSet ✓',
                  onPressed: _currentSetIndex >= 0 ? _logSet : null,
                ),
              const SizedBox(height: AppSpacing.xxl),
              // Bottom actions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _advanceExercise,
                    child: const Text(
                      'Skip exercise',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  TextButton(
                    onPressed: _endWorkout,
                    child: const Text(
                      'End workout early',
                      style: TextStyle(
                        color: AppColors.coral,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
