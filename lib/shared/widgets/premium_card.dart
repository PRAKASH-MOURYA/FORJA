import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  // Kept for API compatibility — ignored; border is always hairline
  final bool showGradientBorder;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.boxShadow,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.showGradientBorder = true,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.backgroundColor ??
        (isDark ? AppColors.bgCard : AppColors.bgCardLight);
    final radius = widget.borderRadius ?? AppRadius.xl;
    final borderColor = isDark ? AppColors.border : AppColors.borderLight;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: AppBlur.card, sigmaY: AppBlur.card),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: widget.boxShadow ?? AppColors.cardShadow,
                border: Border.all(color: borderColor, width: 0.5),
              ),
              padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
