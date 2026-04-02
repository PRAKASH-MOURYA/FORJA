import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/models/exercise.dart';

/// Bottom sheet showing all exercises in the current workout with completion
/// checkmarks. Tapping an exercise calls [onJump] and pops the sheet.
class ExerciseJumpSheet extends StatelessWidget {
  final List<Exercise> exercises;
  final Set<String> completedExerciseIds;
  final Function(String) onJump;

  const ExerciseJumpSheet({
    super.key,
    required this.exercises,
    required this.completedExerciseIds,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.appBgCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Exercises',
                        style: AppTextStyles.heading(context.appTextPrimary),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: context.appTextSecondary,
                        size: 22,
                      ),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
              // Exercise list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl,
                  ),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final isCompleted =
                        completedExerciseIds.contains(exercise.id);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      leading: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompleted
                            ? AppColors.positive
                            : context.appTextTertiary,
                        size: 22,
                      ),
                      title: Text(
                        exercise.name,
                        style:
                            AppTextStyles.bodyStrong(context.appTextPrimary),
                      ),
                      onTap: () {
                        onJump(exercise.id);
                        Navigator.of(context).pop();
                      },
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
