# FORJA — Roadmap

**8 phases** | **37 requirements mapped** | All v1 requirements covered ✓

| # | Phase | Goal | Requirements | Plans |
|---|-------|------|--------------|-------|
| 1 | Build Verification | App runs clean on emulator | INFRA-01–04 | 2/2 DONE |
| 2 | Supabase Backend | Schema + Auth live | SUPABASE-01–03, AUTH-01–05 | 3 DONE |
| 3 | Core Loop Wiring | Real data flows through the loop | TODAY-01–05, WORKOUT-01–10, CHECKIN-01–05 | 4 DONE |
| 4 | History + Progress + Profile | All tabs show real data | HISTORY-01–03, PROGRESS-01–04, PROFILE-01–04 | 3 DONE |
| 5 | Offline Sync + Onboarding | Full offline-first + onboard saves | SYNC-01–05, ONBOARD-01–04 | 2/2 DONE |
| 6 | Adaptive Engine | App adapts to user recovery | ADAPT-01–07 | 3 DONE |
| 7 | Social + Retention | Streaks, challenges, PR cards | v2 social requirements | 4 plans |
| 8 | Advanced Features | Wearables, nutrition, export | v2 advanced requirements | 3 |

---

## Phase 1: Build Verification
**Goal:** App compiles and runs on Android emulator with no crashes — the foundation is solid.

**Requirements:** INFRA-01, INFRA-02, INFRA-03, INFRA-04

**Plans:**
1. `cleanup` — Delete lib/screens/ legacy files, verify lib/features/ is the only source of truth **[DONE — 2026-03-16]**
2. `emulator-run` — Fix vibration Android build, run on emulator-5554, smoke-test all 4 tabs **[DONE — 2026-03-16]**

**Success Criteria:**
1. `flutter run -d emulator-5554` succeeds with no Gradle errors
2. All 4 tabs are visible and tappable
3. Today screen shows Push Day exercises
4. No runtime crashes during 5-minute smoke test
5. lib/screens/ directory deleted from repo

---

## Phase 2: Supabase Backend
**Goal:** Supabase project is live with all tables, RLS, and auth working.

**Requirements:** SUPABASE-01, SUPABASE-02, SUPABASE-03, AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05

**Plans:**
1. `supabase-schema` — Create all 5 tables, enable RLS, add auth.uid() policies, SQL migrations
2. `auth-integration` — Add supabase_flutter to pubspec, implement AuthService (sign up/in/out), secure token storage
3. `auth-screens` — Login/signup screen, go_router redirect guard for unauthenticated users

**Success Criteria:**
1. All 5 tables exist in Supabase with correct schema and RLS
2. User can sign up with email/password
3. Session persists across app restarts
4. Unauthenticated users redirected to auth screen
5. Auth tokens in flutter_secure_storage (not plain Hive)

---

## Phase 3: Core Loop Wiring
**Goal:** The main loop works end-to-end with real data — open app, see today's workout, log it, check in.

**Requirements:** TODAY-01–05, WORKOUT-01–10, CHECKIN-01–05

**Plans:**
1. `today-wiring` — TodayScreen reads from programs constants + UserProfile to show correct workout day; readiness banner uses real CalculationService
2. `workout-wiring` — WorkoutProvider connects to Hive repositories; SetLogs save to Hive on checkbox; weight pre-fill from last session
3. `checkin-wiring` — CompleteScreen shows real stats (volume, sets, PR count); CheckIn saves to Hive via CheckInRepository
4. `pr-detection` — PrRepository detects new PRs per exercise per session using Epley; PR count shown in complete screen

**Success Criteria:**
1. TodayScreen shows correct program day (e.g. Day 2 of PPL on day 2)
2. Workout logging saves a WorkoutLog + SetLogs to Hive and verifiable in debug
3. Rest timer runs 90 seconds and auto-advances
4. CheckIn saved to Hive on "Save & Finish"
5. PR detected when a new max weight is logged

---

## Phase 4: History + Progress + Profile
**Goal:** All remaining tabs show real computed data from Hive.

**Requirements:** HISTORY-01–03, PROGRESS-01–04, PROFILE-01–04

**Plans:**
1. `history-wiring` — HistoryScreen reads WorkoutLogs from Hive; calendar strip marks real workout days; PR badge from PrRepository
2. `progress-wiring` — ProgressScreen reads weekly volume from CalculationService; 1RM trends from PrRepository; stat cards from Hive aggregates
3. `profile-wiring` — ProfileScreen reads UserProfile from Hive; workout count, total volume, streak from repositories

**Success Criteria:**
1. History tab shows actual logged workouts (not hardcoded)
2. Volume bar chart matches real logged volume per day
3. 1RM trend rows update after each PR
4. Profile shows correct name, program, workout count

---

## Phase 5: Offline Sync + Onboarding
**Goal:** Full offline-first works, onboarding saves profile to Supabase, sync pushes pending records.

**Requirements:** SYNC-01–05, ONBOARD-01–04

**Plans:**
1. `sync-service` — SyncService: connectivity_plus listener, push all Hive pending records to Supabase, update sync_status **[DONE — 2026-03-22]**
2. `onboarding-save` — Quiz completion creates UserProfile in Hive + syncs to Supabase profiles table **[DONE — 2026-03-22]**

**Success Criteria:**
1. Workout logs offline (airplane mode) then sync when connectivity restored
2. sync_status transitions: pending to synced after connectivity event
3. Failed syncs retry on next connectivity event
4. Onboarding profile saves to both Hive and Supabase profiles table
5. No network requests block UI during active workout

---

## Phase 6: Adaptive Engine
**Goal:** App feels like it knows the user — adjusts next session based on check-in history.

**Requirements:** ADAPT-01, ADAPT-02, ADAPT-03, ADAPT-04, ADAPT-05, ADAPT-06, ADAPT-07

**Plans:** 3 plans

Plans:
- [x] 06-01-PLAN.md — readiness-score: Wire CalculationService to live readinessProvider; replace hardcoded banner with real zone colors **[DONE — 2026-03-22]**
- [x] 06-02-PLAN.md — adaptive-rules: AdaptiveEngine service with 7 if/then rules; modifies next workout; WHY banner **[DONE — 2026-03-22]**
- [x] 06-03-PLAN.md — rest-day-content: Smart rest day inline in TodayScreen (mobility, foam rolling, active recovery, weekly reflection) **[DONE — 2026-03-22]**

**Success Criteria:**
1. After 3 high-soreness check-ins, next workout shows lighter session banner
2. After all sets completed, next session pre-fills +2.5 kg
3. Readiness score banner shows correct zone color
4. Rest day shows recovery content instead of workout

---

## Phase 7: Social + Retention
**Goal:** Turn solo users into a community — streaks, challenges, shareable PR cards.

**Plans:** 4 plans

Plans:
- [ ] 07-01-PLAN.md — xp-streaks: XpService + StreakService (pure, TDD); XpBanner on ProfileScreen; XP/streak wired into CompleteScreen
- [ ] 07-02-PLAN.md — buddy-challenges: Supabase schema (challenges + challenge_participants), Challenge Freezed model, ChallengeScreen, deep link join via app_links
- [ ] 07-03-PLAN.md — pr-share-cards: PrCardWidget (RepaintBoundary), PrCardService (share_plus v12), Share PR button on CompleteScreen
- [ ] 07-04-PLAN.md — push-notifications: Firebase init, NotificationService (FCM + flutter_local_notifications), workout reminder scheduler, FCM token in Supabase

**Success Criteria:**
1. XP increases after workout completion
2. Weekly streak increments correctly (not daily)
3. Buddy challenge invite link works
4. PR card generates and shares successfully
5. Push notification received for workout reminder

---

## Phase 8: Advanced Features
**Goal:** Holistic fitness companion with wearable data, nutrition basics, and data export.

**Plans:**
1. `wearables` — health package (HealthKit + Health Connect); auto-import sleep/HR/HRV; upgraded readiness score
2. `nutrition-basics` — Daily protein target; training vs rest day plate visual; water reminder; no calorie tracking
3. `data-export` — CSV workout history export; monthly PDF progress summary

**Success Criteria:**
1. Sleep hours auto-imported from HealthKit/Health Connect
2. Protein target shown on Profile based on user goal
3. CSV export downloads full workout history
4. Monthly PDF generates with volume trend + PRs + consistency

---

## Phase Gates

Each phase must pass before next begins:
- **Phase 1 gate:** flutter run succeeds, 4 tabs visible, no crashes
- **Phase 2 gate:** Supabase auth works end-to-end, RLS verified
- **Phase 3 gate:** Full core loop with real data saved
- **Phase 4 gate:** All tabs show real data (no hardcoded values)
- **Phase 5 gate:** Offline mode + sync verified (airplane mode test)
- **Phase 6 gate:** Adaptive logic modifies workout based on check-in history
- **Phase 7 gate:** Streak counting works, PR card shareable, notification received
- **Phase 8 gate:** HealthKit/Health Connect data flows to readiness score
