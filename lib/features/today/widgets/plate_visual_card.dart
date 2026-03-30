import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import 'dart:math' as math;

class PlateVisualCard extends StatelessWidget {
  final bool isRestDay;
  const PlateVisualCard({super.key, this.isRestDay = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRestDay ? 'Rest Day Plate' : 'Training Day Plate',
                style: AppTextStyles.headingLarge(AppColors.textPrimary),
              ),
              Icon(Icons.restaurant_menu, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isRestDay 
              ? 'Focus on protein and veggies for recovery.'
              : 'Add more carbs to fuel your workout.',
            style: AppTextStyles.body(AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: SizedBox(
              height: 140,
              width: 140,
              child: CustomPaint(
                painter: _PlatePainter(isRestDay: isRestDay),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(color: AppColors.accent, label: 'Protein'),
              _LegendItem(color: AppColors.coral, label: 'Carbs'),
              _LegendItem(color: AppColors.warm, label: 'Veggies'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption(AppColors.textSecondary)),
      ],
    );
  }
}

class _PlatePainter extends CustomPainter {
  final bool isRestDay;
  _PlatePainter({required this.isRestDay});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background plate
    final paintPlate = Paint()..color = AppColors.bgElevated..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paintPlate);

    // Rim
    final paintRim = Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawCircle(center, radius - 2, paintRim);

    final rect = Rect.fromCircle(center: center, radius: radius - 8);

    double startAngle = -math.pi / 2;

    // Proportions
    final double proteinP = 0.33;
    final double carbsP = isRestDay ? 0.17 : 0.40;
    final double veggiesP = isRestDay ? 0.50 : 0.27;

    void drawSegment(Color color, double proportion) {
      final sweepAngle = proportion * 2 * math.pi;
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    drawSegment(AppColors.accent, proteinP);
    drawSegment(AppColors.coral, carbsP);
    drawSegment(AppColors.warm, veggiesP);
    
    // Inner cutout to make it look like food on a plate, not just a pie chart
    final paintInner = Paint()..color = AppColors.bgElevated..style = PaintingStyle.stroke..strokeWidth = 4;
    canvas.drawCircle(center, radius - 8, paintInner);
  }

  @override
  bool shouldRepaint(covariant _PlatePainter oldDelegate) => oldDelegate.isRestDay != isRestDay;
}
