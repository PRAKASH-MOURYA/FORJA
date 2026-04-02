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

  String? _goal;
  String? _experience;
  int? _daysPerWeek;
  String? _equipment;
  final Set<String> _injuries = {};
  double? _heightCm;
  double? _weightKg;

  static const int _totalQuestions = 7;

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
        return true;
      case 5:
        return _heightCm != null && _heightCm! > 0;
      case 6:
        return _weightKg != null && _weightKg! > 0;
      default:
        return false;
    }
  }

  void _next() {
    if (_currentQuestion < _totalQuestions - 1) {
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
      heightCm: _heightCm,
      bodyWeightKg: _weightKg,
    );

    await ref.read(userProfileProvider.notifier).save(profile);

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
        'height_cm': profile.heightCm,
        'body_weight_kg': profile.bodyWeightKg,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Profile sync to Supabase failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildPillIndicator(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.08, 0.0),
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

  // ── Animated pill page indicator ──────────────────────────────────────────

  Widget _buildPillIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _currentQuestion > 0
                ? () => setState(() => _currentQuestion--)
                : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _currentQuestion > 0 ? 1.0 : 0.0,
              child:  Icon(
                Icons.arrow_back_ios,
                color: context.appTextSecondary,
                size: 18,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalQuestions, (i) {
                final isActive = i == _currentQuestion;
                final isPast = i < _currentQuestion;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accent
                        : isPast
                            ? AppColors.accent.withValues(alpha: 0.4)
                            : context.appTextTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
    );
  }

  // ── Per-page hero area ────────────────────────────────────────────────────

  Widget _buildHeroArea({
    required String emoji,
    required String label,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.12),
            secondaryColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -12,
            left: 12,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style:  TextStyle(fontSize: 42)),
                 SizedBox(height: 6),
                Text(
                  label,
                  style:  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.appTextSecondary,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Premium option card ───────────────────────────────────────────────────

  Widget _buildPremiumOptionCard({
    required String value,
    required String label,
    required String emoji,
    required String desc,
    required bool isSelected,
    required VoidCallback onTap,
    Color accentColor = AppColors.accent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentDim : context.appBgCard,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.5)
                  : context.appBorder,
              width: isSelected ? 1.5 : 0.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.18)
                      : context.appBgElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style:  TextStyle(fontSize: 22)),
                ),
              ),
               SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? accentColor : context.appTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style:  TextStyle(
                        fontSize: 13,
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.elasticOut,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child:  Icon(Icons.check, color: Colors.black, size: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Question routing ──────────────────────────────────────────────────────

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
      case 5:
        return _buildHeightQuestion();
      case 6:
        return _buildWeightQuestion();
      default:
        return  SizedBox.shrink();
    }
  }

  Widget _buildSingleSelectPage({
    required String question,
    required String subtitle,
    required List<(String, String, String, String)> options,
    required String? selected,
    required ValueChanged<String> onSelect,
    required String heroEmoji,
    required String heroLabel,
    required Color heroPrimary,
    required Color heroSecondary,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroArea(
            emoji: heroEmoji,
            label: heroLabel,
            primaryColor: heroPrimary,
            secondaryColor: heroSecondary,
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question,
                    style: AppTextStyles.headingLarge(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text(subtitle,
                    style: AppTextStyles.body(context.appTextSecondary)),
                const SizedBox(height: AppSpacing.xl),
                ...options.map((opt) => _buildPremiumOptionCard(
                      value: opt.$1,
                      label: opt.$2,
                      emoji: opt.$3,
                      desc: opt.$4,
                      isSelected: selected == opt.$1,
                      onTap: () => onSelect(opt.$1),
                    )),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalQuestion() {
    return _buildSingleSelectPage(
      heroEmoji: '🎯',
      heroLabel: 'YOUR GOAL',
      heroPrimary: AppColors.accent,
      heroSecondary: AppColors.sky,
      question: "What's your main goal?",
      subtitle: 'This shapes your entire program.',
      options: const [
        ('build_muscle', 'Build Muscle', '💪', 'Hypertrophy-focused training'),
        ('lose_fat', 'Lose Fat', '🔥', 'Burn calories and tone up'),
        ('get_stronger', 'Get Stronger', '🏋️', 'Focus on lifts and strength'),
        ('general', 'General Fitness', '⚡', 'Stay active and healthy'),
      ],
      selected: _goal,
      onSelect: (v) => setState(() => _goal = v),
    );
  }

  Widget _buildExperienceQuestion() {
    return _buildSingleSelectPage(
      heroEmoji: '📊',
      heroLabel: 'EXPERIENCE',
      heroPrimary: AppColors.warm,
      heroSecondary: AppColors.coral,
      question: 'How experienced are you?',
      subtitle: 'Be honest — this tailors intensity.',
      options: const [
        ('beginner', 'Complete Beginner', '🌱', 'Less than 6 months lifting'),
        ('some', 'Some Experience', '📈', '6 months to 2 years'),
        ('intermediate', 'Intermediate', '🎯', '2+ years consistent training'),
      ],
      selected: _experience,
      onSelect: (v) => setState(() => _experience = v),
    );
  }

  Widget _buildDaysQuestion() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroArea(
            emoji: '📅',
            label: 'WEEKLY SCHEDULE',
            primaryColor: AppColors.sky,
            secondaryColor: AppColors.accent,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How many days per week?',
                    style: AppTextStyles.headingLarge(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text("We'll build your split around this.",
                    style: AppTextStyles.body(context.appTextSecondary)),
                const SizedBox(height: AppSpacing.xxxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [2, 3, 4, 5, 6].map((days) {
                    final isSelected = _daysPerWeek == days;
                    return GestureDetector(
                      onTap: () => setState(() => _daysPerWeek = days),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: 56,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentDim
                              : context.appBgCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent.withValues(alpha: 0.5)
                                : context.appBorder,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
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
                                    : context.appTextPrimary,
                              ),
                            ),
                            Text(
                              'days',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? AppColors.accent
                                    : context.appTextSecondary,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentQuestion() {
    return _buildSingleSelectPage(
      heroEmoji: '🏋️',
      heroLabel: 'YOUR SETUP',
      heroPrimary: AppColors.coral,
      heroSecondary: AppColors.warm,
      question: 'What equipment do you have?',
      subtitle: 'Exercises will be tailored to your setup.',
      options: const [
        ('full_gym', 'Full Gym', '🏢', 'Barbells, machines, cables'),
        ('home_dumbbells', 'Home Dumbbells', '🏠', 'Dumbbells and bench'),
        ('home_bodyweight', 'No Equipment', '🤸', 'Bodyweight only'),
        ('hybrid', 'Mix of Both', '🔄', 'Gym and home combined'),
      ],
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
      ('none', 'No Limitations', '✅'),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroArea(
            emoji: '🩺',
            label: 'HEALTH CHECK',
            primaryColor: AppColors.warm,
            secondaryColor: AppColors.sky,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Any injuries or limitations?',
                    style: AppTextStyles.headingLarge(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text("We'll avoid exercises that aggravate these.",
                    style: AppTextStyles.body(context.appTextSecondary)),
                const SizedBox(height: AppSpacing.xxl),
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
                          color: isSelected
                              ? AppColors.warmDim
                              : context.appBgCard,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.warm.withValues(alpha: 0.5)
                                : context.appBorder,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.warm.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(emoji,
                                style:  TextStyle(fontSize: 16)),
                             SizedBox(width: AppSpacing.sm),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.warm
                                    : context.appTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightQuestion() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroArea(
            emoji: '📏',
            label: 'YOUR HEIGHT',
            primaryColor: AppColors.accent,
            secondaryColor: AppColors.warm,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How tall are you?',
                    style: AppTextStyles.headingLarge(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                    'Used to calculate protein targets and daily energy expenditure.',
                    style: AppTextStyles.body(context.appTextSecondary)),
                const SizedBox(height: AppSpacing.xxxl),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style:  TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 175',
                          hintStyle: TextStyle(
                              color:
                                  context.appTextSecondary.withValues(alpha: 0.5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide:
                                BorderSide(color: context.appBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide:  BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          filled: true,
                          fillColor: context.appBgCard,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _heightCm = double.tryParse(val);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('cm',
                        style: TextStyle(
                            fontSize: 20, color: context.appTextSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightQuestion() {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroArea(
            emoji: '⚖️',
            label: 'YOUR WEIGHT',
            primaryColor: AppColors.sky,
            secondaryColor: AppColors.coral,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("What's your current weight?",
                    style: AppTextStyles.headingLarge(context.appTextPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                    'Used to generate your daily protein target (1.6g per kg).',
                    style: AppTextStyles.body(context.appTextSecondary)),
                const SizedBox(height: AppSpacing.xxxl),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style:  TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 75.5',
                          hintStyle: TextStyle(
                              color:
                                  context.appTextSecondary.withValues(alpha: 0.5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide:
                                BorderSide(color: context.appBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            borderSide:  BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          filled: true,
                          fillColor: context.appBgCard,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _weightKg = double.tryParse(val);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('kg',
                        style: TextStyle(
                            fontSize: 20, color: context.appTextSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: ForjaButton(
        label: _currentQuestion == _totalQuestions - 1
            ? 'Start Training'
            : 'Next',
        onPressed: _canAdvance ? _next : null,
      ),
    );
  }
}
