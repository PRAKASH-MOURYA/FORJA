import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_card.dart';
import '../../shared/widgets/forja_pill.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/constants/programs.dart';
import 'profile_stats_provider.dart';
import 'xp_banner.dart';
import '../../shared/services/hive_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(profileStatsProvider);

    final name = profile?.name ?? 'Alex';
    final experience = _experienceLabel(profile?.experience);
    final programLabel =
        _programLabel(profile?.currentProgramId, profile?.customSplitId);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Ambient header gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.ambientGradient,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: AppTextStyles.displayLarge(AppColors.textPrimary),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Profile card
                  ForjaCard(
                    shadows: AppColors.cardShadow,
                    child: Row(
                      children: [
                        // Gradient avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius:
                                BorderRadius.circular(AppRadius.circle),
                            boxShadow: AppColors.accentShadow,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.bg,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.headingLarge(
                                    AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$experience · ${_currentWeekLabel()}',
                                style:
                                    AppTextStyles.body(AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ForjaPill.warm(label: _levelLabel(stats.level)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Workouts',
                          value: stats.workoutCount.toString(),
                        ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          label: 'Volume',
                          value:
                              '${(stats.totalVolumeKg / 1000).toStringAsFixed(1)}t',
                        ).animate().fadeIn(delay: 230.ms, duration: 350.ms),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(
                          label: 'Streak',
                          value: '${stats.streakWeeks} wk',
                        ).animate().fadeIn(delay: 280.ms, duration: 350.ms),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  XpBanner(
                    xp: stats.xp,
                    level: stats.level,
                    streakWeeks: stats.streakWeeks,
                    streakShields: profile?.streakShields ?? 1,
                  ).animate().fadeIn(delay: 320.ms, duration: 350.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Current program card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.accentGlow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: AppColors.borderAccent, width: 0.5),
                      boxShadow: AppColors.accentShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Program',
                                style: AppTextStyles.micro(
                                    AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                programLabel,
                                style:
                                    AppTextStyles.subhead(AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _showProgramPicker(context, ref),
                          child:
                              const ForjaPill.accent(label: 'Change'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => context.push('/split-builder'),
                          child: const ForjaPill(label: 'Build Split'),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 360.ms, duration: 350.ms),

                  const SizedBox(height: AppSpacing.md),

                  ForjaCard(
                    onTap: () => context.push('/challenges'),
                    shadows: AppColors.subtleShadow,
                    child: const Row(
                      children: [
                        Icon(Icons.groups_rounded, color: AppColors.accent),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Buddy Challenges',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 350.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Settings
                  const _SettingsGroup(
                    label: 'ACCOUNT',
                    items: [
                      _SettingItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                      ),
                      _SettingItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Reminders & updates',
                      ),
                      _SettingItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SettingsGroup(
                    label: 'APP',
                    items: [
                      _SettingItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Appearance',
                        subtitle: 'Dark mode',
                      ),
                      _SettingItem(
                        icon: Icons.tune_rounded,
                        title: 'Units',
                        subtitle: 'Metric (kg)',
                      ),
                      _SettingItem(
                        icon: Icons.timer_outlined,
                        title: 'Rest Timer',
                        subtitle: '90 seconds default',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SettingsGroup(
                    label: 'DATA',
                    items: [
                      _SettingItem(
                        icon: Icons.cloud_upload_outlined,
                        title: 'Sync & Backup',
                        subtitle: 'Last synced today',
                      ),
                      _SettingItem(
                        icon: Icons.download_outlined,
                        title: 'Export Data',
                      ),
                      _SettingItem(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete Account',
                        isDestructive: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  Center(
                    child: Text(
                      'FORJA v1.0.0',
                      style: AppTextStyles.micro(AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgramPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: ListView(
          shrinkWrap: true,
          children: kPrograms
              .map((program) => ListTile(
                    title: Text(program.name,
                        style: AppTextStyles.bodyStrong(
                            AppColors.textPrimary)),
                    subtitle: Text(program.description,
                        style: AppTextStyles.caption(
                            AppColors.textSecondary)),
                    onTap: () {
                      ref.read(userProfileProvider.notifier).update(
                            (p) => p.copyWith(
                                currentProgramId: program.id),
                          );
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  String _currentWeekLabel() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 4);
    final weekNum =
        ((now.difference(startOfYear).inDays) / 7).ceil();
    return 'Week $weekNum';
  }

  String _levelLabel(String level) {
    const labels = {
      'novice': 'Lv. 1 Novice',
      'beginner': 'Lv. 2 Beginner',
      'intermediate': 'Lv. 3 Athlete',
      'advanced': 'Lv. 4 Advanced',
      'elite': 'Lv. 5 Elite',
    };
    return labels[level] ?? 'Lv. 1 Novice';
  }

  String _experienceLabel(String? experience) {
    switch (experience) {
      case 'beginner':
        return 'Beginner';
      case 'some':
        return 'Intermediate';
      case 'intermediate':
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }

  String _programLabel(String? programId, String? customSplitId) {
    if (customSplitId != null && customSplitId.isNotEmpty) {
      final split = HiveService.customSplits.get(customSplitId);
      if (split != null) return split.name;
    }
    switch (programId) {
      case 'ppl_5x':
        return 'Push/Pull/Legs · 5 days/week';
      case 'upper_lower_4x':
        return 'Upper/Lower · 4 days/week';
      case 'full_body_3x':
        return 'Full Body · 3 days/week';
      case 'strength_5x5_3x':
        return 'Strength 5×5 · 3 days/week';
      case 'home_dumbbell_3x':
        return 'Dumbbell Home · 3 days/week';
      case 'home_bodyweight_3x':
        return 'Bodyweight · 3 days/week';
      case 'hybrid_gym_home':
        return 'Hybrid · 4 days/week';
      default:
        return 'Push/Pull/Legs · 4 days/week';
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  final String label;
  final List<_SettingItem> items;

  const _SettingsGroup({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            label,
            style: AppTextStyles.labelUppercase(AppColors.textSecondary),
          ),
        ),
        ForjaCard(
          padding: EdgeInsets.zero,
          shadows: AppColors.subtleShadow,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        color: item.isDestructive
                            ? AppColors.coral
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: item.isDestructive
                            ? AppColors.coral
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: AppTextStyles.caption(
                                AppColors.textSecondary),
                          )
                        : null,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                    onTap: () {},
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: AppSpacing.xxl + AppSpacing.lg + 36,
                      color: AppColors.border,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
  });
}
