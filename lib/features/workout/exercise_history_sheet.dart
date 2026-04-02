import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/repositories/workout_repository.dart';

class ExerciseHistorySheet extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;

  const ExerciseHistorySheet({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final repo = WorkoutRepository();
    final allLogs = repo.getAll(); // sorted desc by startedAt

    // Collect up to 3 past sessions (most recent first) that have this exercise.
    final sessions = <_HistorySession>[];
    for (final log in allLogs) {
      final sets = repo
          .getSetsForWorkout(log.id)
          .where((s) => s.exerciseId == exerciseId && s.completed)
          .toList();
      if (sets.isEmpty) continue;

      final setsLine = sets
          .map((s) => '${s.weightKg.toStringAsFixed(0)}kg × ${s.reps}')
          .join(', ');

      sessions.add(
        _HistorySession(
          startedAt: log.startedAt,
          setsLine: setsLine,
        ),
      );

      if (sessions.length >= 3) break;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              // Drag handle.
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                exerciseName,
                style: AppTextStyles.heading(AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'RECENT HISTORY',
                style: AppTextStyles.caption(AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(
                          'No history yet. Complete a set to start tracking.',
                          style: AppTextStyles.body(AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 24, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fmtDate(session.startedAt),
                                  style: AppTextStyles.caption(
                                    AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  session.setsLine,
                                  style: AppTextStyles.bodyStrong(
                                    AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistorySession {
  final DateTime startedAt;
  final String setsLine;

  const _HistorySession({
    required this.startedAt,
    required this.setsLine,
  });
}

