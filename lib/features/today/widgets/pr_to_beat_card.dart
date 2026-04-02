import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/forja_card.dart';

class PrToBeatCard extends StatelessWidget {
  final String exerciseName;
  final double currentPrKg;
  final double targetKg;

  const PrToBeatCard({
    super.key,
    required this.exerciseName,
    required this.currentPrKg,
    required this.targetKg,
  });

  const PrToBeatCard.empty({super.key})
      : exerciseName = '',
        currentPrKg = 0,
        targetKg = 0;

  bool get _isEmpty => exerciseName.isEmpty;

  @override
  Widget build(BuildContext context) {
    return ForjaCard(
      shadows: AppColors.subtleShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(
                Icons.emoji_events_rounded,
                color: AppColors.warm,
                size: 14,
              ),
               SizedBox(width: AppSpacing.xs),
              Text(
                'PR TO BEAT',
                style: AppTextStyles.labelUppercase(context.appTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_isEmpty)
            Text(
              'Complete a workout to unlock your first PR target.',
              style: AppTextStyles.body(context.appTextSecondary),
            )
          else ...[
            Text(
              exerciseName,
              style: AppTextStyles.bodyStrong(context.appTextPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  '${currentPrKg.toStringAsFixed(1)} kg',
                  style: AppTextStyles.body(context.appTextSecondary),
                ),
                const SizedBox(width: AppSpacing.sm),
                 Icon(
                  Icons.arrow_forward_rounded,
                  color: context.appTextTertiary,
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.sm),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.heroGradient.createShader(bounds),
                  child: Text(
                    '${targetKg.toStringAsFixed(1)} kg',
                    style: AppTextStyles.dataInline(Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          delay: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
