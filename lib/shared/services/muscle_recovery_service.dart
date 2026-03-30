import '../models/set_log.dart';
import '../repositories/checkin_repository.dart';
import '../services/hive_service.dart';
import '../constants/exercises.dart';

enum MuscleRecoveryZone { green, yellow, red }

class MuscleRecoveryStatus {
  final String muscle;
  final MuscleRecoveryZone zone;

  const MuscleRecoveryStatus({
    required this.muscle,
    required this.zone,
  });
}

class MuscleRecoveryService {
  static const List<String> kCanonicalMuscles = [
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
  ];

  /// Pure zone calculation used by both UI and tests.
  static MuscleRecoveryZone computeZone({
    required int daysSince,
    required int soreness,
  }) {
    // “Recent training” and “high soreness” always indicates recovery risk.
    if (daysSince == 0 || soreness >= 4) return MuscleRecoveryZone.red;

    // Green thresholds (see phase plan):
    // - daysSince >= 3 && soreness <= 3
    // - daysSince >= 2 && soreness <= 2
    if (daysSince >= 3 && soreness <= 3) return MuscleRecoveryZone.green;
    if (daysSince >= 2 && soreness <= 2) return MuscleRecoveryZone.green;

    return MuscleRecoveryZone.yellow;
  }

  /// Maps an exercise muscle label (from kExerciseData) to one of 6 groups.
  static String canonicalizeMuscle(String muscle) {
    final m = muscle.toLowerCase();

    if (m.contains('chest')) return 'Chest';

    if (m.contains('back') || m.contains('lats') || m.contains('rear back')) {
      return 'Back';
    }

    if (m.contains('quad') ||
        m.contains('quads') ||
        m.contains('hamstring') ||
        m.contains('glute') ||
        m.contains('calf') ||
        m.contains('leg')) {
      return 'Legs';
    }

    if (m.contains('shoulder') || m.contains('delts')) return 'Shoulders';

    if (m.contains('bicep') ||
        m.contains('tricep') ||
        m.contains('forearm') ||
        m.contains('arm')) {
      return 'Arms';
    }

    if (m.contains('core') || m.contains('abs') || m.contains('obliqu')) {
      return 'Core';
    }

    // Safe fallback: treat unknown muscles as “Core” to keep the UI stable.
    return 'Core';
  }

  /// Pure-ish computation that can be unit-tested with mocked set logs.
  static List<MuscleRecoveryStatus> computeStatusesFromData({
    required List<SetLog> setLogs,
    required int soreness,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();

    // Track most recent completed set per canonical muscle group.
    final Map<String, DateTime> lastTrainedAtByGroup = {};
    for (final set in setLogs) {
      if (!set.completed) continue;
      final muscle = kExerciseData[set.exerciseId]?['muscle'];
      if (muscle is! String) continue;

      final group = canonicalizeMuscle(muscle);
      final prev = lastTrainedAtByGroup[group];
      if (prev == null || set.createdAt.isAfter(prev)) {
        lastTrainedAtByGroup[group] = set.createdAt;
      }
    }

    // Always return exactly 6 groups, in canonical order.
    return kCanonicalMuscles
        .map((group) {
          final lastTrainedAt = lastTrainedAtByGroup[group];
          final daysSince = lastTrainedAt == null
              ? 999 // never trained -> treat as “fully recovered”
              : effectiveNow.difference(lastTrainedAt).inDays;
          return MuscleRecoveryStatus(
            muscle: group,
            zone: computeZone(daysSince: daysSince, soreness: soreness),
          );
        })
        .toList(growable: false);
  }

  /// UI-facing method: reads from Hive via repositories by default.
  /// For unit tests, callers can inject `setLogs` and `soreness`.
  List<MuscleRecoveryStatus> getRecoveryStatuses({
    List<SetLog>? setLogs,
    int? soreness,
    DateTime? now,
  }) {
    final resolvedSetLogs = setLogs ??
        HiveService.setLogs.values
            .where((s) => s.completed)
            .toList(growable: false);

    final resolvedSoreness =
        soreness ?? CheckInRepository().getLatest()?.soreness ?? 1;
    final safeSoreness = resolvedSoreness.clamp(1, 5);

    return computeStatusesFromData(
      setLogs: resolvedSetLogs,
      soreness: safeSoreness,
      now: now,
    );
  }

  String summaryText(List<MuscleRecoveryStatus> statuses) {
    final ready =
        statuses.where((s) => s.zone == MuscleRecoveryZone.green).length;
    final fatigued = statuses.length - ready;
    if (fatigued == 0) return 'All muscles ready';
    return '$ready ready · $fatigued fatigued';
  }
}

