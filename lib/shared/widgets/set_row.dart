import 'package:flutter/material.dart';
import '../../app/theme.dart';

class SetRow extends StatelessWidget {
  final int setNumber;
  final double weightKg;
  final int reps;
  final bool isActive;
  final bool isDone;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback onToggleDone;

  const SetRow({
    super.key,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    required this.isActive,
    required this.isDone,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? AppColors.accentGlow
        : isDone
            ? AppColors.bgElevated.withValues(alpha: 0.5)
            : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bg,
        border: isActive
            ? const Border(
                left: BorderSide(color: AppColors.accent, width: 2.5),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 32,
            child: Text(
              '$setNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDone
                    ? AppColors.accent
                    : isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
              ),
            ),
          ),
          // Weight
          Expanded(
            child: _EditableValue(
              value: weightKg.toStringAsFixed(1),
              suffix: 'kg',
              isDone: isDone,
              isActive: isActive,
              onMinus: () =>
                  onWeightChanged(weightKg - 2.5 < 0 ? 0 : weightKg - 2.5),
              onPlus: () => onWeightChanged(weightKg + 2.5),
            ),
          ),
          // Reps
          Expanded(
            child: _EditableValue(
              value: '$reps',
              suffix: 'reps',
              isDone: isDone,
              isActive: isActive,
              onMinus: () => onRepsChanged(reps - 1 < 1 ? 1 : reps - 1),
              onPlus: () => onRepsChanged(reps + 1),
            ),
          ),
          // Checkbox
          GestureDetector(
            onTap: onToggleDone,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDone ? AppColors.accent : Colors.transparent,
                border: Border.all(
                  color: isDone ? AppColors.accent : AppColors.textTertiary,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                boxShadow: isDone
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded, size: 16, color: AppColors.bg)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableValue extends StatelessWidget {
  final String value;
  final String suffix;
  final bool isDone;
  final bool isActive;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _EditableValue({
    required this.value,
    required this.suffix,
    required this.isDone,
    required this.isActive,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppColors.textSecondary : AppColors.textPrimary;
    if (!isActive) {
      return Center(
        child: Text(
          '$value $suffix', // concatenated for display
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onMinus,
          child: Container(
            padding: const EdgeInsets.all(2),
            child: const Icon(
              Icons.remove_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('$value', style: AppTextStyles.dataInline(AppColors.textPrimary)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onPlus,
          child: Container(
            padding: const EdgeInsets.all(2),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
