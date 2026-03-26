import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_card.dart';
import '../../shared/widgets/forja_pill.dart';
import '../../shared/widgets/stat_card.dart';
import 'progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressProvider);

    if (!state.isLoading && state.workoutCount == 0) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress',
                        style:
                            AppTextStyles.displayLarge(AppColors.textPrimary)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_currentWeekLabel(),
                        style: AppTextStyles.body(AppColors.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: ForjaCard(
                      child: Text(
                        'Log your first workout to see progress.',
                        style: AppTextStyles.body(AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Ambient top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.ambientGradient,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text('Progress',
                      style:
                          AppTextStyles.displayLarge(AppColors.textPrimary))
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_currentWeekLabel(),
                      style: AppTextStyles.body(AppColors.textSecondary))
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 350.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // 2x2 stat grid
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Volume',
                          value: (state.totalVolumeKg / 1000)
                              .toStringAsFixed(1),
                          pillLabel: 'tonnes',
                          pillBg: AppColors.accentDim,
                          pillFg: AppColors.accent,
                        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          label: 'Workouts',
                          value: state.workoutCount.toString(),
                          pillLabel: 'sessions',
                          pillBg: AppColors.skyDim,
                          pillFg: AppColors.sky,
                        ).animate().fadeIn(delay: 210.ms, duration: 400.ms),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Streak',
                          value: '${state.streakWeeks} wk',
                          pillLabel:
                              state.streakWeeks > 0 ? 'ongoing' : '-',
                          pillBg: AppColors.warmDim,
                          pillFg: AppColors.warm,
                        ).animate().fadeIn(delay: 270.ms, duration: 400.ms),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          label: 'New PRs',
                          value: state.prsThisWeek.toString(),
                          pillLabel: 'this week',
                          pillBg: AppColors.coralDim,
                          pillFg: AppColors.coral,
                        ).animate().fadeIn(delay: 330.ms, duration: 400.ms),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.section),

                  // Volume bar chart
                  _VolumeBarChart(volumes: state.weeklyVolumes)
                      .animate()
                      .fadeIn(delay: 380.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.section),

                  // PR celebration card
                  if (state.recentPRs.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.warmDim,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.warm.withValues(alpha: 0.25),
                          width: 0.5,
                        ),
                        boxShadow: AppColors.warmShadow,
                      ),
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New PR!',
                                  style:
                                      AppTextStyles.bodyStrong(AppColors.warm),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatExerciseName(state.recentPRs.first['exercise_id'] as String)} ${state.recentPRs.first['weight_kg']}kg × ${state.recentPRs.first['reps']}',
                                  style: AppTextStyles.body(
                                      AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 430.ms, duration: 400.ms)
                        .shimmer(
                          delay: 800.ms,
                          duration: 1800.ms,
                          color: AppColors.warm.withValues(alpha: 0.12),
                        ),
                    const SizedBox(height: AppSpacing.section),
                  ],

                  // 1RM trends
                  Text(
                    '1RM TRENDS',
                    style: AppTextStyles.labelUppercase(
                        AppColors.textSecondary),
                  ).animate().fadeIn(delay: 480.ms, duration: 300.ms),
                  const SizedBox(height: AppSpacing.md),
                  ForjaCard(
                    shadows: AppColors.subtleShadow,
                    child: Column(
                      children: state.liftTrends.asMap().entries.map((entry) {
                        final index = entry.key;
                        final trend = entry.value;
                        final color = _getTrendColor(index);
                        return Column(
                          children: [
                            _LiftTrendRow(
                              name: trend.exerciseName,
                              current: trend.currentOneRepMax,
                              trendVal: trend.trendKg,
                              color: color,
                            ),
                            if (index < state.liftTrends.length - 1)
                              const SizedBox(height: AppSpacing.lg),
                          ],
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 520.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _currentWeekLabel() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 4);
    final weekNum =
        ((now.difference(startOfYear).inDays) / 7).ceil();
    return 'Week $weekNum · Getting stronger';
  }

  String _formatExerciseName(String id) {
    final parts = id.split('_');
    return parts
        .map((p) => p.isEmpty
            ? ''
            : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  Color _getTrendColor(int index) {
    const colors = [
      AppColors.accent,
      AppColors.sky,
      AppColors.warm,
      AppColors.coral,
    ];
    return colors[index % colors.length];
  }
}

class _VolumeBarChart extends StatelessWidget {
  final List<double> volumes;

  const _VolumeBarChart({required this.volumes});

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _chartHeight = 110.0;

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;

    double maxVolume =
        volumes.fold(0.0, (val, el) => val > el ? val : el);
    if (maxVolume == 0) maxVolume = 1000.0;

    return ForjaCard(
      shadows: AppColors.subtleShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Volume',
                style: AppTextStyles.bodyStrong(AppColors.textPrimary),
              ),
              Text(
                'kg',
                style: AppTextStyles.caption(AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final volume = volumes[i];
              final isToday = i == todayIndex;
              final barHeight = volume > 0
                  ? (_chartHeight * (volume / maxVolume))
                      .clamp(10.0, _chartHeight)
                  : 10.0;
              final isEmpty = volume == 0;

              return _Bar(
                height: barHeight,
                maxHeight: _chartHeight,
                label: _labels[i],
                isToday: isToday,
                isEmpty: isEmpty,
                index: i,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final double maxHeight;
  final String label;
  final bool isToday;
  final bool isEmpty;
  final int index;

  const _Bar({
    required this.height,
    required this.maxHeight,
    required this.label,
    required this.isToday,
    required this.isEmpty,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: maxHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 350 + index * 60),
              curve: Curves.easeOutCubic,
              width: 26,
              height: height,
              decoration: BoxDecoration(
                gradient: isToday ? AppColors.heroGradient : null,
                color: isToday ? null : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isToday ? AppColors.accentShadow : null,
              ),
            ).animate().scaleY(
                  begin: 0,
                  end: 1,
                  alignment: Alignment.bottomCenter,
                  duration: Duration(milliseconds: 450 + index * 50),
                  curve: Curves.easeOutCubic,
                  delay: Duration(milliseconds: 380 + index * 45),
                ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isToday ? AppColors.accent : AppColors.textTertiary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _LiftTrendRow extends StatelessWidget {
  final String name;
  final double current;
  final double trendVal;
  final Color color;

  const _LiftTrendRow({
    required this.name,
    required this.current,
    required this.trendVal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (current == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: AppTextStyles.bodyStrong(AppColors.textPrimary)),
          Text('No data yet',
              style: AppTextStyles.caption(AppColors.textSecondary)),
        ],
      );
    }

    final maxUi = current * 1.2;
    final progress = (current / maxUi).clamp(0.0, 1.0);
    final trendStr = trendVal > 0
        ? '+${trendVal.toStringAsFixed(1)}'
        : (trendVal < 0 ? trendVal.toStringAsFixed(1) : '—');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style: AppTextStyles.bodyStrong(AppColors.textPrimary)),
            Row(
              children: [
                Text(
                  '${current.toStringAsFixed(0)} kg',
                  style: AppTextStyles.bodyStrong(AppColors.textSecondary),
                ),
                const SizedBox(width: AppSpacing.sm),
                ForjaPill(
                  label: trendVal != 0 ? '↑ $trendStr kg' : '—',
                  backgroundColor: color.withValues(alpha: 0.15),
                  textColor: color,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.bgElevated,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
