import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/theme.dart';

class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double? borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.bgCard : AppColors.bgCardLight;
    final highlight = isDark ? AppColors.bgElevated : AppColors.bgElevatedLight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
    );
  }
}
