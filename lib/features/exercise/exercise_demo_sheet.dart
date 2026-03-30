import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_pill.dart';
import '../../shared/models/exercise.dart';

class ExerciseDemoSheet extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDemoSheet({super.key, required this.exercise});

  @override
  State<ExerciseDemoSheet> createState() => _ExerciseDemoSheetState();
}

class _ExerciseDemoSheetState extends State<ExerciseDemoSheet> {
  int _videoTab = 0; // 0 = Front view, 1 = Side view

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
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
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary, size: 22),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    0,
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                  ),
                  children: [
                    // Video placeholder
                    _buildVideoPlaceholder(),
                    const SizedBox(height: AppSpacing.xxl),
                    // Form cues
                    _buildFormCues(exercise.formCues),
                    const SizedBox(height: AppSpacing.xxl),
                    // Muscles targeted
                    _buildMusclesTargeted(exercise.targetMuscles),
                    const SizedBox(height: AppSpacing.xxl),
                    // Swap exercise
                    _buildSwapSection(exercise.swapAlternatives),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoPlaceholder() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 190,
            color: AppColors.bgElevated,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Placeholder gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.bgElevated,
                        AppColors.bgElevated.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(AppRadius.circle),
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha:0.3),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: AppColors.accent, size: 28),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Exercise Demo',
                      style: AppTextStyles.caption(AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // View toggle pills
        Row(
          children: [
            _VideoTab(
              label: 'Front view',
              isSelected: _videoTab == 0,
              onTap: () => setState(() => _videoTab = 0),
            ),
            const SizedBox(width: AppSpacing.sm),
            _VideoTab(
              label: 'Side view',
              isSelected: _videoTab == 1,
              onTap: () => setState(() => _videoTab = 1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCues(List<String> cues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FORM CUES',
            style: AppTextStyles.labelUppercase(AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.md),
        ...cues.asMap().entries.map((entry) {
          final i = entry.key;
          final cue = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    cue,
                    style: AppTextStyles.body(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMusclesTargeted(List<String> muscles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MUSCLES TARGETED',
            style: AppTextStyles.labelUppercase(AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: muscles.map((m) => ForjaPill.accent(label: m)).toList(),
        ),
      ],
    );
  }

  Widget _buildSwapSection(List<String> alternatives) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SWAP EXERCISE',
            style: AppTextStyles.labelUppercase(AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.md),
        ...alternatives.map((alt) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: () {
                  // TODO: implement exercise swap
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          alt,
                          style: AppTextStyles.subhead(AppColors.textPrimary),
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textTertiary, size: 18),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _VideoTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VideoTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs + 1,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentDim : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
