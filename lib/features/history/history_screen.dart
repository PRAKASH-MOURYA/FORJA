import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_card.dart';
import '../../shared/widgets/forja_pill.dart';
import '../../shared/models/workout_log.dart';
import 'history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
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
                    Text(
                      'History',
                      style: AppTextStyles.displayLarge(AppColors.textPrimary),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _currentWeekLabel(),
                      style: AppTextStyles.body(AppColors.textSecondary),
                    ).animate().fadeIn(delay: 80.ms, duration: 350.ms),
                    const SizedBox(height: AppSpacing.xxl),
                    _WeeklyCalendarCard(workouts: state.workouts)
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.05,
                          end: 0,
                          delay: 150.ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'PAST WORKOUTS',
                      style: AppTextStyles.labelUppercase(
                          AppColors.textSecondary),
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              sliver: state.workouts.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Text(
                            'No workouts logged yet — tap Today to start.',
                            style:
                                AppTextStyles.body(AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate(
                        _buildWorkoutCards(state.workouts, state.recentPRs),
                      ),
                    ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }

  String _currentWeekLabel() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 4);
    final weekNum =
        ((now.difference(startOfYear).inDays) / 7).ceil();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return 'Week $weekNum · ${months[now.month - 1]} ${now.year}';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    return '$m min';
  }

  String _formatDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[dt.weekday - 1]} ${months[dt.month - 1]} ${dt.day}';
  }

  String? _prBadgeForDate(
      List<Map<String, dynamic>> prs, DateTime workoutDate) {
    for (final pr in prs) {
      final achievedAt =
          DateTime.parse(pr['achieved_at'] as String);
      if (achievedAt.year == workoutDate.year &&
          achievedAt.month == workoutDate.month &&
          achievedAt.day == workoutDate.day) {
        return '${_formatExerciseName(pr['exercise_id'] as String)} ${pr['weight_kg']}kg × ${pr['reps']}';
      }
    }
    return null;
  }

  String _formatExerciseName(String id) {
    final parts = id.split('_');
    return parts
        .map((p) => p.isEmpty
            ? ''
            : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  List<Widget> _buildWorkoutCards(
      List<WorkoutLog> workouts, List<Map<String, dynamic>> prs) {
    return workouts.asMap().entries.map((entry) {
      final index = entry.key;
      final log = entry.value;
      final prBadge = _prBadgeForDate(prs, log.startedAt);

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ForjaCard(
          shadows: AppColors.subtleShadow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      log.programDayName,
                      style: AppTextStyles.subhead(AppColors.textPrimary),
                    ),
                  ),
                  if (prBadge != null)
                    ForjaPill(
                      label: '🏆 $prBadge',
                      backgroundColor: AppColors.warmDim,
                      textColor: AppColors.warm,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDate(log.startedAt),
                style: AppTextStyles.caption(AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: _formatDuration(log.durationSeconds),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _StatChip(
                    icon: Icons.fitness_center_rounded,
                    label: '${log.totalSets} sets',
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _StatChip(
                    icon: Icons.bar_chart_rounded,
                    label: '${log.totalVolumeKg.toInt()} kg',
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 250 + index * 70),
            duration: 400.ms,
          )
          .slideY(
            begin: 0.05,
            end: 0,
            delay: Duration(milliseconds: 250 + index * 70),
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          );
    }).toList();
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 14),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption(AppColors.textSecondary)),
      ],
    );
  }
}

class _WeeklyCalendarCard extends StatelessWidget {
  final List<WorkoutLog> workouts;

  const _WeeklyCalendarCard({required this.workouts});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final weekStart = now.subtract(Duration(days: todayWeekday - 1));

    return ForjaCard(
      shadows: AppColors.cardShadow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final weekday = i + 1;
          final isToday = weekday == todayWeekday;
          final dayDate = weekStart.add(Duration(days: i));
          final hasWorkout = workouts.any((w) =>
              w.startedAt.year == dayDate.year &&
              w.startedAt.month == dayDate.month &&
              w.startedAt.day == dayDate.day);

          return Column(
            children: [
              Text(
                _dayLabels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? AppColors.accent
                      : AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: isToday ? AppColors.heroGradient : null,
                  color: isToday ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.circle),
                  boxShadow: isToday ? AppColors.accentShadow : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${dayDate.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? AppColors.bg
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: hasWorkout ? 6 : 4,
                height: hasWorkout ? 6 : 4,
                decoration: BoxDecoration(
                  color: hasWorkout
                      ? AppColors.accent
                      : AppColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.circle),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
