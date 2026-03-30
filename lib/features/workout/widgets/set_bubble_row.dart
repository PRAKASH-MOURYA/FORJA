import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class SetBubbleRow extends StatelessWidget {
  final int totalSets;
  final int currentSetIndex;
  final List<bool> setsDone;

  const SetBubbleRow({
    super.key,
    required this.totalSets,
    required this.currentSetIndex,
    required this.setsDone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalSets,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final isDone = i < setsDone.length && setsDone[i];
          final isActive = i == currentSetIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isDone ? AppColors.accentGradient : null,
              color: isDone
                  ? null
                  : (isDark ? AppColors.bgElevated : AppColors.bgElevatedLight),
              border: isActive && !isDone
                  ? Border.all(color: AppColors.accent, width: 2)
                  : null,
              boxShadow: isDone ? AppColors.accentShadow : null,
            ),
            alignment: Alignment.center,
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : Text(
                    '${i + 1}',
                    style: AppTextStyles.bodyStrong(
                      isActive
                          ? AppColors.accent
                          : (isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
