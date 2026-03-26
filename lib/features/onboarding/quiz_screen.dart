import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_button.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/services/program_selector.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestion = 0;

  // Q1 — goal
  String? _goal;
  // Q2 — experience
  String? _experience;
  // Q3 — days per week
  int? _daysPerWeek;
  // Q4 — equipment
  String? _equipment;
  // Q5 — injuries (multi-select)
  final Set<String> _injuries = {};

  bool get _canAdvance {
    switch (_currentQuestion) {
      case 0:
        return _goal != null;
      case 1:
        return _experience != null;
      case 2:
        return _daysPerWeek != null;
      case 3:
        return _equipment != null;
      case 4:
        return true; // injuries optional
      default:
        return false;
    }
  }

  void _next() {
    if (_currentQuestion < 4) {
      setState(() => _currentQuestion++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final supabase = Supabase.instance.client;
    final authId = supabase.auth.currentUser?.id;
    final profileId = authId ?? 'guest-${DateTime.now().millisecondsSinceEpoch}';

    final programId = ProgramSelector.select(
      goal: _goal!,
      experience: _experience!,
      daysPerWeek: _daysPerWeek!,
      equipment: _equipment!,
    );

    final profile = UserProfile(
      id: profileId,
      name: 'Athlete',
      goal: _goal!,
      experience: _experience!,
      daysPerWeek: _daysPerWeek!,
      equipment: _equipment!,
      injuries: _injuries.toList(),
      currentProgramId: programId,
      createdAt: DateTime.now(),
      onboardingComplete: true,
    );

    // 1. Save to Hive (always — even offline)
    await ref.read(userProfileProvider.notifier).save(profile);

    // 2. Sync to Supabase (only if authenticated)
    if (authId != null) {
      await _upsertProfileToSupabase(supabase, profile);
    }

    if (mounted) context.go('/today');
  }

  Future<void> _upsertProfileToSupabase(
    SupabaseClient supabase,
    UserProfile profile,
  ) async {
    try {
      await supabase.from('profiles').upsert({
        'id': profile.id,
        'name': profile.name,
        'goal': profile.goal,
        'experience': profile.experience,
        'days_per_week': profile.daysPerWeek,
        'equipment': profile.equipment,
        'injuries': profile.injuries,
        'current_program_id': profile.currentProgramId,
        'xp': profile.xp,
        'level': profile.level,
        'streak_weeks': profile.streakWeeks,
        'streak_shields': profile.streakShields,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Non-fatal: profile is already saved to Hive.
      // SyncService will retry on next connectivity event.
      debugPrint('Profile sync to Supabase failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ));
                  return SlideTransition(
                    position: offset,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentQuestion),
                  child: _buildQuestion(),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestion > 0)
                GestureDetector(
                  onTap: () => setState(() => _currentQuestion--),
                  child: const Icon(Icons.arrow_back_ios,
                      color: AppColors.textSecondary, size: 18),
                )
              else
                const SizedBox(width: 18),
              Text(
                '${_currentQuestion + 1} of 5',
                style: AppTextStyles.caption(AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestion + 1) / 5,
              minHeight: 3,
              backgroundColor: AppColors.bgElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    switch (_currentQuestion) {
      case 0:
        return _buildGoalQuestion();
      case 1:
        return _buildExperienceQuestion();
      case 2:
        return _buildDaysQuestion();
      case 3:
        return _buildEquipmentQuestion();
      case 4:
        return _buildInjuriesQuestion();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGoalQuestion() {
    final options = [
      ('build_muscle', 'Build Muscle', '💪', 'Hypertrophy-focused training'),
      ('lose_fat', 'Lose Fat', '🔥', 'Burn calories and tone up'),
      ('get_stronger', 'Get Stronger', '🏋️', 'Focus on lifts and strength'),
      ('general', 'General Fitness', '⚡', 'Stay active and healthy'),
    ];
    return _buildSingleSelectPage(
      question: "What's your main goal?",
      subtitle: 'This shapes your entire program.',
      options: options,
      selected: _goal,
      onSelect: (v) => setState(() => _goal = v),
    );
  }

  Widget _buildExperienceQuestion() {
    final options = [
      ('beginner', 'Complete Beginner', '🌱', 'Less than 6 months lifting'),
      ('some', 'Some Experience', '📈', '6 months to 2 years'),
      ('intermediate', 'Intermediate', '🎯', '2+ years consistent training'),
    ];
    return _buildSingleSelectPage(
      question: 'How experienced are you?',
      subtitle: 'Be honest — this tailors intensity.',
      options: options,
      selected: _experience,
      onSelect: (v) => setState(() => _experience = v),
    );
  }

  Widget _buildDaysQuestion() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How many days per week?',
              style: AppTextStyles.headingLarge(AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text('We\'ll build your split around this.',
              style: AppTextStyles.body(AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xxxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [2, 3, 4, 5, 6].map((days) {
              final isSelected = _daysPerWeek == days;
              return GestureDetector(
                onTap: () => setState(() => _daysPerWeek = days),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentDim : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$days',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'days',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentQuestion() {
    final options = [
      ('full_gym', 'Full Gym', '🏢', 'Barbells, machines, cables'),
      ('home_dumbbells', 'Home Dumbbells', '🏠', 'Dumbbells and bench'),
      ('home_bodyweight', 'No Equipment', '🤸', 'Bodyweight only'),
      ('hybrid', 'Mix of Both', '🔄', 'Gym and home combined'),
    ];
    return _buildSingleSelectPage(
      question: 'What equipment do you have?',
      subtitle: 'Exercises will be tailored to your setup.',
      options: options,
      selected: _equipment,
      onSelect: (v) => setState(() => _equipment = v),
    );
  }

  Widget _buildInjuriesQuestion() {
    final options = [
      ('lower_back', 'Lower Back', '🔴'),
      ('shoulders', 'Shoulders', '🟠'),
      ('knees', 'Knees', '🟡'),
      ('wrists', 'Wrists', '🟢'),
      ('none', 'None', '✅'),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Any injuries or limitations?',
              style: AppTextStyles.headingLarge(AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text('We\'ll avoid exercises that aggravate these.',
              style: AppTextStyles.body(AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xxxl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: options.map((opt) {
              final key = opt.$1;
              final label = opt.$2;
              final emoji = opt.$3;
              final isSelected = _injuries.contains(key);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (key == 'none') {
                      _injuries.clear();
                      _injuries.add('none');
                    } else {
                      _injuries.remove('none');
                      if (isSelected) {
                        _injuries.remove(key);
                      } else {
                        _injuries.add(key);
                      }
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentDim : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelectPage({
    required String question,
    required String subtitle,
    required List<(String, String, String, String)> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: AppTextStyles.headingLarge(AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: AppTextStyles.body(AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xxxl),
          ...options.map((opt) {
            final value = opt.$1;
            final label = opt.$2;
            final emoji = opt.$3;
            final desc = opt.$4;
            final isSelected = selected == value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onSelect(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentDim : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.accent, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: ForjaButton(
        label: _currentQuestion == 4 ? 'Start Training' : 'Next',
        onPressed: _canAdvance ? _next : null,
      ),
    );
  }
}
