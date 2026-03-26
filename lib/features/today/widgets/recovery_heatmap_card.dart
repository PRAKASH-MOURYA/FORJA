import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../shared/services/muscle_recovery_service.dart';

class RecoveryHeatmapCard extends StatefulWidget {
  final List<MuscleRecoveryStatus> statuses;
  final String summaryText;

  const RecoveryHeatmapCard({
    super.key,
    required this.statuses,
    required this.summaryText,
  });

  @override
  State<RecoveryHeatmapCard> createState() => _RecoveryHeatmapCardState();
}

class _RecoveryHeatmapCardState extends State<RecoveryHeatmapCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.textSecondary,
                  size: 14,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.summaryText,
                    style: AppTextStyles.body(AppColors.textSecondary),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.statuses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemBuilder: (context, index) {
                      final status = widget.statuses[index];

                      final tile = switch (status.zone) {
                        MuscleRecoveryZone.green => (
                            bg: AppColors.accentGlow,
                            dot: AppColors.accent,
                            label: AppColors.accent,
                          ),
                        MuscleRecoveryZone.yellow => (
                            bg: AppColors.warmDim,
                            dot: AppColors.warm,
                            label: AppColors.warm,
                          ),
                        MuscleRecoveryZone.red => (
                            bg: AppColors.coralDim,
                            dot: AppColors.coral,
                            label: AppColors.coral,
                          ),
                      };

                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: tile.bg,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.3,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: tile.dot,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: tile.dot.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                status.muscle,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: tile.label,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
