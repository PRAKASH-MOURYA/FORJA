import 'package:flutter/material.dart';
import '../../../app/theme.dart';

// Variants retained for readiness functional states only.
// Default renders as neutral monochrome.
enum StatPillVariant { neutral, positive, warning, danger }

class StatPill extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final StatPillVariant variant;

  const StatPill({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.variant = StatPillVariant.neutral,
  });

  // Legacy constructors — callers using amber/mint/sky/coral map to neutral
  const StatPill.amber({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  }) : variant = StatPillVariant.neutral;

  const StatPill.mint({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  }) : variant = StatPillVariant.neutral;

  const StatPill.sky({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  }) : variant = StatPillVariant.neutral;

  @override
  State<StatPill> createState() => _StatPillState();
}

class _StatPillState extends State<StatPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _dotColor(bool isDark) {
    switch (widget.variant) {
      case StatPillVariant.positive:
        return AppColors.positive;
      case StatPillVariant.warning:
        return AppColors.warning;
      case StatPillVariant.danger:
        return AppColors.danger;
      case StatPillVariant.neutral:
        return isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.border : AppColors.borderLight;
    final bgColor = isDark
        ? AppColors.bgCard
        : AppColors.bgCardLight;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: _dotColor(isDark),
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: AppTextStyles.bodyStrong(
                isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              widget.label,
              style: AppTextStyles.micro(
                isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
