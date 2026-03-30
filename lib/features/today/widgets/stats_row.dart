import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/stat_pill.dart';

class StatsRow extends StatelessWidget {
  final int streakWeeks;
  final int xp;
  final double volumeTonnes;

  const StatsRow({
    super.key,
    required this.streakWeeks,
    required this.xp,
    required this.volumeTonnes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatPill(
            icon: Icons.local_fire_department_rounded,
            value: '${streakWeeks}w',
            label: 'Streak',
            variant: StatPillVariant.amber,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatPill(
            icon: Icons.bolt_rounded,
            value: xp.toString(),
            label: 'XP',
            variant: StatPillVariant.mint,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatPill(
            icon: Icons.fitness_center_rounded,
            value: '${volumeTonnes.toStringAsFixed(1)}T',
            label: 'Volume',
            variant: StatPillVariant.sky,
          ),
        ),
      ],
    );
  }
}
