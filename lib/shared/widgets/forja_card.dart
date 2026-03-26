import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ForjaCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool glass;
  final List<BoxShadow>? shadows;

  const ForjaCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.glass = false,
    this.shadows,
  });

  @override
  State<ForjaCard> createState() => _ForjaCardState();
}

class _ForjaCardState extends State<ForjaCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.backgroundColor ??
        (isDark ? AppColors.bgCard : AppColors.bgCardLight);
    final borderColor = isDark ? AppColors.border : AppColors.borderLight;
    final radius = widget.borderRadius ?? AppRadius.lg;

    final decoration = BoxDecoration(
      color: widget.glass
          ? bg.withValues(alpha: isDark ? 0.72 : 0.88)
          : bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor,
        width: 0.5,
      ),
      boxShadow: widget.shadows ?? (isDark ? AppColors.subtleShadow : null),
    );

    Widget card = Container(
      decoration: decoration,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: widget.child,
    );

    if (widget.glass) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppBlur.card,
            sigmaY: AppBlur.card,
          ),
          child: card,
        ),
      );
    }

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: card,
      ),
    );
  }
}
