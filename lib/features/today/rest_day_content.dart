import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/widgets/stat_card.dart';

class RestDayContent extends StatelessWidget {
  final int workoutsThisWeek;
  final int setsThisWeek;
  final double volumeKgThisWeek;

  const RestDayContent({
    super.key,
    required this.workoutsThisWeek,
    required this.setsThisWeek,
    required this.volumeKgThisWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(context, 'MOBILITY'),
        const SizedBox(height: AppSpacing.sm),
        _buildBulletList(context, [
          'Hip flexor stretch (2x 60s / side)',
          'Couch stretch (2x 60s / side)',
          'Pigeon pose (2x 60s / side)',
          'Thoracic extensions (2x 15 reps)',
          'Ankle dorsiflexion rocks (2x 15 / side)',
        ]),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionHeader(context, 'FOAM ROLLING'),
        const SizedBox(height: AppSpacing.sm),
        _buildBulletList(context, [
          'Quads (2 mins / side)',
          'IT band (1 min / side)',
          'Glutes (1 min / side)',
          'Upper back (2 mins)',
          'Lats (1 min / side)',
        ]),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionHeader(context, 'ACTIVE RECOVERY'),
        const SizedBox(height: AppSpacing.sm),
        _buildBulletList(context, [
          'Light walk (20-30 mins)',
          'Gentle cycling (15 mins)',
          'Yoga flow (15-20 mins)',
        ]),
        const SizedBox(height: AppSpacing.xl),

        _buildSectionHeader(context, 'THIS WEEK'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Workouts',
                value: workoutsThisWeek.toString(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                label: 'Sets',
                value: setsThisWeek.toString(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                label: 'Volume',
                value: '${(volumeKgThisWeek / 1000).toStringAsFixed(1)}k',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.labelUppercase(context.appTextSecondary),
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.body(context.appTextSecondary),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
