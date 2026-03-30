// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutLog _$WorkoutLogFromJson(Map<String, dynamic> json) {
  return _WorkoutLog.fromJson(json);
}

/// @nodoc
mixin _$WorkoutLog {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get userId => throw _privateConstructorUsedError;
  @HiveField(2)
  String get programDayName => throw _privateConstructorUsedError;
  @HiveField(3)
  DateTime get startedAt => throw _privateConstructorUsedError;
  @HiveField(4)
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @HiveField(5)
  double get totalVolumeKg => throw _privateConstructorUsedError;
  @HiveField(6)
  int get totalSets => throw _privateConstructorUsedError;
  @HiveField(7)
  int get durationSeconds => throw _privateConstructorUsedError;
  @HiveField(8)
  int? get readinessScore => throw _privateConstructorUsedError;
  @HiveField(9)
  String get syncStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutLogCopyWith<WorkoutLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutLogCopyWith<$Res> {
  factory $WorkoutLogCopyWith(
          WorkoutLog value, $Res Function(WorkoutLog) then) =
      _$WorkoutLogCopyWithImpl<$Res, WorkoutLog>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String userId,
      @HiveField(2) String programDayName,
      @HiveField(3) DateTime startedAt,
      @HiveField(4) DateTime? completedAt,
      @HiveField(5) double totalVolumeKg,
      @HiveField(6) int totalSets,
      @HiveField(7) int durationSeconds,
      @HiveField(8) int? readinessScore,
      @HiveField(9) String syncStatus});
}

/// @nodoc
class _$WorkoutLogCopyWithImpl<$Res, $Val extends WorkoutLog>
    implements $WorkoutLogCopyWith<$Res> {
  _$WorkoutLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? programDayName = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? totalVolumeKg = null,
    Object? totalSets = null,
    Object? durationSeconds = null,
    Object? readinessScore = freezed,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      programDayName: null == programDayName
          ? _value.programDayName
          : programDayName // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalVolumeKg: null == totalVolumeKg
          ? _value.totalVolumeKg
          : totalVolumeKg // ignore: cast_nullable_to_non_nullable
              as double,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      readinessScore: freezed == readinessScore
          ? _value.readinessScore
          : readinessScore // ignore: cast_nullable_to_non_nullable
              as int?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutLogImplCopyWith<$Res>
    implements $WorkoutLogCopyWith<$Res> {
  factory _$$WorkoutLogImplCopyWith(
          _$WorkoutLogImpl value, $Res Function(_$WorkoutLogImpl) then) =
      __$$WorkoutLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String userId,
      @HiveField(2) String programDayName,
      @HiveField(3) DateTime startedAt,
      @HiveField(4) DateTime? completedAt,
      @HiveField(5) double totalVolumeKg,
      @HiveField(6) int totalSets,
      @HiveField(7) int durationSeconds,
      @HiveField(8) int? readinessScore,
      @HiveField(9) String syncStatus});
}

/// @nodoc
class __$$WorkoutLogImplCopyWithImpl<$Res>
    extends _$WorkoutLogCopyWithImpl<$Res, _$WorkoutLogImpl>
    implements _$$WorkoutLogImplCopyWith<$Res> {
  __$$WorkoutLogImplCopyWithImpl(
      _$WorkoutLogImpl _value, $Res Function(_$WorkoutLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? programDayName = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? totalVolumeKg = null,
    Object? totalSets = null,
    Object? durationSeconds = null,
    Object? readinessScore = freezed,
    Object? syncStatus = null,
  }) {
    return _then(_$WorkoutLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      programDayName: null == programDayName
          ? _value.programDayName
          : programDayName // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalVolumeKg: null == totalVolumeKg
          ? _value.totalVolumeKg
          : totalVolumeKg // ignore: cast_nullable_to_non_nullable
              as double,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      readinessScore: freezed == readinessScore
          ? _value.readinessScore
          : readinessScore // ignore: cast_nullable_to_non_nullable
              as int?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutLogImpl implements _WorkoutLog {
  const _$WorkoutLogImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.userId,
      @HiveField(2) required this.programDayName,
      @HiveField(3) required this.startedAt,
      @HiveField(4) this.completedAt,
      @HiveField(5) this.totalVolumeKg = 0.0,
      @HiveField(6) this.totalSets = 0,
      @HiveField(7) this.durationSeconds = 0,
      @HiveField(8) this.readinessScore,
      @HiveField(9) this.syncStatus = 'pending'});

  factory _$WorkoutLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutLogImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String userId;
  @override
  @HiveField(2)
  final String programDayName;
  @override
  @HiveField(3)
  final DateTime startedAt;
  @override
  @HiveField(4)
  final DateTime? completedAt;
  @override
  @JsonKey()
  @HiveField(5)
  final double totalVolumeKg;
  @override
  @JsonKey()
  @HiveField(6)
  final int totalSets;
  @override
  @JsonKey()
  @HiveField(7)
  final int durationSeconds;
  @override
  @HiveField(8)
  final int? readinessScore;
  @override
  @JsonKey()
  @HiveField(9)
  final String syncStatus;

  @override
  String toString() {
    return 'WorkoutLog(id: $id, userId: $userId, programDayName: $programDayName, startedAt: $startedAt, completedAt: $completedAt, totalVolumeKg: $totalVolumeKg, totalSets: $totalSets, durationSeconds: $durationSeconds, readinessScore: $readinessScore, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.programDayName, programDayName) ||
                other.programDayName == programDayName) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.totalVolumeKg, totalVolumeKg) ||
                other.totalVolumeKg == totalVolumeKg) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.readinessScore, readinessScore) ||
                other.readinessScore == readinessScore) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      programDayName,
      startedAt,
      completedAt,
      totalVolumeKg,
      totalSets,
      durationSeconds,
      readinessScore,
      syncStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      __$$WorkoutLogImplCopyWithImpl<_$WorkoutLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutLogImplToJson(
      this,
    );
  }
}

abstract class _WorkoutLog implements WorkoutLog {
  const factory _WorkoutLog(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String userId,
      @HiveField(2) required final String programDayName,
      @HiveField(3) required final DateTime startedAt,
      @HiveField(4) final DateTime? completedAt,
      @HiveField(5) final double totalVolumeKg,
      @HiveField(6) final int totalSets,
      @HiveField(7) final int durationSeconds,
      @HiveField(8) final int? readinessScore,
      @HiveField(9) final String syncStatus}) = _$WorkoutLogImpl;

  factory _WorkoutLog.fromJson(Map<String, dynamic> json) =
      _$WorkoutLogImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get userId;
  @override
  @HiveField(2)
  String get programDayName;
  @override
  @HiveField(3)
  DateTime get startedAt;
  @override
  @HiveField(4)
  DateTime? get completedAt;
  @override
  @HiveField(5)
  double get totalVolumeKg;
  @override
  @HiveField(6)
  int get totalSets;
  @override
  @HiveField(7)
  int get durationSeconds;
  @override
  @HiveField(8)
  int? get readinessScore;
  @override
  @HiveField(9)
  String get syncStatus;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
