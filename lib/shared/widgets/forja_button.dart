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
    final textColor =
        isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
    final isDisabled = widget.onPressed == null && !widget.isLoading;

    if (widget.variant == ForjaButtonVariant.primary) {
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
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isDisabled
                    ? null
                    : AppColors.accentGradient,
                color: isDisabled ? AppColors.bgElevated : null,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: (!isDisabled && !_pressed)
                    ? AppColors.accentShadow
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.bg,
                        ))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon,
                                color: AppColors.bg, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            widget.label,
                            style: const TextStyle(
                              color: AppColors.bg,
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

    // Secondary
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
                  ? AppColors.bgElevated
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: _pressed
                    ? AppColors.borderHover
                    : (isDark ? AppColors.border : AppColors.borderLight),
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
