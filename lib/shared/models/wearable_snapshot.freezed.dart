// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wearable_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WearableSnapshot {
  double get sleepHours => throw _privateConstructorUsedError;
  double? get restingHR =>
      throw _privateConstructorUsedError; // bpm, nullable if not available
  double? get hrv => throw _privateConstructorUsedError; // RMSSD ms, nullable
  double? get energyScore =>
      throw _privateConstructorUsedError; // 0.0–1.0 derived from HR+HRV; null if neither available
  String get sources => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WearableSnapshotCopyWith<WearableSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WearableSnapshotCopyWith<$Res> {
  factory $WearableSnapshotCopyWith(
          WearableSnapshot value, $Res Function(WearableSnapshot) then) =
      _$WearableSnapshotCopyWithImpl<$Res, WearableSnapshot>;
  @useResult
  $Res call(
      {double sleepHours,
      double? restingHR,
      double? hrv,
      double? energyScore,
      String sources});
}

/// @nodoc
class _$WearableSnapshotCopyWithImpl<$Res, $Val extends WearableSnapshot>
    implements $WearableSnapshotCopyWith<$Res> {
  _$WearableSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sleepHours = null,
    Object? restingHR = freezed,
    Object? hrv = freezed,
    Object? energyScore = freezed,
    Object? sources = null,
  }) {
    return _then(_value.copyWith(
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      restingHR: freezed == restingHR
          ? _value.restingHR
          : restingHR // ignore: cast_nullable_to_non_nullable
              as double?,
      hrv: freezed == hrv
          ? _value.hrv
          : hrv // ignore: cast_nullable_to_non_nullable
              as double?,
      energyScore: freezed == energyScore
          ? _value.energyScore
          : energyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WearableSnapshotImplCopyWith<$Res>
    implements $WearableSnapshotCopyWith<$Res> {
  factory _$$WearableSnapshotImplCopyWith(_$WearableSnapshotImpl value,
          $Res Function(_$WearableSnapshotImpl) then) =
      __$$WearableSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double sleepHours,
      double? restingHR,
      double? hrv,
      double? energyScore,
      String sources});
}

/// @nodoc
class __$$WearableSnapshotImplCopyWithImpl<$Res>
    extends _$WearableSnapshotCopyWithImpl<$Res, _$WearableSnapshotImpl>
    implements _$$WearableSnapshotImplCopyWith<$Res> {
  __$$WearableSnapshotImplCopyWithImpl(_$WearableSnapshotImpl _value,
      $Res Function(_$WearableSnapshotImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sleepHours = null,
    Object? restingHR = freezed,
    Object? hrv = freezed,
    Object? energyScore = freezed,
    Object? sources = null,
  }) {
    return _then(_$WearableSnapshotImpl(
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      restingHR: freezed == restingHR
          ? _value.restingHR
          : restingHR // ignore: cast_nullable_to_non_nullable
              as double?,
      hrv: freezed == hrv
          ? _value.hrv
          : hrv // ignore: cast_nullable_to_non_nullable
              as double?,
      energyScore: freezed == energyScore
          ? _value.energyScore
          : energyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$WearableSnapshotImpl implements _WearableSnapshot {
  const _$WearableSnapshotImpl(
      {required this.sleepHours,
      this.restingHR,
      this.hrv,
      this.energyScore,
      this.sources = ''});

  @override
  final double sleepHours;
  @override
  final double? restingHR;
// bpm, nullable if not available
  @override
  final double? hrv;
// RMSSD ms, nullable
  @override
  final double? energyScore;
// 0.0–1.0 derived from HR+HRV; null if neither available
  @override
  @JsonKey()
  final String sources;

  @override
  String toString() {
    return 'WearableSnapshot(sleepHours: $sleepHours, restingHR: $restingHR, hrv: $hrv, energyScore: $energyScore, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WearableSnapshotImpl &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.restingHR, restingHR) ||
                other.restingHR == restingHR) &&
            (identical(other.hrv, hrv) || other.hrv == hrv) &&
            (identical(other.energyScore, energyScore) ||
                other.energyScore == energyScore) &&
            (identical(other.sources, sources) || other.sources == sources));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, sleepHours, restingHR, hrv, energyScore, sources);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WearableSnapshotImplCopyWith<_$WearableSnapshotImpl> get copyWith =>
      __$$WearableSnapshotImplCopyWithImpl<_$WearableSnapshotImpl>(
          this, _$identity);
}

abstract class _WearableSnapshot implements WearableSnapshot {
  const factory _WearableSnapshot(
      {required final double sleepHours,
      final double? restingHR,
      final double? hrv,
      final double? energyScore,
      final String sources}) = _$WearableSnapshotImpl;

  @override
  double get sleepHours;
  @override
  double? get restingHR;
  @override // bpm, nullable if not available
  double? get hrv;
  @override // RMSSD ms, nullable
  double? get energyScore;
  @override // 0.0–1.0 derived from HR+HRV; null if neither available
  String get sources;
  @override
  @JsonKey(ignore: true)
  _$$WearableSnapshotImplCopyWith<_$WearableSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
