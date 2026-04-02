import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/widgets/forja_button.dart';

class SessionGuardSheet extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const SessionGuardSheet({
    super.key,
    required this.onResume,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      // Keep this sheet relatively “modal”: minimal dragging.
      initialChildSize: 0.35,
      minChildSize: 0.3,
      maxChildSize: 0.4,
      expand: false,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle (purely visual).
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
                'End workout?',
                style: AppTextStyles.heading(AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Your progress will be lost.',
                style: AppTextStyles.body(AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ForjaButton(
                label: 'Resume Workout',
                onPressed: onResume,
              ),
              const SizedBox(height: AppSpacing.md),
              ForjaButton.secondary(
                label: 'Discard & Exit',
                onPressed: onDiscard,
              ),
            ],
          ),
        );
      },
    );
  }
}

