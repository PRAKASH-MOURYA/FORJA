# Phase 6: Adaptive Engine — Research

**Researched:** 2026-03-22
**Domain:** Flutter/Dart rule-based adaptive fitness engine, Riverpod state, Hive persistence
**Confidence:** HIGH

---

## Summary

Phase 6 builds the intelligence layer that makes FORJA feel alive. The app already has all the
raw materials: `ReadinessScore` Freezed model, `CalculationService.readinessScore()` stub,
`CheckInRepository.getLastN()`, `WorkoutRepository`, and the `todayProgramProvider` pipeline.
What does not yet exist is: (1) a `ReadinessProvider` that wires real check-in history through
`CalculationService` and exposes a live `ReadinessScore` to the UI; (2) an `AdaptiveEngine`
service that converts that score + workout history into concrete exercise modifications; and (3)
a `RestDayScreen` (or content block) that surfaces recovery content when the engine decides rest
is appropriate.

The key architectural decision — already locked in the project — is rule-based, not ML-based.
Seven deterministic if/then rules operate on values already available in Hive. No new packages
are required; everything ships on the existing stack. The primary integration surface is
`todayProgramProvider`, which currently resolves a `TodayPlan` by calendar weekday. Phase 6
extends this provider (or composes a new one on top of it) so it returns an
`AdaptiveTodayPlan` that carries modification metadata alongside the exercise list.

**Primary recommendation:** Build `AdaptiveEngine` as a pure static-method service (like
`CalculationService`), expose its output through a new `adaptiveTodayProvider` that wraps
`todayProgramProvider`, and display zone + WHY banner on `TodayScreen` by replacing the
hardcoded "Readiness score: 82" string with the live provider value.

---

## Standard Stack

### Core (already in pubspec.yaml — no new dependencies needed)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_riverpod | ^2.5.1 | State for ReadinessProvider + AdaptiveProvider | Already used everywhere |
| hive_flutter | ^1.1.0 | Reads CheckIn / WorkoutLog history | All existing repos use it |
| freezed_annotation | ^2.4.1 | AdaptiveTodayPlan model (if needed) | Matches all other models |
| flutter_animate | ^4.5.0 | Zone banner entrance animation, rest day cards | Already used for animations |

### No New Packages Required

The entire phase runs on the existing stack. Confirm before starting: `pubspec.yaml`
already includes `flutter_riverpod`, `hive_flutter`, `freezed_annotation`, `flutter_animate`.

---

## Architecture Patterns

### Recommended File Structure for New Phase 6 Code

```
lib/shared/
├── services/
│   └── adaptive_engine.dart          # New — pure static service, 7 rules
├── providers/
│   └── readiness_provider.dart       # New — StateProvider<ReadinessScore?>
│   └── adaptive_today_provider.dart  # New — wraps todayProgramProvider + engine
lib/features/
├── today/
│   └── today_screen.dart             # Modify — replace hardcoded banner values
├── rest_day/
│   └── rest_day_screen.dart          # New — recovery content screen
│   └── rest_day_content.dart         # New — mobility / foam rolling data constants
```

### Pattern 1: Pure Static Service for Rules

**What:** `AdaptiveEngine` exposes static methods only. It takes inputs (ReadinessScore,
WorkoutLog history, SetLog history) and returns an `AdaptiveResult` value object. No state,
no Hive access, fully testable in isolation.

**When to use:** Any time business logic has no side effects and all inputs can be passed as
arguments. This matches how `CalculationService` is already built.

**Example:**
```dart
// lib/shared/services/adaptive_engine.dart
class AdaptiveResult {
  final List<ExerciseModification> modifications;
  final String? whyBannerMessage;
  final bool isRestDay;
  const AdaptiveResult({
    this.modifications = const [],
    this.whyBannerMessage,
    this.isRestDay = false,
  });
}

class ExerciseModification {
  final String exerciseId;
  final double weightAdjustmentKg; // negative = deload
  final String reason;
  const ExerciseModification({
    required this.exerciseId,
    required this.weightAdjustmentKg,
    required this.reason,
  });
}

class AdaptiveEngine {
  static AdaptiveResult evaluate({
    required ReadinessScore readiness,
    required List<WorkoutLog> recentWorkouts,
    required List<SetLog> lastSessionSets,
    required List<Exercise> todayExercises,
  }) {
    // Rule 1: Red zone → rest day
    // Rule 2: 3+ consecutive high-soreness check-ins → deload (-10%)
    // Rule 3: All sets completed last session → progressive overload (+2.5 kg)
    // Rule 4: Missed session (>4 days since last workout) → reduce volume
    // Rule 5: Yellow zone → keep weight, reduce reps target
    // Rule 6: Green zone + 2+ consecutive completions → overload eligible
    // Rule 7: Any failed set last session → hold weight
    ...
  }
}
```

### Pattern 2: Riverpod Provider Composition

**What:** `adaptiveTodayProvider` is a `Provider<AdaptiveTodayPlan?>` that calls
`ref.watch(todayProgramProvider)` for the base plan and `ref.watch(readinessProvider)` for
the score, then passes both through `AdaptiveEngine.evaluate()`.

**When to use:** Whenever one piece of derived state depends on two existing providers.
This is the standard Riverpod composition pattern used throughout the existing codebase.

**Example:**
```dart
// lib/shared/providers/adaptive_today_provider.dart
final adaptiveTodayProvider = Provider<AdaptiveTodayPlan?>((ref) {
  final basePlan = ref.watch(todayProgramProvider);
  final readiness = ref.watch(readinessProvider);
  if (basePlan == null || readiness == null) return null;

  final workouts = WorkoutRepository().getAll();
  final lastSets = workouts.isNotEmpty
      ? WorkoutRepository().getSetsForWorkout(workouts.first.id)
      : <SetLog>[];

  final result = AdaptiveEngine.evaluate(
    readiness: readiness,
    recentWorkouts: workouts.take(7).toList(),
    lastSessionSets: lastSets,
    todayExercises: basePlan.exercises,
  );

  return AdaptiveTodayPlan(
    basePlan: basePlan,
    modifications: result.modifications,
    whyMessage: result.whyBannerMessage,
    isRestDay: result.isRestDay,
  );
});
```

### Pattern 3: ReadinessProvider — Hive-backed, synchronous

**What:** Reads last 3 check-ins from `CheckInRepository`, computes days-since-workout from
`WorkoutRepository`, and passes to existing `CalculationService.readinessScore()`. The provider
is a synchronous `Provider<ReadinessScore?>` because Hive reads are synchronous.

```dart
// lib/shared/providers/readiness_provider.dart
final readinessProvider = Provider<ReadinessScore?>((ref) {
  final lastCheckIn = CheckInRepository().getLatest();
  if (lastCheckIn == null) return null;

  final workouts = WorkoutRepository().getAll();
  final daysSince = workouts.isEmpty
      ? 1
      : DateTime.now().difference(workouts.first.startedAt).inDays.clamp(0, 10);

  return CalculationService.readinessScore(lastCheckIn, daysSince);
});
```

**Confidence:** HIGH — matches the exact signature already in `CalculationService`.

### Pattern 4: TodayScreen banner wiring

**What:** Replace the hardcoded `'Readiness score: 82'` string in `today_screen.dart` (line 137)
with values from `adaptiveTodayProvider`. The banner color maps directly to `AppColors`:
- `green` zone → `AppColors.accent` + `AppColors.accentGlow` background
- `yellow` zone → `AppColors.warm` + `AppColors.warmDim` background
- `red` zone → `AppColors.coral` + `AppColors.coralDim` background

These colors already exist in `theme.dart` — no new color tokens needed.

### Pattern 5: Rest Day Screen

**What:** A full-screen replacement shown when `adaptiveTodayProvider.isRestDay == true`.
The router already has `go_router` with `ShellRoute`; no new routes need to be added —
`TodayScreen` checks the plan and renders `RestDayContent` inline, or navigates to a named
route `/rest-day` via `context.go()`.

**When to use:** `isRestDay == true` in the adaptive result.

### Anti-Patterns to Avoid

- **Storing AdaptiveResult in Hive:** It is derived state. Recompute from source data on each
  screen build. Hive is for raw CheckIn / WorkoutLog records only.
- **Making AdaptiveEngine a Riverpod StateNotifier:** It has no mutable state. Use static
  methods. Stateful complexity belongs in the providers that call it.
- **Calling repositories inside widgets:** All Hive access goes through providers. Widgets
  call `ref.watch(adaptiveTodayProvider)` only.
- **Modifying the underlying ProgramTemplate:** The engine applies modifications to the
  *session copy* of exercises (weight pre-fills), never mutating `kPrograms` constants.
- **Hardcoding zone colors in widgets:** Always reference `AppColors` tokens; they already
  map to all three zones.

---

## The 7 Adaptive Rules (Confirmed by Project Spec)

These are the rules the planner MUST implement in `AdaptiveEngine`. They are already
decided; no alternatives are in scope.

| Rule # | Trigger Condition | Action | WHY Banner Copy |
|--------|-------------------|--------|----------------|
| 1 | readiness.zone == 'red' | isRestDay = true | "High fatigue detected — recovery day." |
| 2 | Last 3 check-ins: avg soreness >= 4 | Deload all weights -10% | "Soreness is high — lighter session today." |
| 3 | Last session: all sets completed | Progressive overload +2.5 kg | "Crushed it last time — time to go heavier." |
| 4 | Days since last workout >= 4 (but not first-ever) | Reduce volume (remove last exercise) | "Gap since last session — easing back in." |
| 5 | readiness.zone == 'yellow' | Hold current weight, note to listen to body | "Moderate recovery — keep weights the same." |
| 6 | readiness.zone == 'green' AND last 2 sessions complete | Allow overload (rules 3 applies) | (No banner — just silently increase) |
| 7 | Last session: any SetLog.failed == true | Hold weight for that exercise | "Struggled last session — hold weight today." |

Rules are evaluated in priority order (1 through 7). Rule 1 short-circuits evaluation.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Weight pre-fill for next session | Custom caching layer | `WorkoutRepository.getSetsForWorkout()` already returns last session's SetLogs | The data is already there; just read last workout's sets |
| Zone color mapping | Custom color registry | `AppColors.accent/warm/coral` already covers Green/Yellow/Red | Tokens already exist in theme.dart |
| Readiness score formula | New algorithm | `CalculationService.readinessScore()` is already fully implemented | It uses the exact 30/25/20/15/10 weighting from spec |
| Rest day content data | External API | Inline Dart constants (List<Map>) in `rest_day_content.dart` | Content is static; no API needed |
| Riverpod state invalidation | Manual cache busting | `ref.invalidate(readinessProvider)` after CheckIn save | Standard Riverpod pattern |

**Key insight:** The calculation layer is already 100% done. Phase 6 is primarily about
wiring, rules logic, and UI display — not about building new algorithms.

---

## Common Pitfalls

### Pitfall 1: Forgetting to invalidate readinessProvider after CheckIn save

**What goes wrong:** User logs a check-in, returns to TodayScreen — banner still shows old
score because the provider cached the previous computation.

**Why it happens:** Riverpod's `Provider<T>` caches unless its watched dependencies change.
`readinessProvider` watches nothing — it reads Hive directly. It will not auto-recompute.

**How to avoid:** After saving a CheckIn in `complete_screen.dart`, call
`ref.invalidate(readinessProvider)` (and `ref.invalidate(adaptiveTodayProvider)` transitively).
Or refactor `readinessProvider` to watch a `checkInsStreamProvider` backed by Hive's
`watchBoxes()` / `Box.watch()`.

**Warning signs:** Score shows stale value after check-in, first visible on testing the full
loop (workout → check-in → return to today).

### Pitfall 2: AdaptiveTodayPlan is null on first launch (no check-in history)

**What goes wrong:** New user has no CheckIn records. `readinessProvider` returns null.
`adaptiveTodayProvider` returns null. `TodayScreen` shows a loading spinner forever.

**Why it happens:** The null-guard short-circuit in `adaptiveTodayProvider` propagates null
when there is no readiness data.

**How to avoid:** Return a default `AdaptiveResult` (no modifications, no WHY banner) when
`readiness == null`. The base plan from `todayProgramProvider` is always shown; the banner is
simply hidden. Add a `showReadinessBanner` bool to `AdaptiveTodayPlan`.

**Warning signs:** TodayScreen blank or spinning on fresh install / before first check-in.

### Pitfall 3: Weight modification mutates Exercise model

**What goes wrong:** `AdaptiveEngine` modifies an `Exercise` object's `defaultWeight` in
place. Since `Exercise` is Freezed/const, this causes a Dart type error or silently copies
through reference.

**Why it happens:** Freezed `copyWith` looks right but if you store a reference to the
original `kExerciseData` map, modifications leak into constants.

**How to avoid:** `ExerciseModification` stores only `(exerciseId, weightAdjustmentKg)`. The
workout screen applies modifications when rendering `SetRow` weight pre-fills — it never
touches the `Exercise` model itself. The exercise list in `TodayPlan` is never mutated.

**Warning signs:** Program templates show wrong weights after an adaptive session.

### Pitfall 4: Rule 3 triggers on incomplete sessions (partial saves)

**What goes wrong:** User started workout, logged 2 of 5 exercises, exited early.
`WorkoutLog.completedAt` is set (by "End workout early" in Phase 3). Rule 3 checks "all sets
completed" but the partial session looks complete at the log level.

**Why it happens:** `WorkoutLog` does not track "expected set count" vs "actual set count".

**How to avoid:** Rule 3 should check `SetLog.skipped` count. If more than 0 sets are skipped
in the last workout, do not apply progressive overload. Add a `hasSkippedSets` helper to the
rule evaluation.

**Warning signs:** Weight jumps +2.5 kg after an incomplete session.

### Pitfall 5: daysSinceWorkout returns 0 on same-day check-in

**What goes wrong:** User completes a workout and check-in on the same day. When they return
to TodayScreen the same evening, `daysSince = 0`. `CalculationService.readinessScore` clamps
`rest` factor with `(daysSinceWorkout.clamp(1, 3) / 3) * 15` — so 0 vs 1 doesn't change the
math. But Rule 4 (gap >= 4 days) won't fire. This is correct behavior, not a bug.

**How to avoid:** This is fine — document it so the planner doesn't add an off-by-one fix.

---

## Code Examples

### Existing CalculationService.readinessScore signature (confirmed from source)

```dart
// Source: lib/shared/services/calculation_service.dart (line 35)
static ReadinessScore readinessScore(
    CheckIn lastCheckIn, int daysSinceWorkout) {
  final energy = (lastCheckIn.energy / 5) * 30;
  final soreness = ((6 - lastCheckIn.soreness) / 5) * 25;
  final sleep = ((lastCheckIn.sleepHours ?? 7.0).clamp(0.0, 9.0) / 9.0) * 20;
  final rest = (daysSinceWorkout.clamp(1, 3) / 3) * 15;
  final mood = (lastCheckIn.mood / 5) * 10;
  final score = (energy + soreness + sleep + rest + mood).round().clamp(0, 100);
  // zones: score >= 70 → green, >= 40 → yellow, < 40 → red
  ...
}
```

### CheckInRepository.getLastN (confirmed from source)

```dart
// Source: lib/shared/repositories/checkin_repository.dart (line 20)
List<CheckIn> getLastN(int n) => getAll().take(n).toList();
```

### TodayScreen hardcoded banner (the exact strings to replace)

```dart
// Source: lib/features/today/today_screen.dart (lines 136–146)
Text(
  'Readiness score: 82',            // ← replace with readiness.score
  style: AppTextStyles.bodyStrong(AppColors.accent),  // ← color from zone
),
Text(
  'Recovery looking great. Push hard today.',  // ← replace with readiness.description
  style: AppTextStyles.body(AppColors.textSecondary),
),
```

### Zone → AppColors mapping (all tokens confirmed in theme.dart)

```dart
// Derive from ReadinessScore.zone string
Color _zoneColor(String zone) => switch (zone) {
  'green' => AppColors.accent,
  'yellow' => AppColors.warm,
  'red' => AppColors.coral,
  _ => AppColors.accent,
};

Color _zoneBg(String zone) => switch (zone) {
  'green' => AppColors.accentGlow,
  'yellow' => AppColors.warmDim,
  'red' => AppColors.coralDim,
  _ => AppColors.accentGlow,
};
```

### Riverpod ref.invalidate pattern (standard Riverpod 2.x)

```dart
// After saving CheckIn in complete_screen.dart:
ref.invalidate(readinessProvider);
// adaptiveTodayProvider auto-recomputes because it watches readinessProvider
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| ML-based periodization | Rule-based if/then engine | Project design decision | Simpler to tweak, audit, test — no training data needed |
| Separate "adaptive screen" | Inline banner on TodayScreen | Phase 6 design | Reduces navigation friction for target users (students) |
| New readiness model | Reuse existing ReadinessScore Freezed model | Already built | No build_runner run needed for this model |

**No deprecated patterns** in scope for this phase. All libraries are current stable.

---

## Open Questions

1. **Where does the "WHY banner" appear when isRestDay = true?**
   - What we know: RestDayScreen needs to exist; the banner copy is defined in the 7 rules.
   - What's unclear: Does TodayScreen render RestDayContent inline (replacing the exercise
     list), or does the router push `/rest-day`? The roadmap says "rest-day-content" is plan
     03, implying it's a distinct screen or content block.
   - Recommendation: Render inline within TodayScreen — swaps the exercise list for rest day
     content, keeps the same header. Avoids a new go_router route and matches the "zero
     decisions" UX principle.

2. **How many check-in records trigger deload (Rule 2)?**
   - What we know: Roadmap says "3 high-soreness check-ins". Threshold for "high soreness"
     is not defined in roadmap.
   - What's unclear: Is soreness >= 4 the threshold? Is it 3 consecutive or 3 of last 5?
   - Recommendation: Use soreness >= 4 as "high" (80th percentile on a 1–5 scale), and
     require 3 of the last 3 check-ins to qualify (consecutive). Document the constant
     `kHighSorenessThreshold = 4` and `kDeloadLookback = 3` in `adaptive_engine.dart`.

3. **Does progressive overload (+2.5 kg) apply per-exercise or per-session?**
   - What we know: Rule 3 says "all sets completed → +2.5 kg". SetLog has `exerciseId`.
   - What's unclear: If only 4 of 5 exercises had all sets completed, does the fifth stay?
   - Recommendation: Apply overload per-exercise, not per-session. Each exercise gets +2.5 kg
     only if all its sets in the last session were completed and not failed/skipped.

---

## Validation Architecture

`nyquist_validation` is enabled in `.planning/config.json`.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK bundled) |
| Config file | none — uses default flutter test runner |
| Quick run command | `flutter test test/services/ test/providers/ --no-pub` |
| Full suite command | `flutter test --no-pub` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| ADAPT-01 | ReadinessScore zone computed from last CheckIn | unit | `flutter test test/services/calculation_service_test.dart -x` | ❌ Wave 0 |
| ADAPT-02 | AdaptiveEngine Rule 1: red zone → isRestDay | unit | `flutter test test/services/adaptive_engine_test.dart -x` | ❌ Wave 0 |
| ADAPT-03 | AdaptiveEngine Rule 2: 3× high soreness → deload | unit | `flutter test test/services/adaptive_engine_test.dart -x` | ❌ Wave 0 |
| ADAPT-04 | AdaptiveEngine Rule 3: all sets complete → +2.5 kg | unit | `flutter test test/services/adaptive_engine_test.dart -x` | ❌ Wave 0 |
| ADAPT-05 | AdaptiveEngine Rule 4: gap >= 4 days → reduce volume | unit | `flutter test test/services/adaptive_engine_test.dart -x` | ❌ Wave 0 |
| ADAPT-06 | AdaptiveEngine Rule 7: failed set → hold weight | unit | `flutter test test/services/adaptive_engine_test.dart -x` | ❌ Wave 0 |
| ADAPT-07 | readinessProvider returns null with no check-ins | unit | `flutter test test/providers/readiness_provider_test.dart -x` | ❌ Wave 0 |
| ADAPT-08 | adaptiveTodayProvider falls back gracefully (null readiness) | unit | `flutter test test/providers/adaptive_today_provider_test.dart -x` | ❌ Wave 0 |
| ADAPT-09 | Readiness banner color changes per zone | widget | `flutter test test/features/today/today_screen_test.dart -x` | ❌ Wave 0 (extend existing) |
| ADAPT-10 | Rest day content renders when isRestDay = true | widget | `flutter test test/features/rest_day/rest_day_screen_test.dart -x` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `flutter test test/services/adaptive_engine_test.dart --no-pub`
- **Per wave merge:** `flutter test --no-pub`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/services/adaptive_engine_test.dart` — covers ADAPT-02 through ADAPT-07
- [ ] `test/services/calculation_service_test.dart` — covers ADAPT-01 (readiness score zones)
- [ ] `test/providers/readiness_provider_test.dart` — covers ADAPT-07
- [ ] `test/providers/adaptive_today_provider_test.dart` — covers ADAPT-08
- [ ] `test/features/rest_day/rest_day_screen_test.dart` — covers ADAPT-10
- [ ] Extend `test/features/today/today_screen_test.dart` — covers ADAPT-09
- [ ] Extend `test/helpers/mock_hive.dart` — register CheckInAdapter, WorkoutLogAdapter, SetLogAdapter (currently only ExerciseAdapter + UserProfileAdapter registered)

---

## Sources

### Primary (HIGH confidence)

- Codebase: `lib/shared/services/calculation_service.dart` — confirmed readiness formula, exact weights, zone thresholds
- Codebase: `lib/shared/models/readiness_score.dart` — confirmed model fields: score, zone, message, description
- Codebase: `lib/shared/models/check_in.dart` — confirmed fields: energy, soreness, mood, sleepHours, stress
- Codebase: `lib/shared/models/set_log.dart` — confirmed fields: completed, failed, skipped, weightKg, reps
- Codebase: `lib/shared/repositories/checkin_repository.dart` — confirmed getLastN(), getLatest()
- Codebase: `lib/shared/repositories/workout_repository.dart` — confirmed getAll(), getSetsForWorkout()
- Codebase: `lib/app/theme.dart` — confirmed AppColors.accent/warm/coral + dim/glow variants
- Codebase: `lib/features/today/today_screen.dart` — confirmed hardcoded banner at lines 136–146
- Project docs: `ROADMAP.md` Phase 6 — confirmed 7 rules, 3 plans, zone display names
- Project docs: `PROJECT.md` — confirmed rule-based engine decision, no ML

### Secondary (MEDIUM confidence)

- Riverpod 2.x `ref.invalidate()` API — standard pattern, confirmed in Riverpod documentation
- Freezed `copyWith` immutability guarantee — confirmed in freezed package documentation

### Tertiary (LOW confidence)

- None — all claims are grounded in direct codebase inspection or authoritative docs.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — confirmed directly in pubspec.yaml; no new packages
- Architecture: HIGH — patterns derived from existing working code in the same codebase
- 7 rules logic: HIGH — specified verbatim in ROADMAP.md and PROJECT.md
- Pitfalls: HIGH — derived from direct reading of the existing provider/repository code
- Test infrastructure: HIGH — flutter_test already in use; test directory structure confirmed

**Research date:** 2026-03-22
**Valid until:** 2026-04-22 (stable stack; Riverpod/Hive/freezed are not fast-moving for this version range)

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| ADAPT-01 | Readiness score computed from last 3 check-ins using energy(30%)/soreness-inverted(25%)/sleep(20%)/days-since-workout(15%)/mood(10%) | `CalculationService.readinessScore()` is fully implemented; only wiring to a live provider is missing |
| ADAPT-02 | Three readiness zones: Green (>=70), Yellow (40–69), Red (<40) driving TodayScreen banner color | Zone logic exists in `CalculationService`; AppColors.accent/warm/coral map directly to zones |
| ADAPT-03 | Auto weight increase (+2.5 kg) when all sets completed last session | Rule 3 in AdaptiveEngine; reads SetLog.completed from WorkoutRepository.getSetsForWorkout() |
| ADAPT-04 | Deload trigger when high soreness detected across multiple sessions | Rule 2 in AdaptiveEngine; reads last N CheckIns via CheckInRepository.getLastN(3) |
| ADAPT-05 | Missed session adjustment (reduce volume) when gap >= 4 days | Rule 4 in AdaptiveEngine; computes daysSince from WorkoutRepository.getAll().first.startedAt |
| ADAPT-06 | WHY banner shown to user explaining workout modification reason | whyBannerMessage field on AdaptiveResult; displayed in TodayScreen banner |
| ADAPT-07 | Smart rest day content: mobility suggestions, foam rolling guide, active recovery | RestDayScreen / rest day inline content block; static content constants |
| ADAPT-08 | Weekly progress reflection on rest day | Additional section in rest day content block |
</phase_requirements>
