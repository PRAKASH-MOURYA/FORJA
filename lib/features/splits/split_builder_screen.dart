import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/constants/exercises.dart';
import '../../shared/models/custom_split.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/services/hive_service.dart';
import '../../shared/widgets/forja_button.dart';
import '../../shared/widgets/forja_card.dart';
import '../../shared/widgets/forja_pill.dart';

class SplitBuilderScreen extends ConsumerStatefulWidget {
  const SplitBuilderScreen({super.key});

  @override
  ConsumerState<SplitBuilderScreen> createState() =>
      _SplitBuilderScreenState();
}

class _SplitBuilderScreenState extends ConsumerState<SplitBuilderScreen> {
  int _daysCount = 3;
  late final List<_DayConfig> _days;
  late final List<TextEditingController> _dayNameControllers;

  final _splitNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _days = List.generate(_daysCount, (i) {
      return _DayConfig(dayName: 'Day ${i + 1}', exerciseIds: []);
    });
    _dayNameControllers =
        List.generate(_daysCount, (i) => TextEditingController(text: _days[i].dayName));
  }

  @override
  void dispose() {
    for (final c in _dayNameControllers) {
      c.dispose();
    }
    _splitNameController.dispose();
    super.dispose();
  }

  void _setDaysCount(int count) {
    if (count == _daysCount) return;

    setState(() {
      if (count > _daysCount) {
        final additional = count - _daysCount;
        for (var i = 0; i < additional; i++) {
          final dayIndex = _days.length;
          _days.add(_DayConfig(
            dayName: 'Day ${dayIndex + 1}',
            exerciseIds: [],
          ));
          _dayNameControllers
              .add(TextEditingController(text: _days[dayIndex].dayName));
        }
      } else {
        final removeCount = _daysCount - count;
        for (var i = 0; i < removeCount; i++) {
          _dayNameControllers.removeLast().dispose();
          _days.removeLast();
        }
      }

      _daysCount = count;
    });
  }

  Future<void> _showExercisePicker(int dayIndex) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final grouped = <String, List<MapEntry<String, Map<String, dynamic>>>>{};
        for (final entry in kExerciseData.entries) {
          final category = entry.value['category'] as String? ?? 'other';
          grouped.putIfAbsent(category, () => []).add(entry);
        }

        final sortedCategories = grouped.keys.toList()..sort();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
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
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.md),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xxl,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                          AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Pick Exercises',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.textSecondary,
                                size: 22,
                              ),
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
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
                            for (final category in sortedCategories) ...[
                              Text(
                                category.toUpperCase(),
                                style: AppTextStyles.labelUppercase(
                                  AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ...grouped[category]!.map((exerciseEntry) {
                                final exerciseId = exerciseEntry.key;
                                final exerciseData = exerciseEntry.value;
                                final exerciseName =
                                    exerciseData['name'] as String? ??
                                        exerciseId;
                                final muscle =
                                    exerciseData['muscle'] as String? ?? '';
                                final isSelected = _days[dayIndex]
                                    .exerciseIds
                                    .contains(exerciseId);

                                return CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (checked) {
                                    setState(() {
                                      final ids = _days[dayIndex].exerciseIds;
                                      if (checked == true) {
                                        ids.add(exerciseId);
                                      } else {
                                        ids.remove(exerciseId);
                                      }
                                    });
                                    setModalState(() {});
                                  },
                                  title: Text(
                                    exerciseName,
                                    style: AppTextStyles.bodyStrong(
                                      AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: muscle.isNotEmpty
                                      ? Text(
                                          muscle,
                                          style: AppTextStyles.caption(
                                            AppColors.textSecondary,
                                          ),
                                        )
                                      : null,
                                  controlAffinity:
                                      ListTileControlAffinity.trailing,
                                );
                              }),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _saveSplit() async {
    final name = _splitNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please name your split.')),
      );
      return;
    }

    final split = CustomSplit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      daysCount: _daysCount,
      days: _days
          .asMap()
          .entries
          .map((entry) {
            final dayIndex = entry.key;
            final day = entry.value;
            final controllerText = _dayNameControllers[dayIndex].text.trim();
            return SplitDay(
              dayName: controllerText.isEmpty ? day.dayName : controllerText,
              exerciseIds: List.from(day.exerciseIds),
            );
          })
          .toList(),
      createdAt: DateTime.now(),
    );

    await HiveService.customSplits.put(split.id, split);

    final profile = ref.read(userProfileProvider);
    if (profile != null) {
      await ref.read(userProfileProvider.notifier).update(
            (p) => p.copyWith(customSplitId: split.id),
          );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          'Build Your Split',
          style: AppTextStyles.heading(AppColors.textPrimary),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textSecondary, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              TextField(
                controller: _splitNameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Push / Pull / Legs',
                  filled: true,
                  fillColor: AppColors.bgElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: const BorderSide(
                      color: AppColors.borderHover,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Text(
                    'NUMBER OF DAYS',
                    style: AppTextStyles.labelUppercase(
                      AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              Wrap(
                spacing: AppSpacing.sm,
                children: List.generate(5, (i) {
                  final count = i + 2; // 2..6
                  final selected = count == _daysCount;
                  return GestureDetector(
                    onTap: () => _setDaysCount(count),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentGlow
                            : AppColors.bgElevated,
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: selected ? AppColors.accent : AppColors.border,
                          width: selected ? 1.0 : 0.5,
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.bodyStrong(
                          selected ? AppColors.accent : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: ListView.builder(
                  itemCount: _days.length,
                  itemBuilder: (context, dayIndex) {
                    final day = _days[dayIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: ForjaCard(
                        padding: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Day ${dayIndex + 1}',
                                    style: AppTextStyles.bodyStrong(
                                      AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: TextField(
                                      controller: _dayNameControllers[dayIndex],
                                      onChanged: (v) =>
                                          day.dayName = v,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 8,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: day.exerciseIds.map((exerciseId) {
                                  final exerciseData =
                                      kExerciseData[exerciseId];
                                  final exerciseName =
                                      exerciseData?['name'] as String? ??
                                          exerciseId;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        day.exerciseIds.remove(exerciseId);
                                      });
                                    },
                                    child: ForjaPill.accent(
                                      label: exerciseName,
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              GestureDetector(
                                onTap: () => _showExercisePicker(dayIndex),
                                child: Row(
                                  children: [
                                    const Icon(Icons.add,
                                        color: AppColors.accent, size: 18),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      '+ Add Exercise',
                                      style: AppTextStyles.body(
                                          AppColors.accent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
              ForjaButton(
                label: 'Save Split',
                onPressed: _saveSplit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayConfig {
  String dayName;
  final List<String> exerciseIds;

  _DayConfig({
    required this.dayName,
    required this.exerciseIds,
  });
}

