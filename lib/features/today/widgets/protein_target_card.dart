import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/models/user_profile.dart';

class ProteinTargetCard extends StatelessWidget {
  final UserProfile? profile;
  const ProteinTargetCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null || profile!.bodyWeightKg == null || profile!.bodyWeightKg! <= 0) {
      return const SizedBox.shrink();
    }

    final proteinTarget = (profile!.bodyWeightKg! * 1.6).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Protein Target', style: AppTextStyles.bodyStrong(AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('Based on 1.6g per kg of body weight', style: AppTextStyles.micro(AppColors.textSecondary)),
              ],
            ),
          ),
          Text('${proteinTarget}g', style: AppTextStyles.headingLarge(AppColors.accent)),
        ],
      ),
    );
  }
}
