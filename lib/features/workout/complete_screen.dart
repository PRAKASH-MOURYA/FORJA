import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_button.dart';
import '../../shared/widgets/forja_card.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/checkin_slider.dart';
import '../../shared/widgets/celebration_overlay.dart';
import '../../shared/models/check_in.dart';
import '../../shared/providers/workout_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/readiness_provider.dart';
import '../../shared/repositories/checkin_repository.dart';
import '../../shared/repositories/workout_repository.dart';
import '../../shared/services/streak_service.dart';
import '../../shared/services/xp_service.dart';
import '../../shared/services/pr_card_service.dart';
import '../../shared/services/calculation_service.dart';
import '../../shared/services/notification_service.dart';
import '../pr_card/pr_card_widget.dart';
import '../history/history_provider.dart';
import '../progress/progress_provider.dart';
import '../profile/profile_stats_provider.dart';

class CompleteScreen extends ConsumerStatefulWidget {
  const CompleteScreen({super.key});

  @override
  ConsumerState<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends ConsumerState<CompleteScreen> {
  final _prCardKey = GlobalKey();
  int _energy = 3;
  bool _celebrationShown = false;
  int _soreness = 3;
  int _mood = 3;
  bool _isSaving = false;

  Future<void> _saveAndFinish() async {
    setState(() => _isSaving = true);
    try {
      final profile = ref.read(userProfileProvider);
      final workoutState = ref.read(workoutProvider);

      final checkIn = CheckIn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: profile?.id ?? 'guest',
        workoutLogId: workoutState.activeLog?.id,
        energy: _energy,
        soreness: _soreness,
        mood: _mood,
        createdAt: DateTime.now(),
      );

      await CheckInRepository().save(checkIn);

      await ref.read(userProfileProvider.notifier).update((p) {
        var updated = XpService.awardXp(p, 'workout');
        updated = XpService.awardXp(updated, 'checkin');

        final prCount = workoutState.newPRs.length;
        for (var i = 0; i < prCount; i++) {
          updated = XpService.awardXp(updated, 'pr');
        }

        final workoutDate = workoutState.activeLog?.startedAt ?? DateTime.now();
        final previousWorkout = WorkoutRepository()
            .getAll()
            .where((w) => w.id != workoutState.activeLog?.id)
            .toList();
        final lastDate = previousWorkout.isEmpty
            ? workoutDate.subtract(const Duration(days: 8))
            : previousWorkout.first.startedAt;

        return StreakService.evaluateStreak(
          updated,
          lastDate,
          now: workoutDate,
        );
      });

      final updatedProfile = ref.read(userProfileProvider);
      if ((updatedProfile?.xp ?? 0) <= 120) {
        await NotificationService.requestPermission();
      }
      await NotificationService.scheduleWorkoutReminder(
        const TimeOfDay(hour: 19, minute: 0),
      );

      ref.invalidate(historyProvider);
      ref.invalidate(progressProvider);
      ref.invalidate(profileStatsProvider);
      ref.invalidate(readinessProvider);
      if (mounted) context.go('/today');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(workoutProvider.notifier).reset();
      });
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  void _skip() {
    ref.invalidate(historyProvider);
    ref.invalidate(progressProvider);
    ref.invalidate(profileStatsProvider);
    context.go('/today');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutProvider.notifier).reset();
    });
  }

  Future<void> _sharePr() async {
    final workoutState = ref.read(workoutProvider);
    final prExerciseId = workoutState.newPRs.isNotEmpty ? workoutState.newPRs.first : null;
    if (prExerciseId == null) return;
    await PrCardService.sharePrCard(_prCardKey, context);
  }

  String _formatVolume(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)}t';
    }
    return '${kg.toStringAsFixed(0)} kg';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutProvider);
    final log = workoutState.activeLog;

    final durationStr =
        log != null ? _formatDuration(log.durationSeconds) : '48 min';
    final setsStr = '${workoutState.totalSets} sets';
    final volumeStr = _formatVolume(workoutState.totalVolume);
    final prsCount = workoutState.newPRs.length;

    final prExerciseId = prsCount > 0 ? workoutState.newPRs.first : null;
    final matchedNames = workoutState.exercises
        .where((e) => e.id == prExerciseId)
        .map((e) => e.name)
        .toList();
    final prExerciseName = matchedNames.isNotEmpty ? matchedNames.first : null;
    final prSets = workoutState.completedSets
        .where((s) => s.exerciseId == prExerciseId && s.completed)
        .toList();
    final estimatedOneRm = prSets.isEmpty
        ? 100.0
        : prSets
            .map((s) => CalculationService.oneRepMax(s.weightKg, s.reps))
            .reduce((a, b) => a > b ? a : b);
    final athleteName = ref.read(userProfileProvider)?.name ?? 'Athlete';

    if (!_celebrationShown) {
      _celebrationShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCelebrationOverlay(context);
      });
    }

    return Stack(
      children: [
        IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0,
            child: PrCardWidget(
              cardKey: _prCardKey,
              exerciseName: prExerciseName ?? 'PR',
              estimatedOneRmKg: estimatedOneRm,
              userName: athleteName,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.bg
              : AppColors.bgLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Success animation
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(AppRadius.circle),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 200.ms),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Workout Complete!',
                style: AppTextStyles.headingLarge(AppColors.textPrimary),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Push Day · $durationStr · $setsStr',
                style: AppTextStyles.body(AppColors.textSecondary),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.xxxl),
              // Stats row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Volume',
                      value: volumeStr,
                      pillLabel: 'kg lifted',
                      pillBg: AppColors.accentDim,
                      pillFg: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      label: 'Sets Done',
                      value: '${workoutState.totalSets}',
                      pillLabel: 'completed',
                      pillBg: AppColors.skyDim,
                      pillFg: AppColors.sky,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      label: 'New PRs',
                      value: '$prsCount',
                      pillLabel: prsCount == 1 ? 'PR' : 'PRs',
                      pillBg: AppColors.warmDim,
                      pillFg: AppColors.warm,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.15, end: 0),
              const SizedBox(height: AppSpacing.xxxl),
              // Quick check-in heading
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Check-in',
                  style: AppTextStyles.heading(AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ForjaCard(
                child: Column(
                  children: [
                    CheckInSlider(
                      label: 'Energy',
                      emojis: const ['😴', '😪', '😐', '😊', '🔥'],
                      value: _energy,
                      activeColor: AppColors.accent,
                      onChanged: (v) => setState(() => _energy = v),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CheckInSlider(
                      label: 'Soreness',
                      emojis: const ['😭', '😣', '😕', '🙂', '💪'],
                      value: _soreness,
                      activeColor: AppColors.coral,
                      onChanged: (v) => setState(() => _soreness = v),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CheckInSlider(
                      label: 'Mood',
                      emojis: const ['😞', '😟', '😐', '😊', '😄'],
                      value: _mood,
                      activeColor: AppColors.warm,
                      onChanged: (v) => setState(() => _mood = v),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.15, end: 0),
              const SizedBox(height: AppSpacing.xxl),
              ForjaButton(
                label: 'Save & Finish',
                isLoading: _isSaving,
                onPressed: _saveAndFinish,
              ),
              if (prsCount > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _sharePr,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share PR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent, width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip check-in',
                  style: AppTextStyles.body(AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
