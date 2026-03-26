import 'package:flutter/material.dart';
import '../../app/theme.dart';
import 'forja_card.dart';
import 'forja_pill.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? pillLabel;
  final Color? pillBg;
  final Color? pillFg;
  final bool useGradientValue;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.pillLabel,
    this.pillBg,
    this.pillFg,
    this.useGradientValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;

    Widget valueWidget = useGradientValue
        ? ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.heroGradient.createShader(bounds),
            child: Text(
              value,
              style: AppTextStyles.dataMedium(Colors.white),
            ),
          )
        : Text(
            value,
            style: AppTextStyles.dataMedium(
              isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          );

    return ForjaCard(
      shadows: AppColors.subtleShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.micro(textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          valueWidget,
          if (pillLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ForjaPill(
              label: pillLabel!,
              backgroundColor: pillBg,
              textColor: pillFg,
            ),
          ],
        ],
      ),
    );
  }
}
