---
phase: 9
slug: ui-redesign-convert-react-native-figma-design-to-flutter-dart-remove-old-ui-verify-backend-connectivity
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-26
---

# Phase 9 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter test |
| **Config file** | pubspec.yaml (test/ directory) |
| **Quick run command** | `flutter analyze` |
| **Full suite command** | `flutter test && flutter analyze` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter analyze`
- **After every plan wave:** Run `flutter test && flutter analyze`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 9-01-01 | 01 | 0 | Theme consolidation | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-01-02 | 01 | 0 | FCard widget | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-01-03 | 01 | 0 | FButton widget | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-01-04 | 01 | 0 | FBadge widget | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-01-05 | 01 | 0 | FBottomNav widget | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-02-01 | 02 | 1 | TodayScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-02-02 | 02 | 1 | WorkoutScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-02-03 | 02 | 1 | CompleteScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-03-01 | 03 | 2 | HistoryScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-03-02 | 03 | 2 | ProgressScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-03-03 | 03 | 2 | ProfileScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-04-01 | 04 | 3 | AuthScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-04-02 | 04 | 3 | OnboardingScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-04-03 | 04 | 3 | QuizScreen redesign | compile | `flutter analyze` | ✅ | ⬜ pending |
| 9-04-04 | 04 | 3 | Dead code cleanup | compile | `flutter analyze` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- No new test framework needed — Flutter test already configured.
- `flutter analyze` is the primary automated check after every task.
- `flutter run -d emulator-5554` smoke test required after each wave.

*Existing infrastructure covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Visual design matches TSX reference | Phase 9 goal | UI comparison requires human eye | Open both new_ui/ in browser and Flutter app side by side |
| Floating nav correct safe area | Phase 9 nav | Device-specific rendering | Run on physical device or emulator, verify nav not obscured |
| Backend data flows (Today screen live data) | Phase 9 backend | Requires live Supabase + auth | Log in, complete workout, verify data persists |
| PR card still shareable | Phase 9 cleanup | Requires share_plus + RepaintBoundary | Trigger PR, tap share, verify PNG captured |
| Rest timer vibration | Phase 9 workout | Requires physical device | Complete a set, verify vibration on timer end |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
