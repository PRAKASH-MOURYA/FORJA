# Phase 7: Social + Retention - Research

**Researched:** 2026-03-22
**Domain:** Flutter gamification, push notifications (FCM), widget-to-image sharing, Supabase social schema
**Confidence:** HIGH (stack well-verified; challenge invite link approach is MEDIUM)

---

## Summary

Phase 7 adds four retention and social systems on top of a fully wired offline-first Flutter app (Riverpod + Hive + Supabase). The good news: **the data models are already built**. `UserProfile` has `xp`, `level`, `streakWeeks`, and `streakShields` fields with matching Hive TypeAdapters, and the Supabase `profiles` table already has those same columns. The XP/streak plan is a logic layer and UI update, not a schema migration.

The biggest new dependency is `firebase_messaging` (16.1.2), which requires a Firebase project, `flutterfire_cli` configuration, `google-services.json` on Android, and a `@pragma('vm:entry-point')` top-level background handler. On Android, FCM does not display foreground notifications automatically — `flutter_local_notifications` (21.0.0) is required alongside it. PR card sharing uses Flutter's `RepaintBoundary.toImage()` piped into `share_plus` (12.0.1) with no external screenshot service needed. Buddy challenge invite links should use `app_links` (7.0.0) with a custom URL scheme and a Supabase `challenges` table — Firebase Dynamic Links were shut down August 2025 and must not be used.

**Primary recommendation:** Implement in plan order: XP/streaks first (models exist, purely local), then PR share cards (RepaintBoundary + share_plus), then push notifications (Firebase setup cost is high, do it once), then buddy challenges (Supabase schema + deep link).

---

## Critical Pre-Existing Foundation

This context is essential — the planner must NOT re-create or migrate these:

| Asset | Location | What It Provides |
|-------|----------|-----------------|
| `UserProfile.xp` | `lib/shared/models/user_profile.dart` HiveField(8) | XP integer, persisted to Hive, typeId 4 |
| `UserProfile.level` | HiveField(9) | String: 'novice' \| 'beginner' \| 'intermediate' \| 'advanced' \| 'elite' |
| `UserProfile.streakWeeks` | HiveField(10) | Int, weekly streak count |
| `UserProfile.streakShields` | HiveField(11) | Int, default 1 |
| `profiles` Supabase table | `supabase_schema.sql` | `xp`, `level`, `streak_weeks`, `streak_shields` columns already exist |
| `UserProfileNotifier.update()` | `auth_provider.dart` | Immutable update + Hive save in one call |
| `PrRepository.saveIfPR()` | `pr_repository.dart` | Returns bool — true when a new PR was set |
| `WorkoutRepository` | `lib/shared/repositories/workout_repository.dart` | Source of truth for workout history |

**The XP/streak plan touches only:** `XpService` (new), `ProfileScreen` (UI update), and post-workout/check-in wiring. No Freezed regeneration needed if fields already exist in the model.

---

## Standard Stack

### Core New Dependencies

| Library | Version | Purpose | Why |
|---------|---------|---------|-----|
| `firebase_core` | ^3.x | Firebase initialization | Required by firebase_messaging |
| `firebase_messaging` | ^16.1.2 | FCM push notifications | Official Google plugin, cross-platform |
| `flutter_local_notifications` | ^21.0.0 | Foreground notification display | FCM blocks foreground on Android without this |
| `share_plus` | ^12.0.1 | Native share sheet for PR cards | ACTION_SEND on Android, UIActivityViewController on iOS |
| `app_links` | ^7.0.0 | Deep link handling for challenge invites | Firebase Dynamic Links shut down Aug 2025 |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `path_provider` | ^2.x | Temp file path for share_plus XFile | Always needed when sharing image bytes |
| `flutterfire_cli` | latest (dev tool) | `flutterfire configure` — generates firebase_options.dart | Run once during setup |

### Already in pubspec (no additions needed)

- `flutter_riverpod` ^2.5.1 — XP/streak state management
- `hive_flutter` ^1.1.0 — XP/streak local persistence
- `supabase_flutter` ^2.12.0 — challenge leaderboard, Supabase profile sync
- `flutter_animate` ^4.5.0 — XP level-up animation

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `share_plus` | `appinio_social_share` | appinio has direct Instagram Story API but requires app-specific setup; share_plus native sheet is simpler and covers WhatsApp natively |
| `app_links` | `uni_links` | uni_links is desktop-focused; app_links handles Android + iOS + desktop all with one API |
| Custom XP logic | `teqani_rewards` package | teqani is heavier; FORJA XP rules are simple enough for a single service class |

**Installation:**
```bash
flutter pub add firebase_core firebase_messaging flutter_local_notifications share_plus app_links path_provider
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## Architecture Patterns

### Recommended File Structure (Phase 7 additions)

```
lib/
├── shared/
│   ├── services/
│   │   ├── xp_service.dart              # XP award logic + level threshold map
│   │   ├── streak_service.dart          # Weekly streak + shield logic
│   │   ├── notification_service.dart    # FCM init, foreground handler, scheduling
│   │   └── pr_card_service.dart         # RepaintBoundary capture + share_plus
│   ├── providers/
│   │   ├── xp_provider.dart             # Exposes XP + level from userProfileProvider
│   │   └── challenge_provider.dart      # Supabase challenge state
│   └── models/
│       └── challenge.dart               # Freezed model for buddy challenges
├── features/
│   ├── profile/
│   │   └── xp_banner.dart               # XP progress bar + level widget
│   ├── challenges/
│   │   ├── challenge_screen.dart        # List active challenges
│   │   └── challenge_invite_screen.dart # Accept challenge from deep link
│   └── pr_card/
│       └── pr_card_widget.dart          # Off-screen render target for share
```

### Pattern 1: XP Award via Service + Notifier Update

**What:** XP is awarded at well-defined events (workout complete, check-in saved, PR detected). The `XpService` computes new XP + level, then `UserProfileNotifier.update()` persists the change immutably.

**When to use:** Whenever a workout completes, check-in saves, or PR is detected.

```dart
// Source: established Riverpod StateNotifier pattern (auth_provider.dart line 51)
class XpService {
  static const Map<String, int> kXpRewards = {
    'workout': 100,
    'pr': 200,
    'checkin': 20,
  };

  static const Map<String, int> kLevelThresholds = {
    'novice': 0,
    'beginner': 500,
    'intermediate': 1500,
    'advanced': 3500,
    'elite': 7000,
  };

  // Returns updated profile with new XP and level — never mutates input
  static UserProfile awardXp(UserProfile profile, String eventType) {
    final reward = kXpRewards[eventType] ?? 0;
    final newXp = profile.xp + reward;
    final newLevel = _computeLevel(newXp);
    return profile.copyWith(xp: newXp, level: newLevel);
  }

  static String _computeLevel(int xp) {
    String result = 'novice';
    for (final entry in kLevelThresholds.entries) {
      if (xp >= entry.value) result = entry.key;
    }
    return result;
  }
}
```

### Pattern 2: Weekly Streak Logic (not daily)

**What:** A streak week increments when a user completes at least one workout in the current ISO week (Monday–Sunday). A shield absorbs a missed week. Shields accrue at 1/month cap.

**When to use:** Called after each workout save, checked against the ISO week of the last workout.

```dart
// Streak logic — pure function, easily unit-tested
class StreakService {
  static UserProfile evaluateStreak(UserProfile profile, DateTime workoutDate) {
    final lastWorkoutWeek = _isoWeek(workoutDate);
    final currentWeek = _isoWeek(DateTime.now());

    // Same week — streak already counted, no change
    if (lastWorkoutWeek == currentWeek) return profile;

    final weekGap = currentWeek - lastWorkoutWeek;

    if (weekGap == 1) {
      // Consecutive week: increment streak
      return profile.copyWith(streakWeeks: profile.streakWeeks + 1);
    } else if (weekGap > 1 && profile.streakShields > 0) {
      // Missed week but shield available: consume shield, preserve streak
      return profile.copyWith(streakShields: profile.streakShields - 1);
    } else {
      // Streak broken
      return profile.copyWith(streakWeeks: 0);
    }
  }

  static int _isoWeek(DateTime date) {
    // ISO 8601 week number
    final jan4 = DateTime(date.year, 1, 4);
    return ((date.difference(jan4).inDays + jan4.weekday) / 7).ceil();
  }
}
```

### Pattern 3: RepaintBoundary → PNG → share_plus

**What:** Render the PR card widget off-screen at 3x device pixel ratio, capture as PNG bytes, write to a temp file, share via the native sheet.

**When to use:** When user taps "Share PR" from the post-workout complete screen.

```dart
// Source: official Flutter RenderRepaintBoundary.toImage() API
// https://api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html

Future<void> sharePrCard(GlobalKey cardKey, BuildContext context) async {
  final boundary = cardKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0); // high DPI
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/pr_card.png');
  await file.writeAsBytes(bytes);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'Just hit a new PR on FORJA! 💪',
    ),
  );
}
```

### Pattern 4: FCM Background Handler

**What:** A top-level function annotated `@pragma('vm:entry-point')` runs in a separate isolate when FCM messages arrive in background/terminated state. It must not touch Flutter UI or Riverpod state.

```dart
// Source: firebase.google.com/docs/cloud-messaging/flutter/receive-messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Only log or schedule local notification — NO UI / Provider access
}

// In main():
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

### Pattern 5: Supabase Challenge Schema

**What:** A minimal `challenges` table stores challenge state. Each participant row holds a `user_id` and `challenge_id`. Volume or consistency is aggregated via a Supabase view, not client-side.

```sql
-- New tables for Phase 7 (buddy challenges)
create table if not exists public.challenges (
    id uuid primary key default gen_random_uuid(),
    creator_id uuid references auth.users not null,
    type text not null,  -- 'volume_battle' | 'consistency' | '30_day'
    start_date date not null,
    end_date date not null,
    invite_code text unique not null default substr(md5(random()::text), 1, 8),
    created_at timestamptz default now()
);

create table if not exists public.challenge_participants (
    id uuid primary key default gen_random_uuid(),
    challenge_id uuid references public.challenges(id) on delete cascade,
    user_id uuid references auth.users not null,
    joined_at timestamptz default now(),
    unique(challenge_id, user_id)
);

-- RLS: participants can read challenges they belong to
alter table public.challenges enable row level security;
alter table public.challenge_participants enable row level security;

create policy "Anyone can read a challenge they participate in"
  on public.challenges for select
  using (exists (
    select 1 from public.challenge_participants cp
    where cp.challenge_id = challenges.id
    and cp.user_id = auth.uid()
  ));

create policy "Creator can insert challenges"
  on public.challenges for insert
  with check (auth.uid() = creator_id);

create policy "Users manage their own participation"
  on public.challenge_participants for all
  using (auth.uid() = user_id);
```

### Anti-Patterns to Avoid

- **Daily streak counting:** The requirement is explicitly weekly (ISO week). Daily streak is listed as out of scope in REQUIREMENTS.md.
- **Firebase Dynamic Links for invite links:** Shut down August 25, 2025. Use `app_links` + custom scheme + Supabase `invite_code` column instead.
- **Touching Riverpod providers inside background handler:** The background isolate has no ProviderScope — use only Firebase + minimal local storage.
- **Mutating UserProfile in-place:** Always use `profile.copyWith(...)` via `UserProfileNotifier.update()`. The existing notifier pattern enforces this.
- **Sharing image with share_plus without a temp file:** `XFile.fromData()` can be used but writing to a temp file is more reliable across Android versions.
- **Regenerating Freezed for XP fields:** The `UserProfile` model already has `xp`, `level`, `streakWeeks`, `streakShields` as HiveFields. Do not add new HiveField indices that conflict with existing typeIds 0–4.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Push notification delivery | Custom WebSocket / polling | `firebase_messaging` 16.1.2 | FCM handles delivery guarantees, retry, platform routing |
| Foreground notification display on Android | Custom overlay | `flutter_local_notifications` 21.0.0 | FCM SDK blocks foreground display by design; this is the documented workaround |
| Image sharing | Custom intent builder | `share_plus` 12.0.1 | Wraps ACTION_SEND + UIActivityViewController correctly; handles iPad sharePositionOrigin |
| Widget screenshot | Custom RenderObject | `RenderRepaintBoundary.toImage()` | Built into Flutter SDK, no package needed |
| Deep link parsing | Manual URI parsing | `app_links` 7.0.0 | Handles cold start, background, and foreground link states across Android/iOS |
| XP level thresholds | Database-driven config | Dart constants map | 6 levels are fixed by product spec; Dart constants avoid a Supabase roundtrip |

**Key insight:** The XP and streak system requires zero new packages — it is pure Dart logic operating on the already-typed `UserProfile` model. Only the social transport layer (FCM, share_plus, app_links) requires new dependencies.

---

## Common Pitfalls

### Pitfall 1: FCM Foreground Notifications Silently Dropped on Android

**What goes wrong:** Push notifications sent via FCM when the app is in the foreground never appear on Android. Users think notifications are broken.

**Why it happens:** The Firebase Android SDK intentionally blocks FCM notifications in the foreground. This is documented behavior, not a bug.

**How to avoid:** Listen to `FirebaseMessaging.onMessage` stream and display a local notification via `flutter_local_notifications` with a HIGH importance notification channel.

**Warning signs:** Notifications work when app is background/killed but not in foreground.

### Pitfall 2: @pragma Missing on Background Handler

**What goes wrong:** Background notifications are silently ignored in release builds. Works fine in debug.

**Why it happens:** Dart's tree shaker removes the function in release mode without the pragma annotation.

**How to avoid:** Always annotate: `@pragma('vm:entry-point')` immediately above the top-level background handler function.

### Pitfall 3: Streak Increments on Same-Week Workout

**What goes wrong:** Streak goes up every workout instead of once per week. User completes 3 workouts in one week → streak shows +3.

**Why it happens:** Comparing by date instead of ISO week number.

**How to avoid:** `StreakService._isoWeek()` must be the gate — only increment when the gap between last-workout week and current week is exactly 1.

### Pitfall 4: iPad Crash on share_plus

**What goes wrong:** App crashes on iPad when the native share sheet is shown.

**Why it happens:** iPad requires `sharePositionOrigin` (the Rect of the source widget) to anchor the popover.

**How to avoid:** Always provide `sharePositionOrigin` in `ShareParams` on iPad, or use `RenderBox` to find the widget's position:

```dart
final box = context.findRenderObject() as RenderBox;
final origin = box.localToGlobal(Offset.zero) & box.size;
SharePlus.instance.share(ShareParams(files: [...], sharePositionOrigin: origin));
```

### Pitfall 5: Hive TypeId Collision When Adding New Models

**What goes wrong:** App crashes at startup with `HiveError: There is already a TypeAdapter for typeId X`.

**Why it happens:** New Freezed model registered with a typeId already used by an existing model.

**How to avoid:** Current registered typeIds are 0 (Exercise), 1 (WorkoutLog), 2 (SetLog), 3 (CheckIn), 4 (UserProfile). New models (e.g., `Challenge`) must start at typeId 5.

### Pitfall 6: XP Fields Conflict with Existing Hive HiveField Indices

**What goes wrong:** Build runner generates wrong adapter, data reads as null.

**Why it happens:** Attempting to re-declare `xp`, `level`, `streakWeeks`, `streakShields` in UserProfile with different HiveField numbers.

**How to avoid:** These fields already exist: HiveField(8)=xp, (9)=level, (10)=streakWeeks, (11)=streakShields. The model does NOT need modification. Only service and UI layers need to be added.

### Pitfall 7: Firebase Project Not Linked to Android App

**What goes wrong:** `MissingPluginException` or FCM token returns null at runtime.

**Why it happens:** `google-services.json` not placed in `android/app/`, or `flutterfire configure` was not run.

**How to avoid:** Run `flutterfire configure` once, commit `firebase_options.dart` and `google-services.json`. Verify `classpath 'com.google.gms:google-services'` in `android/build.gradle`.

---

## Code Examples

### XP Award at Workout Completion

```dart
// In the workout completion handler (complete_screen.dart or WorkoutProvider)
// Source: established UserProfileNotifier.update() pattern (auth_provider.dart)
await ref.read(userProfileProvider.notifier).update((p) {
  final afterWorkout = XpService.awardXp(p, 'workout');
  return StreakService.evaluateStreak(afterWorkout, DateTime.now());
});
```

### FCM Permission Request (iOS + Android 13+)

```dart
// Source: firebase.google.com/docs/cloud-messaging/flutter/receive-messages
final settings = await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
  provisional: false,
);
// Store FCM token to Supabase profiles table for server-side targeting
final token = await FirebaseMessaging.instance.getToken();
```

### Challenge Invite via Supabase + app_links

```dart
// Generate invite link (creator side)
final challenge = await supabase
    .from('challenges')
    .insert({'creator_id': uid, 'type': type, ...})
    .select()
    .single();
final inviteLink = 'forja://challenge/${challenge['invite_code']}';
await SharePlus.instance.share(ShareParams(text: 'Join my FORJA challenge! $inviteLink'));

// Receive link (app_links stream in router.dart)
// Source: pub.dev/packages/app_links
AppLinks().uriLinkStream.listen((uri) {
  if (uri.scheme == 'forja' && uri.pathSegments.first == 'challenge') {
    context.push('/challenge/join/${uri.pathSegments[1]}');
  }
});
```

### Supabase Leaderboard Query (Postgres aggregation, not client-side)

```dart
// Volume leaderboard for a challenge — let Supabase aggregate
final leaderboard = await supabase
    .from('workout_logs')
    .select('user_id, total_volume_kg')
    .gte('started_at', challenge.startDate.toIso8601String())
    .lte('started_at', challenge.endDate.toIso8601String());
// Group client-side by user_id and sum volumes
// (Or use a Supabase RPC function for server-side GROUP BY)
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Firebase Dynamic Links for invite URLs | `app_links` + custom scheme | Aug 25, 2025 (shutdown) | Must not use Dynamic Links — they are dead |
| `uni_links` for deep links | `app_links` 7.0.0 | ~2024 | app_links replaces it with broader platform support |
| Manual notification display | `flutter_local_notifications` alongside FCM | Stable since FCM 6.0.13+ | Compat issues are resolved in current versions |
| `Share.shareFiles()` (share_plus v8) | `SharePlus.instance.share(ShareParams(...))` | share_plus v10+ | API renamed; old method deprecated |

**Deprecated/outdated:**
- `Share.shareFiles()`: Use `SharePlus.instance.share(ShareParams(files: [...]))` in v12.
- Firebase Dynamic Links: Shut down. Do not use.

---

## Open Questions

1. **FCM server-side token targeting for scheduled reminders**
   - What we know: Client can get an FCM token via `getToken()`. The "max 3/week" cap requires server-side scheduling logic or Cloud Functions.
   - What's unclear: Phase 7 does not explicitly include Cloud Functions. The planner should decide whether to implement client-scheduled local notifications (simpler, no server) or server-push (requires Firebase Cloud Functions).
   - Recommendation: Use `flutter_local_notifications` scheduled notifications for workout reminders (client-side, no server cost). Reserve server-push for streak-at-risk (requires knowing the user hasn't worked out this week — needs backend).

2. **Challenge leaderboard real-time vs. polling**
   - What we know: Supabase supports real-time subscriptions via `supabase.from('...').stream(primaryKey: [...])`.
   - What's unclear: Real-time adds subscription management complexity.
   - Recommendation: Poll on screen focus (pull-to-refresh or `onAppLifecycleStateChanged`). Defer real-time subscription to Phase 8.

3. **Notification permission timing**
   - What we know: Android 13+ requires explicit permission. Asking at first launch has low acceptance rates.
   - What's unclear: FORJA has no onboarding gate for notification permission yet.
   - Recommendation: Request permission the first time a workout is completed (contextually motivating moment).

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK built-in) |
| Config file | none (uses `flutter test`) |
| Quick run command | `flutter test test/services/xp_service_test.dart -x` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| XP-01 | XP increases by 100 after workout completion | unit | `flutter test test/services/xp_service_test.dart -x` | ❌ Wave 0 |
| XP-02 | XP increases by 200 on PR detection | unit | `flutter test test/services/xp_service_test.dart -x` | ❌ Wave 0 |
| XP-03 | XP increases by 20 on check-in save | unit | `flutter test test/services/xp_service_test.dart -x` | ❌ Wave 0 |
| XP-04 | Level upgrades correctly at thresholds | unit | `flutter test test/services/xp_service_test.dart -x` | ❌ Wave 0 |
| STREAK-01 | Weekly streak increments only once per ISO week | unit | `flutter test test/services/streak_service_test.dart -x` | ❌ Wave 0 |
| STREAK-02 | Shield consumed on missed week, streak preserved | unit | `flutter test test/services/streak_service_test.dart -x` | ❌ Wave 0 |
| STREAK-03 | Streak resets to 0 when no shields remain | unit | `flutter test test/services/streak_service_test.dart -x` | ❌ Wave 0 |
| SHARE-01 | PR card widget renders to PNG bytes without crash | widget | `flutter test test/features/pr_card_test.dart -x` | ❌ Wave 0 |
| NOTIF-01 | NotificationService initializes without exception | unit | `flutter test test/services/notification_service_test.dart -x` | ❌ Wave 0 |
| CHALLENGE-01 | Invite code generated and parseable from deep link | unit | `flutter test test/services/challenge_service_test.dart -x` | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** `flutter test test/services/ -x`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `test/services/xp_service_test.dart` — covers XP-01, XP-02, XP-03, XP-04
- [ ] `test/services/streak_service_test.dart` — covers STREAK-01, STREAK-02, STREAK-03
- [ ] `test/features/pr_card_test.dart` — covers SHARE-01 (widget test with pump)
- [ ] `test/services/notification_service_test.dart` — covers NOTIF-01 (mock FirebaseMessaging)
- [ ] `test/services/challenge_service_test.dart` — covers CHALLENGE-01

---

## Sources

### Primary (HIGH confidence)

- pub.dev/packages/firebase_messaging — version 16.1.2, dependency requirements
- firebase.google.com/docs/cloud-messaging/flutter/receive-messages — background handler pattern, @pragma requirement, foreground notification behavior
- pub.dev/packages/share_plus — version 12.0.1, ShareParams API, platform support matrix
- api.flutter.dev/flutter/rendering/RenderRepaintBoundary/toImage.html — widget screenshot API
- pub.dev/packages/app_links — version 7.0.0, uriLinkStream API, platform setup
- pub.dev/packages/flutter_local_notifications — version 21.0.0, FCM compatibility note
- Project: `lib/shared/models/user_profile.dart` — confirmed xp, level, streakWeeks, streakShields HiveFields
- Project: `supabase_schema.sql` — confirmed profiles table has xp, level, streak_weeks, streak_shields columns

### Secondary (MEDIUM confidence)

- freecodecamp.org/news/how-to-save-and-share-flutter-widgets-as-images — RepaintBoundary + share_plus production pattern
- firebase.flutter.dev/docs/messaging/overview — FlutterFire messaging setup overview
- Multiple 2025 articles confirming Firebase Dynamic Links shutdown August 25, 2025

### Tertiary (LOW confidence)

- Supabase leaderboard via direct workout_logs query — no official "leaderboard" Supabase feature; custom aggregation pattern described from general Supabase docs

---

## Metadata

**Confidence breakdown:**
- XP/streak system: HIGH — model fields pre-exist, pure Dart logic, well-established patterns
- PR card sharing: HIGH — RepaintBoundary + share_plus are official Flutter/flutterfire-endorsed approaches
- Push notifications (FCM): HIGH — official Firebase docs, confirmed versions, known pitfalls documented
- Buddy challenges schema: MEDIUM — custom Supabase schema (no official "challenge" feature), invite link pattern verified via app_links
- Leaderboard aggregation approach: MEDIUM — generic Supabase query pattern, not a dedicated API

**Research date:** 2026-03-22
**Valid until:** 2026-04-22 (firebase_messaging releases frequently; check for breaking changes if delayed)
