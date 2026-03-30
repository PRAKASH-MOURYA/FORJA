// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SetLog _$SetLogFromJson(Map<String, dynamic> json) {
  return _SetLog.fromJson(json);
}

/// @nodoc
mixin _$SetLog {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get workoutLogId => throw _privateConstructorUsedError;
  @HiveField(2)
  String get exerciseId => throw _privateConstructorUsedError;
  @HiveField(3)
  int get setNumber => throw _privateConstructorUsedError;
  @HiveField(4)
  double get weightKg => throw _privateConstructorUsedError;
  @HiveField(5)
  int get reps => throw _privateConstructorUsedError;
  @HiveField(6)
  bool get completed => throw _privateConstructorUsedError;
  @HiveField(7)
  bool get failed => throw _privateConstructorUsedError;
  @HiveField(8)
  bool get skipped => throw _privateConstructorUsedError;
  @HiveField(9)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(10)
  String get syncStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SetLogCopyWith<SetLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetLogCopyWith<$Res> {
  factory $SetLogCopyWith(SetLog value, $Res Function(SetLog) then) =
      _$SetLogCopyWithImpl<$Res, SetLog>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String workoutLogId,
      @HiveField(2) String exerciseId,
      @HiveField(3) int setNumber,
      @HiveField(4) double weightKg,
      @HiveField(5) int reps,
      @HiveField(6) bool completed,
      @HiveField(7) bool failed,
      @HiveField(8) bool skipped,
      @HiveField(9) DateTime createdAt,
      @HiveField(10) String syncStatus});
}

/// @nodoc
class _$SetLogCopyWithImpl<$Res, $Val extends SetLog>
    implements $SetLogCopyWith<$Res> {
  _$SetLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutLogId = null,
    Object? exerciseId = null,
    Object? setNumber = null,
    Object? weightKg = null,
    Object? reps = null,
    Object? completed = null,
    Object? failed = null,
    Object? skipped = null,
    Object? createdAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutLogId: null == workoutLogId
          ? _value.workoutLogId
          : workoutLogId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      failed: null == failed
          ? _value.failed
          : failed // ignore: cast_nullable_to_non_nullable
              as bool,
      skipped: null == skipped
          ? _value.skipped
          : skipped // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$SetLogImplCopyWith<$Res> implements $SetLogCopyWith<$Res> {
  factory _$$SetLogImplCopyWith(
          _$SetLogImpl value, $Res Function(_$SetLogImpl) then) =
      __$$SetLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String workoutLogId,
      @HiveField(2) String exerciseId,
      @HiveField(3) int setNumber,
      @HiveField(4) double weightKg,
      @HiveField(5) int reps,
      @HiveField(6) bool completed,
      @HiveField(7) bool failed,
      @HiveField(8) bool skipped,
      @HiveField(9) DateTime createdAt,
      @HiveField(10) String syncStatus});
}

/// @nodoc
class __$$SetLogImplCopyWithImpl<$Res>
    extends _$SetLogCopyWithImpl<$Res, _$SetLogImpl>
    implements _$$SetLogImplCopyWith<$Res> {
  __$$SetLogImplCopyWithImpl(
      _$SetLogImpl _value, $Res Function(_$SetLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutLogId = null,
    Object? exerciseId = null,
    Object? setNumber = null,
    Object? weightKg = null,
    Object? reps = null,
    Object? completed = null,
    Object? failed = null,
    Object? skipped = null,
    Object? createdAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$SetLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutLogId: null == workoutLogId
          ? _value.workoutLogId
          : workoutLogId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      failed: null == failed
          ? _value.failed
          : failed // ignore: cast_nullable_to_non_nullable
              as bool,
      skipped: null == skipped
          ? _value.skipped
          : skipped // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$SetLogImpl implements _SetLog {
  const _$SetLogImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.workoutLogId,
      @HiveField(2) required this.exerciseId,
      @HiveField(3) required this.setNumber,
      @HiveField(4) required this.weightKg,
      @HiveField(5) required this.reps,
      @HiveField(6) this.completed = false,
      @HiveField(7) this.failed = false,
      @HiveField(8) this.skipped = false,
      @HiveField(9) required this.createdAt,
      @HiveField(10) this.syncStatus = 'pending'});

  factory _$SetLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetLogImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String workoutLogId;
  @override
  @HiveField(2)
  final String exerciseId;
  @override
  @HiveField(3)
  final int setNumber;
  @override
  @HiveField(4)
  final double weightKg;
  @override
  @HiveField(5)
  final int reps;
  @override
  @JsonKey()
  @HiveField(6)
  final bool completed;
  @override
  @JsonKey()
  @HiveField(7)
  final bool failed;
  @override
  @JsonKey()
  @HiveField(8)
  final bool skipped;
  @override
  @HiveField(9)
  final DateTime createdAt;
  @override
  @JsonKey()
  @HiveField(10)
  final String syncStatus;

  @override
  String toString() {
    return 'SetLog(id: $id, workoutLogId: $workoutLogId, exerciseId: $exerciseId, setNumber: $setNumber, weightKg: $weightKg, reps: $reps, completed: $completed, failed: $failed, skipped: $skipped, createdAt: $createdAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workoutLogId, workoutLogId) ||
                other.workoutLogId == workoutLogId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            (identical(other.skipped, skipped) || other.skipped == skipped) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      workoutLogId,
      exerciseId,
      setNumber,
      weightKg,
      reps,
      completed,
      failed,
      skipped,
      createdAt,
      syncStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetLogImplCopyWith<_$SetLogImpl> get copyWith =>
      __$$SetLogImplCopyWithImpl<_$SetLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetLogImplToJson(
      this,
    );
  }
}

abstract class _SetLog implements SetLog {
  const factory _SetLog(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String workoutLogId,
      @HiveField(2) required final String exerciseId,
      @HiveField(3) required final int setNumber,
      @HiveField(4) required final double weightKg,
      @HiveField(5) required final int reps,
      @HiveField(6) final bool completed,
      @HiveField(7) final bool failed,
      @HiveField(8) final bool skipped,
      @HiveField(9) required final DateTime createdAt,
      @HiveField(10) final String syncStatus}) = _$SetLogImpl;

  factory _SetLog.fromJson(Map<String, dynamic> json) = _$SetLogImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get workoutLogId;
  @override
  @HiveField(2)
  String get exerciseId;
  @override
  @HiveField(3)
  int get setNumber;
  @override
  @HiveField(4)
  double get weightKg;
  @override
  @HiveField(5)
  int get reps;
  @override
  @HiveField(6)
  bool get completed;
  @override
  @HiveField(7)
  bool get failed;
  @override
  @HiveField(8)
  bool get skipped;
  @override
  @HiveField(9)
  DateTime get createdAt;
  @override
  @HiveField(10)
  String get syncStatus;
  @override
  @JsonKey(ignore: true)
  _$$SetLogImplCopyWith<_$SetLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
