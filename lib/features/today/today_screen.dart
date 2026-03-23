import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_button.dart';
import '../../shared/widgets/forja_pill.dart';
import '../../shared/widgets/exercise_row.dart';
import '../../shared/repositories/workout_repository.dart';
import '../../shared/repositories/pr_repository.dart';
import '../../shared/models/exercise.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/adaptive_today_provider.dart';
import '../../shared/providers/readiness_provider.dart';
import '../../shared/models/readiness_score.dart';
import '../../shared/services/muscle_recovery_service.dart';
import '../exercise/exercise_demo_sheet.dart';
import 'rest_day_content.dart';
import 'widgets/pr_to_beat_card.dart';
import 'widgets/recovery_heatmap_card.dart';



class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final profileName = profile?.name;
    final adaptivePlan = ref.watch(adaptiveTodayProvider);
    final readiness = ref.watch(readinessProvider);
    final now = DateTime.now();
    final dayName = _dayName(now.weekday).toUpperCase();
    final dateStr =
        '$dayName, ${_monthName(now.month).toUpperCase()} ${now.day}';

    if (adaptivePlan == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    final plan = adaptivePlan.basePlan;

    final sessionExercises = plan.exercises
        .where((e) => !adaptivePlan.isExerciseRemoved(e.id))
        .toList();

    // --- Pre-workout data (synchronous Hive reads) ---
    final workoutRepo = WorkoutRepository();
    final prRepo = PrRepository();
    final allLogs = workoutRepo.getAll();

    // lastSessionSubtitles: exerciseId -> "Last: Xkg × Y"
    final Map<String, String> lastSessionSubtitles = {};
    for (final exercise in sessionExercises) {
      for (final log in allLogs) {
        final sets = workoutRepo
            .getSetsForWorkout(log.id)
            .where((s) => s.exerciseId == exercise.id && s.completed)
            .toList();

        if (sets.isEmpty) continue;

        // Use the highest-weight completed set as representative.
        final best = sets.reduce((a, b) => a.weightKg > b.weightKg ? a : b);
        lastSessionSubtitles[exercise.id] =
            'Last: ${best.weightKg.toStringAsFixed(0)}kg × ${best.reps}';
        break; // most recent log found — stop scanning
      }
    }

    // PR to Beat: find the best current PR opportunity across today's exercises.
    String? prExerciseName;
    double prCurrentKg = 0;
    for (final exercise in sessionExercises) {
      final pr = prRepo.getLatestPRForExercise(exercise.id);
      if (pr == null) continue;

      final weightKg = (pr['weight_kg'] as num).toDouble();
      if (prExerciseName == null || weightKg > prCurrentKg) {
        prExerciseName = exercise.name;
        prCurrentKg = weightKg;
      }
    }
    final prTargetKg = prCurrentKg + 2.5;

    // Recovery heatmap
    final recoveryService = MuscleRecoveryService();
    final recoveryStatuses = recoveryService.getRecoveryStatuses();
    final recoverySummary = recoveryService.summaryText(recoveryStatuses);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateStr,
                                  style: AppTextStyles.caption(
                                      AppColors.textSecondary)),
                              const SizedBox(height: AppSpacing.xs),
                              Text(plan.dayName,
                                  style: AppTextStyles.display(
                                      AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        // Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius:
                                BorderRadius.circular(AppRadius.circle),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            (profileName != null && profileName.isNotEmpty)
                                ? profileName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.bg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Pills row
                    const Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        ForjaPill.accent(label: 'Day 3 of 4'),
                        ForjaPill(label: '~52 min'),
                        ForjaPill.warm(label: 'Ready'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Readiness banner
                    _readinessBanner(readiness),
                    if (adaptivePlan.whyMessage != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _whyBanner(adaptivePlan.whyMessage!),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    // Section label
                    Text('EXERCISES',
                        style: AppTextStyles.labelUppercase(
                            AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
            if (adaptivePlan.isRestDay)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                sliver: SliverToBoxAdapter(
                  child: RestDayContent(
                    workoutsThisWeek: adaptivePlan.workoutsThisWeek,
                    setsThisWeek: adaptivePlan.setsThisWeek,
                    volumeKgThisWeek: adaptivePlan.volumeKgThisWeek,
                  ),
                ),
              )
            else ...[
              // Exercise list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exercise = sessionExercises[index];
                      return ExerciseRow(
                        exercise: exercise,
                        index: index,
                        onTap: () => _showDemoSheet(context, exercise),
                        lastSessionSubtitle:
                            lastSessionSubtitles[exercise.id],
                      );
                    },
                    childCount: sessionExercises.length,
                  ),
                ),
              ),
              // PR to Beat Card
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: prExerciseName != null
                      ? PrToBeatCard(
                          exerciseName: prExerciseName,
                          currentPrKg: prCurrentKg,
                          targetKg: prTargetKg,
                        )
                      : const PrToBeatCard.empty(),
                ),
              ),
              // Recovery Heatmap
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.sm,
                  AppSpacing.xxl,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: RecoveryHeatmapCard(
                    statuses: recoveryStatuses,
                    summaryText: recoverySummary,
                  ),
                ),
              ),
              // Start button
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: ForjaButton(
                    label: 'Start Workout',
                    onPressed: () => context.push('/workout', extra: {
                      'exercises': sessionExercises,
                      'dayName': plan.dayName,
                    }),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDemoSheet(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseDemoSheet(exercise: exercise),
    );
  }

  Widget _whyBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body(AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readinessBanner(ReadinessScore? readiness) {
    if (readiness == null) return const SizedBox.shrink();

    final Color zoneColor = switch (readiness.zone) {
      'green' => AppColors.accent,
      'yellow' => AppColors.warm,
      'red' => AppColors.coral,
      _ => AppColors.accent,
    };
    final Color zoneBg = switch (readiness.zone) {
      'green' => AppColors.accentGlow,
      'yellow' => AppColors.warmDim,
      'red' => AppColors.coralDim,
      _ => AppColors.accentGlow,
    };
    final Color zoneBorder = zoneColor.withAlpha(
      (zoneColor.a * 255.0 * 0.3).round().clamp(0, 255),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: zoneBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: zoneBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: zoneColor,
              borderRadius: BorderRadius.circular(AppRadius.circle),
              boxShadow: [
                BoxShadow(
                  color:
                      zoneColor.withAlpha(
                        (zoneColor.a * 255.0 * 0.4).round().clamp(0, 255),
                      ),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Readiness: ${readiness.score}',
                  style: AppTextStyles.bodyStrong(zoneColor),
                ),
                const SizedBox(height: 2),
                Text(
                  readiness.description,
                  style: AppTextStyles.body(AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[(weekday - 1).clamp(0, 6)];
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
