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
import 'widgets/export_section.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/services/hive_service.dart';
import '../../shared/models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(profileStatsProvider);
    final themeMode = ref.watch(themeModeProvider);

    final name = profile?.name ?? 'Alex';
    final experience = _experienceLabel(profile?.experience);
    final programLabel =
        _programLabel(profile?.currentProgramId, profile?.customSplitId);

    return Scaffold(
      backgroundColor: context.appBg,
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
                    style: AppTextStyles.displayLarge(context.appTextPrimary),
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
                              color: Colors.white,
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
                                    context.appTextPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$experience · ${_currentWeekLabel()}',
                                style:
                                    AppTextStyles.body(context.appTextSecondary),
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
                      color: context.appAccentGlow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                          color: context.appBorderAccent, width: 0.5),
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
                                    context.appTextSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                programLabel,
                                style:
                                    AppTextStyles.subhead(context.appTextPrimary),
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
                    child: Row(
                      children: [
                        const Icon(Icons.groups_rounded, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Buddy Challenges',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.appTextPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.appTextTertiary,
                          size: 18,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 350.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Settings
                  _SettingsGroup(
                    label: 'ACCOUNT',
                    items: [
                      _SettingItem(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Body Metrics',
                        subtitle: '${profile?.heightCm?.toStringAsFixed(0) ?? "--"} cm · ${profile?.bodyWeightKg?.toStringAsFixed(1) ?? "--"} kg',
                        onTap: () => _showBodyMetricsEditor(context, ref, profile),
                      ),
                      _SettingItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        onTap: () => _showEditProfile(context, ref, profile),
                      ),
                      const _SettingItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Reminders & updates',
                      ),
                      const _SettingItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SettingsGroup(
                    label: 'APP',
                    items: [
                      _SettingItem(
                        icon: themeMode == ThemeMode.dark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        title: 'Appearance',
                        subtitle: themeMode == ThemeMode.dark
                            ? 'Dark mode'
                            : 'Light mode',
                        onTap: () => ref
                            .read(themeModeProvider.notifier)
                            .toggleTheme(),
                      ),
                      const _SettingItem(
                        icon: Icons.tune_rounded,
                        title: 'Units',
                        subtitle: 'Metric (kg)',
                      ),
                      const _SettingItem(
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
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Data Export
                  ExportSection(profile: profile),
                  const SizedBox(height: AppSpacing.xl),

                  const _SettingsGroup(
                    label: 'DANGER ZONE',
                    items: [
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
                      style: AppTextStyles.micro(context.appTextTertiary),
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
      backgroundColor: context.appBgElevated,
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
                            context.appTextPrimary)),
                    subtitle: Text(program.description,
                        style: AppTextStyles.caption(
                            context.appTextSecondary)),
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

  void _showBodyMetricsEditor(BuildContext context, WidgetRef ref, UserProfile? profile) {
    if (profile == null) return;

    double? tempHeight = profile.heightCm;
    double? tempWeight = profile.bodyWeightKg;

    // Controllers created once outside StatefulBuilder to avoid recreation on rebuild
    final heightController = TextEditingController(text: profile.heightCm?.toStringAsFixed(0) ?? '');
    final weightController = TextEditingController(text: profile.bodyWeightKg?.toStringAsFixed(1) ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (innerCtx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(innerCtx).viewInsets.bottom,
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                top: AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Body Metrics', style: AppTextStyles.headingLarge(context.appTextPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            filled: true,
                            fillColor: context.appBgCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                          onChanged: (v) => tempHeight = double.tryParse(v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            filled: true,
                            fillColor: context.appBgCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          ),
                          onChanged: (v) => tempWeight = double.tryParse(v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      onPressed: () {
                        ref.read(userProfileProvider.notifier).update(
                              (p) => p.copyWith(
                                heightCm: tempHeight,
                                bodyWeightKg: tempWeight,
                              ),
                            );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Dispose if user dismisses without saving
      heightController.dispose();
      weightController.dispose();
    });
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, UserProfile? profile) {
    if (profile == null) return;

    final nameController = TextEditingController(text: profile.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            top: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: AppTextStyles.headingLarge(context.appTextPrimary)),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: context.appBgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  onPressed: () {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      ref.read(userProfileProvider.notifier).update(
                            (p) => p.copyWith(name: newName),
                          );
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    ).whenComplete(() => nameController.dispose());
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
            style: AppTextStyles.labelUppercase(context.appTextSecondary),
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
                        color: context.appBgElevated,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        color: item.isDestructive
                            ? AppColors.coral
                            : context.appTextSecondary,
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
                            : context.appTextPrimary,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: AppTextStyles.caption(
                                context.appTextSecondary),
                          )
                        : null,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: context.appTextTertiary,
                      size: 18,
                    ),
                    onTap: item.onTap ?? () {},
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: AppSpacing.xxl + AppSpacing.lg + 36,
                      color: context.appBorder,
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
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    this.onTap,
  });
}
