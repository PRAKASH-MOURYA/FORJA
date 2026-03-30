// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'readiness_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReadinessScore {
  int get score => throw _privateConstructorUsedError; // 0-100
  String get zone => throw _privateConstructorUsedError; // green | yellow | red
  String get message => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get sources => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReadinessScoreCopyWith<ReadinessScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadinessScoreCopyWith<$Res> {
  factory $ReadinessScoreCopyWith(
          ReadinessScore value, $Res Function(ReadinessScore) then) =
      _$ReadinessScoreCopyWithImpl<$Res, ReadinessScore>;
  @useResult
  $Res call(
      {int score,
      String zone,
      String message,
      String description,
      String? sources});
}

/// @nodoc
class _$ReadinessScoreCopyWithImpl<$Res, $Val extends ReadinessScore>
    implements $ReadinessScoreCopyWith<$Res> {
  _$ReadinessScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? zone = null,
    Object? message = null,
    Object? description = null,
    Object? sources = freezed,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      zone: null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sources: freezed == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReadinessScoreImplCopyWith<$Res>
    implements $ReadinessScoreCopyWith<$Res> {
  factory _$$ReadinessScoreImplCopyWith(_$ReadinessScoreImpl value,
          $Res Function(_$ReadinessScoreImpl) then) =
      __$$ReadinessScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int score,
      String zone,
      String message,
      String description,
      String? sources});
}

/// @nodoc
class __$$ReadinessScoreImplCopyWithImpl<$Res>
    extends _$ReadinessScoreCopyWithImpl<$Res, _$ReadinessScoreImpl>
    implements _$$ReadinessScoreImplCopyWith<$Res> {
  __$$ReadinessScoreImplCopyWithImpl(
      _$ReadinessScoreImpl _value, $Res Function(_$ReadinessScoreImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
    Object? zone = null,
    Object? message = null,
    Object? description = null,
    Object? sources = freezed,
  }) {
    return _then(_$ReadinessScoreImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      zone: null == zone
          ? _value.zone
          : zone // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      sources: freezed == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ReadinessScoreImpl implements _ReadinessScore {
  const _$ReadinessScoreImpl(
      {required this.score,
      required this.zone,
      required this.message,
      required this.description,
      this.sources});

  @override
  final int score;
// 0-100
  @override
  final String zone;
// green | yellow | red
  @override
  final String message;
  @override
  final String description;
  @override
  final String? sources;

  @override
  String toString() {
    return 'ReadinessScore(score: $score, zone: $zone, message: $message, description: $description, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadinessScoreImpl &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.zone, zone) || other.zone == zone) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.sources, sources) || other.sources == sources));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, score, zone, message, description, sources);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadinessScoreImplCopyWith<_$ReadinessScoreImpl> get copyWith =>
      __$$ReadinessScoreImplCopyWithImpl<_$ReadinessScoreImpl>(
          this, _$identity);
}

abstract class _ReadinessScore implements ReadinessScore {
  const factory _ReadinessScore(
      {required final int score,
      required final String zone,
      required final String message,
      required final String description,
      final String? sources}) = _$ReadinessScoreImpl;

  @override
  int get score;
  @override // 0-100
  String get zone;
  @override // green | yellow | red
  String get message;
  @override
  String get description;
  @override
  String? get sources;
  @override
  @JsonKey(ignore: true)
  _$$ReadinessScoreImplCopyWith<_$ReadinessScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
