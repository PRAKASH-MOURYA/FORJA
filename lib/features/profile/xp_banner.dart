import 'package:flutter/material.dart';

import '../../app/theme.dart';

class XpBanner extends StatelessWidget {
  const XpBanner({
    super.key,
    required this.xp,
    required this.level,
    required this.streakWeeks,
    required this.streakShields,
  });

  final int xp;
  final String level;
  final int streakWeeks;
  final int streakShields;

  static const Map<String, int> _thresholds = {
    'novice': 0,
    'beginner': 500,
    'intermediate': 1500,
    'advanced': 3500,
    'elite': 7000,
  };

  static const List<String> _levels = [
    'novice',
    'beginner',
    'intermediate',
    'advanced',
    'elite',
  ];

  @override
  Widget build(BuildContext context) {
    final normalizedLevel = level.toLowerCase();
    final levelIndex = _levels.indexOf(normalizedLevel).clamp(0, _levels.length - 1);
    final currentLevel = _levels[levelIndex];
    final currentThreshold = _thresholds[currentLevel] ?? 0;
    final nextThreshold = levelIndex == _levels.length - 1
        ? currentThreshold
        : (_thresholds[_levels[levelIndex + 1]] ?? currentThreshold);

    final progress = nextThreshold == currentThreshold
        ? 1.0
        : ((xp - currentThreshold) / (nextThreshold - currentThreshold))
            .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Lv. ${levelIndex + 1} ${_displayLevel(currentLevel)}',
                style: AppTextStyles.bodyStrong(AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                '$xp XP',
                style: AppTextStyles.caption(AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.bgInput,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            nextThreshold == currentThreshold
                ? 'Max level reached'
                : '$xp / $nextThreshold XP',
            style: AppTextStyles.caption(AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: 16, color: AppColors.warm),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$streakWeeks wk streak',
                style: AppTextStyles.body(AppColors.textPrimary),
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(Icons.shield_outlined, size: 16, color: AppColors.sky),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$streakShields shields',
                style: AppTextStyles.body(AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _displayLevel(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}
