import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../models/exercise.dart';

class ExerciseRow extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback? onTap;
  final String? lastSessionSubtitle;
  final String? prSubtitle;

  const ExerciseRow({
    super.key,
    required this.exercise,
    required this.index,
    this.onTap,
    this.lastSessionSubtitle,
    this.prSubtitle,
  });

  @override
  State<ExerciseRow> createState() => _ExerciseRowState();
}

class _ExerciseRowState extends State<ExerciseRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
    final bgElevated =
        isDark ? AppColors.bgElevated : AppColors.bgElevatedLight;

    // First exercise gets gradient treatment
    final isHighlighted = widget.index == 0;

    Widget numberCircle = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: isHighlighted ? AppColors.heroGradient : null,
        color: isHighlighted ? null : bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: Text(
        '${widget.index + 1}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isHighlighted ? AppColors.bg : textSecondary,
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          child: Row(
            children: [
              numberCircle,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    if (widget.prSubtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.prSubtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                      ),
                    ],
                    if (widget.lastSessionSubtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.lastSessionSubtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.sky,
                size: 17,
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textTertiary
                    : AppColors.textTertiaryLight,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: widget.index * 55),
        )
        .slideX(
          begin: 0.04,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: widget.index * 55),
          curve: Curves.easeOutCubic,
        );
  }
}
