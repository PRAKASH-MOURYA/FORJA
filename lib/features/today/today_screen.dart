import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/exercise_row.dart';
import '../../shared/widgets/section_header.dart';
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
import 'widgets/connect_health_nudge_card.dart';
import '../../shared/providers/wearable_provider.dart';
import 'widgets/plate_visual_card.dart';
import 'widgets/protein_target_card.dart';
import 'widgets/hero_workout_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/quick_actions_row.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TodayScreen extends HookConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final profileName = profile?.name;
    final adaptivePlan = ref.watch(adaptiveTodayProvider);
    final readiness = ref.watch(readinessProvider);

    final nudgeDismissed = useState(false);
    final permissionDenied =
        ref.watch(wearablePermissionDeniedProvider).valueOrNull ?? false;

    final now = DateTime.now();
    final dayOfWeek = _dayName(now.weekday).toUpperCase();
    final greeting = _greeting(now.hour);

    if (adaptivePlan == null) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }
    final plan = adaptivePlan.basePlan;
    final sessionExercises = plan.exercises
        .where((e) => !adaptivePlan.isExerciseRemoved(e.id))
        .toList();

    final workoutRepo = WorkoutRepository();
    final prRepo = PrRepository();
    final allLogs = workoutRepo.getAll();

    final Map<String, String> lastSessionSubtitles = {};
    final Map<String, String> prSubtitles = {};
    for (final exercise in sessionExercises) {
      for (final log in allLogs) {
        final sets = workoutRepo
            .getSetsForWorkout(log.id)
            .where((s) => s.exerciseId == exercise.id && s.completed)
            .toList();
        if (sets.isEmpty) continue;
        final best = sets.reduce((a, b) => a.weightKg > b.weightKg ? a : b);
        lastSessionSubtitles[exercise.id] =
            'Last: ${best.weightKg.toStringAsFixed(0)}kg × ${best.reps}';
        break;
      }
      final pr = prRepo.getLatestPRForExercise(exercise.id);
      if (pr != null) {
        final weightKg = (pr['weight_kg'] as num).toDouble();
        prSubtitles[exercise.id] = 'PR: ${weightKg.toStringAsFixed(0)} kg';
      }
    }

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

    final recoveryService = MuscleRecoveryService();
    final recoveryStatuses = recoveryService.getRecoveryStatuses();
    final recoverySummary = recoveryService.summaryText(recoveryStatuses);

    final streakWeeks = profile?.streakWeeks ?? 0;
    final xp = profile?.xp ?? 0;
    final volumeTonnes = adaptivePlan.volumeKgThisWeek / 1000;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bg : AppColors.bgLight,
      body: Stack(
        children: [
          // Ambient gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.ambientGradient,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── HERO HEADER ──────────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dayOfWeek,
                                    style: AppTextStyles.labelUppercase(
                                      isDark
                                          ? AppColors.textTertiary
                                          : AppColors.textTertiaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$greeting, ${profileName?.split(' ').first ?? 'Athlete'}',
                                    style: AppTextStyles.headingLarge(
                                      isDark
                                          ? AppColors.textPrimary
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            // Notification bell
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.bgCard
                                    : AppColors.bgCardLight,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.border
                                      : AppColors.borderLight,
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            // Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.heroGradient,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.circle),
                                boxShadow: AppColors.accentShadow,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                profileName?.isNotEmpty == true
                                    ? profileName![0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.bg,
                                ),
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: AppSpacing.xl),

                        // ── READINESS BANNER ─────────────────────────────────
                        if (permissionDenied && !nudgeDismissed.value) ...[
                          ConnectHealthNudgeCard(
                            onDismiss: () => nudgeDismissed.value = true,
                          ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
                          const SizedBox(height: AppSpacing.sm),
                        ],

                        _readinessBanner(readiness)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms),

                        if (adaptivePlan.whyMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _whyBanner(adaptivePlan.whyMessage!, isDark),
                        ],

                        if (readiness != null ||
                            (permissionDenied && !nudgeDismissed.value) ||
                            adaptivePlan.whyMessage != null)
                          const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),

                if (adaptivePlan.isRestDay)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl),
                    sliver: SliverToBoxAdapter(
                      child: RestDayContent(
                        workoutsThisWeek: adaptivePlan.workoutsThisWeek,
                        setsThisWeek: adaptivePlan.setsThisWeek,
                        volumeKgThisWeek: adaptivePlan.volumeKgThisWeek,
                      ),
                    ),
                  )
                else ...[
                  // ── HERO WORKOUT CARD ────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl),
                    sliver: SliverToBoxAdapter(
                      child: HeroWorkoutCard(
                        dayName: plan.dayName,
                        exercises: sessionExercises,
                        onStart: () => context.push('/workout', extra: {
                          'exercises': sessionExercises,
                          'dayName': plan.dayName,
                        }),
                      )
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 450.ms)
                          .slideY(
                              begin: 0.06,
                              end: 0,
                              delay: 120.ms,
                              duration: 450.ms,
                              curve: Curves.easeOutCubic),
                    ),
                  ),

                  // ── STATS ROW ────────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, 0),
                    sliver: SliverToBoxAdapter(
                      child: StatsRow(
                        streakWeeks: streakWeeks,
                        xp: xp,
                        volumeTonnes: volumeTonnes,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms),
                    ),
                  ),

                  // ── EXERCISES ────────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 0),
                    sliver: SliverToBoxAdapter(
                      child: SectionHeader(
                        'Today\'s Exercises',
                        subtitle: '${sessionExercises.length} movements',
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final exercise = sessionExercises[index];
                          return ExerciseRow(
                            exercise: exercise,
                            index: index,
                            onTap: () => _showDemoSheet(context, exercise),
                            prSubtitle: prSubtitles[exercise.id],
                            lastSessionSubtitle:
                                lastSessionSubtitles[exercise.id],
                          );
                        },
                        childCount: sessionExercises.length,
                      ),
                    ),
                  ),

                  // ── PR TO BEAT ───────────────────────────────────────────
                  if (prExerciseName != null)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, 0),
                      sliver: SliverToBoxAdapter(
                        child: PrToBeatCard(
                          exerciseName: prExerciseName,
                          currentPrKg: prCurrentKg,
                          targetKg: prTargetKg,
                        )
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms),
                      ),
                    ),

                  // ── RECOVERY HEATMAP ─────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader('Recovery Status',
                              subtitle: 'Updated 2h ago'),
                          RecoveryHeatmapCard(
                            statuses: recoveryStatuses,
                            summaryText: recoverySummary,
                          ),
                        ],
                      ).animate().fadeIn(delay: 360.ms, duration: 400.ms),
                    ),
                  ),

                  // ── NUTRITION ────────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, 0),
                    sliver: SliverToBoxAdapter(
                      child: ProteinTargetCard(profile: profile)
                          .animate()
                          .fadeIn(delay: 420.ms, duration: 400.ms),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, 0),
                    sliver: SliverToBoxAdapter(
                      child: PlateVisualCard(
                              isRestDay: adaptivePlan.isRestDay)
                          .animate()
                          .fadeIn(delay: 460.ms, duration: 400.ms),
                    ),
                  ),

                  // ── QUICK ACTIONS ─────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader('Quick Access'),
                          const QuickActionsRow(),
                        ],
                      ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                    ),
                  ),

                  // ── BOTTOM PADDING ────────────────────────────────────────
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: AppSpacing.section),
                  ),
                ],
              ],
            ),
          ),
        ],
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

  Widget _whyBanner(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgElevated : AppColors.bgElevatedLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTextStyles.body(AppColors.textSecondary)),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: zoneBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: zoneColor.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: zoneColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: zoneColor.withValues(alpha: 0.5),
                  blurRadius: 8,
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
                Text('Readiness: ${readiness.score}',
                    style: AppTextStyles.bodyStrong(zoneColor)),
                const SizedBox(height: 2),
                Text(readiness.description,
                    style: AppTextStyles.body(AppColors.textSecondary)),
                if (readiness.sources?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(readiness.sources!,
                      style: AppTextStyles.micro(AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _dayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday'];
    return days[(weekday - 1).clamp(0, 6)];
  }
}
