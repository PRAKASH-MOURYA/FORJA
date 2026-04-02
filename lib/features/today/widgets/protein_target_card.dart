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
        color: context.appBgElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.appBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Icon(Icons.fitness_center, color: AppColors.accent, size: 20),
          ),
           SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Protein Target', style: AppTextStyles.bodyStrong(context.appTextPrimary)),
                const SizedBox(height: 2),
                Text('Based on 1.6g per kg of body weight', style: AppTextStyles.micro(context.appTextSecondary)),
              ],
            ),
          ),
          Text('${proteinTarget}g', style: AppTextStyles.headingLarge(AppColors.accent)),
        ],
      ),
    );
  }
}
