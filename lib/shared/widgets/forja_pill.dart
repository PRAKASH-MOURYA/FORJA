import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ForjaPill extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const ForjaPill({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  const ForjaPill.accent({super.key, required this.label})
      : backgroundColor = AppColors.accentDim,
        textColor = AppColors.accent;

  const ForjaPill.warm({super.key, required this.label})
      : backgroundColor = AppColors.warmDim,
        textColor = AppColors.warm;

  const ForjaPill.coral({super.key, required this.label})
      : backgroundColor = AppColors.coralDim,
        textColor = AppColors.coral;

  const ForjaPill.sky({super.key, required this.label})
      : backgroundColor = AppColors.skyDim,
        textColor = AppColors.sky;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? AppColors.bgElevated;
    final fg = textColor ??
        (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: fg.withValues(alpha: 0.18),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
