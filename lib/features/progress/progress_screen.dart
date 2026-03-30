import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../shared/widgets/premium_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/constants/dummy_data.dart';
import 'progress_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedPeriod = 0; // 0=7D, 1=30D, 2=90D, 3=All
  String _selectedLift = 'Barbell Bench Press';

  static const _periods = ['7D', '30D', '90D', 'All'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bg : AppColors.bgLight;
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;

    if (!state.isLoading && state.workoutCount == 0) {
      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress',
                    style: AppTextStyles.displayLarge(textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text('Start training to see your progress',
                    style: AppTextStyles.body(isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight)),
                const Spacer(),
                Center(
                  child: PremiumCard(
                    child: Column(
                      children: [
                        const Text('📊',
                            style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Log your first workout to see progress.',
                          style: AppTextStyles.body(isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight),
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

    return Scaffold(
      backgroundColor: bg,
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
                            style: AppTextStyles.displayLarge(textPrimary)),
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
                          value: '${(state.totalVolumeKg / 1000).toStringAsFixed(1)}T',
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

                  // ── VOLUME BAR CHART (fl_chart) ────────────────────────
                  const SectionHeader('Weekly Volume',
                      subtitle: 'kg per session'),
                  PremiumCard(
                    child: _VolumeBarChart(
                      volumes: state.weeklyVolumes,
                      isDark: isDark,
                    ),
                  ).animate().fadeIn(delay: 160.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── STRENGTH TRENDS (fl_chart) ─────────────────────────
                  SectionHeader('Strength Trends', subtitle: 'My lifts',
                      actionLabel: 'See all', onAction: () {}),
                  _LiftSelector(
                    lifts: DummyData.strengthTrends.keys.toList(),
                    selected: _selectedLift,
                    onSelect: (l) => setState(() => _selectedLift = l),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PremiumCard(
                    child: _StrengthLineChart(
                      lift: _selectedLift,
                      isDark: isDark,
                    ),
                  ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── PERSONAL RECORDS ───────────────────────────────────
                  const SectionHeader('Personal Records'),
                  ...state.liftTrends.asMap().entries.map((entry) {
                    final i = entry.key;
                    final trend = entry.value;
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    child: _ConsistencyHeatmap(isDark: isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
          width: 0.5,
        ),
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
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                e.value,
                style: AppTextStyles.micro(
                  isSelected ? AppColors.bg : AppColors.textTertiary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              style: AppTextStyles.dataMedium(
                isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              )),
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
  final bool isDark;

  const _VolumeBarChart({required this.volumes, required this.isDark});

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
              getTooltipColor: (_) =>
                  isDark ? AppColors.bgElevated : AppColors.bgElevatedLight,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                '${(rod.toY / 1000).toStringAsFixed(1)}T',
                AppTextStyles.caption(AppColors.textPrimary),
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
                          ? AppColors.accent
                          : (isDark
                              ? AppColors.textTertiary
                              : AppColors.textTertiaryLight),
                    ),
                  );
                },
                reservedSize: 24,
              ),
            ),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark
                  ? AppColors.border
                  : AppColors.borderLight,
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
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                  gradient: isToday
                      ? AppColors.accentGradient
                      : null,
                  color: isToday
                      ? null
                      : (isDark
                          ? AppColors.bgElevated
                          : AppColors.bgElevatedLight),
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
                color: isSelected
                    ? AppColors.accent
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.bgCard
                        : AppColors.bgCardLight),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accent
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.border
                          : AppColors.borderLight),
                ),
              ),
              child: Text(
                lifts[i],
                style: AppTextStyles.caption(
                  isSelected ? AppColors.bg : AppColors.textSecondary,
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
  final String lift;
  final bool isDark;

  const _StrengthLineChart({required this.lift, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final data = DummyData.strengthTrends[lift] ?? [];
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Text('No data yet',
              style: AppTextStyles.body(AppColors.textSecondary)),
        ),
      );
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final minY = data.reduce((a, b) => a < b ? a : b) - 10;
    final maxY = data.reduce((a, b) => a > b ? a : b) + 10;

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? AppColors.bgElevated : AppColors.bgElevatedLight,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(0)} kg',
                        AppTextStyles.caption(AppColors.textPrimary),
                      ))
                  .toList(),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark ? AppColors.border : AppColors.borderLight,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) {
                  const labels = ['Wk1', 'Wk2', 'Wk3', 'Wk4'];
                  final i = val.toInt();
                  return Text(
                    i < labels.length ? labels[i] : '',
                    style: AppTextStyles.micro(
                      isDark
                          ? AppColors.textTertiary
                          : AppColors.textTertiaryLight,
                    ),
                  );
                },
                reservedSize: 24,
              ),
            ),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.accent,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.accent,
                  strokeWidth: 2,
                  strokeColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.25),
                    AppColors.accent.withValues(alpha: 0.0),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  style: AppTextStyles.bodyStrong(
                    isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ),
                ),
                if (trendKg > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+${trendKg.toStringAsFixed(1)} kg since last month',
                    style: AppTextStyles.caption(AppColors.accent),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isNew ? AppColors.warm.withValues(alpha: 0.2) : color.withValues(alpha: 0.12),
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
  final bool isDark;
  const _ConsistencyHeatmap({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final grid = DummyData.consistencyGrid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: AppTextStyles.micro(
                            isDark
                                ? AppColors.textTertiary
                                : AppColors.textTertiaryLight,
                          )),
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
                  .map((day) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 14,
                          decoration: BoxDecoration(
                            color: day == 1
                                ? AppColors.accent
                                : (isDark
                                    ? AppColors.bgElevated
                                    : AppColors.bgElevatedLight),
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
                style: AppTextStyles.micro(
                  isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                )),
            const SizedBox(width: 6),
            ...List.generate(
              4,
              (i) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2 + i * 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('More',
                style: AppTextStyles.micro(
                  isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                )),
          ],
        ),
      ],
    );
  }
}
