import 'package:flutter/material.dart';
import '../../../app/theme.dart';

enum StatPillVariant { mint, amber, coral, sky }

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
    this.variant = StatPillVariant.mint,
  });

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

  Color get _color {
    switch (widget.variant) {
      case StatPillVariant.mint:
        return AppColors.accent;
      case StatPillVariant.amber:
        return AppColors.warm;
      case StatPillVariant.coral:
        return AppColors.coral;
      case StatPillVariant.sky:
        return AppColors.sky;
    }
  }

  Gradient get _gradient {
    switch (widget.variant) {
      case StatPillVariant.mint:
        return AppColors.accentGradient;
      case StatPillVariant.amber:
        return AppColors.warmGradient;
      case StatPillVariant.coral:
        return AppColors.coralGradient;
      case StatPillVariant.sky:
        return AppColors.skyGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: _color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) =>
                  _gradient.createShader(bounds),
              child: Icon(widget.icon, color: Colors.white, size: 18),
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
                isDark
                    ? AppColors.textTertiary
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
