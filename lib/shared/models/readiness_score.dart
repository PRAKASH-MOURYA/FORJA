import 'package:freezed_annotation/freezed_annotation.dart';

part 'readiness_score.freezed.dart';

@freezed
class ReadinessScore with _$ReadinessScore {
  const factory ReadinessScore({
    required int score, // 0-100
    required String zone, // green | yellow | red
    required String message,
    required String description,
    String? sources,
  }) = _ReadinessScore;
}
