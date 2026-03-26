# Phase 9: UI Redesign — Research

**Researched:** 2026-03-26
**Domain:** Flutter UI migration — TSX→Dart design system replacement, light theme, floating nav, animation parity
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Design language:**
- Background: `#EEF6FB`; Card: white + shadow `0 2px 12px rgba(100,150,190,0.1)`; no border
- Primary CTA: coral gradient `#F07866` → `#E85C48`
- Secondary: teal `#4ECDC4` → `#3DBDB5`; Tertiary: blue `#60A5FA`; Warm: amber `#FFB347`
- Text primary: `#1A2540`; secondary: `#9DAEC3`; tertiary: `#C5D5E0`
- Display font: Syne (bold/editorial); Body font: Inter
- Card radius: 18–24px; Button shape: pill (rounded-full)
- Floating pill bottom nav, 20px from screen bottom

**Screens to migrate (all 9):**
1. `AuthScreen.tsx` → `auth_screen.dart`
2. `OnboardingScreen.tsx` → `onboarding_screen.dart`
3. `QuizScreen.tsx` → `quiz_screen.dart`
4. `TodayScreen.tsx` → `today_screen.dart`
5. `WorkoutScreen.tsx` → `workout_screen.dart`
6. `CompleteScreen.tsx` → `complete_screen.dart`
7. `HistoryScreen.tsx` → `history_screen.dart`
8. `ProgressScreen.tsx` → `progress_screen.dart`
9. `ProfileScreen.tsx` → `profile_screen.dart`

**Shared widget renames:**
| Old | New | Key change |
|-----|-----|------------|
| `ForjaCard` | `FCard` | White bg, shadow-only, 18–24px radius |
| `ForjaButton` | `FButton` | Coral gradient, pill, scale press |
| `ForjaPill/ForjaBadge` | `FBadge` | Colored dot + muted bg |
| `ForjaBottomNav` | `FBottomNav` | Floating pill, elevated above content |
| `StatCard` | `FStatCard` | Light card, Syne for numbers |
| `ExerciseRow` | `FExerciseCard` | Card-style with category color icon |
| `SetRow` | `FSetRow` | Cleaner ±buttons, spring check animation |
| `RestTimer` | `FRestTimer` | Circular progress ring, large countdown |
| `CheckInSlider` | `FMoodSelector` | Horizontal segment pill selector |

**Theme system:**
- Consolidate `lib/app/theme.dart` + `lib/shared/constants/tokens.dart` → single `lib/app/theme.dart`
- Replace all dark-theme tokens with new light-theme tokens
- Shadow system replaces border system for card elevation
- 8pt spacing grid

**Backend connectivity (MUST maintain):**
- All Riverpod providers MUST stay wired (see CONTEXT.md for full mapping)
- go_router routes MUST stay identical
- Hive repositories MUST stay unchanged
- Supabase sync MUST stay unchanged

**New features to wire (as part of migration):**
- Computed "Day X of Y" from `todayProgramProvider`
- Computed estimated duration from `exercises.length * avgSetTime`
- History week navigation (`←` / `→`)
- Pull-to-refresh on TodayScreen and ProgressScreen
- Sign-out button wired in ProfileScreen
- Inline name edit wired in ProfileScreen
- Settings handlers: Appearance, Units toggle, Rest Timer duration
- Exercise swap logic in ExerciseDemoSheet

**Code cleanup (after migration):**
- Delete old `Forja*` widget files once new `F*` widgets fully replace them
- Delete `lib/shared/constants/tokens.dart` (merged into theme.dart)
- Remove all unreferenced files

### Claude's Discretion
- Animation curves and durations (match flutter_animate equivalents of framer-motion spring)
- Exact Flutter layout for complex TSX flex patterns
- Platform-specific shadow values (BoxDecoration shadowColor opacity)
- How to render Syne font weight availability in google_fonts

### Deferred Ideas (OUT OF SCOPE)
- Light/dark theme toggle — new UI is light-only; full dark theme parity deferred
- Video player in ExerciseDemoSheet — placeholder UI acceptable
- Confetti animation on CompleteScreen — nice-to-have, implement if time permits
- WCAG accessibility audit — defer to separate polish phase
- `challenge_invite_screen.dart` redesign — not in new_ui, keep existing
- `split_builder_screen.dart` search bar — implement if time permits

</user_constraints>

---

## Summary

Phase 9 replaces the FORJA app's dark-theme aesthetic with the light-theme design defined in `new_ui/src/app/screens/*.tsx`. Every screen is rewritten in place — same file paths, same Riverpod provider connections, same go_router routes. Only the visual layer changes: colors, fonts, card shapes, shadows, and the bottom nav implementation.

The migration is a visual-only replacement. All data providers (`adaptiveTodayProvider`, `workoutProvider`, `historyProvider`, `progressProvider`, `profileStatsProvider`, `authStateProvider`, `readinessProvider`, `syncProvider`, `challengeNotifierProvider`) remain wired exactly as they are today. The Hive repositories and Supabase sync layer are untouched.

The ProgressScreen TSX design uses `recharts` (BarChart, LineChart) for chart rendering. Flutter has no direct recharts equivalent — this requires the existing animated bar-chart approach (already in `progress_screen.dart` using flutter_animate stagger) to be restyled rather than replaced with a chart library. The 1RM trend "sparklines" in ProgressScreen.tsx become simplified animated progress rows (existing `_LiftTrendRow` pattern), since adding a full charting library is out of scope.

**Primary recommendation:** Use a replace-in-place migration strategy. Rewrite each screen file one at a time with the new theme. Build the design system (theme.dart, F* widgets) first, then migrate screens from high-impact to low-impact. Never delete old Forja* widgets until all screens using them are migrated.

---

## Standard Stack

### Core (all already in pubspec.yaml)
| Library | Version | Purpose | Status |
|---------|---------|---------|--------|
| `google_fonts` | ^6.1.0 | Inter (body) + **Syne** (display) | Already installed — add `GoogleFonts.syne()` |
| `flutter_animate` | ^4.5.0 | All UI animations (replaces framer-motion) | Already installed |
| `flutter_riverpod` | ^2.5.1 | All provider connections | Already installed, unchanged |
| `go_router` | ^13.0.0 | Navigation | Already installed, unchanged |
| `hive_flutter` | ^1.1.0 | Local persistence | Already installed, unchanged |
| `vibration` | ^2.0.0 | Haptic feedback on rest timer | Already installed, uncomment usage |

### To Add
| Library | Version | Purpose | When |
|---------|---------|---------|------|
| `confetti` | ^0.7.0 | CompleteScreen celebration burst | Wave 4 (deferred, nice-to-have) |

**Installation for addition:**
```bash
flutter pub add confetti
```

### Alternatives Considered
| Instead of | Could Use | Why we don't |
|------------|-----------|--------------|
| `CustomPainter` for circular timer | `fl_chart` CircularChart | CustomPainter is zero-dep, exact visual match to TSX SVG arc |
| `flutter_animate` for nav transitions | `animations` package | flutter_animate already installed; spring physics supported |
| `confetti` | particles_flutter | confetti is simpler, 0 config, works on Android/iOS |

---

## Architecture Patterns

### Recommended Project Structure (unchanged from current)
```
lib/
├── app/
│   ├── theme.dart           # REWRITE — consolidate tokens, new light colors
│   └── router.dart          # MINOR EDIT — swap ForjaBottomNav → FBottomNav in ScaffoldWithBottomNav
├── features/
│   ├── auth/auth_screen.dart         # REWRITE
│   ├── onboarding/onboarding_screen.dart   # REWRITE
│   ├── onboarding/quiz_screen.dart         # REWRITE
│   ├── today/today_screen.dart             # REWRITE
│   ├── today/rest_day_content.dart         # REWRITE
│   ├── today/widgets/pr_to_beat_card.dart  # REWRITE
│   ├── today/widgets/recovery_heatmap_card.dart # REWRITE
│   ├── workout/workout_screen.dart         # REWRITE
│   ├── workout/complete_screen.dart        # REWRITE
│   ├── workout/exercise_history_sheet.dart # REWRITE
│   ├── workout/session_guard_sheet.dart    # REWRITE
│   ├── history/history_screen.dart         # REWRITE
│   ├── progress/progress_screen.dart       # REWRITE
│   ├── profile/profile_screen.dart         # REWRITE
│   ├── profile/xp_banner.dart             # REWRITE (inline into profile)
│   ├── exercise/exercise_demo_sheet.dart   # REWRITE + wire swap
│   ├── splits/split_builder_screen.dart    # KEEP (optional search bar)
│   ├── challenges/challenge_screen.dart    # KEEP (not in new_ui)
│   └── pr_card/pr_card_widget.dart         # RESTYLE only (keep render path)
└── shared/
    ├── widgets/
    │   ├── f_card.dart          # NEW — replaces forja_card.dart
    │   ├── f_button.dart        # NEW — replaces forja_button.dart
    │   ├── f_badge.dart         # NEW — replaces forja_pill.dart
    │   ├── f_stat_card.dart     # NEW — replaces stat_card.dart
    │   ├── f_bottom_nav.dart    # NEW — replaces bottom_nav.dart
    │   ├── f_exercise_card.dart # NEW — replaces exercise_row.dart
    │   ├── f_set_row.dart       # NEW — replaces set_row.dart
    │   ├── f_rest_timer.dart    # NEW — replaces rest_timer.dart
    │   ├── f_mood_selector.dart # NEW — replaces checkin_slider.dart
    │   ├── forja_button.dart    # KEEP until all usages migrated, then DELETE
    │   ├── forja_card.dart      # KEEP until all usages migrated, then DELETE
    │   ├── forja_pill.dart      # KEEP until all usages migrated, then DELETE
    │   ├── bottom_nav.dart      # KEEP until router migrated, then DELETE
    │   └── ...other existing widgets
    └── constants/
        └── tokens.dart          # DELETE after theme.dart consolidation
```

### Migration Order (critical — prevents mid-migration breakage)

**Wave 0 — Design Foundation (no visible changes):**
1. Rewrite `lib/app/theme.dart` — new `FColors`, `FSpacing`, `FRadius`, `FTextStyles` classes with light-theme tokens
2. Create 9 new `F*` widget files in `lib/shared/widgets/` — all new files, old Forja* files stay
3. App still compiles and runs with old dark theme (old widgets still used)

**Wave 1 — Navigation Shell (one file change, high confidence):**
4. Create `f_bottom_nav.dart` — floating pill nav
5. Edit `router.dart` `ScaffoldWithBottomNav` to use `FBottomNav` instead of `ForjaBottomNav`
6. Edit `main.dart` to force light theme (hardcode `themeMode: ThemeMode.light` for this phase)
7. App now has floating nav and light background

**Wave 2 — Core Loop (Today → Workout → Complete):**
8. Rewrite `today_screen.dart` — uses `FCard`, `FButton`, `FExerciseCard`, `FBadge`
9. Rewrite `workout_screen.dart` — uses `FSetRow`, `FRestTimer`
10. Rewrite `complete_screen.dart` — uses `FMoodSelector`, `FStatCard`

**Wave 3 — Data Tabs (History → Progress → Profile):**
11. Rewrite `history_screen.dart` — add week navigation state
12. Rewrite `progress_screen.dart` — restyle bar chart + 1RM trend rows
13. Rewrite `profile_screen.dart` — wire all settings

**Wave 4 — Auth + Onboarding + Cleanup:**
14. Rewrite `auth_screen.dart`, `onboarding_screen.dart`, `quiz_screen.dart`
15. Rewrite bottom sheets: `exercise_demo_sheet.dart` (+ swap), `exercise_history_sheet.dart`, `session_guard_sheet.dart`
16. Restyle `pr_card_widget.dart`, `rest_day_content.dart`
17. Delete old Forja* widget files
18. Delete `lib/shared/constants/tokens.dart`

### Pattern 1: New Theme Token Class Structure
**What:** Single `lib/app/theme.dart` replaces both `theme.dart` and `tokens.dart`
**When to use:** Every screen and widget references `FColors.*`, `FSpacing.*`, `FRadius.*`, `FTextStyles.*`

```dart
// lib/app/theme.dart — authoritative tokens for Phase 9
class FColors {
  // Background
  static const bg         = Color(0xFFEEF6FB);
  static const cardBg     = Color(0xFFFFFFFF);
  static const inputBg    = Color(0xFFF4F8FC);
  static const surface    = Color(0xFFF4F9FC); // muted surface

  // Accent — coral CTA
  static const coral      = Color(0xFFF07866);
  static const coralDeep  = Color(0xFFE85C48);
  static const coralDim   = Color(0x1AF07866); // 10% opacity

  // Secondary — teal
  static const teal       = Color(0xFF4ECDC4);
  static const tealDeep   = Color(0xFF3DBDB5);
  static const tealDim    = Color(0x1A4ECDC4);

  // Tertiary — blue
  static const blue       = Color(0xFF60A5FA);
  static const blueDim    = Color(0x1A60A5FA);

  // Warm — amber
  static const amber      = Color(0xFFFFB347);
  static const amberDim   = Color(0x1AFFB347);

  // Text
  static const textPrimary   = Color(0xFF1A2540);
  static const textSecondary = Color(0xFF9DAEC3);
  static const textTertiary  = Color(0xFFC5D5E0);
  static const textMid       = Color(0xFF6B7A9A);

  // Borders (used sparingly — prefer shadows)
  static const borderSubtle  = Color(0x0F1A2540); // 6% navy
  static const borderLight   = Color(0x14283447); // 8% navy

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: Color(0x1A6496BE), blurRadius: 12, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> get cardShadowHero => [
    BoxShadow(color: Color(0x264196BE), blurRadius: 24, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> get coralGlow => [
    BoxShadow(color: Color(0x60F07866), blurRadius: 28, offset: Offset(0, 8)),
  ];
  static List<BoxShadow> get navShadow => [
    BoxShadow(color: Color(0x3F6496B4), blurRadius: 32, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // Gradients
  static const coralGradient = LinearGradient(
    colors: [Color(0xFFF07866), Color(0xFFE85C48)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const tealGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF3DBDB5)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const xpGradient = LinearGradient(
    colors: [Color(0xFFF07866), Color(0xFF4ECDC4)],
    begin: Alignment.centerLeft, end: Alignment.centerRight,
  );
}

class FSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class FRadius {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 18;
  static const double xxl = 20;
  static const double card = 20;  // most cards
  static const double hero = 24;  // readiness hero, auth card
  static const double pill = 999; // fully rounded
}
```

### Pattern 2: Display Font (Syne) + Body Font (Inter)
**What:** Two-font system using google_fonts
**When to use:** Syne for all large numbers, screen titles, headings. Inter for all body, labels, captions.

```dart
// Verified: GoogleFonts.syne() is available in google_fonts ^6.1.0
// Source: fonts.google.com/specimen/Syne — confirmed in Google Fonts catalog
class FTextStyles {
  // Display — Syne
  static TextStyle displayXL(Color color) => GoogleFonts.syne(
    fontSize: 32, fontWeight: FontWeight.w800, color: color, height: 1.0);

  static TextStyle display(Color color) => GoogleFonts.syne(
    fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1.1);

  static TextStyle heading(Color color) => GoogleFonts.syne(
    fontSize: 20, fontWeight: FontWeight.w700, color: color);

  static TextStyle dataLarge(Color color) => GoogleFonts.syne(
    fontSize: 52, fontWeight: FontWeight.w800, color: color, height: 1.0);

  static TextStyle dataMedium(Color color) => GoogleFonts.syne(
    fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1.0);

  // Body — Inter
  static TextStyle bodyStrong(Color color) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, color: color);

  static TextStyle body(Color color) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: color);

  static TextStyle caption(Color color) => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500, color: color);

  static TextStyle label(Color color) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600, color: color,
    letterSpacing: 0.12 * 11); // ~1.2pt
}
```

**Important:** `GoogleFonts.syne()` uses `FontWeight.w600`, `w700`, and `w800` — all are available in the Syne family (Syne has Regular/Medium/SemiBold/Bold/ExtraBold). Syne does NOT have an italic variant for w800, so avoid italic on display text.

### Pattern 3: FCard — Shadow-Only Card
**What:** White card with shadow, no border (except very subtle for structure)
**When to use:** Every content card in the new design

```dart
// lib/shared/widgets/f_card.dart
class FCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const FCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      decoration: BoxDecoration(
        color: FColors.cardBg,
        borderRadius: BorderRadius.circular(borderRadius ?? FRadius.card),
        // Shadow-based elevation — no Border.all
        boxShadow: shadows ?? FColors.cardShadow,
        // Very subtle structural border — matches TSX "1px solid rgba(26,37,64,0.06)"
        border: Border.all(color: FColors.borderSubtle, width: 1),
      ),
      padding: padding ?? const EdgeInsets.all(FSpacing.lg),
      child: child,
    );
    if (onTap == null) return container;
    return GestureDetector(onTap: onTap, child: container);
  }
}
```

**Note:** The TSX designs show `border: '1px solid rgba(26,37,64,0.06)'` on most cards alongside the box-shadow. This is a very subtle structural border (not a design border) to prevent cards from "bleeding" into the bg on some devices. Keep it — use `FColors.borderSubtle` (6% opacity).

### Pattern 4: FBottomNav — Floating Pill
**What:** Floating pill nav positioned 20px above safe area bottom, not anchored in Scaffold.bottomNavigationBar
**When to use:** ScaffoldWithBottomNav wrapper in router.dart

```dart
// lib/shared/widgets/f_bottom_nav.dart
// The key architectural change: the nav is NOT in Scaffold.bottomNavigationBar.
// It is Positioned/Stack-based or uses an overlay via Stack inside the Scaffold body.
// Screens must add bottom padding equal to navHeight + 20px + safeAreaBottom.

class FBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 20 + safeBottom, // 20px above safe area
      left: FSpacing.xl,
      right: FSpacing.xl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: FSpacing.md, vertical: FSpacing.sm + 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(FRadius.pill),
          boxShadow: FColors.navShadow,
          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [/* tab items */],
        ),
      ),
    );
  }
}
```

**ScaffoldWithBottomNav change:** Switch from `Scaffold.bottomNavigationBar` to a `Stack` body:

```dart
// router.dart — ScaffoldWithBottomNav
@override
Widget build(BuildContext context) {
  return Scaffold(
    // NO bottomNavigationBar
    body: Stack(
      children: [
        widget.child,
        FBottomNav(currentIndex: _currentIndex, onTap: _onTap),
      ],
    ),
  );
}
```

**Screen padding:** Each tab screen must add `pb-32` equivalent (128px) so content is not hidden behind the floating nav. Use `MediaQuery.of(context).padding.bottom + 100` as bottom padding in each screen's scrollable area.

### Pattern 5: FRestTimer — Circular Progress with CustomPainter
**What:** The circular countdown timer that overlays the workout screen
**When to use:** `FRestTimer` replaces `RestTimer` (linear bar) in WorkoutScreen

```dart
// lib/shared/widgets/f_rest_timer.dart
// Pattern: CustomPainter with AnimationController for the arc, Ticker-based countdown

class _RestTimerPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (remaining/duration)
  final Color trackColor;
  final Color arcColor;

  _RestTimerPainter({required this.progress, required this.trackColor, required this.arcColor})
      : super(repaint: null);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final paint = Paint()
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track (background ring)
    canvas.drawCircle(center, radius, paint..color = trackColor);

    // Arc (progress) — starts at -90 degrees (top)
    final sweepAngle = -2 * math.pi * (1 - progress); // clockwise drain
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // -90 degrees = top
      sweepAngle,   // sweeps clockwise as time passes
      false,
      paint..color = arcColor,
    );
  }

  @override
  bool shouldRepaint(_RestTimerPainter old) => old.progress != progress;
}
```

**Important:** The TSX uses SVG `strokeDasharray` for the arc effect. The Flutter equivalent is `canvas.drawArc` with `sweepAngle` = `2π × (remaining/duration)`. This is a drain animation (starts full, drains to empty), matching the TSX pattern exactly.

**For the gradient arc** (TSX uses `linearGradient` on the stroke in WorkoutScreen's RestTimerOverlay), use `paint.shader = ui.Gradient.linear(...)` on the Paint object. This requires `dart:ui` import.

### Pattern 6: spring Animation with flutter_animate
**What:** Matching framer-motion spring animations using flutter_animate
**When to use:** All entrance animations, button press scale, nav tab transitions

```dart
// framer-motion: transition={{ type: 'spring', stiffness: 400, damping: 35 }}
// flutter_animate equivalent:
widget.animate().scale(
  begin: const Offset(0.9, 0.9),
  end: const Offset(1.0, 1.0),
  curve: Curves.easeOutBack,     // approximates spring stiffness:400 damping:35
  duration: const Duration(milliseconds: 300),
)

// framer-motion: initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }}
// flutter_animate equivalent:
widget.animate(delay: 100.ms)
  .fadeIn(duration: 400.ms)
  .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut)

// framer-motion: whileTap={{ scale: 0.97 }}
// Flutter equivalent: use GestureDetector with scale Transform or AnimatedScale
GestureDetector(
  onTapDown: (_) => setState(() => _pressed = true),
  onTapUp: (_) => setState(() => _pressed = false),
  child: AnimatedScale(
    scale: _pressed ? 0.97 : 1.0,
    duration: const Duration(milliseconds: 100),
    child: ...,
  ),
)

// Staggered list entry (framer-motion: delay={0.35 + i * 0.06})
ListView.builder(
  itemBuilder: (context, i) => item.animate(delay: (350 + i * 60).ms)
    .fadeIn().slideX(begin: -0.15),
)
```

**framer-motion → flutter_animate mapping table:**
| framer-motion | flutter_animate equivalent | Notes |
|---------------|---------------------------|-------|
| `initial={{ opacity: 0 }} animate={{ opacity: 1 }}` | `.fadeIn(duration: Xms)` | Direct |
| `initial={{ y: 16 }} animate={{ y: 0 }}` | `.slideY(begin: 0.4, end: 0)` | begin as fraction of height |
| `initial={{ x: -12 }} animate={{ x: 0 }}` | `.slideX(begin: -0.3, end: 0)` | fraction, not pixels |
| `initial={{ scale: 0 }} animate={{ scale: 1 }}` | `.scale(begin: Offset(0,0))` | |
| `whileTap={{ scale: 0.97 }}` | `AnimatedScale` in `GestureDetector` | StatefulWidget required |
| `AnimatePresence` conditional render | `AnimatedSwitcher` or `AnimatedOpacity` | |
| `height: 'auto'` collapse | `AnimatedCrossFade` or `AnimatedSize` | |
| `layoutId="nav-bg"` shared element | `AnimatedPositioned` or ignore | Nav bg tab highlight |

**AnimatePresence equivalent for bottom sheets (session guard, logout confirm):**
The TSX uses `motion.div initial={{ y: 100 }} animate={{ y: 0 }} type='spring'`. In Flutter this is `showModalBottomSheet` with a custom `AnimationController` or `DraggableScrollableSheet`. Use `showModalBottomSheet(isScrollControlled: true, ...)` with a `SlideTransition`.

### Pattern 7: Collapsible Section (RecoveryHeatmap)
**What:** The TSX `AnimatePresence` height collapse animation
**Flutter equivalent:** `AnimatedSize` widget

```dart
// TSX: <AnimatePresence> height: 0 → 'auto' collapse
// Flutter:
AnimatedSize(
  duration: const Duration(milliseconds: 250),
  curve: Curves.easeInOut,
  child: isOpen ? heatmapGrid : const SizedBox.shrink(),
)
```

### Pattern 8: Inline Name Edit (ProfileScreen)
**What:** The TSX inline name edit — clicking name shows a TextField in place
**Flutter approach:** `AnimatedSwitcher` between `Text` and `TextField`

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: _editingName
    ? TextField(key: const ValueKey('edit'), ...)
    : GestureDetector(key: const ValueKey('display'), onTap: () => setState(() => _editingName = true), child: Text(name)),
)
```

### Anti-Patterns to Avoid
- **Don't use `Scaffold.bottomNavigationBar` for the floating nav** — it anchors to the bottom edge and cannot float above content
- **Don't delete Forja* widgets before all screens are migrated** — will break compilation
- **Don't import new F* widgets in old screens before the wave arrives** — causes mixed visual state
- **Don't use `px` thinking from TSX** — Flutter uses logical pixels that already account for density; TSX pixel values translate 1:1 to Flutter logical pixels at typical screen densities
- **Don't wrap the entire app in a RepaintBoundary for PrCardWidget** — it must stay as an offscreen repaint boundary for screenshot capture, change only its internal styling
- **Don't change the `syncProvider` initialization in main.dart** — it uses `ref.watch(syncProvider)` as a side-effect trigger; this pattern is required

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SVG arc countdown ring | Custom arc math from scratch | `CustomPainter.drawArc` with `canvas.drawArc` | One method, handles strokeCap rounding |
| Collapsible section animation | Manual height interpolation | `AnimatedSize` widget | Handles intrinsic height automatically |
| Spring button press | Manual spring physics | `AnimatedScale` + `GestureDetector` | Simpler, correct behavior |
| Gradient stroke on arc | Multiple overlapping arcs | `Paint().shader = ui.Gradient.linear()` | Supported natively |
| Google Font loading/caching | Manual HTTP font fetch | `GoogleFonts.syne()` | Handles cache, offline fallback |
| Week navigation state | Complex date math | `DateTime.now().subtract(Duration(days: 7))` + `weekOffset` int | Simple offset arithmetic |
| Staggered list animation | `AnimationController` per item | `flutter_animate` `.animate(delay: (i * 60).ms)` | Built-in stagger support |

**Key insight:** The TSX uses framer-motion as the animation layer. Every framer-motion pattern has a direct flutter_animate or core Flutter equivalent that is simpler to write than the TSX version — no animation controllers or tweens required in most cases.

---

## Common Pitfalls

### Pitfall 1: Screen Content Hidden Behind Floating Nav
**What goes wrong:** All tab screens appear to scroll correctly but content near the bottom is permanently hidden behind the floating pill nav.
**Why it happens:** The old `ForjaBottomNav` was in `Scaffold.bottomNavigationBar` which automatically pushed content up. The new floating nav is in a `Stack` overlay with no automatic padding.
**How to avoid:** Every tab screen's scrollable widget must have bottom padding of `MediaQuery.of(context).padding.bottom + 100`. Extract this as a constant `FSpacing.navClearance(context)`.
**Warning signs:** A "Save & Finish" or "Start Workout" CTA button at the bottom of a screen is partially hidden.

### Pitfall 2: Syne Font Weights Not Available
**What goes wrong:** `GoogleFonts.syne(fontWeight: FontWeight.w900)` falls back to w800 silently, causing subtle rendering differences.
**Why it happens:** Syne has Regular (400), Medium (500), SemiBold (600), Bold (700), and ExtraBold (800). Weight 900 does not exist.
**How to avoid:** Never use `FontWeight.w900` with Syne. The TSX uses `fontWeight: 800` which maps to `FontWeight.w800` — use that exactly.
**Warning signs:** Display text appears lighter than expected on device.

### Pitfall 3: Breaking the PrCardWidget Screenshot Path
**What goes wrong:** PR cards fail to capture after redesign — `RenderRepaintBoundary.toImage()` throws.
**Why it happens:** The `PrCardWidget` renders offscreen (positioned at `top: -9999` or inside `Offstage`). If it gains a dependency on `MediaQuery` or `Theme` that differs in the offscreen context, capture fails.
**How to avoid:** The `PrCardWidget` must be restyled with hardcoded light-theme colors (do not use `Theme.of(context)` inside it). It already uses hardcoded colors — keep that pattern.
**Warning signs:** `completeWorkout()` throws `RenderRepaintBoundary.toImage()` exception.

### Pitfall 4: Mixed Dark/Light Widget State During Migration
**What goes wrong:** Some screens use new F* widgets (light), others still use Forja* widgets (dark). The app looks broken mid-migration.
**Why it happens:** Forja* widgets use `isDark ? darkColor : lightColor` conditional. With `themeMode: ThemeMode.light` forced in Wave 1, they render the light versions — but those are the OLD light colors (e.g. `#F8F8FC` bg, mint green accent), not the new ones.
**How to avoid:** Migrate wave-by-wave. Every screen migrated in a wave should be fully converted to F* widgets within that wave's PRs. Do not leave a screen half-converted.
**Warning signs:** Today screen is coral/light but Profile screen is mint/dark.

### Pitfall 5: go_router `currentIndex` Desync with Floating Nav
**What goes wrong:** User navigates by deep link or back button; the floating nav pill shows wrong active tab.
**Why it happens:** `ScaffoldWithBottomNav` tracks `_currentIndex` as local state, but go_router can navigate without calling `onTap`.
**How to avoid:** Use `GoRouterState` or listen to `router.routerDelegate.currentConfiguration` to sync `_currentIndex`. The `FBottomNav` should derive active state from `GoRouter.of(context).location` rather than local int state.

```dart
// Correct pattern — derive active tab from route:
final location = GoRouterState.of(context).matchedLocation;
final _currentIndex = switch(location) {
  '/today'   => 0,
  '/history' => 1,
  '/progress'=> 2,
  '/profile' => 3,
  _ => 0,
};
```

### Pitfall 6: UserProfile Hive Adapter for New Settings Fields
**What goes wrong:** Adding `units` and `restTimerDuration` fields to `UserProfile` requires regenerating Hive type adapters, or the app crashes on existing Hive boxes.
**Why it happens:** Hive type adapters use field indices. Adding a new field without proper annotation causes deserialization to fail for existing records.
**How to avoid:** Add new fields with `@HiveField(N)` where N is the next available index. Fields must be nullable or have a default value. Run `flutter pub run build_runner build --delete-conflicting-outputs` after adding fields. Existing Hive boxes will use null for missing fields (safe).
**Warning signs:** `HiveError: Cannot read field` on launch after adding UserProfile fields.

### Pitfall 7: Backdrop Blur Performance on Android
**What goes wrong:** `BackdropFilter(filter: ImageFilter.blur(...))` on the auth screen glass card and floating nav causes jank or black boxes on Android API < 28.
**Why it happens:** Backdrop filter requires a compositor layer which is expensive and not supported on older Android.
**How to avoid:** The floating nav uses `Colors.white.withOpacity(0.95)` — this is opaque enough without blur. For the auth screen, use `Colors.white.withOpacity(0.90)` instead of a real backdrop blur. Only apply `BackdropFilter` if a `ClipRRect` parent is also present (required for the blur to work).
**Warning signs:** Black rectangle appears where the frosted glass should be.

---

## Code Examples

### Floating Nav Active Tab Detection
```dart
// Source: go_router ShellRoute pattern — verified against go_router 13.x docs
// In FBottomNav, derive active state from matched route:
class FBottomNav extends ConsumerWidget {
  final ValueChanged<int> onTap;
  const FBottomNav({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = switch (location) {
      '/today'    => 0,
      '/history'  => 1,
      '/progress' => 2,
      '/profile'  => 3,
      _ => 0,
    };
    // ... build pill with currentIndex
  }
}
```

### Readiness Ring (SVG arc → CustomPainter)
```dart
// Source: Flutter canvas docs — canvas.drawArc
// Matches TSX: svg circle with strokeDasharray
CustomPaint(
  size: const Size(100, 100),
  painter: _ReadinessPainter(score: score / 100.0, color: zoneColor),
)

class _ReadinessPainter extends CustomPainter {
  final double score; // 0.0–1.0
  final Color color;
  _ReadinessPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    final paint = Paint()..strokeWidth = 8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    // Track
    canvas.drawCircle(c, r, paint..color = const Color(0xFFEEF6FB));
    // Arc — rotated -90deg (top), sweeps clockwise
    if (score > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * score,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_ReadinessPainter old) => old.score != score || old.color != color;
}
```

### FButton — Coral Gradient Pill with Scale Press
```dart
// lib/shared/widgets/f_button.dart
class FButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  const FButton({super.key, required this.label, this.onPressed, this.isLoading = false, this.icon});

  @override
  State<FButton> createState() => _FButtonState();
}

class _FButtonState extends State<FButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onPressed?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: widget.onPressed != null ? FColors.coralGradient : null,
              color: widget.onPressed == null ? FColors.textTertiary : null,
              borderRadius: BorderRadius.circular(FRadius.pill),
              boxShadow: widget.onPressed != null ? FColors.coralGlow : null,
            ),
            child: Center(
              child: widget.isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
                    Text(widget.label, style: FTextStyles.bodyStrong(Colors.white)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
```

### Week Navigation (HistoryScreen state)
```dart
// Derived from TSX getWeekDates(offset) function
int _weekOffset = 0; // 0 = current week, -1 = last week

List<DateTime> _getWeekDates(int offset) {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: (now.weekday - 1) % 7)).add(Duration(days: offset * 7));
  return List.generate(7, (i) => monday.add(Duration(days: i)));
}

// In build:
Row(children: [
  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _weekOffset--)),
  Text(weekRange),
  IconButton(
    icon: Icon(Icons.chevron_right, color: _weekOffset < 0 ? null : FColors.coral),
    onPressed: _weekOffset < 0 ? () => setState(() => _weekOffset++) : null,
  ),
])
```

### Pull-to-Refresh
```dart
// flutter RefreshIndicator — wraps any scrollable
RefreshIndicator(
  color: FColors.coral,
  backgroundColor: FColors.cardBg,
  onRefresh: () async {
    ref.invalidate(adaptiveTodayProvider);
    ref.invalidate(readinessProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  },
  child: CustomScrollView(slivers: [...]),
)
```

### MoodSelector (replacing CheckInSlider)
```dart
// Matches TSX MoodSelector — 5 pill buttons, filled up to selected value
Row(
  children: List.generate(5, (i) {
    final val = i + 1;
    final selected = val <= currentValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 40,
          decoration: BoxDecoration(
            gradient: selected ? LinearGradient(colors: [accentColor, accentColor.withOpacity(0.8)]) : null,
            color: selected ? null : FColors.surface,
            borderRadius: BorderRadius.circular(FRadius.sm + 2),
            boxShadow: val == currentValue ? [BoxShadow(color: accentColor.withOpacity(0.25), blurRadius: 12, offset: Offset(0, 4))] : null,
          ),
          child: Center(child: Text('$val',
            style: FTextStyles.display(selected ? Colors.white : FColors.textTertiary))),
        ),
      ),
    );
  }),
)
```

---

## State of the Art

| Old Approach | Current Approach | Impact |
|--------------|------------------|--------|
| Dark bg `#0A0A0F` + mint accent | Light bg `#EEF6FB` + coral gradient | Complete visual reversal |
| `Border.all` for card depth | Shadow-based elevation | Cards feel floating, not flat |
| Inter-only typography | Syne (display) + Inter (body) | Editorial headers, readable body |
| Standard `BottomNavigationBar` | Floating pill overlay | Modern, doesn't clip screen |
| Linear `RestTimer` progress bar | Circular `CustomPainter` arc | Matches rest timer convention |
| `CheckInSlider` (slider widget) | `FMoodSelector` (5 pill buttons) | Faster interaction, clearer value |

**What the TSX uses that has NO Flutter equivalent:**
- `recharts` BarChart / LineChart → Use existing custom bar chart in `progress_screen.dart` (already flutter_animate animated). 1RM sparklines → `LinearProgressIndicator` trend bars (simpler, works).
- `canvas-confetti` npm package → `confetti` pub.dev package (deferred per CONTEXT.md)
- `backdropFilter` on nav → approximate with `Colors.white.withOpacity(0.95)` (no real blur needed for pill nav)

---

## Open Questions

1. **UserProfile model fields for settings**
   - What we know: `units` (kg/lbs) and `restTimerDuration` (seconds) need to be stored per profile
   - What's unclear: Do these already exist on the Freezed `UserProfile` model? The FEATURES_ANALYSIS shows the field list doesn't include `units` or `restTimerDuration`.
   - Recommendation: Add `@HiveField(N) final String? units` and `@HiveField(N) final int? restTimerDuration` to `UserProfile`. Run build_runner. Default to `'kg'` and `90` when null.

2. **go_router currentIndex sync in FBottomNav**
   - What we know: `GoRouterState.of(context).matchedLocation` gives the current route
   - What's unclear: Whether `GoRouterState.of(context)` works correctly inside a `Positioned` widget that is not a direct route descendant
   - Recommendation: Make `FBottomNav` a `ConsumerWidget` that reads the router's current location from `ref.watch(routerProvider).location` or passes `currentIndex` from `ScaffoldWithBottomNav` which derives it from `GoRouterState`.

3. **Progress screen charts — recharts vs flutter**
   - What we know: TSX uses recharts BarChart with Cell coloring; Flutter has no recharts equivalent
   - What's unclear: Whether to add `fl_chart` package or use the existing custom animated bars
   - Recommendation: Keep existing custom animated bar chart pattern (flutter_animate stagger on `AnimatedContainer` height bars). The 1RM trend "sparklines" in TSX become `LinearProgressIndicator`-based trend rows. Do NOT add fl_chart — scope creep.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in SDK) |
| Config file | None — uses standard `flutter test` |
| Quick run command | `flutter test test/ --no-pub` |
| Full suite command | `flutter test test/ --coverage --no-pub` |

### Phase Requirements → Test Map

Phase 9 is a visual redesign. No new business logic is introduced. Requirements are UI-correctness and backend connectivity preservation.

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| UI-01 | App builds with zero errors after redesign | Build smoke | `flutter build apk --debug` | ❌ Wave 0 script |
| UI-02 | TodayScreen loads exercises from provider (not hardcoded) | Widget test | `flutter test test/today_screen_test.dart` | ✅ exists |
| UI-03 | Floating nav switches between 4 tabs correctly | Widget test | `flutter test test/router_test.dart` | ✅ exists |
| UI-04 | WorkoutProvider still receives exercises on Start Workout tap | Widget test | `flutter test test/today_screen_test.dart` | ✅ exists |
| UI-05 | Readiness score zone shows correct color (green/yellow/red) | Unit test | `flutter test test/today_provider_test.dart` | ✅ exists |
| UI-06 | HistoryScreen week navigation changes displayed week | Widget test | `flutter test test/` | ❌ Wave 3 |
| UI-07 | ProfileScreen sign-out triggers auth provider signOut | Widget test | `flutter test test/auth_provider_test.dart` | ✅ exists |

### Sampling Rate
- **Per task commit:** `flutter analyze && flutter test test/ --no-pub`
- **Per wave merge:** `flutter build apk --debug && flutter test test/ --coverage`
- **Phase gate:** `flutter build apk --debug` passes, all existing tests green, emulator smoke test on all 4 tabs

### Wave 0 Gaps
- [ ] `test/history_week_navigation_test.dart` — covers UI-06 week navigation state
- [ ] Build verification script: `flutter analyze && flutter build apk --debug` — run at start of each wave

*(All other existing test files cover the backend-connectivity requirements that must be preserved)*

---

## Sources

### Primary (HIGH confidence)
- `new_ui/src/app/screens/*.tsx` — 9 authoritative TSX screen files, directly analyzed
- `new_ui/src/app/components/FloatingNav.tsx` — floating nav reference design
- `new_ui/src/imports/FORJA_FEATURES_ANALYSIS.md` — complete feature inventory
- `lib/app/theme.dart` — current theme tokens to be replaced
- `lib/app/router.dart` — `ScaffoldWithBottomNav` pattern that needs updating
- `pubspec.yaml` — confirmed library versions: flutter_animate ^4.5.0, google_fonts ^6.1.0
- fonts.google.com/specimen/Syne — Syne font confirmed in Google Fonts catalog (all weights 400–800)
- Flutter docs: `canvas.drawArc` — circular arc drawing API

### Secondary (MEDIUM confidence)
- `new_ui/src/imports/UI_REDESIGN_PLAN.md` — planning document, some values may be aspirational
- FORJA_FEATURES_ANALYSIS.md §7 "Gaps & Issues" — accurate gap analysis for hardcoded values

### Tertiary (LOW confidence)
- Web search: flutter_animate spring curves — no official framer-motion ↔ flutter_animate equivalence chart exists; mapping is approximated by curve behavior description

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages confirmed in pubspec.yaml; Syne confirmed in Google Fonts
- Architecture (migration order): HIGH — derived directly from file dependency graph
- Animation patterns: MEDIUM — flutter_animate ↔ framer-motion mapping approximated; exact durations are Claude's discretion
- Pitfalls: HIGH — derived from existing codebase analysis (HiveField indices, RepaintBoundary, backdrop filter)

**Research date:** 2026-03-26
**Valid until:** 2026-05-01 (flutter_animate and google_fonts are stable; go_router ShellRoute API stable)
