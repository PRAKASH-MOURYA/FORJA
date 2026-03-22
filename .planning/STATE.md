# FORJA — Project State

## Current Status

**Active Phase:** 5 — Offline Sync + Onboarding
**Phase Status:** planned
**Current Plan:** Phase 4 COMPLETE — Phase 5 planned and ready to execute
**Last Updated:** 2026-03-22
**Last Session:** Phase 4 done — History/Progress/Profile all wired to real Hive data. Phase 5 plans created: SyncService (connectivity_plus + Supabase push) and onboarding profile save to Supabase.

## Phase Progress

| Phase | Status | Notes |
|-------|--------|-------|
| 1 — Build Verification | DONE | All 2 plans complete. Emulator smoke test approved 2026-03-16. All 4 tabs pass. |
| 2 — Supabase Backend | DONE | Auth, RLS schema, router redirect, secure token storage via FlutterSecureStorage all done. |
| 3 — Core Loop Wiring | DONE | WorkoutProvider→Hive, SetLog save, rest timer, CheckIn save, PR detection (Epley) all done. |
| 4 — History + Progress + Profile | DONE | History, Progress, Profile screens all wired to real Hive data. |
| 5 — Offline Sync + Onboarding | 📋 planned | Plans created 2026-03-22. 2 plans ready to execute. |
| 6 — Adaptive Engine | 🔲 not_started | |
| 7 — Social + Retention | 🔲 not_started | |
| 8 — Advanced Features | 🔲 not_started | |

## Extra Work Done Outside Formal Phases (2026-03-17 to 2026-03-22)

The following was built outside GSD phases. It is committed and functional but predates Supabase integration:

| Area | What Was Built | Relevant Future Phase |
|------|---------------|----------------------|
| Foundation models | 6 Freezed models (Exercise, WorkoutLog, SetLog, CheckIn, UserProfile, ReadinessScore) with Hive adapters | Phase 3 |
| Data layer | HiveService, CalculationService, ProgramSelector, AuthService | Phase 3–5 |
| Repositories | workout_repo, checkin_repo, profile_repo, pr_repo (Hive-backed) | Phase 3–4 |
| Providers | auth_provider, workout_provider, theme_provider, sync_provider | Phase 3 |
| Shared widgets | ForjaButton, ForjaCard, ForjaPill, StatCard, ExerciseRow, RestTimer, SetRow, CheckInSlider | All phases |
| Auth screen | Email/password + guest mode (Supabase stub — not yet wired to real project) | Phase 2 |
| Onboarding | quiz_screen.dart — ProgramSelector.select() → saves UserProfile to Hive | Phase 5 |
| Router redirect | go_router redirect checks UserProfile.onboardingComplete; un-onboarded → /onboarding | Phase 5 |
| TodayScreen | Reads todayProgramProvider (real program day) instead of hardcoded list | Phase 3 |
| today_provider | todayProgramProvider resolves program day + swapAlternatives by weekday | Phase 3 |
| Programs/exercises | 8 program templates, 40+ exercises with form cues and swap alternatives | Phase 3 |
| Tests | 6 test files (program_selector, auth_provider, today_provider, router, today_screen, mock_hive) | Phase 3 |

## Plan Progress — Phase 1

| Plan | Status | Summary |
|------|--------|---------|
| 01 — Legacy Deletion | DONE | Deleted 5 dirs (14 files, 3140 lines). 0 errors confirmed. |
| 02 — Emulator Run | DONE | Freezed verified, VIBRATE added, APK builds, emulator smoke test approved 2026-03-16. All 4 tabs pass. |

## Codebase Snapshot (current)

- Flutter analyze: 0 errors, 47 info warnings (down from ~83 — legacy files removed)
- All Freezed models generated
- 9 screens written (features/), 9 shared widgets, 42 exercises, 8 programs
- GitHub: https://github.com/PRAKASH-MOURYA/FORJA.git (master, 6 commits)
- lib/screens/, lib/widgets/, lib/theme/, lib/models/, lib/data/ — DELETED (Phase 1 Plan 01)
- lib/ now contains only: app/, features/, shared/, main.dart
- Freezed: 6 models, 11 generated files, all committed
- AndroidManifest.xml: VIBRATE permission added (Phase 1 Plan 02)
- flutter build apk --debug: BUILD SUCCESSFUL (app-debug.apk confirmed)
- Supabase: not integrated
- Emulator: smoke test APPROVED 2026-03-16 — all 4 tabs (Today, History, Progress, Profile) loaded without crashing on emulator-5554

## Decisions Log

| Date | Decision | Reason |
|------|----------|--------|
| 2026-03-16 | Phase 1 = build verification first | App has code but hasn't been verified running on emulator |
| 2026-03-16 | Supabase in Phase 2 (not Phase 1) | Get the UI loop working before adding backend complexity |
| 2026-03-16 | Data wiring in Phase 3 | Connect real data only after auth is confirmed working |
| 2026-03-16 | Deleted legacy dirs in one atomic rm -rf pass | Avoids analyzer panic mid-deletion; all 5 dirs had zero imports from new code |
| 2026-03-16 | lib/features/ is single source of truth | Legacy directories fully decoupled; new architecture clean |
| 2026-03-16 | Freezed files committed to git (not gitignored) | Generated files must be committed — build_runner only runs if files are missing |
| 2026-03-16 | flutter pub get (not upgrade) during build sequence | Preserves pubspec.lock; prevents unexpected dependency upgrades |
| 2026-03-16 | flutter build apk --debug for CI-safe build verify | Produces APK artifact without requiring connected device or emulator |

## Performance Metrics

| Phase | Plan | Duration | Tasks | Files Changed |
|-------|------|----------|-------|---------------|
| 01-build-verification | 01 | ~5 min | 2/2 | 14 deleted |
| 01-build-verification | 02 | ~15 min | 3/3 | 1 modified |
