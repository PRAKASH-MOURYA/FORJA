# Phase 8: Advanced Features - Research

**Researched:** 2026-03-27
**Domain:** Flutter health data integration, PDF generation, CSV export, nutrition display
**Confidence:** HIGH (core stack verified via pub.dev official pages and changelog)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **Permission denied (wearables):** show persistent "Connect Health" nudge card on TodayScreen. User can dismiss once but it reappears next session until connected.
- **Data source priority:** health package abstracts smartwatch > Health app > manual. No special-casing needed.
- **What's imported:** sleep hours, resting HR, HRV (RMSSD).
- **When import happens:** once per day, lazily when readiness score is first computed on TodayScreen.
- **Readiness formula upgrade:** sleep component pre-filled from wearable (user can override via slider). Energy component (30%) derived from resting HR + HRV when wearable present. No check-in required if at minimum sleep hours available. Banner shows data sources.
- **Nutrition — onboarding extension:** add height (cm) and body weight (kg) to quiz/onboarding. Saved to UserProfile. Protein target = `bodyWeightKg × 1.6`.
- **Protein display:** passive card on TodayScreen, below readiness banner. No input, no tracking.
- **Plate visual:** two static variants (training day vs rest day) on TodayScreen. Training = higher carbs, rest = higher protein/fat. Determined by `adaptiveTodayProvider`.
- **Water reminder:** local notification via existing NotificationService at 12:00 daily. Toggled in Profile. Default: off.
- **Export entry point:** Export section on ProfileScreen (new section below stats).
- **CSV format:** one row per SetLog — `date, workout_id, exercise_name, set_number, weight_kg, reps, completed, is_pr`.
- **PDF format:** monthly progress summary — volume trend chart, PR list, workout consistency. No minimum data requirement. If < 1 month, header says "Your progress so far."
- **Delivery:** save to device Downloads folder. Show snackbar: "Saved to Downloads: forja_export_2026-03.csv".
- **PDF generation:** on-device using `pdf` package. No server.

### Claude's Discretion
- Exact HRV/HR → energy score mapping function (normalization curve or lookup table)
- PDF layout and chart rendering details
- Plate visual illustration approach (custom painter vs SVG vs static asset)
- `health` package query window (last 24h vs last night's sleep session)
- Exact wearable nudge card dismissal logic (once per session vs once per day)

### Deferred Ideas (OUT OF SCOPE)
- HRV trend chart over time
- Barcode scanning for food logging
- Macro tracking (carbs, fat, calories)
- Dedicated nutrition tab
- Cloud backup for exports (Google Drive, iCloud)
- Muscle-specific recovery notifications
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| WEAR-01 | Sleep hours auto-imported from HealthKit/Health Connect | health 13.3.1, HealthDataType.SLEEP_ASLEEP, requestAuthorization + getHealthDataFromTypes |
| WEAR-02 | Resting HR + HRV imported and stored as WearableSnapshot | HealthDataType.RESTING_HEART_RATE, HEART_RATE_VARIABILITY_RMSSD |
| WEAR-03 | Readiness score upgraded when wearable data present | CalculationService.readinessScore extended with optional wearable params |
| WEAR-04 | "Connect Health" nudge card on TodayScreen when permission denied | Standard Flutter widget; permission state from WearableService |
| NUT-01 | height + bodyWeightKg fields added to UserProfile + onboarding quiz | Hive HiveField append pattern; Freezed model regeneration |
| NUT-02 | Protein target card on TodayScreen (passive, no tracking) | bodyWeightKg × 1.6; reads from UserProfile via profileProvider |
| NUT-03 | Plate visual card on TodayScreen (training vs rest day) | adaptiveTodayProvider.isRestDay; static asset recommended |
| NUT-04 | Water reminder notification toggle in Profile (default off) | NotificationService.scheduleWaterReminder pattern (ID 1002) |
| EXP-01 | CSV export of full SetLog history to Downloads | share_plus SharePlus.shareXFiles() — recommended over path_provider |
| EXP-02 | Monthly PDF progress summary (volume trend, PRs, consistency) | pdf 3.12.0 — pw.Document, pw.MultiPage, pw.Table, custom bar drawing |
</phase_requirements>

---

## Summary

Phase 8 adds three self-contained feature pillars to FORJA: wearable health data import, passive nutrition guidance, and data export. All three pillars integrate cleanly with existing services and models — no new backend tables are required.

The `health` package (v13.3.1) provides a unified API over HealthKit (iOS) and Health Connect (Android). It requires non-trivial platform setup on both targets: an activity-alias in AndroidManifest.xml, FlutterFragmentActivity requirement on Android 14+, and HealthKit capability + Info.plist keys on iOS. The singleton initialization pattern changed in v12 — `Health()` is no longer a factory; it must be instantiated once globally.

PDF generation uses `pdf` 3.12.0 (stable, on-device). The `printing` companion package is useful for previewing but not required for saving. Chart rendering inside PDFs is done via custom drawing using `pw.CustomPaint` or by rendering simple bar graphics manually — `pw.Chart` is not a documented widget in this package; bar charts are drawn using `pw.Container` rows or via SVG. For file delivery, **`share_plus` (already in pubspec) is the correct approach** — `path_provider.getDownloadsDirectory()` on Android returns an app-scoped path (`Android/data/…/files/downloads`), not the visible public Downloads folder, and this is a known open issue.

**Primary recommendation:** Use `share_plus` `SharePlus.shareXFiles()` for both CSV and PDF delivery. This triggers the native share sheet, which lets users save to Files/Downloads themselves — avoiding all scoped storage complexity. This is the standard pattern for Flutter file export to user-visible storage.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| health | ^13.3.1 | HealthKit + Health Connect unified API | Only Flutter-maintained cross-platform health package; Google Fit removed in v11 |
| pdf | ^3.12.0 | On-device PDF generation | Mature, zero-server Dart-native PDF builder; active maintenance (v3.12.0 released 2026-03) |
| share_plus | ^12.0.1 | File delivery (CSV + PDF) | Already in pubspec; triggers native share sheet; correct approach for public file handoff |
| path_provider | ^2.1.0 | App-local temp file path for PDF/CSV before sharing | Already in pubspec; use `getApplicationDocumentsDirectory()` or `getTemporaryDirectory()` for temp writes |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| permission_handler | ^12.0.1 | Android notification permission for water reminder | Already likely in project; NOT needed for health data (health package handles its own permissions) |
| flutter_local_notifications | ^17.2.4 | Water reminder scheduling | Already in pubspec via NotificationService |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| share_plus for export | path_provider getDownloadsDirectory | share_plus is simpler and correct; getDownloadsDirectory has open scope bug on Android returning app-private path |
| pdf package | syncfusion_flutter_pdf | syncfusion is commercially licensed (free tier has watermarks); pdf package is MIT |
| Static asset plate visual | Custom painter | Static assets are simpler, no rendering bugs, easiest to design well |

### Installation
```bash
# Add to pubspec.yaml (share_plus, path_provider already present)
flutter pub add health
flutter pub add pdf
# permission_handler likely already present; verify in pubspec
```

---

## Architecture Patterns

### Recommended Project Structure (new files only)
```
lib/shared/
├── services/
│   ├── wearable_service.dart       # Wraps health package; returns WearableSnapshot
│   └── export_service.dart         # Builds CSV string + generates PDF bytes
├── models/
│   └── wearable_snapshot.dart      # Freezed: sleepHours, restingHR?, hrv?
└── providers/
    └── wearable_provider.dart      # AsyncNotifier; calls WearableService once/day

lib/features/
├── today/                          # TodayScreen additions:
│   │                               #   protein_target_card.dart
│   │                               #   plate_visual_card.dart
│   │                               #   connect_health_nudge_card.dart
└── profile/                        # ProfileScreen additions:
                                    #   export_section.dart
```

### Pattern 1: Global Health Singleton (CRITICAL — v12+ breaking change)
**What:** `Health` class must be instantiated once globally, not via factory
**When to use:** At app startup, before any health data reads

```dart
// lib/main.dart or lib/app/app.dart — initialize once
final health = Health();

// In WearableService constructor or init:
class WearableService {
  final Health _health;
  WearableService(this._health);  // inject the global instance
}
```

### Pattern 2: WearableService — Request + Read
**What:** Request permissions, then query last night's sleep window and today's resting HR/HRV

```dart
// Source: pub.dev/packages/health official API
class WearableService {
  final Health _health;
  WearableService(this._health);

  static const _types = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
  ];

  Future<bool> requestPermission() async {
    return _health.requestAuthorization(_types);
  }

  Future<WearableSnapshot?> fetchSnapshot() async {
    final now = DateTime.now();
    // Sleep window: yesterday 18:00 to now (captures last night's sleep)
    final sleepStart = DateTime(now.year, now.month, now.day - 1, 18, 0);
    // HR/HRV window: last 24h
    final hrStart = now.subtract(const Duration(hours: 24));

    final sleepData = await _health.getHealthDataFromTypes(
      startTime: sleepStart,
      endTime: now,
      types: [HealthDataType.SLEEP_ASLEEP],
    );
    final hrData = await _health.getHealthDataFromTypes(
      startTime: hrStart,
      endTime: now,
      types: [HealthDataType.RESTING_HEART_RATE, HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
    );

    final clean = Health.removeDuplicates([...sleepData, ...hrData]);
    return _parseSnapshot(clean);
  }
}
```

### Pattern 3: Energy Score from HR + HRV (Claude's Discretion)
**What:** Map resting HR and HRV to 0.0–1.0 energy value; lower HR + higher HRV = higher energy
**Recommended approach:** Linear clamp normalization (verifiable, transparent, no training data needed)

```dart
// Source: physiological ranges from kubios.com/blog/heart-rate-variability-normal-range
// Resting HR: 40 (elite athlete) to 100+ (poor). Good range: 50–70 bpm.
// HRV RMSSD: 20ms (low) to 80ms+ (high). Typical healthy: 30–60ms.

static double energyFromWearables({double? restingHrBpm, double? hrvMs}) {
  double hrScore = 0.5;   // neutral if unavailable
  double hrvScore = 0.5;

  if (restingHrBpm != null) {
    // 50 bpm → 1.0 (excellent), 90 bpm → 0.0 (poor)
    hrScore = ((90 - restingHrBpm) / 40).clamp(0.0, 1.0);
  }
  if (hrvMs != null) {
    // 20ms → 0.0, 70ms → 1.0
    hrvScore = ((hrvMs - 20) / 50).clamp(0.0, 1.0);
  }

  // Average if both available; use single if only one
  if (restingHrBpm != null && hrvMs != null) {
    return (hrScore + hrvScore) / 2;
  }
  return restingHrBpm != null ? hrScore : hrvScore;
}
```

### Pattern 4: Extend CalculationService.readinessScore (backward-compatible)
**What:** Add optional wearable parameters; existing call sites without them continue to work

```dart
// Extend signature — keep old positional params, add named optionals
static ReadinessScore readinessScore(
  CheckIn? lastCheckIn,
  int daysSinceWorkout, {
  WearableSnapshot? wearable,   // new optional param
}) {
  // Energy: use wearable-derived if available, else checkIn.energy (or neutral 3)
  final energyInput = (wearable?.energyScore != null)
      ? wearable!.energyScore!
      : (lastCheckIn?.energy ?? 3) / 5.0;
  final energy = energyInput * 30;

  // Sleep: wearable pre-fills but user slider (checkIn.sleepHours) wins if present
  final sleepHours = lastCheckIn?.sleepHours ?? wearable?.sleepHours ?? 7.0;
  final sleep = (sleepHours.clamp(0.0, 9.0) / 9.0) * 20;

  // Remaining components fall back to neutral if no checkIn
  final soreness = ((6 - (lastCheckIn?.soreness ?? 3)) / 5) * 25;
  final rest = (daysSinceWorkout.clamp(1, 3) / 3) * 15;
  final mood = ((lastCheckIn?.mood ?? 3) / 5) * 10;
  // ... rest unchanged
}
```

### Pattern 5: ReadinessScore model — add sources field
**What:** Freeze-extend with optional `sources` string for transparency banner

```dart
@freezed
class ReadinessScore with _$ReadinessScore {
  const factory ReadinessScore({
    required int score,
    required String zone,
    required String message,
    required String description,
    String? sources,  // new: "Sleep: 6.5h from Apple Health · HR: 58 bpm from Watch"
  }) = _ReadinessScore;
}
```

**Note:** Adding a new optional field to a Freezed model requires re-running `build_runner`. Existing call sites constructing `ReadinessScore(score:, zone:, message:, description:)` remain valid — `sources` is optional.

### Pattern 6: ExportService — CSV build
**What:** Build CSV string from repositories; write to temp file; share via share_plus

```dart
// Source: pub.dev/packages/pdf official API + share_plus docs
class ExportService {
  Future<String> buildCsvString() async {
    final workouts = WorkoutRepository().getAll();
    final prs = PrRepository();
    final buf = StringBuffer();
    buf.writeln('date,workout_id,exercise_name,set_number,weight_kg,reps,completed,is_pr');

    for (final w in workouts) {
      final sets = WorkoutRepository().getSetsForWorkout(w.id);
      for (final s in sets) {
        final isPr = prs.getLatestPRForExercise(s.exerciseId)?.containsKey('weight_kg') ?? false;
        buf.writeln([
          w.startedAt.toIso8601String(),
          w.id, s.exerciseId, s.setNumber,
          s.weightKg, s.reps, s.completed, isPr,
        ].join(','));
      }
    }
    return buf.toString();
  }

  Future<void> exportCsv() async {
    final csv = await buildCsvString();
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final filename = 'forja_export_${now.year}-${now.month.toString().padLeft(2,'0')}.csv';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csv);
    await SharePlus.instance.shareXFiles([XFile(file.path)], subject: filename);
  }
}
```

### Pattern 7: ExportService — PDF generation
**What:** Build monthly PDF with pw package; save to temp, share via share_plus

```dart
// Source: pub.dev/packages/pdf 3.12.0 official API
Future<void> exportPdf() async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final monthLabel = '${now.year}-${now.month.toString().padLeft(2, '0')}';

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    header: (_) => pw.Text(
      workouts.length < 4 ? 'Your progress so far' : 'Monthly Progress — $monthLabel',
      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
    ),
    build: (ctx) => [
      _buildVolumeSection(),   // pw.Column with pw.Container bars (custom bar chart)
      pw.SizedBox(height: 16),
      _buildPrTable(),         // pw.Table with pw.TableBorder.all()
      pw.SizedBox(height: 16),
      _buildConsistencyTable(),
    ],
  ));

  final bytes = await pdf.save();
  final dir = await getTemporaryDirectory();
  final filename = 'forja_progress_$monthLabel.pdf';
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.shareXFiles([XFile(file.path)], subject: filename);
}

// Bar chart: use pw.Row + pw.Container (no pw.Chart widget exists in this package)
pw.Widget _buildVolumeBars(List<double> weeklyVolumes) {
  final maxVol = weeklyVolumes.reduce(max);
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: weeklyVolumes.asMap().entries.map((e) {
      final height = maxVol > 0 ? (e.value / maxVol) * 80 : 4.0;
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4),
        child: pw.Column(children: [
          pw.Container(width: 24, height: height, color: PdfColors.blue),
          pw.Text('W${e.key + 1}', style: pw.TextStyle(fontSize: 8)),
        ]),
      );
    }).toList(),
  );
}
```

### Pattern 8: Android platform setup for health package
**What:** Required AndroidManifest.xml entries and Activity type

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<!-- Health Connect permissions -->
<uses-permission android:name="android.permission.health.READ_SLEEP"/>
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
<uses-permission android:name="android.permission.health.READ_HEART_RATE_VARIABILITY"/>

<!-- Activity-alias required for permission request flow -->
<activity-alias
    android:name="ViewPermissionUsageActivity"
    android:exported="true"
    android:targetActivity=".MainActivity"
    android:permission="android.permission.START_VIEW_PERMISSION_USAGE">
  <intent-filter>
    <action android:name="android.intent.action.VIEW_PERMISSION_USAGE"/>
    <category android:name="android.intent.category.HEALTH_PERMISSIONS"/>
  </intent-filter>
</activity-alias>

<!-- Health Connect intent to open store if not installed -->
<queries>
  <package android:name="com.google.android.apps.healthdata"/>
</queries>
```

**CRITICAL — Android 14+ (API 34):** `MainActivity.kt` must extend `FlutterFragmentActivity`, not `FlutterActivity`. Without this, health permission dialogs fail silently.

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity : FlutterFragmentActivity()
```

### Pattern 9: iOS platform setup for health package
**What:** Info.plist keys and Xcode capability

```xml
<!-- ios/Runner/Info.plist -->
<key>NSHealthShareUsageDescription</key>
<string>FORJA uses your health data to compute your readiness score.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>FORJA may write workout data to Apple Health.</string>
```

In Xcode: Runner target → Signing & Capabilities → add "HealthKit" capability.

**Note:** HealthKit does NOT work on iOS simulator. Testing requires a real device.

### Pattern 10: WaterReminder notification (NotificationService extension)
**What:** Add `scheduleWaterReminder` and `cancelWaterReminder` to existing service

```dart
// Notification ID 1002 (1001 already used by workout reminder)
static Future<void> scheduleWaterReminder() async {
  await _flnp.zonedSchedule(
    1002,
    'Stay hydrated',
    'Drink water today — your performance depends on it.',
    _nextInstanceOf(const TimeOfDay(hour: 12, minute: 0)),
    const NotificationDetails(
      android: AndroidNotificationDetails(_channelId, _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

static Future<void> cancelWaterReminder() async => _flnp.cancel(1002);
```

### Anti-Patterns to Avoid
- **Re-instantiating `Health()` per request:** v12+ breaks this. Must use one global instance.
- **Using `path_provider.getDownloadsDirectory()` for user-visible files:** Returns app-scoped path on Android — users cannot find the file in their Downloads app. Use `share_plus` instead.
- **`WRITE_EXTERNAL_STORAGE` manifest permission:** Does not grant public Downloads access on Android 10+. Scoped storage rules apply. `share_plus` bypasses this cleanly.
- **Reading health data synchronously:** All `health` package calls are async and can throw. Always wrap in try/catch with explicit null returns.
- **Adding HiveField to UserProfile without incrementing field index:** Field 14 is `customSplitId`. New fields must use HiveField(15), HiveField(16). Never reuse indices.
- **Mutating Freezed models:** Use `.copyWith()` for all state updates.
- **Testing HealthKit on iOS simulator:** Will always fail. Integration tests for WearableService must run on real device or be mocked.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Health data platform abstraction | Custom HealthKit/Health Connect bridge | `health` 13.3.1 | ~60 data types, permission flow, duplicate removal, platform differences already solved |
| PDF layout engine | Custom PDF byte writer | `pdf` 3.12.0 pw.* widgets | Text reflow, pagination, fonts, table borders are non-trivial to implement correctly |
| File share / save dialog | Custom file manager intent | `share_plus` (already present) | Native share sheet handles iOS Files, Android Downloads, email, cloud — one call |
| CSV encoding | Manual string builder with escape logic | Simple `StringBuffer` is fine for this use case (no commas in exercise names) | If exercise names ever contain commas, use the `csv` pub.dev package for proper RFC 4180 compliance |
| Sleep hour aggregation | Custom sum logic | Sum `SLEEP_ASLEEP` point values over the window (values are in minutes) | Package returns individual sleep stage points; sum them |

**Key insight:** Health data permission flows are platform-specific and evolve with OS versions. Never replicate what the `health` package already abstracts — Android 14 changed the Activity requirement, Health Connect became mandatory (Google Fit EOL May 2024), and iOS HealthKit requires Xcode-level capability toggles. These are exactly the kind of platform surface area that breaks without a maintained abstraction layer.

---

## Common Pitfalls

### Pitfall 1: FlutterFragmentActivity Missing on Android 14+
**What goes wrong:** Health Connect permission sheet never appears. App silently fails to receive permission grants. `requestAuthorization()` returns false without showing UI.
**Why it happens:** Android 14+ Health Connect requires `FlutterFragmentActivity` for the permission activity result callback to reach Flutter.
**How to avoid:** Change `MainActivity.kt` from `FlutterActivity` to `FlutterFragmentActivity` before writing any health code.
**Warning signs:** `requestAuthorization()` returns false on Android 14 emulator/device; no permission dialog appears.

### Pitfall 2: Hive TypeId Collision on UserProfile Extension
**What goes wrong:** App crashes with `HiveError: Cannot overwrite existing typeId` or silently reads wrong field values after adding `heightCm`/`bodyWeightKg`.
**Why it happens:** HiveField indices must be unique and stable. Reusing or skipping indices causes serialization corruption.
**How to avoid:** Current last field in UserProfile is `@HiveField(14) String? customSplitId`. Add new fields at indices 15 and 16. Re-run `build_runner`. Test reading an existing Hive box after the change.
**Warning signs:** Existing UserProfile data reads null for fields that had values; HiveError at runtime.

### Pitfall 3: Health Connect Not Installed (Android)
**What goes wrong:** `requestAuthorization()` throws or returns false. No useful error to the user.
**Why it happens:** Health Connect is a separate app (pre-installed on Android 14+, but must be installed from Play Store on Android 9–13).
**How to avoid:** WearableService should check `Health().isHealthConnectAvailable()` first. If false, show a "Health Connect not available" state on the nudge card with a deep-link to install it (play store intent).
**Warning signs:** Permission never granted on Android 9–13 devices.

### Pitfall 4: Sleep Duration Calculation
**What goes wrong:** Sleep hours are wrong — shows 0, or massive values.
**Why it happens:** `SLEEP_ASLEEP` data points returned by the health package have values in **minutes** (not hours). Also, multiple overlapping sleep stage segments may be returned — duplicates must be removed before summing.
**How to avoid:** Call `Health.removeDuplicates()` on the result, then sum values (in minutes), then convert to hours: `totalMinutes / 60`.
**Warning signs:** Sleep shows 0 even when Apple Health has data; or shows 400+ hours.

### Pitfall 5: PDF Chart — pw.Chart Does Not Exist
**What goes wrong:** `pw.Chart` is not a documented widget in the `pdf` package. Build error if used.
**Why it happens:** Common misconception from searching. The package has `pw.CustomPaint` and primitive drawing, but no pre-built chart widget.
**How to avoid:** Draw bar charts manually using `pw.Container` with fixed heights (normalized from max volume). Simple and sufficient for a monthly report.
**Warning signs:** Compile error `Class 'pw' has no getter called 'Chart'`.

### Pitfall 6: iOS Share Sheet for Files Requires XFile with Correct MIME Type
**What goes wrong:** iOS share sheet shows no apps or the file opens incorrectly.
**Why it happens:** iOS uses MIME type / UTI for app filtering. Wrong MIME = wrong app list.
**How to avoid:** Use correct MIME types: `XFile(path, mimeType: 'text/csv')` for CSV, `XFile(path, mimeType: 'application/pdf')` for PDF.
**Warning signs:** Share sheet shows on Android but is empty on iOS.

### Pitfall 7: Freezed Rebuild Required After Model Changes
**What goes wrong:** `_$ReadinessScore`, `_$UserProfile` generated code is stale. Compiler errors.
**Why it happens:** Any Freezed model change requires re-running code generation.
**How to avoid:** After every model change, run: `dart run build_runner build --delete-conflicting-outputs`
**Warning signs:** `Error: The getter 'sources' isn't defined for the class 'ReadinessScore'`.

---

## Code Examples

### Initialize Health globally (v12+ pattern)
```dart
// Source: pub.dev/packages/health changelog v12.0.0
// lib/shared/services/wearable_service.dart
import 'package:health/health.dart';

// Create once, inject everywhere
final healthInstance = Health();

class WearableService {
  final Health _health;
  const WearableService(this._health);
  // ...
}
```

### Request health authorization
```dart
// Source: pub.dev/packages/health official API
static const _types = [
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.RESTING_HEART_RATE,
  HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
];

Future<bool> requestPermission() async {
  try {
    return await _health.requestAuthorization(_types);
  } catch (e) {
    return false; // Health Connect not installed, or permission denied
  }
}
```

### Read sleep hours from last night
```dart
// Source: pub.dev/packages/health official API
Future<double?> readSleepHours() async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day - 1, 18, 0);
  try {
    final raw = await _health.getHealthDataFromTypes(
      startTime: start, endTime: now,
      types: [HealthDataType.SLEEP_ASLEEP],
    );
    final clean = Health.removeDuplicates(raw);
    if (clean.isEmpty) return null;
    // Values are in minutes
    final totalMinutes = clean
        .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
        .reduce((a, b) => a + b);
    return totalMinutes / 60.0;
  } catch (_) {
    return null;
  }
}
```

### Build PDF with table
```dart
// Source: github.com/DavBfr/dart_pdf README + pub.dev/packages/pdf 3.12.0
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Widget buildPrTable(List<Map> prs) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300),
    columnWidths: {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(2),
      2: const pw.FlexColumnWidth(2),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
        children: ['Exercise', 'Weight (kg)', 'Est. 1RM']
            .map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(h,
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold)),
                ))
            .toList(),
      ),
      ...prs.map((pr) => pw.TableRow(
            children: [
              pr['exercise_id'].toString(),
              pr['weight_kg'].toString(),
              pr['estimated_1rm'].toStringAsFixed(1),
            ]
                .map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(cell),
                    ))
                .toList(),
          )),
    ],
  );
}
```

### Share file via share_plus (works for both CSV and PDF)
```dart
// Source: pub.dev/packages/share_plus 12.x
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> shareFile(List<int> bytes, String filename, String mimeType) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.shareXFiles(
    [XFile(file.path, mimeType: mimeType)],
    subject: filename,
  );
}

// Usage:
await shareFile(csvBytes, 'forja_export_2026-03.csv', 'text/csv');
await shareFile(pdfBytes, 'forja_progress_2026-03.pdf', 'application/pdf');
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Google Fit API for Android health data | Health Connect (mandatory) | May 2024 (Google Fit EOL) | Must use `health` v11+ which removed Google Fit; Health Connect required |
| `HealthFactory()` singleton pattern | `Health()` instance — initialize once globally | health v12.0.0 | Old code using `HealthFactory` compile-errors; migrate to direct `Health()` |
| `isManualEntry` bool on health data | `recordingMethod` enum | health v11.0.0 | Filtering manual entries changed; use `recordingMethodsToFilter` |
| `path_provider getDownloadsDirectory` for export | `share_plus shareXFiles` | Ongoing (issue open 2024) | path_provider returns app-scoped path, not public Downloads |
| `WRITE_EXTERNAL_STORAGE` permission | No storage permission needed with share_plus | Android 10+ scoped storage | share_plus uses system share sheet, no storage permission required |

**Deprecated/outdated:**
- `HealthFactory` class: removed in health v12.0.0; use `Health()` constructor
- Google Fit data source: removed in health v11.0.0; Health Connect only on Android
- `SLEEP_IN_BED` data type: removed in health v11.0.0; use `SLEEP_ASLEEP` or `SLEEP_SESSION`

---

## Open Questions

1. **Health Connect availability on older Android (API 28–32)**
   - What we know: Health Connect is pre-installed on Android 14+ (API 34+). On Android 9–13 (API 28–33), users must install it from Play Store.
   - What's unclear: What percentage of target users (students) will have it? Will the nudge card be actionable enough to drive installs?
   - Recommendation: WearableService should check `Health().isHealthConnectAvailable()` and expose a `bool isAvailable` state. Nudge card shows "Install Health Connect" with a play store deep-link when not available, vs "Connect Health" when available but not authorized.

2. **iOS HealthKit real device requirement for testing**
   - What we know: HealthKit does not work on iOS simulator.
   - What's unclear: Project has been tested on Android emulator so far (Phase 1 note). iOS WearableService path is untestable without a real device.
   - Recommendation: Mock WearableService in all Flutter tests. Integration tests for actual health data are manual-only on real device. Document this explicitly in verification plan.

3. **Plate visual illustration approach (Claude's Discretion)**
   - What we know: Static asset is simplest; custom painter allows theming; SVG requires flutter_svg package (not currently in pubspec).
   - What's unclear: Whether design assets exist or need to be created.
   - Recommendation: Use two static PNG assets (`assets/plate_training.png`, `assets/plate_rest.png`). Simple, no new dependencies, can be replaced by designer later. If no design assets exist, draw two simple `CustomPaint` plates (circles with colored wedges) inline — faster than adding flutter_svg.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | None (standard Flutter test runner) |
| Quick run command | `flutter test test/services/wearable_service_test.dart test/services/export_service_test.dart test/services/calculation_service_test.dart -x` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| WEAR-01 | WearableService returns sleepHours from mocked health data | unit | `flutter test test/services/wearable_service_test.dart -x` | Wave 0 |
| WEAR-02 | WearableService returns restingHR and hrv from mocked data | unit | `flutter test test/services/wearable_service_test.dart -x` | Wave 0 |
| WEAR-03 | CalculationService.readinessScore with wearable params produces expected score | unit | `flutter test test/services/calculation_service_test.dart -x` | exists (extend) |
| WEAR-04 | Energy formula maps HR=58/HRV=55 → ~0.75 score | unit | `flutter test test/services/calculation_service_test.dart -x` | exists (extend) |
| WEAR-03 | Readiness banner sources string populated when wearable present | unit | `flutter test test/services/wearable_service_test.dart -x` | Wave 0 |
| NUT-01 | UserProfile.bodyWeightKg persists through Hive serialize/deserialize | unit | `flutter test test/repositories/ -x` | Wave 0 |
| NUT-02 | Protein target = bodyWeightKg × 1.6 (e.g., 75kg → 120g) | unit | `flutter test test/services/calculation_service_test.dart -x` | exists (extend) |
| NUT-04 | NotificationService.scheduleWaterReminder schedules ID 1002 | unit | `flutter test test/services/notification_service_test.dart -x` | exists (extend) |
| EXP-01 | ExportService.buildCsvString produces correct header + rows | unit | `flutter test test/services/export_service_test.dart -x` | Wave 0 |
| EXP-02 | ExportService.buildPdf returns non-empty bytes list | unit | `flutter test test/services/export_service_test.dart -x` | Wave 0 |
| EXP-01 | CSV row count matches total SetLog count | unit | `flutter test test/services/export_service_test.dart -x` | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/services/ -x`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/services/wearable_service_test.dart` — covers WEAR-01, WEAR-02, WEAR-03 (mock health package)
- [ ] `test/services/export_service_test.dart` — covers EXP-01, EXP-02 (mock repositories, test CSV header/rows/PDF bytes)
- [ ] `test/repositories/user_profile_repository_test.dart` — covers NUT-01 (Hive field extension)
- [ ] Mock class for `Health` — required for WearableService unit tests (HealthKit cannot run in test environment)
- [ ] Extend `test/services/calculation_service_test.dart` — add wearable param cases
- [ ] Extend `test/services/notification_service_test.dart` — add water reminder ID 1002 case

---

## Sources

### Primary (HIGH confidence)
- pub.dev/packages/health — version 13.3.1, HealthDataType enum, Health class API, SLEEP_ASLEEP/RESTING_HEART_RATE/HEART_RATE_VARIABILITY_RMSSD types
- pub.dev/packages/health/changelog — v11/v12/v13 breaking changes, HealthFactory removal, Google Fit removal, recordingMethod enum
- pub.dev/packages/pdf — version 3.12.0, pw.Document/pw.MultiPage/pw.Table/pw.Text API
- pub.dev/packages/share_plus — version 12.0.1, SharePlus.shareXFiles, XFile with mimeType
- pub.dev/packages/path_provider — version 2.1.0, getTemporaryDirectory for temp file writes

### Secondary (MEDIUM confidence)
- github.com/flutter/flutter/issues/155367 — getDownloadsDirectory returns app-scoped path on Android (open issue 2024); confirms share_plus recommendation
- kubios.com/blog/heart-rate-variability-normal-range — HRV normal ranges (20–70ms RMSSD) informing energy score normalization
- pub.dev/packages/health changelog + web search cross-verified — Android activity-alias requirement, FlutterFragmentActivity for Android 14+
- github.com/DavBfr/dart_pdf README — pw.MultiPage pattern, File.writeAsBytes for save

### Tertiary (LOW confidence)
- Search result: "pw.Chart does not exist" — inferred from absence in official docs, changelog, and README; not an explicit statement in official source. Plan accordingly (draw bars manually).
- HRV/HR energy normalization bounds (40–100 bpm HR range, 20–70ms HRV) — derived from physiological literature, not from an app-specific source. Claude's Discretion allows adjustment.

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — versions verified on pub.dev, changelogs read
- Architecture: HIGH — patterns derived from official API docs and existing codebase analysis
- Platform setup (Android/iOS): MEDIUM-HIGH — cross-verified via web search + changelog; exact XML confirmed from multiple sources
- Downloads pitfall: HIGH — confirmed via open GitHub issue #155367 with Flutter team acknowledgment
- HRV normalization: MEDIUM — physiological ranges from medical sources; bounds are defensible starting points, tunable

**Research date:** 2026-03-27
**Valid until:** 2026-04-27 (health package evolves with Android OS releases; verify Health Connect availability API before planning)
