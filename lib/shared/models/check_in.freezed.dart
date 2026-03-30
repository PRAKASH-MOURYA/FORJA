// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckIn _$CheckInFromJson(Map<String, dynamic> json) {
  return _CheckIn.fromJson(json);
}

/// @nodoc
mixin _$CheckIn {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get userId => throw _privateConstructorUsedError;
  @HiveField(2)
  String? get workoutLogId => throw _privateConstructorUsedError;
  @HiveField(3)
  int get energy => throw _privateConstructorUsedError; // 1-5
  @HiveField(4)
  int get soreness => throw _privateConstructorUsedError; // 1-5
  @HiveField(5)
  int get mood => throw _privateConstructorUsedError; // 1-5
  @HiveField(6)
  double? get sleepHours => throw _privateConstructorUsedError;
  @HiveField(7)
  int? get stress => throw _privateConstructorUsedError; // 1-5
  @HiveField(8)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(9)
  String get syncStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckInCopyWith<CheckIn> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInCopyWith<$Res> {
  factory $CheckInCopyWith(CheckIn value, $Res Function(CheckIn) then) =
      _$CheckInCopyWithImpl<$Res, CheckIn>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String userId,
      @HiveField(2) String? workoutLogId,
      @HiveField(3) int energy,
      @HiveField(4) int soreness,
      @HiveField(5) int mood,
      @HiveField(6) double? sleepHours,
      @HiveField(7) int? stress,
      @HiveField(8) DateTime createdAt,
      @HiveField(9) String syncStatus});
}

/// @nodoc
class _$CheckInCopyWithImpl<$Res, $Val extends CheckIn>
    implements $CheckInCopyWith<$Res> {
  _$CheckInCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? workoutLogId = freezed,
    Object? energy = null,
    Object? soreness = null,
    Object? mood = null,
    Object? sleepHours = freezed,
    Object? stress = freezed,
    Object? createdAt = null,
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
      workoutLogId: freezed == workoutLogId
          ? _value.workoutLogId
          : workoutLogId // ignore: cast_nullable_to_non_nullable
              as String?,
      energy: null == energy
          ? _value.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as int,
      soreness: null == soreness
          ? _value.soreness
          : soreness // ignore: cast_nullable_to_non_nullable
              as int,
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as int,
      sleepHours: freezed == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double?,
      stress: freezed == stress
          ? _value.stress
          : stress // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInImplCopyWith<$Res> implements $CheckInCopyWith<$Res> {
  factory _$$CheckInImplCopyWith(
          _$CheckInImpl value, $Res Function(_$CheckInImpl) then) =
      __$$CheckInImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String userId,
      @HiveField(2) String? workoutLogId,
      @HiveField(3) int energy,
      @HiveField(4) int soreness,
      @HiveField(5) int mood,
      @HiveField(6) double? sleepHours,
      @HiveField(7) int? stress,
      @HiveField(8) DateTime createdAt,
      @HiveField(9) String syncStatus});
}

/// @nodoc
class __$$CheckInImplCopyWithImpl<$Res>
    extends _$CheckInCopyWithImpl<$Res, _$CheckInImpl>
    implements _$$CheckInImplCopyWith<$Res> {
  __$$CheckInImplCopyWithImpl(
      _$CheckInImpl _value, $Res Function(_$CheckInImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? workoutLogId = freezed,
    Object? energy = null,
    Object? soreness = null,
    Object? mood = null,
    Object? sleepHours = freezed,
    Object? stress = freezed,
    Object? createdAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$CheckInImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutLogId: freezed == workoutLogId
          ? _value.workoutLogId
          : workoutLogId // ignore: cast_nullable_to_non_nullable
              as String?,
      energy: null == energy
          ? _value.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as int,
      soreness: null == soreness
          ? _value.soreness
          : soreness // ignore: cast_nullable_to_non_nullable
              as int,
      mood: null == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as int,
      sleepHours: freezed == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double?,
      stress: freezed == stress
          ? _value.stress
          : stress // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInImpl implements _CheckIn {
  const _$CheckInImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.userId,
      @HiveField(2) this.workoutLogId,
      @HiveField(3) required this.energy,
      @HiveField(4) required this.soreness,
      @HiveField(5) required this.mood,
      @HiveField(6) this.sleepHours,
      @HiveField(7) this.stress,
      @HiveField(8) required this.createdAt,
      @HiveField(9) this.syncStatus = 'pending'});

  factory _$CheckInImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String userId;
  @override
  @HiveField(2)
  final String? workoutLogId;
  @override
  @HiveField(3)
  final int energy;
// 1-5
  @override
  @HiveField(4)
  final int soreness;
// 1-5
  @override
  @HiveField(5)
  final int mood;
// 1-5
  @override
  @HiveField(6)
  final double? sleepHours;
  @override
  @HiveField(7)
  final int? stress;
// 1-5
  @override
  @HiveField(8)
  final DateTime createdAt;
  @override
  @JsonKey()
  @HiveField(9)
  final String syncStatus;

  @override
  String toString() {
    return 'CheckIn(id: $id, userId: $userId, workoutLogId: $workoutLogId, energy: $energy, soreness: $soreness, mood: $mood, sleepHours: $sleepHours, stress: $stress, createdAt: $createdAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.workoutLogId, workoutLogId) ||
                other.workoutLogId == workoutLogId) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            (identical(other.soreness, soreness) ||
                other.soreness == soreness) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.stress, stress) || other.stress == stress) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, workoutLogId, energy,
      soreness, mood, sleepHours, stress, createdAt, syncStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInImplCopyWith<_$CheckInImpl> get copyWith =>
      __$$CheckInImplCopyWithImpl<_$CheckInImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInImplToJson(
      this,
    );
  }
}

abstract class _CheckIn implements CheckIn {
  const factory _CheckIn(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String userId,
      @HiveField(2) final String? workoutLogId,
      @HiveField(3) required final int energy,
      @HiveField(4) required final int soreness,
      @HiveField(5) required final int mood,
      @HiveField(6) final double? sleepHours,
      @HiveField(7) final int? stress,
      @HiveField(8) required final DateTime createdAt,
      @HiveField(9) final String syncStatus}) = _$CheckInImpl;

  factory _CheckIn.fromJson(Map<String, dynamic> json) = _$CheckInImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get userId;
  @override
  @HiveField(2)
  String? get workoutLogId;
  @override
  @HiveField(3)
  int get energy;
  @override // 1-5
  @HiveField(4)
  int get soreness;
  @override // 1-5
  @HiveField(5)
  int get mood;
  @override // 1-5
  @HiveField(6)
  double? get sleepHours;
  @override
  @HiveField(7)
  int? get stress;
  @override // 1-5
  @HiveField(8)
  DateTime get createdAt;
  @override
  @HiveField(9)
  String get syncStatus;
  @override
  @JsonKey(ignore: true)
  _$$CheckInImplCopyWith<_$CheckInImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
