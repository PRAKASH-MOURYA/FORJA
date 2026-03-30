import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/forja_button.dart';

class LogSetPanel extends StatelessWidget {
  final int setNumber;
  final double weightKg;
  final int reps;
  final double? lastWeightKg;
  final int? lastReps;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback? onLogSet;
  final bool isEnabled;

  const LogSetPanel({
    super.key,
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.lastWeightKg,
    this.lastReps,
    required this.onWeightChanged,
    required this.onRepsChanged,
    this.onLogSet,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.borderAccent : AppColors.accentDimLight,
          width: 1,
        ),
        boxShadow: AppColors.cardGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lastWeightKg != null && lastReps != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'Last: ${lastWeightKg!.toStringAsFixed(0)}kg × $lastReps',
                style: AppTextStyles.caption(
                  isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _ValueInput(
                  label: 'KG',
                  value: weightKg.toStringAsFixed(0),
                  onDecrement: () => onWeightChanged(
                      (weightKg - 2.5).clamp(0.0, 500.0)),
                  onIncrement: () => onWeightChanged(
                      (weightKg + 2.5).clamp(0.0, 500.0)),
                  isDark: isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  '×',
                  style: AppTextStyles.headingLarge(
                    isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                  ),
                ),
              ),
              Expanded(
                child: _ValueInput(
                  label: 'REPS',
                  value: reps.toString(),
                  onDecrement: () =>
                      onRepsChanged((reps - 1).clamp(1, 100)),
                  onIncrement: () =>
                      onRepsChanged((reps + 1).clamp(1, 100)),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ForjaButton(
            label: 'Log Set $setNumber',
            onPressed: isEnabled ? onLogSet : null,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}

class _ValueInput extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isDark;

  const _ValueInput({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgElevated : AppColors.bgElevatedLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(label,
              style: AppTextStyles.micro(
                  isDark ? AppColors.textTertiary : AppColors.textTertiaryLight)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepBtn(icon: Icons.remove, onTap: onDecrement, isDark: isDark),
              Text(value,
                  style: AppTextStyles.dataMedium(
                      isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)),
              _StepBtn(icon: Icons.add, onTap: onIncrement, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _StepBtn(
      {required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16,
            color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
      ),
    );
  }
}
