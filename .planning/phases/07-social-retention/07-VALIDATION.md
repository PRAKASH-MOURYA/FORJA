---
phase: 7
slug: social-retention
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-03-22
---

# Phase 7 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter test |
| **Config file** | pubspec.yaml |
| **Quick run command** | `flutter test test/services/xp_service_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/services/xp_service_test.dart`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 7-01-01 | 01 (xp-streaks) | 1 | XP accumulation | unit | `flutter test test/services/xp_service_test.dart` | ❌ W0 | ⬜ pending |
| 7-01-02 | 01 (xp-streaks) | 1 | Weekly streak logic | unit | `flutter test test/services/streak_service_test.dart` | ❌ W0 | ⬜ pending |
| 7-01-03 | 01 (xp-streaks) | 1 | Streak shield (1/month) | unit | `flutter test test/services/streak_service_test.dart` | ❌ W0 | ⬜ pending |
| 7-02-01 | 02 (buddy-challenges) | 2 | Challenge creation + invite code | unit | `flutter test test/services/challenge_service_test.dart` | ❌ W0 | ⬜ pending |
| 7-03-01 | 03 (pr-share-cards) | 2 | PR card renders correctly | unit | `flutter test test/features/pr_card_test.dart` | ❌ W0 | ⬜ pending |
| 7-04-01 | 04 (push-notifications) | 3 | FCM token registration | manual | Check Firebase console | - | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/services/xp_service_test.dart` — XP accumulation (workout +100, PR +200, check-in +20), level thresholds
- [ ] `test/services/streak_service_test.dart` — Weekly streak increment (not daily), shield consumption
- [ ] `test/services/challenge_service_test.dart` — Challenge creation, join via invite code, volume aggregation
- [ ] `test/features/pr_card_test.dart` — PrCardWidget pumps without exception (SHARE-01)
- [ ] `test/services/notification_service_test.dart` — NotificationService structural test (static method presence)

*Existing test infrastructure (flutter test) covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| PR card generates PNG and shares to WhatsApp | pr-share-cards | Requires real device + installed apps | Tap Share on PR card in emulator; verify share sheet appears |
| Push notification received for workout reminder | push-notifications | Requires real device + FCM token | Trigger via Firebase console → check notification appears |
| Streak-at-risk notification fires | push-notifications | Requires real device + scheduled local notification | Let streak be active, do not work out for 5 days → check notification |
| Invite link opens app deep link | buddy-challenges | Requires installed app + URL handler | Tap `forja://join/{code}` URL → verify ChallengeJoinScreen appears |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
