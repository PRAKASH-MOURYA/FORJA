import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../shared/widgets/premium_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/repositories/workout_repository.dart';
import '../../shared/providers/auth_provider.dart';
import 'progress_provider.dart';
import 'progress_utils.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedPeriod = 0; // 0=7D, 1=30D, 2=90D, 3=All
  String _selectedLift = 'Bench Press';

  static const _periods = ['7D', '30D', '90D', 'All'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressProvider);

    if (!state.isLoading && state.workoutCount == 0) {
      return Scaffold(
        backgroundColor: context.appBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress',
                    style: AppTextStyles.displayLarge(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text('Start training to see your progress',
                    style: AppTextStyles.body(context.appTextSecondary)),
                const Spacer(),
                Center(
                  child: PremiumCard(
                    child: Column(
                      children: [
                        const Text('📊', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Log your first workout to see progress.',
                          style: AppTextStyles.body(context.appTextSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    // Volume delta (this week vs last week)
    final workoutRepo = WorkoutRepository();
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final thisWeekLogs = workoutRepo.getForWeek(weekStart);
    final lastWeekLogs = workoutRepo.getForWeek(lastWeekStart);
    final delta = volumeDeltaLabel(thisWeekLogs, lastWeekLogs);

    // Lift names from real data
    final liftNames = state.liftTrends.map((t) => t.exerciseName).toList();
    if (liftNames.isNotEmpty && !liftNames.contains(_selectedLift)) {
      _selectedLift = liftNames.first;
    }

    // Consistency grid from real data
    final allLogs = workoutRepo.getAll();
    final profile = ref.watch(userProfileProvider);
    final weekdayMap = profile?.customSplitId != null ? <int, int>{} : null;

    return Scaffold(
      backgroundColor: context.appBg,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.ambientGradient),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER + PERIOD SELECTOR ───────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text('Progress',
                            style: AppTextStyles.displayLarge(
                                context.appTextPrimary)),
                      ),
                      _PeriodSelector(
                        periods: _periods,
                        selected: _selectedPeriod,
                        onSelect: (i) => setState(() => _selectedPeriod = i),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── SUMMARY CARDS ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          label: 'Volume',
                          value:
                              '${(state.totalVolumeKg / 1000).toStringAsFixed(1)}T',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _MiniStatCard(
                          label: 'Sessions',
                          value: state.workoutCount.toString(),
                          color: AppColors.sky,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _MiniStatCard(
                          label: 'PRs',
                          value: state.prsThisWeek.toString(),
                          color: AppColors.warm,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 80.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── VOLUME BAR CHART ────────────────────────────────────
                  SectionHeader(
                    'Weekly Volume',
                    subtitle: delta ?? 'kg per session',
                  ),
                  PremiumCard(
                    child: _VolumeBarChart(volumes: state.weeklyVolumes),
                  ).animate().fadeIn(delay: 160.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── STRENGTH TRENDS ─────────────────────────────────────
                  if (liftNames.isNotEmpty) ...[
                    SectionHeader('Strength Trends',
                        subtitle: 'My lifts',
                        actionLabel: 'See all',
                        onAction: () {}),
                    _LiftSelector(
                      lifts: liftNames,
                      selected: _selectedLift,
                      onSelect: (l) => setState(() => _selectedLift = l),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PremiumCard(
                      child: _StrengthLineChart(
                        liftTrend: state.liftTrends.firstWhere(
                          (t) => t.exerciseName == _selectedLift,
                          orElse: () => state.liftTrends.first,
                        ),
                      ),
                    ).animate().fadeIn(delay: 240.ms, duration: 400.ms),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // ── PERSONAL RECORDS ───────────────────────────────────
                  const SectionHeader('Personal Records'),
                  ...state.liftTrends.asMap().entries.map((entry) {
                    final i = entry.key;
                    final trend = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _PrCard(
                        exerciseName: trend.exerciseName,
                        weightKg: trend.currentOneRepMax,
                        trendKg: trend.trendKg,
                        colorIndex: i,
                        isNew: i == 0 && state.prsThisWeek > 0,
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 300 + i * 60),
                            duration: 400.ms,
                          ),
                    );
                  }),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── CONSISTENCY HEATMAP ────────────────────────────────
                  const SectionHeader('Consistency',
                      subtitle: '12-week grid'),
                  PremiumCard(
                    child: _ConsistencyHeatmap(
                      logs: allLogs,
                      weekdayMap: weekdayMap,
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PERIOD SELECTOR ──────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final int selected;
  final ValueChanged<int> onSelect;

  const _PeriodSelector(
      {required this.periods, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.appBgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.appBorder, width: 0.5),
      ),
      child: Row(
        children: periods.asMap().entries.map((e) {
          final isSelected = e.key == selected;
          return GestureDetector(
            onTap: () => onSelect(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? context.appAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                e.value,
                style: AppTextStyles.micro(
                  isSelected ? context.appBg : context.appTextTertiary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── MINI STAT CARD ───────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.dataMedium(context.appTextPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.micro(color)),
        ],
      ),
    );
  }
}

// ── VOLUME BAR CHART ─────────────────────────────────────────────────────────

class _VolumeBarChart extends StatelessWidget {
  final List<double> volumes;

  const _VolumeBarChart({required this.volumes});

  @override
  Widget build(BuildContext context) {
    final todayIndex = DateTime.now().weekday - 1;
    double maxVal = volumes.fold(0.0, (a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 5000;

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => context.appBgElevated,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                '${(rod.toY / 1000).toStringAsFixed(1)}T',
                AppTextStyles.caption(context.appTextPrimary),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final i = value.toInt();
                  return Text(
                    labels[i.clamp(0, 6)],
                    style: AppTextStyles.micro(
                      i == todayIndex
                          ? context.appAccent
                          : context.appTextTertiary,
                    ),
                  );
                },
                reservedSize: 24,
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.appBorder,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: volumes.asMap().entries.map((e) {
            final isToday = e.key == todayIndex;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 18,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: isToday ? AppColors.accentGradient : null,
                  color: isToday ? null : context.appBgElevated,
                ),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }
}

// ── LIFT SELECTOR ─────────────────────────────────────────────────────────────

class _LiftSelector extends StatelessWidget {
  final List<String> lifts;
  final String selected;
  final ValueChanged<String> onSelect;

  const _LiftSelector(
      {required this.lifts, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: lifts.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final isSelected = lifts[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(lifts[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? context.appAccent : context.appBgCard,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected ? context.appAccent : context.appBorder,
                ),
              ),
              child: Text(
                lifts[i],
                style: AppTextStyles.caption(
                  isSelected ? context.appBg : context.appTextSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── STRENGTH LINE CHART ───────────────────────────────────────────────────────

class _StrengthLineChart extends StatelessWidget {
  final LiftTrend liftTrend;

  const _StrengthLineChart({required this.liftTrend});

  @override
  Widget build(BuildContext context) {
    // Build a simple two-point line from previous → current 1RM
    final data = [liftTrend.previousOneRepMax, liftTrend.currentOneRepMax];
    final validData = data.where((d) => d > 0).toList();
    if (validData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text('No data yet',
              style: AppTextStyles.body(context.appTextSecondary)),
        ),
      );
    }

    final lineColor = trendColor(validData);
    final spots = validData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final minY = validData.reduce((a, b) => a < b ? a : b) - 10;
    final maxY = validData.reduce((a, b) => a > b ? a : b) + 10;

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => context.appBgElevated,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(0)} kg',
                        AppTextStyles.caption(context.appTextPrimary),
                      ))
                  .toList(),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.appBorder,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            bottomTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: lineColor,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: context.appBgCard,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withValues(alpha: 0.25),
                    lineColor.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

// ── PR CARD ───────────────────────────────────────────────────────────────────

class _PrCard extends StatelessWidget {
  final String exerciseName;
  final double weightKg;
  final double trendKg;
  final int colorIndex;
  final bool isNew;

  const _PrCard({
    required this.exerciseName,
    required this.weightKg,
    required this.trendKg,
    required this.colorIndex,
    this.isNew = false,
  });

  static const _colors = [
    AppColors.accent,
    AppColors.sky,
    AppColors.warm,
    AppColors.coral,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[colorIndex % _colors.length];
    if (weightKg == 0) return const SizedBox.shrink();

    return PremiumCard(
      showGradientBorder: isNew,
      boxShadow: isNew ? AppColors.fireGlow : AppColors.subtleShadow,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  style:
                      AppTextStyles.bodyStrong(context.appTextPrimary),
                ),
                if (trendKg > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+${trendKg.toStringAsFixed(1)} kg since last month',
                    style: AppTextStyles.caption(AppColors.positive),
                  ),
                ] else if (trendKg < 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${trendKg.toStringAsFixed(1)} kg since last month',
                    style: AppTextStyles.caption(AppColors.danger),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.heroGradient.createShader(bounds),
                child: Text(
                  '${weightKg.toStringAsFixed(0)}kg',
                  style: AppTextStyles.dataMedium(Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isNew
                      ? AppColors.warm.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  isNew ? 'NEW' : 'PR',
                  style: AppTextStyles.micro(isNew ? AppColors.warm : color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── CONSISTENCY HEATMAP ───────────────────────────────────────────────────────

class _ConsistencyHeatmap extends StatelessWidget {
  final List<dynamic> logs;
  final Map<int, int>? weekdayMap;

  const _ConsistencyHeatmap({required this.logs, this.weekdayMap});

  @override
  Widget build(BuildContext context) {
    // Build real 12-week grid from workout logs
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    // Start of the current week (Monday)
    final currentWeekStart =
        todayOnly.subtract(Duration(days: todayOnly.weekday - 1));
    // We want 12 weeks ending at current week
    final gridStart = currentWeekStart.subtract(const Duration(days: 77)); // 11 weeks back

    final grid = List.generate(12, (week) {
      return List.generate(7, (day) {
        final date = gridStart.add(Duration(days: week * 7 + day));
        return classifyDay(date, logs.cast(), weekdayMap);
      });
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: AppTextStyles.micro(
                              context.appTextTertiary)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        ...grid.map(
          (week) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: week
                  .map((cell) => Expanded(
                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 2),
                          height: 14,
                          decoration: BoxDecoration(
                            color: _cellColor(cell, context),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less',
                style: AppTextStyles.micro(context.appTextTertiary)),
            const SizedBox(width: 6),
            ...List.generate(
              4,
              (i) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  color: context.appAccent
                      .withValues(alpha: 0.2 + i * 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('More',
                style: AppTextStyles.micro(context.appTextTertiary)),
          ],
        ),
      ],
    );
  }

  Color _cellColor(CellState cell, BuildContext context) {
    switch (cell) {
      case CellState.workout:
        return context.appAccent;
      case CellState.missed:
        return AppColors.danger.withValues(alpha: 0.4);
      case CellState.neutral:
        return context.appBgElevated;
    }
  }
}
