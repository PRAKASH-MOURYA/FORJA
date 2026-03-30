import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/widgets/muscle_chip.dart';

class ExerciseHeroCard extends StatelessWidget {
  final Exercise exercise;
  final int exerciseIndex;
  final int totalExercises;
  final VoidCallback? onHistoryTap;

  const ExerciseHeroCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.totalExercises,
    this.onHistoryTap,
  });

  Color get _categoryColor {
    final cat = exercise.category.toLowerCase();
    if (cat.contains('push')) return AppColors.coral;
    if (cat.contains('pull')) return AppColors.sky;
    if (cat.contains('legs')) return AppColors.warm;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
          width: 0.5,
        ),
        boxShadow: AppColors.cardShadow,
        gradient: LinearGradient(
          colors: [
            _categoryColor.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  exercise.category.toUpperCase(),
                  style: AppTextStyles.micro(_categoryColor),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              MuscleChip.fromMuscle(exercise.muscle),
              const Spacer(),
              // History button
              GestureDetector(
                onTap: onHistoryTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgElevated : AppColors.bgElevatedLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            exercise.name,
            style: AppTextStyles.display(
              isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Exercise ${exerciseIndex + 1} of $totalExercises · ${exercise.muscle}',
            style: AppTextStyles.caption(
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
