import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/models/exercise.dart';

/// Pre-completion screen shown when user taps "Finish Workout" and some
/// exercises have 0 completed sets. Each row allows "Add Sets" (returns to
/// workout) or "Skip" (marks as intentionally skipped).
///
/// Pushed via [Navigator.push] (not context.go) so WorkoutScreen State
/// stays alive in the stack.
class FinishUpScreen extends StatefulWidget {
  final List<Exercise> incompleteExercises;
  final Function(String) onAddSets;
  final Function(String) onSkip;
  final VoidCallback onProceed;

  const FinishUpScreen({
    super.key,
    required this.incompleteExercises,
    required this.onAddSets,
    required this.onSkip,
    required this.onProceed,
  });

  @override
  State<FinishUpScreen> createState() => _FinishUpScreenState();
}

class _FinishUpScreenState extends State<FinishUpScreen> {
  final Set<String> _skippedIds = {};

  bool get _allResolved =>
      widget.incompleteExercises.every((e) => _skippedIds.contains(e.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: context.appBg,
        elevation: 0,
        title: Text(
          'Finish Up',
          style: AppTextStyles.heading(context.appTextPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: context.appTextSecondary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'These exercises have no sets logged.',
                style: AppTextStyles.body(context.appTextSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.incompleteExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = widget.incompleteExercises[index];
                    final isSkipped = _skippedIds.contains(exercise.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.appBgCard,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSkipped
                              ? context.appBorder
                              : context.appBorderStrong,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: AppTextStyles.bodyStrong(
                                isSkipped
                                    ? context.appTextTertiary
                                    : context.appTextPrimary,
                              ),
                            ),
                          ),
                          if (!isSkipped) ...[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onAddSets(exercise.id);
                              },
                              child: Text(
                                'Add Sets',
                                style: AppTextStyles.bodyStrong(
                                    AppColors.accent),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            TextButton(
                              onPressed: () {
                                widget.onSkip(exercise.id);
                                setState(() => _skippedIds.add(exercise.id));
                              },
                              child: Text(
                                'Skip',
                                style: AppTextStyles.body(
                                    context.appTextSecondary),
                              ),
                            ),
                          ] else
                            Text(
                              'Skipped',
                              style:
                                  AppTextStyles.caption(context.appTextTertiary),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appAccent,
                    foregroundColor:
                        context.isDark ? AppColors.bg : AppColors.bgLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: _allResolved ? widget.onProceed : null,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _allResolved
                          ? (context.isDark ? AppColors.bg : AppColors.bgLight)
                          : context.appTextTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
