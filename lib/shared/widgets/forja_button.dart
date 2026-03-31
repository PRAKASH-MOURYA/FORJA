import 'package:flutter/material.dart';
import '../../app/theme.dart';

enum ForjaButtonVariant { primary, secondary }

class ForjaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ForjaButtonVariant variant;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const ForjaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ForjaButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  const ForjaButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : variant = ForjaButtonVariant.secondary;

  @override
  State<ForjaButton> createState() => _ForjaButtonState();
}

class _ForjaButtonState extends State<ForjaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    // Primary: solid accent fill (white dark / black light)
    if (widget.variant == ForjaButtonVariant.primary) {
      final bg = isDisabled
          ? (isDark ? AppColors.bgElevated : AppColors.bgElevatedLight)
          : (isDark ? AppColors.accent : AppColors.accentLight);
      final fg = isDisabled
          ? (isDark ? AppColors.textTertiary : AppColors.textTertiaryLight)
          : (isDark ? AppColors.textInverse : AppColors.textInverseLight);

      return GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: 56,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: isDisabled || _pressed ? null : AppColors.subtleShadow,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: fg,
                        ))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: fg, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: fg,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      );
    }

    // Secondary: transparent with hairline border
    final textColor = isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: 56,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _pressed
                  ? (isDark ? AppColors.bgElevated : AppColors.bgElevatedLight)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.borderLight,
                width: 1.0,
              ),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: textColor))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: textColor, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
