import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_card.dart';
import '../../shared/widgets/forja_pill.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/animated_progress_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/constants/dummy_data.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/constants/programs.dart';
import 'profile_stats_provider.dart';
import 'xp_banner.dart';
import 'widgets/export_section.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/providers/sync_provider.dart';
import '../../shared/services/hive_service.dart';
import '../../shared/services/export_service.dart';
import '../../shared/services/notification_service.dart';
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
      body: SafeArea(
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

              // Hero profile section — XP ring + name
              Center(
                child: Column(
                  children: [
                    AnimatedProgressRing(
                      size: ProgressRingSize.md,
                      progress:
                          (stats.xp / DummyData.xpToNextLevel).clamp(0.0, 1.0),
                      center: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: context.appAccent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'A',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: context.isDark
                                ? AppColors.textInverse
                                : AppColors.textInverseLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      name,
                      style: AppTextStyles.headingLarge(context.appTextPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_levelLabel(stats.level)} · $experience',
                      style: AppTextStyles.subhead(context.appTextSecondary),
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

              const SizedBox(height: AppSpacing.xxl),

              // ── ACHIEVEMENTS GRID ────────────────────────────────
              SectionHeader(
                'Achievements',
                subtitle:
                    '${DummyData.achievements.where((a) => a['earned'] == true).length}/${DummyData.achievements.length}',
              ),
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: DummyData.achievements.asMap().entries.map((entry) {
                  final i = entry.key;
                  final badge = entry.value;
                  final earned = badge['earned'] as bool;
                  return GestureDetector(
                    onTap:
                        earned ? () => _showBadgeDetail(context, badge) : null,
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: earned
                                ? context.appAccent
                                : context.appBgElevated,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            badge['icon'] as String,
                            style: TextStyle(
                              fontSize: 22,
                              color: earned
                                  ? (context.isDark
                                      ? AppColors.textInverse
                                      : AppColors.textInverseLight)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge['name'] as String,
                          style: AppTextStyles.micro(
                            earned
                                ? context.appTextSecondary
                                : context.appTextTertiary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 360 + i * 40),
                        duration: 350.ms,
                      );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Current program card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.appBgCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: context.appBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Program',
                            style:
                                AppTextStyles.micro(context.appTextSecondary),
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
                      onTap: () => _showProgramPicker(context, ref),
                      child: const ForjaPill.accent(label: 'Change'),
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
                    Icon(Icons.groups_rounded, color: context.appTextSecondary),
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
                    subtitle:
                        '${profile?.heightCm?.toStringAsFixed(0) ?? "--"} cm · ${profile?.bodyWeightKg?.toStringAsFixed(1) ?? "--"} kg',
                    onTap: () => _showBodyMetricsEditor(context, ref, profile),
                  ),
                  _SettingItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    onTap: () => _showEditProfile(context, ref, profile),
                  ),
                  _SettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Reminders & updates',
                    onTap: () => _showNotificationsSettings(context, ref),
                  ),
                  _SettingItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy',
                    subtitle: 'Data & permissions',
                    onTap: () => _showPrivacySettings(context),
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
                    onTap: () =>
                        ref.read(themeModeProvider.notifier).toggleTheme(),
                  ),
                  _SettingItem(
                    icon: Icons.tune_rounded,
                    title: 'Units',
                    subtitle: 'Metric (kg)',
                    onTap: () => _showUnitsSettings(context),
                  ),
                  _SettingItem(
                    icon: Icons.timer_outlined,
                    title: 'Rest Timer',
                    subtitle: '90 seconds default',
                    onTap: () => _showRestTimerSettings(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsGroup(
                label: 'DATA',
                items: [
                  _SettingItem(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Sync & Backup',
                    subtitle: 'Last synced today',
                    onTap: () => _showSyncSettings(context, ref),
                  ),
                  _SettingItem(
                    icon: Icons.download_outlined,
                    title: 'Export Data',
                    onTap: () => _showExportDataSettings(context, profile),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Data Export
              ExportSection(profile: profile),
              const SizedBox(height: AppSpacing.xl),

              _SettingsGroup(
                label: 'DANGER ZONE',
                items: [
                  _SettingItem(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Account',
                    isDestructive: true,
                    onTap: () => _showDeleteAccount(context, ref),
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
    );
  }

  void _showBadgeDetail(BuildContext context, Map<String, dynamic> badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge['icon'] as String, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(badge['name'] as String,
                style: AppTextStyles.headingLarge(context.appTextPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text('Badge earned!',
                style: AppTextStyles.body(context.appTextSecondary)),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showProgramPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: ListView(
          shrinkWrap: true,
          children: kPrograms
              .map((program) => ListTile(
                    title: Text(program.name,
                        style:
                            AppTextStyles.bodyStrong(context.appTextPrimary)),
                    subtitle: Text(program.description,
                        style: AppTextStyles.caption(context.appTextSecondary)),
                    onTap: () {
                      ref.read(userProfileProvider.notifier).update(
                            (p) => p.copyWith(
                              currentProgramId: program.id,
                              customSplitId:
                                  null, // clear custom split so todayProgramProvider uses program template
                            ),
                          );
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showBodyMetricsEditor(
      BuildContext context, WidgetRef ref, UserProfile? profile) {
    if (profile == null) return;

    double? tempHeight = profile.heightCm;
    double? tempWeight = profile.bodyWeightKg;

    // Controllers created once outside StatefulBuilder to avoid recreation on rebuild
    final heightController =
        TextEditingController(text: profile.heightCm?.toStringAsFixed(0) ?? '');
    final weightController = TextEditingController(
        text: profile.bodyWeightKg?.toStringAsFixed(1) ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
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
                  Text('Body Metrics',
                      style:
                          AppTextStyles.headingLarge(context.appTextPrimary)),
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
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md)),
                          ),
                          onChanged: (v) => tempHeight = double.tryParse(v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            filled: true,
                            fillColor: context.appBgCard,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md)),
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
                      child: const Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

  void _showEditProfile(
      BuildContext context, WidgetRef ref, UserProfile? profile) {
    if (profile == null) return;

    final nameController = TextEditingController(text: profile.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
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
              Text('Edit Profile',
                  style: AppTextStyles.headingLarge(context.appTextPrimary)),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: context.appBgCard,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
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
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    ).whenComplete(() => nameController.dispose());
  }

  void _showNotificationsSettings(BuildContext context, WidgetRef ref) {
    bool workoutReminder = true;
    bool restTimerAlerts = true;
    bool progressUpdates = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (innerCtx, setState) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications',
                        style:
                            AppTextStyles.headingLarge(context.appTextPrimary)),
                    TextButton(
                      onPressed: () async {
                        await NotificationService.requestPermission();
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Notification permissions updated')),
                          );
                        }
                      },
                      child: const Text('Permissions'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  title: const Text('Workout Reminders'),
                  subtitle: const Text('Daily reminder to work out'),
                  value: workoutReminder,
                  onChanged: (v) async {
                    setState(() => workoutReminder = v);
                    if (v) {
                      await NotificationService.scheduleWorkoutReminder(
                          TimeOfDay(hour: 8, minute: 0));
                    } else {
                      await NotificationService.cancelReminder();
                    }
                  },
                ),
                if (workoutReminder)
                  ListTile(
                    title: const Text('Reminder Time'),
                    subtitle: const Text('8:00 AM'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: innerCtx,
                        initialTime: TimeOfDay(hour: 8, minute: 0),
                      );
                      if (time != null) {
                        await NotificationService.scheduleWorkoutReminder(time);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Reminder set for ${time.format(context)}')),
                          );
                        }
                      }
                    },
                  ),
                SwitchListTile(
                  title: const Text('Rest Timer Alerts'),
                  subtitle: const Text('Vibrate when rest timer ends'),
                  value: restTimerAlerts,
                  onChanged: (v) {
                    setState(() => restTimerAlerts = v);
                  },
                ),
                SwitchListTile(
                  title: const Text('Progress Updates'),
                  subtitle: const Text('Weekly summary notifications'),
                  value: progressUpdates,
                  onChanged: (v) {
                    setState(() => progressUpdates = v);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy & Data',
                style: AppTextStyles.headingLarge(context.appTextPrimary)),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Data Sharing'),
              subtitle: const Text('Anonymous usage data'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.cookie),
              title: const Text('Cookies'),
              subtitle: const Text('Manage cookie preferences'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              subtitle: const Text('Opt out of analytics'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear Local Data'),
              subtitle: const Text('Remove cached data'),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Clear Data?'),
                    content: const Text(
                        'This will clear all cached data. Your account data will remain.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Local data cleared')));
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showUnitsSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Units',
                style: AppTextStyles.headingLarge(context.appTextPrimary)),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              title: const Text('Weight'),
              subtitle: const Text('Metric (kg)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Distance'),
              subtitle: const Text('Metric (km)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showRestTimerSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (innerCtx, setState) {
          int defaultRest = 90;
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rest Timer',
                    style: AppTextStyles.headingLarge(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.lg),
                Text('Default rest time',
                    style: AppTextStyles.bodyStrong(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [60, 90, 120, 180].map((seconds) {
                    final isSelected = defaultRest == seconds;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => defaultRest = seconds),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : context.appBgCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : context.appBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${seconds}s',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : context.appTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSyncSettings(BuildContext context, WidgetRef ref) {
    final syncState = ref.read(syncProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sync & Backup',
                style: AppTextStyles.headingLarge(context.appTextPrimary)),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              subtitle: Text(syncState.lastSyncAt != null
                  ? 'Last synced ${_formatLastSync(syncState.lastSyncAt!)}'
                  : 'Never synced'),
              trailing: syncState.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () => ref.read(syncProvider.notifier).syncPending(),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Auto Sync'),
              subtitle: const Text('Sync when connected'),
              trailing: Switch(
                value: true,
                onChanged: (v) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wifi_off),
              title: const Text('Offline Mode'),
              subtitle: const Text('Work out without internet'),
              trailing: Switch(
                value: false,
                onChanged: (v) {},
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String _formatLastSync(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showExportDataSettings(BuildContext context, UserProfile? profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.appBgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export Data',
                style: AppTextStyles.headingLarge(context.appTextPrimary)),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ExportService.exportCsv();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('CSV exported successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: const Text('Report format'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ExportService.exportPdf(profile);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('PDF exported successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all your data. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // TODO: Actually delete account - clear Hive data, sign out from Supabase
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Account deletion initiated. Please contact support.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
          padding:
              const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
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
                            style:
                                AppTextStyles.caption(context.appTextSecondary),
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
