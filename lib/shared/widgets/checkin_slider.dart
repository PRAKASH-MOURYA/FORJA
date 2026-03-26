import 'package:flutter/material.dart';
import '../../app/theme.dart';

class CheckInSlider extends StatelessWidget {
  final String label;
  final List<String> emojis;
  final int value; // 1–5
  final Color activeColor;
  final ValueChanged<int> onChanged;

  const CheckInSlider({
    super.key,
    required this.label,
    required this.emojis,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyStrong(AppColors.textPrimary)),
            Text(emojis[(value - 1).clamp(0, 4)],
                style: const TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(5, (i) {
            final isFilled = i < value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 4 ? AppSpacing.sm : 0),
                child: GestureDetector(
                  onTap: () => onChanged(i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 44,
                    decoration: BoxDecoration(
                      color: isFilled
                          ? activeColor
                          : AppColors.bgInput.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
