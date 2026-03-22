---
phase: 6
slug: adaptive-engine
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-22
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK bundled) |
| **Config file** | none — uses default flutter test runner |
| **Quick run command** | `flutter test test/services/ test/providers/ --no-pub` |
| **Full suite command** | `flutter test --no-pub` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/services/ test/providers/ --no-pub`
- **After every plan wave:** Run `flutter test --no-pub`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 6-01-01 | 06-01 | 1 | ADAPT-01 | unit | `flutter test test/services/calculation_service_test.dart --no-pub` | ❌ W0 | ⬜ pending |
| 6-01-02 | 06-01 | 1 | ADAPT-02 | widget | `flutter test test/features/today/today_screen_test.dart --no-pub` | ❌ W0 | ⬜ pending |
| 6-02-01 | 06-02 | 2 | ADAPT-03, ADAPT-04, ADAPT-05, ADAPT-06 | unit | `flutter test test/services/adaptive_engine_test.dart --no-pub` | ❌ W0 | ⬜ pending |
| 6-02-02 | 06-02 | 2 | ADAPT-03, ADAPT-04 | provider | `flutter test test/providers/adaptive_today_provider_test.dart --no-pub` | ❌ W0 | ⬜ pending |
| 6-03-01 | 06-03 | 3 | ADAPT-07 | widget | `flutter test test/features/rest_day/rest_day_screen_test.dart --no-pub` | ❌ W0 | ⬜ pending |
| 6-03-02 | 06-03 | 3 | ADAPT-07 | widget | `flutter test test/features/today/today_screen_test.dart --no-pub` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/services/adaptive_engine_test.dart` — stubs for ADAPT-02 through ADAPT-06 (all 7 rules)
- [ ] `test/services/calculation_service_test.dart` — readiness score zones (ADAPT-01)
- [ ] `test/providers/readiness_provider_test.dart` — null on no check-ins (ADAPT-01)
- [ ] `test/providers/adaptive_today_provider_test.dart` — graceful null fallback (ADAPT-03/04)
- [ ] `test/features/rest_day/rest_day_screen_test.dart` — rest day content renders (ADAPT-07)
- [ ] Extend `test/features/today/today_screen_test.dart` — banner zone color (ADAPT-02)
- [ ] Extend `test/helpers/mock_hive.dart` — register CheckInAdapter, WorkoutLogAdapter, SetLogAdapter (currently only ExerciseAdapter + UserProfileAdapter registered)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Readiness banner color updates after logging a check-in and returning to TodayScreen | ADAPT-01, ADAPT-02 | Requires full app loop: workout → check-in → today | Log workout, complete check-in with high/low energy values, verify banner color changes on TodayScreen |
| After 3 consecutive high-soreness check-ins, next workout shows lighter session banner | ADAPT-04, ADAPT-06 | Requires seeded check-in history | Manually insert 3 CheckIns with soreness=5 into Hive, open TodayScreen, verify WHY banner appears |
| Progressive overload +2.5 kg pre-fills after a complete session | ADAPT-03, ADAPT-05 | Requires last session SetLog data in Hive | Complete a full workout with all sets, open TodayScreen next session, verify weight pre-fills +2.5 kg |
| Rest day shows recovery content (not workout) when zone is red | ADAPT-07 | Requires red zone trigger | Set readiness to red zone (low energy check-in), open TodayScreen, verify rest day content renders |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
