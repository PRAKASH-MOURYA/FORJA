import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'custom_split.freezed.dart';
part 'custom_split.g.dart';

@freezed
@HiveType(typeId: 6)
class CustomSplit with _$CustomSplit {
  const factory CustomSplit({
    @HiveField(0) required String id, // UUID string (stored as string)
    @HiveField(1) required String name,
    @HiveField(2) required int daysCount, // 2-6
    @HiveField(3) required List<SplitDay> days,
    @HiveField(4) required DateTime createdAt,
  }) = _CustomSplit;

  factory CustomSplit.fromJson(Map<String, dynamic> json) =>
      _$CustomSplitFromJson(json);
}

@freezed
@HiveType(typeId: 7)
class SplitDay with _$SplitDay {
  const factory SplitDay({
    @HiveField(0) required String dayName, // e.g. "Push A"
    @HiveField(1) required List<String> exerciseIds,
  }) = _SplitDay;

  factory SplitDay.fromJson(Map<String, dynamic> json) =>
      _$SplitDayFromJson(json);
}

