import 'package:flutter/material.dart';
import '../../../app/theme.dart';

enum MuscleCategory { push, pull, legs, core }

class MuscleChip extends StatelessWidget {
  final String label;
  final MuscleCategory category;

  const MuscleChip({
    super.key,
    required this.label,
    required this.category,
  });

  factory MuscleChip.fromMuscle(String muscle) {
    final lower = muscle.toLowerCase();
    MuscleCategory cat;
    if (['chest', 'shoulders', 'triceps', 'front delt'].any(lower.contains)) {
      cat = MuscleCategory.push;
    } else if (['back', 'biceps', 'rear delt', 'lats', 'traps']
        .any(lower.contains)) {
      cat = MuscleCategory.pull;
    } else if (['quads', 'hamstrings', 'glutes', 'calves', 'leg']
        .any(lower.contains)) {
      cat = MuscleCategory.legs;
    } else {
      cat = MuscleCategory.core;
    }
    return MuscleChip(label: muscle, category: cat);
  }

  Color get _color {
    switch (category) {
      case MuscleCategory.push:
        return AppColors.coral;
      case MuscleCategory.pull:
        return AppColors.sky;
      case MuscleCategory.legs:
        return AppColors.warm;
      case MuscleCategory.core:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: AppTextStyles.micro(_color),
      ),
    );
  }
}
