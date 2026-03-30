import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/export_service.dart';

class ExportSection extends StatelessWidget {
  final UserProfile? profile;

  const ExportSection({Key? key, this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
             'Data Export',
             style: AppTextStyles.bodyStrong(AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
             'Download your fitness history as CSV or generate a PDF report.',
             style: AppTextStyles.body(AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ExportService.exportCsv(),
                  icon: const Icon(Icons.table_chart, size: 20),
                  label: const Text('Export CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ExportService.exportPdf(profile),
                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                  label: const Text('Export PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
