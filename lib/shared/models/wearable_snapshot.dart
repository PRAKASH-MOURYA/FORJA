import 'package:freezed_annotation/freezed_annotation.dart';

part 'wearable_snapshot.freezed.dart';

@freezed
class WearableSnapshot with _$WearableSnapshot {
  const factory WearableSnapshot({
    required double sleepHours,
    double? restingHR,       // bpm, nullable if not available
    double? hrv,             // RMSSD ms, nullable
    double? energyScore,     // 0.0–1.0 derived from HR+HRV; null if neither available
    @Default('') String sources,  // display string: "Sleep: 6.5h from Apple Health · HR: 58 bpm"
  }) = _WearableSnapshot;
}
