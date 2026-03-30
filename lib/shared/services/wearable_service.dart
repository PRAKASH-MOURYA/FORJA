import 'package:health/health.dart';
import '../models/wearable_snapshot.dart';

class WearableService {
  final Health _health;
  WearableService(this._health);

  static const _types = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
  ];

  Future<bool> requestPermission() =>
      _health.requestAuthorization(_types);

  Future<WearableSnapshot?> fetchSnapshot() async {
    final granted = await requestPermission();
    if (!granted) return null;

    final now = DateTime.now();
    // Sleep window: yesterday 18:00 -> now (captures last night's sleep session)
    final sleepStart = DateTime(now.year, now.month, now.day - 1, 18, 0);
    // HR/HRV window: last 24h
    final hrStart = now.subtract(const Duration(hours: 24));

    final sleepData = await _health.getHealthDataFromTypes(
      startTime: sleepStart, endTime: now,
      types: [HealthDataType.SLEEP_ASLEEP],
    );
    final hrData = await _health.getHealthDataFromTypes(
      startTime: hrStart, endTime: now,
      types: [HealthDataType.RESTING_HEART_RATE, HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
    );

    final all = Health().removeDuplicates([...sleepData, ...hrData]);
    return _parseSnapshot(all);
  }

  WearableSnapshot? _parseSnapshot(List<HealthDataPoint> points) {
    // Sum SLEEP_ASLEEP durations in hours
    final sleepMinutes = points
        .where((p) => p.type == HealthDataType.SLEEP_ASLEEP)
        .fold<double>(0, (sum, p) =>
            sum + p.dateTo.difference(p.dateFrom).inMinutes);
    if (sleepMinutes == 0 && points.where((p) => p.type == HealthDataType.RESTING_HEART_RATE).isEmpty) {
      return null; // No useful data
    }
    final sleepHours = sleepMinutes / 60.0;

    // Take latest RESTING_HEART_RATE value
    final hrPoints = points.where((p) => p.type == HealthDataType.RESTING_HEART_RATE).toList()
      ..sort((a, b) => b.dateTo.compareTo(a.dateTo));
    final restingHR = hrPoints.isNotEmpty
        ? (hrPoints.first.value as NumericHealthValue).numericValue.toDouble()
        : null;

    // Take latest HRV value
    final hrvPoints = points.where((p) => p.type == HealthDataType.HEART_RATE_VARIABILITY_RMSSD).toList()
      ..sort((a, b) => b.dateTo.compareTo(a.dateTo));
    final hrv = hrvPoints.isNotEmpty
        ? (hrvPoints.first.value as NumericHealthValue).numericValue.toDouble()
        : null;

    final energyScore = (restingHR != null || hrv != null)
        ? _energyFromWearables(restingHR, hrv)
        : null;

    final sourcesParts = <String>[];
    if (sleepHours > 0) sourcesParts.add('Sleep: ${sleepHours.toStringAsFixed(1)}h from Health');
    if (restingHR != null) sourcesParts.add('HR: ${restingHR.round()} bpm');
    if (hrv != null) sourcesParts.add('HRV: ${hrv.round()}ms');

    return WearableSnapshot(
      sleepHours: sleepHours,
      restingHR: restingHR,
      hrv: hrv,
      energyScore: energyScore,
      sources: sourcesParts.join(' · '),
    );
  }

  /// Linear normalization: 50 bpm -> 1.0, 90 bpm -> 0.0; 20ms -> 0.0, 70ms -> 1.0
  static double _energyFromWearables(double? restingHrBpm, double? hrvMs) {
    double hrScore = 0.5;
    double hrvScore = 0.5;
    bool hrAvail = false, hrvAvail = false;

    if (restingHrBpm != null) {
      hrScore = ((90 - restingHrBpm) / 40).clamp(0.0, 1.0);
      hrAvail = true;
    }
    if (hrvMs != null) {
      hrvScore = ((hrvMs - 20) / 50).clamp(0.0, 1.0);
      hrvAvail = true;
    }
    if (hrAvail && hrvAvail) return (hrScore + hrvScore) / 2;
    return hrAvail ? hrScore : hrvScore;
  }
}
