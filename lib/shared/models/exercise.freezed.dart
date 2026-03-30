// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return _Exercise.fromJson(json);
}

/// @nodoc
mixin _$Exercise {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  String get muscle =>
      throw _privateConstructorUsedError; // primary muscle group
  @HiveField(3)
  String get equipment =>
      throw _privateConstructorUsedError; // full_gym | home_dumbbells | home_bodyweight | hybrid
  @HiveField(4)
  int get sets => throw _privateConstructorUsedError;
  @HiveField(5)
  int get reps => throw _privateConstructorUsedError;
  @HiveField(6)
  double get defaultKg => throw _privateConstructorUsedError;
  @HiveField(7)
  List<String> get formCues => throw _privateConstructorUsedError;
  @HiveField(8)
  List<String> get targetMuscles => throw _privateConstructorUsedError;
  @HiveField(9)
  List<String> get swapAlternatives => throw _privateConstructorUsedError;
  @HiveField(10)
  String get videoUrl => throw _privateConstructorUsedError;
  @HiveField(11)
  String get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String muscle,
      @HiveField(3) String equipment,
      @HiveField(4) int sets,
      @HiveField(5) int reps,
      @HiveField(6) double defaultKg,
      @HiveField(7) List<String> formCues,
      @HiveField(8) List<String> targetMuscles,
      @HiveField(9) List<String> swapAlternatives,
      @HiveField(10) String videoUrl,
      @HiveField(11) String category});
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? muscle = null,
    Object? equipment = null,
    Object? sets = null,
    Object? reps = null,
    Object? defaultKg = null,
    Object? formCues = null,
    Object? targetMuscles = null,
    Object? swapAlternatives = null,
    Object? videoUrl = null,
    Object? category = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      muscle: null == muscle
          ? _value.muscle
          : muscle // ignore: cast_nullable_to_non_nullable
              as String,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      defaultKg: null == defaultKg
          ? _value.defaultKg
          : defaultKg // ignore: cast_nullable_to_non_nullable
              as double,
      formCues: null == formCues
          ? _value.formCues
          : formCues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value.targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      swapAlternatives: null == swapAlternatives
          ? _value.swapAlternatives
          : swapAlternatives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
          _$ExerciseImpl value, $Res Function(_$ExerciseImpl) then) =
      __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String muscle,
      @HiveField(3) String equipment,
      @HiveField(4) int sets,
      @HiveField(5) int reps,
      @HiveField(6) double defaultKg,
      @HiveField(7) List<String> formCues,
      @HiveField(8) List<String> targetMuscles,
      @HiveField(9) List<String> swapAlternatives,
      @HiveField(10) String videoUrl,
      @HiveField(11) String category});
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
      _$ExerciseImpl _value, $Res Function(_$ExerciseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? muscle = null,
    Object? equipment = null,
    Object? sets = null,
    Object? reps = null,
    Object? defaultKg = null,
    Object? formCues = null,
    Object? targetMuscles = null,
    Object? swapAlternatives = null,
    Object? videoUrl = null,
    Object? category = null,
  }) {
    return _then(_$ExerciseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      muscle: null == muscle
          ? _value.muscle
          : muscle // ignore: cast_nullable_to_non_nullable
              as String,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      defaultKg: null == defaultKg
          ? _value.defaultKg
          : defaultKg // ignore: cast_nullable_to_non_nullable
              as double,
      formCues: null == formCues
          ? _value._formCues
          : formCues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      targetMuscles: null == targetMuscles
          ? _value._targetMuscles
          : targetMuscles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      swapAlternatives: null == swapAlternatives
          ? _value._swapAlternatives
          : swapAlternatives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseImpl implements _Exercise {
  const _$ExerciseImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required this.muscle,
      @HiveField(3) required this.equipment,
      @HiveField(4) required this.sets,
      @HiveField(5) required this.reps,
      @HiveField(6) required this.defaultKg,
      @HiveField(7) required final List<String> formCues,
      @HiveField(8) required final List<String> targetMuscles,
      @HiveField(9) required final List<String> swapAlternatives,
      @HiveField(10) this.videoUrl = '',
      @HiveField(11) required this.category})
      : _formCues = formCues,
        _targetMuscles = targetMuscles,
        _swapAlternatives = swapAlternatives;

  factory _$ExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String muscle;
// primary muscle group
  @override
  @HiveField(3)
  final String equipment;
// full_gym | home_dumbbells | home_bodyweight | hybrid
  @override
  @HiveField(4)
  final int sets;
  @override
  @HiveField(5)
  final int reps;
  @override
  @HiveField(6)
  final double defaultKg;
  final List<String> _formCues;
  @override
  @HiveField(7)
  List<String> get formCues {
    if (_formCues is EqualUnmodifiableListView) return _formCues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formCues);
  }

  final List<String> _targetMuscles;
  @override
  @HiveField(8)
  List<String> get targetMuscles {
    if (_targetMuscles is EqualUnmodifiableListView) return _targetMuscles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetMuscles);
  }

  final List<String> _swapAlternatives;
  @override
  @HiveField(9)
  List<String> get swapAlternatives {
    if (_swapAlternatives is EqualUnmodifiableListView)
      return _swapAlternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_swapAlternatives);
  }

  @override
  @JsonKey()
  @HiveField(10)
  final String videoUrl;
  @override
  @HiveField(11)
  final String category;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, muscle: $muscle, equipment: $equipment, sets: $sets, reps: $reps, defaultKg: $defaultKg, formCues: $formCues, targetMuscles: $targetMuscles, swapAlternatives: $swapAlternatives, videoUrl: $videoUrl, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.muscle, muscle) || other.muscle == muscle) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.defaultKg, defaultKg) ||
                other.defaultKg == defaultKg) &&
            const DeepCollectionEquality().equals(other._formCues, _formCues) &&
            const DeepCollectionEquality()
                .equals(other._targetMuscles, _targetMuscles) &&
            const DeepCollectionEquality()
                .equals(other._swapAlternatives, _swapAlternatives) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      muscle,
      equipment,
      sets,
      reps,
      defaultKg,
      const DeepCollectionEquality().hash(_formCues),
      const DeepCollectionEquality().hash(_targetMuscles),
      const DeepCollectionEquality().hash(_swapAlternatives),
      videoUrl,
      category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseImplToJson(
      this,
    );
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final String muscle,
      @HiveField(3) required final String equipment,
      @HiveField(4) required final int sets,
      @HiveField(5) required final int reps,
      @HiveField(6) required final double defaultKg,
      @HiveField(7) required final List<String> formCues,
      @HiveField(8) required final List<String> targetMuscles,
      @HiveField(9) required final List<String> swapAlternatives,
      @HiveField(10) final String videoUrl,
      @HiveField(11) required final String category}) = _$ExerciseImpl;

  factory _Exercise.fromJson(Map<String, dynamic> json) =
      _$ExerciseImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  String get muscle;
  @override // primary muscle group
  @HiveField(3)
  String get equipment;
  @override // full_gym | home_dumbbells | home_bodyweight | hybrid
  @HiveField(4)
  int get sets;
  @override
  @HiveField(5)
  int get reps;
  @override
  @HiveField(6)
  double get defaultKg;
  @override
  @HiveField(7)
  List<String> get formCues;
  @override
  @HiveField(8)
  List<String> get targetMuscles;
  @override
  @HiveField(9)
  List<String> get swapAlternatives;
  @override
  @HiveField(10)
  String get videoUrl;
  @override
  @HiveField(11)
  String get category;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
