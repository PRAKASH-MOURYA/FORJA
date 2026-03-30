# FORJA — Flutter App

Your intelligent training companion. Built with Flutter, Riverpod, and go_router.

## Project structure

```
flutter_forja/
├── lib/
│   ├── main.dart                          # App entry point — full-screen, dark-mode-first
│   │
│   ├── shared/
│   │   └── constants/
│   │       └── tokens.dart               # ✅ Design tokens (AppColors, AppSpacing, AppTextStyle)
│   │
│   ├── theme/
│   │   └── app_theme.dart                # ThemeData + AppColors ThemeExtension
│   │
│   ├── models/
│   │   └── exercise.dart                 # Exercise data model
│   │
│   ├── data/
│   │   └── exercises_data.dart           # Seed exercise list
│   │
│   ├── screens/
│   │   ├── today_screen.dart             # Screen 1 — Today (workout overview + demo sheet)
│   │   ├── history_screen.dart           # Screen 2 — History (calendar strip + workout cards)
│   │   ├── progress_screen.dart          # Screen 3 — Progress (charts + PR tracking)
│   │   ├── profile_screen.dart           # Screen 4 — Profile (stats + settings)
│   │   ├── workout_logging_screen.dart   # Screen 5 — Workout Logging (sets + rest timer)
│   │   ├── post_workout_checkin_screen.dart # Screen 6 — Post-Workout Check-in (sliders)
│   │   ├── exercise_screen.dart          # Exercise detail / demo screen
│   │   └── workout_complete_screen.dart  # Completion screen (kept for backward compat)
│   │
│   └── widgets/
│       ├── bottom_nav.dart               # 4-tab bottom navigation bar
│       ├── pill.dart                     # Reusable Pill/badge widget
│       └── status_bar.dart              # ✅ Device-agnostic safe-area spacer (no iPhone elements)
│
└── pubspec.yaml                          # Dependencies: go_router, flutter_riverpod, hive_flutter
```

## Design tokens

All colors, spacing, and typography live in `lib/shared/constants/tokens.dart`:

| Token | Value | Usage |
|---|---|---|
| `AppColors.darkBg` | `#0A0A0F` | Main background |
| `AppColors.darkBgCard` | `#13131A` | Card surfaces |
| `AppColors.darkBgElevated` | `#1A1A24` | Elevated rows, inputs |
| `AppColors.darkAccent` | `#6EE7B7` | Mint — primary CTA, highlights |
| `AppColors.darkWarm` | `#F59E0B` | Amber — timer, readiness badge |
| `AppColors.darkCoral` | `#FB7185` | Coral — soreness, warnings |
| `AppColors.darkSky` | `#38BDF8` | Sky — video, secondary info |
| `AppColors.darkTextPrimary` | `#F0F0F5` | Body text |
| `AppColors.darkTextSecondary` | `#8888A0` | Labels, captions |
| `AppColors.darkBorder` | `rgba(255,255,255,6%)` | Separators, card borders |

## Running the app

```bash
cd flutter_forja
flutter pub get
flutter run
```

## Key design decisions

- **No phone frame** — full-screen immersive app, works on any Android or iOS device
- **No iPhone-specific elements** — no dynamic island, no 9:41 clock, no signal/battery icons
- **Safe-area spacer** — `StatusBarWidget` uses `MediaQuery.viewPadding.top` so the real OS
  status bar always shows through correctly on every device
- **Always dark** — `ThemeMode.dark` is set in `main.dart`; the light theme is preserved
  for future use but not active in the current build
- **Riverpod ready** — add `ProviderScope` around `ForjaApp` when wiring up Riverpod providers
