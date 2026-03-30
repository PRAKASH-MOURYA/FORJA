import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/muscle_chip.dart';
import '../../../shared/widgets/forja_button.dart';

class HeroWorkoutCard extends StatelessWidget {
  final String dayName;
  final List<Exercise> exercises;
  final VoidCallback onStart;

  const HeroWorkoutCard({
    super.key,
    required this.dayName,
    required this.exercises,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estMinutes = (exercises.length * 8 + 4).clamp(20, 90);
    final estVolume = exercises.fold<double>(
      0,
      (sum, e) => sum + (e.sets * e.reps * e.defaultKg),
    );

    return PremiumCard(
      padding: EdgeInsets.zero,
      boxShadow: AppColors.cardGlow,
      onTap: onStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top gradient header strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.12),
                  AppColors.sky.withValues(alpha: 0.06),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${exercises.length} EXERCISES',
                    style: AppTextStyles.micro(AppColors.accent),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: exercises
                          .take(3)
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.only(right: AppSpacing.xs),
                                child:
                                    MuscleChip.fromMuscle(e.muscle),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: AppTextStyles.display(
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Est. $estMinutes min · ${(estVolume / 1000).toStringAsFixed(1)}T total',
                  style: AppTextStyles.caption(
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ForjaButton(
                  label: 'Start Workout',
                  onPressed: onStart,
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
