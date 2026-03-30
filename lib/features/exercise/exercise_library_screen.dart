import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../shared/constants/exercises.dart';
import '../../shared/widgets/premium_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/muscle_chip.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();

  static const _categories = [
    'All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio',
  ];

  List<Map<String, dynamic>> get _filteredExercises {
    return kExerciseData.values.where((e) {
      final matchesSearch = _searchQuery.isEmpty ||
          (e['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          (e['muscle'] as String)
              .toLowerCase()
              .contains(_selectedCategory.toLowerCase()) ||
          (e['category'] as String)
              .toLowerCase()
              .contains(_selectedCategory.toLowerCase());
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercises = _filteredExercises;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bg : AppColors.bgLight,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.ambientGradient),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise Library',
                        style: AppTextStyles.headingLarge(
                          isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 2),
                      Text(
                        '${kExerciseData.length}+ exercises',
                        style: AppTextStyles.caption(
                          isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                        ),
                      ).animate().fadeIn(delay: 60.ms, duration: 350.ms),

                      const SizedBox(height: AppSpacing.lg),

                      // ── SEARCH BAR ──────────────────────────────────
                      PremiumCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        showGradientBorder: false,
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: isDark
                                  ? AppColors.textTertiary
                                  : AppColors.textTertiaryLight,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                style: AppTextStyles.body(
                                  isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search exercises...',
                                  hintStyle: AppTextStyles.body(
                                    isDark
                                        ? AppColors.textTertiary
                                        : AppColors.textTertiaryLight,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: isDark
                                      ? AppColors.textTertiary
                                      : AppColors.textTertiaryLight,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),

                // ── CATEGORY FILTER PILLS ───────────────────────────────
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : (isDark
                                    ? AppColors.bgCard
                                    : AppColors.bgCardLight),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : (isDark
                                      ? AppColors.border
                                      : AppColors.borderLight),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: AppTextStyles.caption(
                              isSelected
                                  ? AppColors.bg
                                  : (isDark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 140.ms, duration: 350.ms),

                const SizedBox(height: AppSpacing.lg),

                // ── GRID ─────────────────────────────────────────────────
                Expanded(
                  child: exercises.isEmpty
                      ? Center(
                          child: Text(
                            'No exercises found',
                            style: AppTextStyles.body(
                              isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xxl,
                            0,
                            AppSpacing.xxl,
                            AppSpacing.xxxl,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppSpacing.md,
                            mainAxisSpacing: AppSpacing.md,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: exercises.length,
                          itemBuilder: (context, i) =>
                              _ExerciseLibraryCard(
                            data: exercises[i],
                            isDark: isDark,
                            onTap: () => _showDetailSheet(
                              context,
                              exercises[i],
                              isDark,
                            ),
                          ).animate().fadeIn(
                                delay:
                                    Duration(milliseconds: 40 * (i % 8)),
                                duration: 350.ms,
                              ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(
      BuildContext context, Map<String, dynamic> data, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseDetailSheet(data: data, isDark: isDark),
    );
  }
}

// ── EXERCISE LIBRARY CARD ─────────────────────────────────────────────────────

class _ExerciseLibraryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final VoidCallback onTap;

  const _ExerciseLibraryCard(
      {required this.data, required this.isDark, required this.onTap});

  Color get _categoryColor {
    final cat = (data['category'] as String? ?? '').toLowerCase();
    if (cat.contains('push')) return AppColors.coral;
    if (cat.contains('pull')) return AppColors.sky;
    if (cat.contains('legs')) return AppColors.warm;
    return AppColors.accent;
  }

  IconData get _categoryIcon {
    final cat = (data['category'] as String? ?? '').toLowerCase();
    if (cat.contains('push')) return Icons.fitness_center_rounded;
    if (cat.contains('pull')) return Icons.rowing_rounded;
    if (cat.contains('legs')) return Icons.directions_run_rounded;
    return Icons.sports_gymnastics_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.borderLight,
            width: 0.5,
          ),
          boxShadow: AppColors.subtleShadow,
          gradient: LinearGradient(
            colors: [
              _categoryColor.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MuscleChip.fromMuscle(data['muscle'] as String? ?? ''),
            const Spacer(),
            ShaderMask(
              shaderCallback: (b) =>
                  LinearGradient(colors: [_categoryColor, _categoryColor])
                      .createShader(b),
              child: Icon(_categoryIcon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data['name'] as String? ?? '',
              style: AppTextStyles.bodyStrong(
                isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.bgElevated : AppColors.bgElevatedLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                (data['equipment'] as String? ?? '')
                    .replaceAll('_', ' '),
                style: AppTextStyles.micro(
                  isDark ? AppColors.textTertiary : AppColors.textTertiaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── EXERCISE DETAIL SHEET ─────────────────────────────────────────────────────

class _ExerciseDetailSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _ExerciseDetailSheet({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final formCues =
        (data['formCues'] as List<dynamic>? ?? []).cast<String>();
    final targetMuscles =
        (data['targetMuscles'] as List<dynamic>? ?? []).cast<String>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl)),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.border : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['name'] as String? ?? '',
                            style: AppTextStyles.headingLarge(
                              isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        MuscleChip.fromMuscle(
                            data['muscle'] as String? ?? ''),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.bgElevated
                                : AppColors.bgElevatedLight,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            (data['equipment'] as String? ?? '')
                                .replaceAll('_', ' '),
                            style: AppTextStyles.micro(
                              isDark
                                  ? AppColors.textTertiary
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    if (formCues.isNotEmpty) ...[
                      SectionHeader('Form Cues'),
                      ...formCues.map((cue) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.md),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentDim,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.check_rounded,
                                      color: AppColors.accent, size: 12),
                                ),
                                Expanded(
                                  child: Text(
                                    cue,
                                    style: AppTextStyles.body(
                                      isDark
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (targetMuscles.isNotEmpty) ...[
                      SectionHeader('Target Muscles'),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: targetMuscles
                            .map((m) => MuscleChip.fromMuscle(m))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
