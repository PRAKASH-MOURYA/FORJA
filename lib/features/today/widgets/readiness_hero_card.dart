import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../app/theme.dart';
import '../../../shared/models/readiness_score.dart';
import '../../../shared/widgets/animated_progress_ring.dart';

class ReadinessHeroCard extends HookConsumerWidget {
  final ReadinessScore? readiness;
  final int streakWeeks;
  final double volumeTonnes;

  const ReadinessHeroCard({
    required this.readiness,
    required this.streakWeeks,
    required this.volumeTonnes,
    super.key,
  });

  static Color _zoneColor(int score) {
    if (score <= 40) return AppColors.danger;
    if (score <= 70) return AppColors.warning;
    return AppColors.positive;
  }

  static String _zoneLabel(int score) {
    if (score <= 40) return 'Recover';
    if (score <= 70) return 'Moderate';
    return 'Ready';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force animation replay strictly on remount
    final animKey = useMemoized(() => UniqueKey());
    final targetScore = readiness?.score ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _FlankStat(
              label: '🔥 Streak',
              value: '$streakWeeks wks',
              alignment: CrossAxisAlignment.end,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          TweenAnimationBuilder<double>(
            key: animKey,
            tween: Tween<double>(begin: 0, end: targetScore.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              final displayScore = value.round();
              final zoneColor = _zoneColor(displayScore);
              final zoneLabel = readiness == null ? '–' : _zoneLabel(displayScore);
              
              return AnimatedProgressRing(
                progress: targetScore == 0 ? 0 : value / 100,
                size: ProgressRingSize.lg,
                progressGradient: LinearGradient(colors: [zoneColor, zoneColor]),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      readiness == null ? '–' : '$displayScore',
                      style: AppTextStyles.dataLarge(zoneColor),
                    ),
                    Text(
                      zoneLabel,
                      style: AppTextStyles.bodyStrong(context.appTextSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: _FlankStat(
              label: 'Volume',
              value: '${volumeTonnes.toStringAsFixed(1)}T',
              alignment: CrossAxisAlignment.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlankStat extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  const _FlankStat({
    required this.label,
    required this.value,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyStrong(context.appTextPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.micro(context.appTextTertiary),
        ),
      ],
    );
  }
}
