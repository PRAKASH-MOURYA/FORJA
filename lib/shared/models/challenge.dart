import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
@HiveType(typeId: 5)
class Challenge with _$Challenge {
  const factory Challenge({
    @HiveField(0) required String id,
    @HiveField(1) required String creatorId,
    @HiveField(2) required String type,
    @HiveField(3) required DateTime startDate,
    @HiveField(4) required DateTime endDate,
    @HiveField(5) required String inviteCode,
    @HiveField(6) @Default(<String>[]) List<String> participantIds,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
}
