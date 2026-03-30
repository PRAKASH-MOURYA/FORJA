import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/animated_progress_ring.dart';

class RestTimerSheet extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const RestTimerSheet({
    super.key,
    this.totalSeconds = 90,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress =
        (_remaining / widget.totalSeconds).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warm.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.border : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Rest',
            style: AppTextStyles.labelUppercase(
              isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Progress ring with countdown
          AnimatedProgressRing(
            progress: progress,
            size: ProgressRingSize.md,
            progressGradient: AppColors.warmGradient,
            center: Text(
              _timeLabel,
              style: AppTextStyles.dataMedium(AppColors.warm),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          TextButton(
            onPressed: widget.onSkip,
            child: Text(
              'SKIP REST',
              style: AppTextStyles.labelUppercase(AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Shows the rest timer as a bottom sheet.
void showRestTimerSheet(
    BuildContext context, VoidCallback onComplete) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    builder: (ctx) => RestTimerSheet(
      totalSeconds: 90,
      onComplete: () {
        Navigator.of(ctx).pop();
        onComplete();
      },
      onSkip: () => Navigator.of(ctx).pop(),
    ),
  );
}
