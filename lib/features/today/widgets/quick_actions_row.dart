import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/premium_card.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickCard(
            icon: Icons.fitness_center_rounded,
            label: 'Exercise\nLibrary',
            onTap: () => context.push('/exercises'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickCard(
            icon: Icons.grid_view_rounded,
            label: 'My\nSplits',
            onTap: () => context.push('/split-builder'),
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      showGradientBorder: false,
      child: SizedBox(
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              size: 28,
            ),
            Text(
              label,
              style: AppTextStyles.bodyStrong(
                isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
