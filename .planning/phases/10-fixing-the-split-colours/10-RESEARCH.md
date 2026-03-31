# Phase 10: Fixing the Split, Colours & UX Polish — Research

**Researched:** 2026-03-31
**Domain:** Flutter/Dart — Freezed models, Riverpod StateNotifier, fl_chart, flutter_animate, Drag-and-drop UI, Hive persistence, light/dark theme consistency
**Confidence:** HIGH (all findings sourced directly from existing codebase)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**A. Split Day Scheduling**
- Root cause confirmed: `customSplitId` non-null permanently overrides pre-built plan. Fix = clear `customSplitId` on profile when user selects a pre-built plan.
- Replace cyclic day-index approach with explicit weekday assignment (`Map<int, int>` weekday→dayIndex on `CustomSplit`).
- UI: Calendar-week drag-and-drop view at top of Split Builder (Mon–Sun slots).
- Unassigned slots = rest day; rest day has "free workout" escape hatch.
- `todayProgramProvider` uses `DateTime.now().weekday` lookup into `CustomSplit.weekdayMap`.
- Data model change: `CustomSplit` gets `weekdayMap: Map<int, int>` — `SplitDay` unchanged.

**B. Exercise Freedom During Workout**
- Floating pill button `⊞ Exercises (4)` bottom-right of WorkoutScreen.
- Tap → bottom sheet, all exercises with checkmarks on fully-completed ones.
- Tapping an exercise in sheet jumps directly to it; prior exercise stays in-progress.
- Before CompleteScreen: "Finish Up" screen listing exercises with 0 sets logged.
- Each row has "Add Sets" (jumps back) or "Skip" (marks intentionally skipped).
- `WorkoutProvider` changes: remove linear `currentExerciseIndex` constraint; per-exercise set state as `Map<exerciseId, ExerciseSetState>`.

**C. Readiness Circle Animation**
- Replace small dot + text readiness banner on TodayScreen with large animated circle hero.
- Layout: streak weeks left, circle center, weekly volume right.
- StatsRow merged into this hero section (removed from separate position below HeroWorkoutCard).
- Animation: plays every TodayScreen load, arc 0→score 800ms ease-out, number counts up.
- Color zones: 0–40 = `AppColors.danger`, 41–70 = `AppColors.warning`, 71–100 = `AppColors.positive`.
- Labels: "Recover" / "Moderate" / "Ready".
- Base: existing `AnimatedProgressRing` + `TweenAnimationBuilder` for count-up.

**D. Consistency Grid + Performance Arrows**
- Green = workout logged; Red = missed (split day assigned, no log); Neutral = rest/future.
- Weekly volume arrow: green up / red down vs last week + percentage delta.
- Strength trend chart: green line = 1RM trending up, red = trending down, neutral = no change.
- `fl_chart` `LineChartBarData.color` based on slope of last two data points.

**Additional Fixes (locked)**
- Rest timer: remove from `PremiumCard`, make full-width `Container` with `EdgeInsets.zero` horizontal padding.
- Dynamic sets: start with 1 set + "Add Set" button; show last session + PR to beat below exercise name.
- App restart bug: `completeWorkout()` must not touch `userProfileProvider` or router in ways triggering full app reload.
- Light mode: `SplitBuilderScreen` uses hardcoded `AppColors.bg` → replace with `context.appBg`; audit all `lib/features/` screens.

### Claude's Discretion
- None explicitly stated.

### Deferred Ideas (OUT OF SCOPE)
- None explicitly listed; items not in CONTEXT.md sections are out of scope.
</user_constraints>

---

## Summary

Phase 10 addresses 9 concrete, well-scoped bugs and polish items across 4 themes. Every issue is identified with a root cause or specific UX decision in CONTEXT.md, making this a surgical fix phase rather than an exploratory build.

The biggest architectural change is the `CustomSplit` data model migration (`weekdayMap` field) and the `WorkoutProvider` refactor from linear index-based navigation to per-exercise Map-based state. Both are bounded changes that ripple through known call sites. The Freezed + Hive constraint means `weekdayMap` requires a new `@HiveField` index and regenerated `.freezed.dart`/`.g.dart` files.

The visual changes (readiness hero, consistency grid colours, chart line colours) are self-contained widget changes using already-imported packages (`flutter_animate`, `fl_chart`, `AnimatedProgressRing`). Light mode fixes are a systematic audit pattern, not a new system.

**Primary recommendation:** Execute in dependency order — data model changes first (CustomSplit weekdayMap), then provider refactor (WorkoutProvider), then UI changes (all can be parallelised after providers are stable).

---

## Standard Stack

### Core (already in pubspec.yaml — no new packages needed)

| Library | Version | Purpose | Usage in this phase |
|---------|---------|---------|---------------------|
| `flutter_riverpod` | ^2.5.1 | State management | WorkoutProvider refactor, todayProgramProvider weekday logic |
| `hooks_riverpod` | ^2.5.1 | Hook-aware providers | TodayScreen uses `HookConsumerWidget` |
| `freezed_annotation` | ^2.4.1 | Immutable models | `CustomSplit` weekdayMap addition |
| `hive_flutter` | ^1.1.0 | Local persistence | New `@HiveField` for weekdayMap |
| `flutter_animate` | ^4.5.0 | Animations | Readiness hero number count-up |
| `fl_chart` | ^0.68.0 | Charts | Strength trend line colour by slope |
| `flutter` built-in | — | Drag-and-drop | `Draggable` / `DragTarget` for weekday assignment |

### No New Dependencies Required

All required capabilities are already in pubspec. The drag-and-drop weekday calendar uses Flutter's built-in `Draggable`/`DragTarget` widgets — no additional package needed. `flutter_animate` handles the readiness number count-up.

**Confirm no new package needed for drag-and-drop:** Flutter's `LongPressDraggable` + `DragTarget` covers the split builder weekday grid use case fully (non-list reordering, fixed 7-slot target). The `reorderables` package is only beneficial for reordering lists, which is not the use case here.

---

## Architecture Patterns

### Recommended Project Structure (no new directories needed)

All changes are modifications to existing files. New files needed:

```
lib/features/workout/finish_up_screen.dart     # new — incomplete exercises screen
lib/features/workout/widgets/
  exercise_jump_sheet.dart                     # new — floating exercises bottom sheet
lib/features/today/widgets/
  readiness_hero_card.dart                     # new — animated circle hero
```

### Pattern 1: Freezed Model Extension with New HiveField

**What:** Adding `weekdayMap: Map<int, int>` to `CustomSplit` (a Freezed + Hive class).
**When to use:** Any time a persisted Freezed model needs a new field.
**Critical constraint:** Next available `@HiveField` index for `CustomSplit` is `5` (fields 0–4 are used). Use `@Default({})` so existing Hive records without the field deserialise without error.

```dart
// lib/shared/models/custom_split.dart — addition
@HiveField(5) @Default(<int, int>{}) Map<int, int> weekdayMap,
```

After editing: run `flutter pub run build_runner build --delete-conflicting-outputs`.

**Hive Map<int,int> adapter:** Hive supports `Map<int, int>` natively — no custom adapter needed. Dart `int` keys and values are Hive-primitive.

### Pattern 2: WorkoutProvider Map-Based Exercise State

**What:** Replace `currentExerciseIndex: int` + flat `List<bool> _setsDone` with per-exercise map state.
**Current state structure:**
```dart
// WorkoutState (current)
int currentExerciseIndex    // linear
List<SetLog> completedSets  // flat list
```

**Target state additions:**
```dart
// WorkoutState (new fields)
String? activeExerciseId              // replaces currentExerciseIndex concept
Set<String> skippedExerciseIds        // exercises explicitly skipped
```

**WorkoutScreen local state change:**
```dart
// Current: flat arrays indexed by position
List<double> _setWeights;
List<int> _setReps;
List<bool> _setsDone;

// New: maps keyed by exerciseId
Map<String, List<double>> _setWeights;  // exerciseId → weights per set
Map<String, List<int>> _setReps;        // exerciseId → reps per set
Map<String, List<bool>> _setsDone;      // exerciseId → done flags
```

**Completion condition:** `exercises.every((e) => hasAtLeastOneSet(e.id) || skipped(e.id))` replaces `isLastExercise`.

### Pattern 3: TweenAnimationBuilder for Score Count-Up

**What:** Animate readiness score number from 0 to value on TodayScreen load.
**Implementation using existing `flutter_animate`:**

```dart
// Wrap the AnimatedProgressRing or use TweenAnimationBuilder directly
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: score.toDouble()),
  duration: const Duration(milliseconds: 800),
  curve: Curves.easeOut,
  builder: (context, value, child) {
    final displayScore = value.round();
    final color = _zoneColor(displayScore);  // danger/warning/positive
    return AnimatedProgressRing(
      progress: value / 100,
      progressGradient: LinearGradient(colors: [color, color]),
      // ...center shows displayScore
    );
  },
)
```

`AnimatedProgressRing` already accepts `progressGradient`. To support a dynamic solid color, pass a `LinearGradient` with the same color at both stops — this avoids modifying the ring's painter.

**Re-trigger on load:** Because `TodayScreen` is `HookConsumerWidget`, use `useAnimationController` from `flutter_hooks` with `addPostFrameCallback` or simply rely on the fact that `TweenAnimationBuilder` retriggers whenever `key` changes. Add a `ValueKey(readiness.score)` to force replay on score change.

### Pattern 4: fl_chart Slope-Based Line Color

**What:** Determine line color from direction of last two data points.
**Current:** `_StrengthLineChart` uses `AppColors.accent` (white) hardcoded.
**New logic:**
```dart
Color _trendColor(List<double> data) {
  if (data.length < 2) return AppColors.accent; // neutral
  final slope = data.last - data[data.length - 2];
  if (slope > 0) return AppColors.positive;  // green
  if (slope < 0) return AppColors.danger;    // red
  return AppColors.accent;                   // neutral white
}
```

In `LineChartBarData`, set `color:` and match `FlDotCirclePainter` color and `belowBarData` gradient to the same color with opacity.

### Pattern 5: Consistency Grid Missed-Day Logic

**What:** Determine "missed" vs "rest" vs "workout" for each grid cell.
**Current:** `_ConsistencyHeatmap` uses `DummyData.consistencyGrid` (a hardcoded `List<List<int>>`).
**New data source:** Compute from `WorkoutRepository` + user's `CustomSplit.weekdayMap`.

```dart
// For each day cell:
// 1. Was this date in the past?                       → could be missed
// 2. Did the user's split assign a workout to this weekday?  → check weekdayMap
// 3. Is there a WorkoutLog with startedAt on that date? → logged
// Result:
//   future date OR rest day assigned  → CellState.neutral
//   split day assigned + log exists   → CellState.workout (green)
//   split day assigned + no log       → CellState.missed (red)
```

For users without a custom split, fall back to: any day where a log exists = workout, no log = neutral (cannot determine "missed" without a schedule).

### Pattern 6: Weekday Drag-and-Drop (Draggable / DragTarget)

**What:** 7-slot weekday row where users drag their split day cards onto slots.
**Flutter built-in pattern:**

```dart
// Drag source — each split day card
LongPressDraggable<int>(
  data: dayIndex,           // index into split.days
  feedback: DayCardWidget(day: split.days[dayIndex]),
  childWhenDragging: DayCardPlaceholder(),
  child: DayCardWidget(day: split.days[dayIndex]),
)

// Drop target — each weekday slot (Mon=1 ... Sun=7)
DragTarget<int>(
  onAcceptWithDetails: (details) {
    setState(() => _weekdayMap[weekday] = details.data);
  },
  builder: (context, candidateData, rejectedData) {
    final assignedDayIndex = _weekdayMap[weekday];
    return WeekdaySlotWidget(
      label: label,
      assigned: assignedDayIndex != null ? split.days[assignedDayIndex] : null,
      isHovered: candidateData.isNotEmpty,
    );
  },
)
```

`_weekdayMap` is `Map<int, int>` local state; serialised to `CustomSplit.weekdayMap` on save.

### Anti-Patterns to Avoid

- **Modifying `_DayConfig` in place during drag:** Use immutable local state (`Map<int, int>`) and rebuild. Do not mutate the existing `_days` list to store weekday assignments — weekday mapping is a separate concern.
- **Using `customSplitId` check to determine pre-built plan:** The bug is exactly this. After fix, `customSplitId` should only be non-null when user has an active custom split — clearing it is the correct semantic.
- **Calling `workoutProvider.notifier.reset()` from `_saveAndFinish` before navigation completes:** `complete_screen.dart` line 97 calls `reset()` then `context.go('/today')`. If `reset()` causes router/shell rebuild before navigation settles, it can cause the observed restart. Use `await` navigation or post-frame callback order carefully.
- **Hardcoded `AppColors.bg` instead of `context.appBg`:** Pattern already established in TodayScreen and most newer screens. SplitBuilderScreen pre-dates the `AppThemeX` extension adoption.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Animated number count-up | Custom ticker + setState | `TweenAnimationBuilder<double>` | Built into Flutter, handles curves, disposal |
| Progress arc animation | Custom `AnimationController` setup | Existing `AnimatedProgressRing` widget | Already in project, already has controller + easeOut |
| Chart line colors | Fork fl_chart | `LineChartBarData.color` / gradient property | fl_chart v0.68 supports per-bar-data color |
| List drag-reorder | Custom gesture detector + position math | `LongPressDraggable` + `DragTarget` | Flutter built-in, handles feedback, hit testing |
| Weekday→workout mapping persistence | Custom Hive serializer | Hive `Map<int,int>` (supported natively) | Hive handles primitive-keyed maps |
| Volume delta calculation | Complex query | `WorkoutRepository.getForWeek()` (already exists) | Method already implemented, just call twice |

---

## Common Pitfalls

### Pitfall 1: Hive Field Index Collision on CustomSplit
**What goes wrong:** Adding `weekdayMap` without checking next available `@HiveField` index. CustomSplit uses 0–4; SplitDay uses 0–1. Using an already-assigned index causes silent data corruption or Hive adapter registration failure.
**Why it happens:** Freezed/Hive field indices must be contiguous and non-overlapping per class.
**How to avoid:** Use `@HiveField(5)` for `weekdayMap`. Run `build_runner` after change and commit generated files.
**Warning signs:** `HiveError: Cannot read, unknown typeId` or adapter registration exception at startup.

### Pitfall 2: build_runner Not Re-Run After Model Change
**What goes wrong:** `CustomSplit` change to add `weekdayMap` requires regeneration of `custom_split.freezed.dart` and `custom_split.g.dart`. If not done, the app will not compile.
**How to avoid:** Always run `flutter pub run build_runner build --delete-conflicting-outputs` after any Freezed model change. Commit generated files (project policy confirmed in STATE.md).

### Pitfall 3: App Restart Bug — completeWorkout + router interaction
**Root cause (from code audit):** `complete_screen.dart` line 97 calls `ref.read(workoutProvider.notifier).reset()` immediately followed by `context.go('/today')`. The `reset()` call sets `WorkoutState` to `const WorkoutState()` — this emits a state change. If any widget in the shell tree watches `workoutProvider` and rebuilds on this emission, GoRouter may detect a shell-level change and reinitialise.
**Fix pattern:** Ensure `reset()` is called AFTER successful navigation, not before. Or: keep `isActive: false` state without full reset, and reset lazily on `startWorkout()` call.
**Warning signs:** `initState` called again on TodayScreen widgets after returning from CompleteScreen.

### Pitfall 4: TweenAnimationBuilder Not Re-Triggering on Same Score
**What goes wrong:** If `readiness.score` doesn't change between loads (user comes back same day), `TweenAnimationBuilder` won't replay because tween end value is the same.
**How to avoid:** Add a `_animKey` counter incremented in `initState` or via `useEffect` hook in `HookConsumerWidget`. Pass it as `key:` to force the builder to treat it as a new widget.

### Pitfall 5: WorkoutProvider Reset Losing In-Progress Sets
**What goes wrong:** The exercise freedom refactor changes per-exercise state from flat lists to maps in `WorkoutScreen` local state. If the user navigates away from an exercise and the local state is in `_WorkoutScreenState`, it survives as long as the widget stays in tree. But if the screen is ever popped and re-pushed (e.g., from "Add Sets" in Finish Up screen), local state is lost.
**How to avoid:** When implementing the Finish Up → "Add Sets" → jump back flow, do NOT pop WorkoutScreen. Instead, navigate by pushing FinishUpScreen on top and using a callback to set `activeExerciseId` in WorkoutScreen when user taps "Add Sets". This keeps WorkoutScreen's `State` alive.

### Pitfall 6: Light Mode Hardcoded Color Audit Scope
**What goes wrong:** SplitBuilderScreen confirmed to use `AppColors.bg` hardcoded in 4+ places (Scaffold backgroundColor, AppBar backgroundColor, exercise picker sheet background, TextField fillColor). Partial fix leaves visual inconsistencies.
**How to avoid:** In SplitBuilderScreen, replace all `AppColors.bg` → `context.appBg`, `AppColors.bgElevated` → `context.appBgElevated`, `AppColors.bgCard` → `context.appBgCard`, `AppColors.textPrimary` → `context.appTextPrimary`. The `AppThemeX` extension on `BuildContext` already provides all needed aliases.
**Audit scope:** `lib/features/splits/`, `lib/features/workout/` (workout_screen.dart uses `isDark ? AppColors.bg : AppColors.bgLight` pattern which is correct but verbose — can be simplified to `context.appBg`).

### Pitfall 7: Consistency Grid Requires WorkoutLog Start Date, Not Completion Date
**What goes wrong:** Using `completedAt` instead of `startedAt` for matching workout days means a workout started at 11:50 PM logs to the wrong calendar day if it ends after midnight.
**How to avoid:** Always use `startedAt.toLocal()` date for grid cell matching. `WorkoutRepository.getAll()` sorts by `startedAt` already.

---

## Code Examples

Verified patterns from existing codebase:

### Existing AnimatedProgressRing API
```dart
// lib/shared/widgets/animated_progress_ring.dart
// Constructor:
AnimatedProgressRing(
  progress: 0.0 to 1.0,        // arc fill fraction
  size: ProgressRingSize.lg,    // sm=64px, md=120px, lg=200px
  progressGradient: Gradient,   // override default accentGradient
  trackColor: Color,            // override track
  center: Widget,               // center content
  pulseAtComplete: bool,        // pulse when progress >= 1.0
)
// strokeWidth at lg: 12px; diameter at lg: 200px
// Already has AnimationController with 600ms easeOutCubic
```

### fl_chart LineChartBarData Color
```dart
// fl_chart v0.68 — from progress_screen.dart
LineChartBarData(
  spots: spots,
  isCurved: true,
  color: AppColors.accent,       // change to trendColor
  barWidth: 2.5,
  dotData: FlDotData(
    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
      color: AppColors.accent,   // match trendColor
    ),
  ),
  belowBarData: BarAreaData(
    gradient: LinearGradient(
      colors: [AppColors.accent.withValues(alpha: 0.25), ...], // match trendColor
    ),
  ),
)
```

### WorkoutRepository Weekly Volume (existing)
```dart
// lib/shared/repositories/workout_repository.dart
List<WorkoutLog> getForWeek(DateTime weekStart) {
  final weekEnd = weekStart.add(const Duration(days: 7));
  return getAll()
      .where((w) => w.startedAt.isAfter(weekStart) && w.startedAt.isBefore(weekEnd))
      .toList();
}
// SetLog: weightKg * reps = volume per set
// Sum all completed SetLogs for that week's WorkoutLogs
```

### AppThemeX context extension (correct light/dark pattern)
```dart
// lib/app/theme.dart — AppThemeX extension
context.appBg          // dark: 0xFF0A0A0A  light: 0xFFFFFFFF
context.appBgCard      // dark: 0xFF111111  light: 0xFFFAFAFA
context.appBgElevated  // dark: 0xFF1A1A1A  light: 0xFFF2F2F2
context.appTextPrimary // dark: 0xFFF5F5F5  light: 0xFF0A0A0A
context.appTextSecondary
context.appTextTertiary
context.appBorder
context.appAccent      // dark: white       light: black
```

### todayProgramProvider weekday lookup (current + proposed)
```dart
// CURRENT (cyclic)
final dayIndex = (DateTime.now().weekday - 1) % split.days.length;

// NEW (weekday map)
final weekday = DateTime.now().weekday; // 1=Mon ... 7=Sun
final dayIndex = split.weekdayMap[weekday]; // null = rest day
if (dayIndex == null) {
  return TodayPlan(dayName: 'Rest Day', exercises: const [], isRest: true);
}
```

### Pre-built plan bug fix (profile update)
```dart
// When user selects pre-built program in Profile:
ref.read(userProfileProvider.notifier).update(
  (p) => p.copyWith(
    currentProgramId: selectedProgramId,
    customSplitId: null,   // THIS is the fix — clear customSplitId
  ),
);
```

---

## State of the Art

| Old Approach | Current Approach | Impact for Phase 10 |
|--------------|------------------|---------------------|
| `DummyData.consistencyGrid` | Real `WorkoutRepository` query | Consistency heatmap will show real data |
| `DummyData.strengthTrends` | Real `PrRepository` data | Strength chart will show real exercise history |
| Linear `currentExerciseIndex` | Map-based per-exercise state | Enables free exercise navigation |
| Cyclic weekday modulo | Explicit weekday map | Correct weekly scheduling |

**Note on dummy data:** `progress_screen.dart` still uses `DummyData.strengthTrends` and `DummyData.consistencyGrid`. Phase 10 must replace these with real data sources to implement the colour logic correctly — the colours are meaningless on dummy data.

---

## Open Questions

1. **`TodayPlan` rest day flag**
   - What we know: `TodayPlan` has `dayName` and `exercises` fields. No `isRest` boolean.
   - What's unclear: When weekday is unmapped, the provider should return a rest-day signal.
   - Recommendation: Add `isRest: bool` field to `TodayPlan` (not persisted, just a typed result). TodayScreen already handles `adaptivePlan.isRestDay` — confirm this flows correctly from `todayProgramProvider` through `adaptiveTodayProvider`.

2. **Free workout on rest day entry point**
   - What we know: CONTEXT.md says rest day should have option to start free workout (pick any exercises, no split required).
   - What's unclear: Where the free workout flow starts — `RestDayContent` widget? A new route?
   - Recommendation: Add a "Free Workout" button inside existing `RestDayContent` widget that pushes `/workout` with an empty exercises list and a "Free Workout" day name. WorkoutScreen already handles arbitrary exercise lists.

3. **Hive `Map<int, int>` across Dart versions**
   - What we know: Hive supports `Map` types. Dart `int` keys are valid.
   - What's unclear: Whether `Map<int, int>` requires explicit registration or works out of the box.
   - Recommendation: Treat as HIGH confidence it works (Hive primitive type); verify by running `build_runner` and checking no adapter errors in generated code. If issues arise, use `Map<String, int>` with string weekday keys as fallback.

4. **`completeWorkout()` and app restart root cause**
   - What we know (from code audit): `complete_screen.dart` calls `reset()` then `context.go('/today')`. `reset()` emits `WorkoutState()` with `isActive: false`. No widget in `app/router.dart` watches `workoutProvider` at the route level.
   - What's unclear: Whether any provider in the shell (e.g., `adaptiveTodayProvider`) invalidates in a way that rebuilds the root navigator.
   - Recommendation: Add debug logging before and after `reset()` + `context.go()` in a test run to confirm ordering. Fix = call `reset()` inside a `WidgetsBinding.instance.addPostFrameCallback` after `context.go('/today')`.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK built-in) |
| Config file | none — standard `flutter test` |
| Quick run command | `flutter test test/providers/today_provider_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Area | Behavior | Test Type | Automated Command | File Exists? |
|------|----------|-----------|-------------------|-------------|
| Pre-built plan fix | `customSplitId` cleared when pre-built selected; `todayProgramProvider` returns program exercises | unit | `flutter test test/providers/today_provider_test.dart` | Partial (test file exists, new case needed) |
| Weekday map resolution | `todayProgramProvider` uses `weekdayMap[weekday]`; unmapped weekday → rest | unit | `flutter test test/providers/today_provider_test.dart` | Partial (new test cases needed) |
| App restart bug | After `completeWorkout()` + `reset()`, `todayProgramProvider` still resolves | integration | `flutter test test/features/today/today_screen_test.dart` | Partial (file exists, new case) |
| WorkoutProvider map state | `startWorkout` with 3 exercises; jump to exercise 2; exercise 1 state preserved | unit | `flutter test test/providers/` (new file needed) | No (Wave 0) |
| Consistency grid colours | Days with workoutLog = workout; split days without log = missed; rest days = neutral | unit | `flutter test test/` (new file needed) | No (Wave 0) |
| Volume delta calculation | `getForWeek` sum this week > last week → positive delta | unit | `flutter test test/` (new file needed) | No (Wave 0) |
| Light mode | All screens render without hardcoded dark colors | widget | Manual visual test on light theme | N/A |

### Sampling Rate
- **Per task commit:** `flutter test test/providers/today_provider_test.dart`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/providers/workout_provider_test.dart` — covers Map-based exercise state, jump-to-exercise, finish-up logic
- [ ] `test/features/progress/consistency_grid_test.dart` — covers missed/workout/neutral cell logic
- [ ] `test/features/progress/volume_delta_test.dart` — covers weekly volume delta computation

*(All other existing test infrastructure remains valid and covers adjacent concerns)*

---

## Sources

### Primary (HIGH confidence)
- Direct codebase audit — all findings verified by reading source files
  - `lib/shared/providers/today_provider.dart` — root cause of customSplitId bug confirmed (line 24-28)
  - `lib/shared/models/custom_split.dart` — HiveField indices 0–4 confirmed, next is 5
  - `lib/shared/providers/workout_provider.dart` — linear index structure confirmed
  - `lib/features/workout/workout_screen.dart` — flat list set state confirmed
  - `lib/features/workout/complete_screen.dart` — reset()+go() ordering confirmed (lines 93-99)
  - `lib/features/today/today_screen.dart` — `_readinessBanner` is small dot+text confirmed
  - `lib/shared/widgets/animated_progress_ring.dart` — API, sizes, gradient parameter confirmed
  - `lib/features/progress/progress_screen.dart` — dummy data usage confirmed, fl_chart v0.68 API confirmed
  - `lib/app/theme.dart` — AppColors semantic tokens + AppThemeX extension confirmed
  - `lib/features/splits/split_builder_screen.dart` — hardcoded `AppColors.bg` confirmed (lines 271, 273, 295)
  - `lib/shared/models/user_profile.dart` — `customSplitId` is `@HiveField(14) String?` confirmed
  - `pubspec.yaml` — all required packages already present, no new dependencies needed

### Secondary (MEDIUM confidence)
- Flutter framework documentation (built-in knowledge): `Draggable`/`DragTarget`/`LongPressDraggable` widget patterns
- fl_chart v0.68 changelog (built-in knowledge): `LineChartBarData.color` property stable since v0.40

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages confirmed in pubspec.yaml
- Architecture: HIGH — sourced from direct code audit
- Pitfalls: HIGH — identified from reading actual call sites and known Flutter patterns
- Data model migration: HIGH — Hive field indices verified by reading model files
- Test infrastructure: HIGH — test files audited directly

**Research date:** 2026-03-31
**Valid until:** 2026-04-30 (stable stack, no fast-moving dependencies)
