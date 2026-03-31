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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgElevated : AppColors.bgElevatedLight;
    final border = isDark ? AppColors.border : AppColors.borderLight;
    final text = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.micro(text),
      ),
    );
  }
}
