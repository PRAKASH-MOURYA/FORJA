# Roadmap: FORJA

## Overview

FORJA is a Flutter gym tracking app (iOS + Android) for students and beginners aged 18-28. The development arc starts with infrastructure cleanup and a verified build foundation, then builds the full user journey: auth → onboarding quiz → today's workout → live workout logging → post-workout check-in → history/progress/profile screens with real data → full test coverage.

## Phases

- [x] **Phase 1: Build Verification** - Delete legacy code, add VIBRATE permission, verify app runs on emulator
- [x] **Phase 2: Foundation Layer** - Auth screen, all Freezed models, HiveService, services, repositories, providers, shared widgets, scaffolded feature screens
- [ ] **Phase 3: Onboarding + Today Screen** - Wire onboarding quiz to real UserProfile persistence; replace hardcoded TodayScreen with live program data
- [ ] **Phase 4: Workout Flow** - Full workout logging (sets, weights, rest timer, auto-advance, PR detection, crash recovery)
- [ ] **Phase 5: Data Screens** - History, Progress, and Profile screens with real Hive data
- [ ] **Phase 6: Tests + Polish** - 80%+ coverage, integration tests, final emulator QA

---

## Phase Details

### Phase 1: Build Verification
**Goal**: App compiles and runs on Android emulator with no crashes — the foundation is solid
**Depends on**: Nothing
**Requirements**: INFRA-01, INFRA-02, INFRA-03
**Status**: ✅ COMPLETE (2026-03-16)
**Success Criteria**:
  1. lib/screens/, lib/widgets/, lib/theme/, lib/models/, lib/data/ deleted — lib/features/ is single source of truth
  2. flutter analyze: 0 errors
  3. VIBRATE permission in AndroidManifest.xml
  4. App runs on emulator-5554, all 4 tabs smoke-tested

Plans:
- [x] 01-01: Delete 5 legacy directories, verify flutter analyze clean
- [x] 01-02: Verify Freezed files, add VIBRATE permission, clean build, emulator smoke test

---

### Phase 2: Foundation Layer
**Goal**: All infrastructure in place — models, data layer, state management, auth, 8 shared widgets, feature screen scaffolds
**Depends on**: Phase 1
**Requirements**: AUTH-01, AUTH-02, AUTH-03, INFRA-04, INFRA-05
**Status**: ✅ COMPLETE (2026-03-21)
**Success Criteria**:
  1. All 6 Freezed models with Hive adapters (Exercise, WorkoutLog, SetLog, CheckIn, UserProfile, ReadinessScore)
  2. HiveService, CalculationService, ProgramSelector, AuthService implemented
  3. All 4 repositories (workout, checkin, profile, pr) and 4 providers (auth, theme, workout, sync)
  4. All 8 shared widgets (ForjaButton, ForjaCard, ForjaPill, StatCard, ExerciseRow, RestTimer, SetRow, CheckInSlider)
  5. AuthScreen (email/password + guest mode) with go_router redirect logic
  6. 8 program templates in programs.dart, 40+ exercises in exercises.dart
  7. All feature screens scaffolded (onboarding, quiz, today, history, progress, profile, workout, complete)

Plans:
- [x] 02-01: Foundation built manually outside GSD

---

### Phase 3: Onboarding + Today Screen
**Goal**: First-time user flows through onboarding quiz → program assigned → TodayScreen shows real exercises for today
**Depends on**: Phase 2
**Requirements**: ONBD-01, ONBD-02, ONBD-03, ONBD-04, ONBD-05, ONBD-06, TODAY-01, TODAY-02, TODAY-03, TODAY-04, TODAY-05
**Success Criteria**:
  1. New user (guest or authed) with no UserProfile is redirected to /onboarding
  2. Quiz completes → UserProfile saved to Hive with currentProgramId → redirect to /today
  3. TodayScreen reads assigned program day's exercises (not hardcoded _pushDayExercises)
  4. Tapping an exercise opens ExerciseDemoSheet with form cues, target muscles, swap alternatives
  5. "Start Workout" navigates to /workout with today's exercises as arguments
**Plans**: 3 plans

Plans:
- [ ] 03-01-PLAN.md — Create failing test stubs for all Phase 3 behaviours (Wave 1)
- [ ] 03-02-PLAN.md — Router onboarding redirect + todayProgramProvider (Wave 2)
- [ ] 03-03-PLAN.md — Wire TodayScreen to live data + emulator smoke test (Wave 3)

---

### Phase 4: Workout Flow
**Goal**: User can log a complete workout — sets, weights, rest timer, auto-advance, PR detection — all persisted to Hive
**Depends on**: Phase 3
**Requirements**: WKT-01, WKT-02, WKT-03, WKT-04, WKT-05, WKT-06, WKT-07, CMP-01, CMP-02, CMP-03, CMP-04
**Success Criteria**:
  1. WorkoutScreen: exercises auto-advance, each set logged with weight/reps/checkbox
  2. Rest timer counts down and vibrates on completion
  3. PR badge shown inline when a personal record is set
  4. CompleteScreen shows real volume/duration/set stats + PR count
  5. CheckIn slider saves to Hive; ReadinessScore calculated
  6. Full workout persists across app restart (WidgetsBindingObserver)
**Plans**: TBD

---

### Phase 5: Data Screens
**Goal**: History, Progress, and Profile screens powered by real Hive data
**Depends on**: Phase 4
**Requirements**: HIST-01, HIST-02, HIST-03, PROG-01, PROG-02, PROG-03, PROG-04, PROF-01, PROF-02, PROF-03, PROF-04
**Success Criteria**:
  1. HistoryScreen lists completed workouts (most recent first), empty state if none
  2. ProgressScreen shows volume chart (last 8 weeks, animated), 1RM trends, PR badges
  3. ProfileScreen shows real name, assigned program, total workouts/volume/streak, XP level
**Plans**: TBD

---

### Phase 6: Tests + Polish
**Goal**: 80%+ test coverage; final emulator QA pass; app ready for TestFlight/internal testing
**Depends on**: Phase 5
**Requirements**: INFRA-06
**Success Criteria**:
  1. Unit tests: CalculationService (1RM edge cases, PR detection, readiness)
  2. Unit tests: ProgramSelector (all 8 template mappings)
  3. Unit tests: All 4 repositories (CRUD with mocked Hive)
  4. Widget tests: All 8 shared widgets
  5. Integration test: Onboarding → Today screen → Workout → Complete → History shows entry
  6. 80%+ coverage verified
  7. Final emulator run on emulator-5554: all critical flows pass
**Plans**: TBD

---

*Last updated: 2026-03-21*
