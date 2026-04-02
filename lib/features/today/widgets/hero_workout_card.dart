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
        final estMinutes = (exercises.length * 8 + 4).clamp(20, 90);
    final estVolume = exercises.fold<double>(
      0,
      (sum, e) => sum + (e.sets * e.reps * e.defaultKg),
    );

    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      onTap: onStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metadata row: exercise count + muscle chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.appBgElevated,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: context.appBorder,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${exercises.length} EXERCISES',
                  style: AppTextStyles.micro(
                    context.appTextSecondary,
                  ),
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
                              padding: const EdgeInsets.only(right: AppSpacing.xs),
                              child: MuscleChip.fromMuscle(e.muscle),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            dayName,
            style: AppTextStyles.display(
              context.appTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Est. $estMinutes min · ${(estVolume / 1000).toStringAsFixed(1)}T total',
            style: AppTextStyles.caption(
              context.appTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ForjaButton(
            label: 'Start Workout',
            onPressed: onStart,
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}
