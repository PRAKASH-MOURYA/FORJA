// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  String get goal =>
      throw _privateConstructorUsedError; // lose_fat | build_muscle | get_stronger | general
  @HiveField(3)
  String get experience =>
      throw _privateConstructorUsedError; // beginner | some | intermediate
  @HiveField(4)
  int get daysPerWeek => throw _privateConstructorUsedError;
  @HiveField(5)
  String get equipment =>
      throw _privateConstructorUsedError; // full_gym | home_dumbbells | home_bodyweight | hybrid
  @HiveField(6)
  List<String> get injuries => throw _privateConstructorUsedError;
  @HiveField(7)
  String get currentProgramId => throw _privateConstructorUsedError;
  @HiveField(8)
  int get xp => throw _privateConstructorUsedError;
  @HiveField(9)
  String get level => throw _privateConstructorUsedError;
  @HiveField(10)
  int get streakWeeks => throw _privateConstructorUsedError;
  @HiveField(11)
  int get streakShields => throw _privateConstructorUsedError;
  @HiveField(12)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(13)
  bool get onboardingComplete => throw _privateConstructorUsedError;
  @HiveField(14)
  String? get customSplitId => throw _privateConstructorUsedError;
  @HiveField(15)
  double? get heightCm => throw _privateConstructorUsedError;
  @HiveField(16)
  double? get bodyWeightKg => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String goal,
      @HiveField(3) String experience,
      @HiveField(4) int daysPerWeek,
      @HiveField(5) String equipment,
      @HiveField(6) List<String> injuries,
      @HiveField(7) String currentProgramId,
      @HiveField(8) int xp,
      @HiveField(9) String level,
      @HiveField(10) int streakWeeks,
      @HiveField(11) int streakShields,
      @HiveField(12) DateTime createdAt,
      @HiveField(13) bool onboardingComplete,
      @HiveField(14) String? customSplitId,
      @HiveField(15) double? heightCm,
      @HiveField(16) double? bodyWeightKg});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? goal = null,
    Object? experience = null,
    Object? daysPerWeek = null,
    Object? equipment = null,
    Object? injuries = null,
    Object? currentProgramId = null,
    Object? xp = null,
    Object? level = null,
    Object? streakWeeks = null,
    Object? streakShields = null,
    Object? createdAt = null,
    Object? onboardingComplete = null,
    Object? customSplitId = freezed,
    Object? heightCm = freezed,
    Object? bodyWeightKg = freezed,
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
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as String,
      daysPerWeek: null == daysPerWeek
          ? _value.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String,
      injuries: null == injuries
          ? _value.injuries
          : injuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentProgramId: null == currentProgramId
          ? _value.currentProgramId
          : currentProgramId // ignore: cast_nullable_to_non_nullable
              as String,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      streakWeeks: null == streakWeeks
          ? _value.streakWeeks
          : streakWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      streakShields: null == streakShields
          ? _value.streakShields
          : streakShields // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      onboardingComplete: null == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      customSplitId: freezed == customSplitId
          ? _value.customSplitId
          : customSplitId // ignore: cast_nullable_to_non_nullable
              as String?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyWeightKg: freezed == bodyWeightKg
          ? _value.bodyWeightKg
          : bodyWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) String goal,
      @HiveField(3) String experience,
      @HiveField(4) int daysPerWeek,
      @HiveField(5) String equipment,
      @HiveField(6) List<String> injuries,
      @HiveField(7) String currentProgramId,
      @HiveField(8) int xp,
      @HiveField(9) String level,
      @HiveField(10) int streakWeeks,
      @HiveField(11) int streakShields,
      @HiveField(12) DateTime createdAt,
      @HiveField(13) bool onboardingComplete,
      @HiveField(14) String? customSplitId,
      @HiveField(15) double? heightCm,
      @HiveField(16) double? bodyWeightKg});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? goal = null,
    Object? experience = null,
    Object? daysPerWeek = null,
    Object? equipment = null,
    Object? injuries = null,
    Object? currentProgramId = null,
    Object? xp = null,
    Object? level = null,
    Object? streakWeeks = null,
    Object? streakShields = null,
    Object? createdAt = null,
    Object? onboardingComplete = null,
    Object? customSplitId = freezed,
    Object? heightCm = freezed,
    Object? bodyWeightKg = freezed,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as String,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as String,
      daysPerWeek: null == daysPerWeek
          ? _value.daysPerWeek
          : daysPerWeek // ignore: cast_nullable_to_non_nullable
              as int,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String,
      injuries: null == injuries
          ? _value._injuries
          : injuries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      currentProgramId: null == currentProgramId
          ? _value.currentProgramId
          : currentProgramId // ignore: cast_nullable_to_non_nullable
              as String,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      streakWeeks: null == streakWeeks
          ? _value.streakWeeks
          : streakWeeks // ignore: cast_nullable_to_non_nullable
              as int,
      streakShields: null == streakShields
          ? _value.streakShields
          : streakShields // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      onboardingComplete: null == onboardingComplete
          ? _value.onboardingComplete
          : onboardingComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      customSplitId: freezed == customSplitId
          ? _value.customSplitId
          : customSplitId // ignore: cast_nullable_to_non_nullable
              as String?,
      heightCm: freezed == heightCm
          ? _value.heightCm
          : heightCm // ignore: cast_nullable_to_non_nullable
              as double?,
      bodyWeightKg: freezed == bodyWeightKg
          ? _value.bodyWeightKg
          : bodyWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required this.goal,
      @HiveField(3) required this.experience,
      @HiveField(4) required this.daysPerWeek,
      @HiveField(5) required this.equipment,
      @HiveField(6) final List<String> injuries = const [],
      @HiveField(7) required this.currentProgramId,
      @HiveField(8) this.xp = 0,
      @HiveField(9) this.level = 'novice',
      @HiveField(10) this.streakWeeks = 0,
      @HiveField(11) this.streakShields = 1,
      @HiveField(12) required this.createdAt,
      @HiveField(13) this.onboardingComplete = false,
      @HiveField(14) this.customSplitId,
      @HiveField(15) this.heightCm,
      @HiveField(16) this.bodyWeightKg})
      : _injuries = injuries;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String goal;
// lose_fat | build_muscle | get_stronger | general
  @override
  @HiveField(3)
  final String experience;
// beginner | some | intermediate
  @override
  @HiveField(4)
  final int daysPerWeek;
  @override
  @HiveField(5)
  final String equipment;
// full_gym | home_dumbbells | home_bodyweight | hybrid
  final List<String> _injuries;
// full_gym | home_dumbbells | home_bodyweight | hybrid
  @override
  @JsonKey()
  @HiveField(6)
  List<String> get injuries {
    if (_injuries is EqualUnmodifiableListView) return _injuries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_injuries);
  }

  @override
  @HiveField(7)
  final String currentProgramId;
  @override
  @JsonKey()
  @HiveField(8)
  final int xp;
  @override
  @JsonKey()
  @HiveField(9)
  final String level;
  @override
  @JsonKey()
  @HiveField(10)
  final int streakWeeks;
  @override
  @JsonKey()
  @HiveField(11)
  final int streakShields;
  @override
  @HiveField(12)
  final DateTime createdAt;
  @override
  @JsonKey()
  @HiveField(13)
  final bool onboardingComplete;
  @override
  @HiveField(14)
  final String? customSplitId;
  @override
  @HiveField(15)
  final double? heightCm;
  @override
  @HiveField(16)
  final double? bodyWeightKg;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, goal: $goal, experience: $experience, daysPerWeek: $daysPerWeek, equipment: $equipment, injuries: $injuries, currentProgramId: $currentProgramId, xp: $xp, level: $level, streakWeeks: $streakWeeks, streakShields: $streakShields, createdAt: $createdAt, onboardingComplete: $onboardingComplete, customSplitId: $customSplitId, heightCm: $heightCm, bodyWeightKg: $bodyWeightKg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.daysPerWeek, daysPerWeek) ||
                other.daysPerWeek == daysPerWeek) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            const DeepCollectionEquality().equals(other._injuries, _injuries) &&
            (identical(other.currentProgramId, currentProgramId) ||
                other.currentProgramId == currentProgramId) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.streakWeeks, streakWeeks) ||
                other.streakWeeks == streakWeeks) &&
            (identical(other.streakShields, streakShields) ||
                other.streakShields == streakShields) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete) &&
            (identical(other.customSplitId, customSplitId) ||
                other.customSplitId == customSplitId) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.bodyWeightKg, bodyWeightKg) ||
                other.bodyWeightKg == bodyWeightKg));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      goal,
      experience,
      daysPerWeek,
      equipment,
      const DeepCollectionEquality().hash(_injuries),
      currentProgramId,
      xp,
      level,
      streakWeeks,
      streakShields,
      createdAt,
      onboardingComplete,
      customSplitId,
      heightCm,
      bodyWeightKg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final String goal,
      @HiveField(3) required final String experience,
      @HiveField(4) required final int daysPerWeek,
      @HiveField(5) required final String equipment,
      @HiveField(6) final List<String> injuries,
      @HiveField(7) required final String currentProgramId,
      @HiveField(8) final int xp,
      @HiveField(9) final String level,
      @HiveField(10) final int streakWeeks,
      @HiveField(11) final int streakShields,
      @HiveField(12) required final DateTime createdAt,
      @HiveField(13) final bool onboardingComplete,
      @HiveField(14) final String? customSplitId,
      @HiveField(15) final double? heightCm,
      @HiveField(16) final double? bodyWeightKg}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  String get goal;
  @override // lose_fat | build_muscle | get_stronger | general
  @HiveField(3)
  String get experience;
  @override // beginner | some | intermediate
  @HiveField(4)
  int get daysPerWeek;
  @override
  @HiveField(5)
  String get equipment;
  @override // full_gym | home_dumbbells | home_bodyweight | hybrid
  @HiveField(6)
  List<String> get injuries;
  @override
  @HiveField(7)
  String get currentProgramId;
  @override
  @HiveField(8)
  int get xp;
  @override
  @HiveField(9)
  String get level;
  @override
  @HiveField(10)
  int get streakWeeks;
  @override
  @HiveField(11)
  int get streakShields;
  @override
  @HiveField(12)
  DateTime get createdAt;
  @override
  @HiveField(13)
  bool get onboardingComplete;
  @override
  @HiveField(14)
  String? get customSplitId;
  @override
  @HiveField(15)
  double? get heightCm;
  @override
  @HiveField(16)
  double? get bodyWeightKg;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
