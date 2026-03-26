# Phase 9: UI Redesign — Context

**Gathered:** 2026-03-26
**Status:** Ready for planning
**Source:** User specification + new_ui/ design reference

<domain>
## Phase Boundary

Convert the complete new UI design from `C:\gymapp\new_ui` (React/TSX) to Flutter/Dart. Replace all existing screens with the new design. Ensure all screens connect to existing Riverpod providers and Hive/Supabase backend. Clean dead code after migration is complete.

**What this phase does NOT include:**
- New backend features (those are in earlier phases)
- Changing navigation structure (go_router stays)
- Changing data models (Freezed models stay)
- Changing providers (Riverpod providers stay)

</domain>

<decisions>
## Implementation Decisions

### New Design Language (from new_ui/ TSX code)
- **Background:** `#EEF6FB` (very light blue-grey) — replaces current dark `#0A0A0F`
- **Card surface:** white (`#FFFFFF`) with box shadow `0 2px 12px rgba(100,150,190,0.1)` — no border
- **Primary accent (CTA):** coral gradient `#F07866` → `#E85C48`
- **Secondary accent:** teal `#4ECDC4` → `#3DBDB5`
- **Tertiary:** blue `#60A5FA`
- **Warm:** amber `#FFB347`
- **Text primary:** `#1A2540` (deep navy)
- **Text secondary:** `#9DAEC3`
- **Text tertiary:** `#C5D5E0`
- **Typography display font:** Syne (bold editorial feel) — maps to `var(--font-display)` in TSX
- **Typography body font:** Inter — maps to `var(--font-body)` in TSX
- **Card radius:** 18–24px
- **Button shape:** pill (rounded-full)
- **Nav:** floating pill bottom nav, 20px from screen bottom

### Screens to Migrate (from new_ui/src/app/screens/)
All 9 screens must be rewritten in Flutter/Dart matching the TSX design:
1. `AuthScreen.tsx` → `auth_screen.dart`
2. `OnboardingScreen.tsx` → `onboarding_screen.dart`
3. `QuizScreen.tsx` → `quiz_screen.dart`
4. `TodayScreen.tsx` → `today_screen.dart`
5. `WorkoutScreen.tsx` → `workout_screen.dart`
6. `CompleteScreen.tsx` → `complete_screen.dart`
7. `HistoryScreen.tsx` → `history_screen.dart`
8. `ProgressScreen.tsx` → `progress_screen.dart`
9. `ProfileScreen.tsx` → `profile_screen.dart`

### Shared Widgets to Replace/Rewrite
| Old Widget | New Widget | Key Change |
|-----------|-----------|------------|
| `ForjaCard` | `FCard` | White bg, shadow-only, no border, 18–24px radius |
| `ForjaButton` | `FButton` | Coral gradient, pill shape, scale press |
| `ForjaPill` / `ForjaBadge` | `FBadge` | Colored dot + muted bg |
| `ForjaBottomNav` | `FBottomNav` | Floating pill, elevated above content |
| `StatCard` | `FStatCard` | Light card, Syne font for numbers |
| `ExerciseRow` | `FExerciseCard` | Card-style with category color icon |
| `SetRow` | `FSetRow` | Cleaner ±buttons, spring check animation |
| `RestTimer` | `FRestTimer` | Circular progress ring, large countdown |
| `CheckInSlider` | `FMoodSelector` | Horizontal segment pill selector |

### New Theme System
- Consolidate `lib/app/theme.dart` + `lib/shared/constants/tokens.dart` → single `lib/app/theme.dart`
- Replace dark theme tokens with light theme tokens from new_ui design
- Add `syne` font from google_fonts (display/headings)
- Keep Inter for body text
- Shadow system instead of border system for card elevation
- 8pt spacing grid

### Backend Connectivity (MUST maintain)
- All existing Riverpod providers MUST stay wired:
  - `authStateProvider`, `userProfileProvider` → AuthScreen, ProfileScreen
  - `todayProgramProvider`, `adaptiveTodayProvider`, `readinessProvider` → TodayScreen
  - `workoutProvider` → WorkoutScreen, CompleteScreen
  - `historyProvider` → HistoryScreen
  - `progressProvider` → ProgressScreen
  - `profileStatsProvider` → ProfileScreen
  - `challengeNotifierProvider` → ChallengeScreen (not in new_ui, keep existing)
  - `syncProvider` → runs in background, no change
- Navigation (go_router routes) must stay identical
- Hive repositories stay unchanged
- Supabase sync stays unchanged

### New Features to Wire (from UI_REDESIGN_PLAN.md)
- **Computed Day X of Y:** Fix hardcoded "Day 3 of 4" — derive from `todayProgramProvider`
- **Computed estimated duration:** derive from `exercises.length * avgSetTime`
- **History week navigation:** add `←` / `→` week nav in HistoryScreen
- **Pull-to-refresh:** add RefreshIndicator on TodayScreen and ProgressScreen
- **Sign-out button:** wire in ProfileScreen
- **Inline name edit:** wire in ProfileScreen
- **Settings handlers:** wire Appearance (dark/light), Units toggle, Rest Timer duration
- **Exercise swap:** implement swap logic in ExerciseDemoSheet

### Code Cleanup (after migration)
- Delete old `Forja*` widget files once new `F*` widgets are fully wired
- Delete `lib/shared/constants/tokens.dart` (merged into theme.dart)
- Remove any file that is no longer referenced

### Claude's Discretion
- Animation curves and durations (match flutter_animate equivalents of framer-motion spring)
- Exact Flutter layout for complex TSX flex patterns
- Platform-specific shadow values (BoxDecoration shadowColor opacity)
- How to render Syne font weight availability in google_fonts

</decisions>

<specifics>
## Specific References

**New UI source:** `C:\gymapp\new_ui\src\app\screens\` — 9 TSX screen files
**Design analysis:** `C:\gymapp\new_ui\src\imports\FORJA_FEATURES_ANALYSIS.md`
**Full redesign plan:** `C:\gymapp\new_ui\src\imports\UI_REDESIGN_PLAN.md`

**Key color values from TodayScreen.tsx (authoritative):**
- bg: `#EEF6FB`
- card bg: `white` + `boxShadow: 0 2px 12px rgba(100,150,190,0.1)`
- coral: `#F07866` / `#E85C48`
- teal: `#4ECDC4` / `#3DBDB5`
- text dark: `#1A2540`
- text mid: `#9DAEC3`
- amber: `#FFB347`

**Floating nav design (FloatingNav.tsx):**
- Positioned above safe area, 20px from bottom
- Pill-shaped container with shadow
- Active tab: coral dot indicator below icon

</specifics>

<deferred>
## Deferred Ideas

- Light/dark theme toggle — new UI is light-only; full dark theme parity deferred to a polish phase
- Video player in ExerciseDemoSheet — placeholder UI acceptable for now
- Confetti animation on CompleteScreen — nice-to-have, implement if time permits
- WCAG accessibility audit — defer to separate polish phase
- `challenge_invite_screen.dart` redesign — not in new_ui, keep existing
- `split_builder_screen.dart` search bar — implement if time permits within plan scope

</deferred>

---

*Phase: 09-ui-redesign-convert-react-native-figma-design-to-flutter-dart-remove-old-ui-verify-backend-connectivity*
*Context gathered: 2026-03-26 via user specification + new_ui/ TSX analysis*
