// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_split.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomSplit _$CustomSplitFromJson(Map<String, dynamic> json) {
  return _CustomSplit.fromJson(json);
}

/// @nodoc
mixin _$CustomSplit {
  @HiveField(0)
  String get id =>
      throw _privateConstructorUsedError; // UUID string (stored as string)
  @HiveField(1)
  String get name => throw _privateConstructorUsedError;
  @HiveField(2)
  int get daysCount => throw _privateConstructorUsedError; // 2-6
  @HiveField(3)
  List<SplitDay> get days => throw _privateConstructorUsedError;
  @HiveField(4)
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // weekday (1=Mon … 7=Sun) → index into days list.
// Empty map = all days are rest days.
// @Default ensures backwards-compat: existing Hive records without this field
// deserialise to {} instead of null.
  @HiveField(5, defaultValue: <int, int>{})
  Map<int, int> get weekdayMap => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomSplitCopyWith<CustomSplit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomSplitCopyWith<$Res> {
  factory $CustomSplitCopyWith(
          CustomSplit value, $Res Function(CustomSplit) then) =
      _$CustomSplitCopyWithImpl<$Res, CustomSplit>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) int daysCount,
      @HiveField(3) List<SplitDay> days,
      @HiveField(4) DateTime createdAt,
      @HiveField(5, defaultValue: <int, int>{}) Map<int, int> weekdayMap});
}

/// @nodoc
class _$CustomSplitCopyWithImpl<$Res, $Val extends CustomSplit>
    implements $CustomSplitCopyWith<$Res> {
  _$CustomSplitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? daysCount = null,
    Object? days = null,
    Object? createdAt = null,
    Object? weekdayMap = null,
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
      daysCount: null == daysCount
          ? _value.daysCount
          : daysCount // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as List<SplitDay>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekdayMap: null == weekdayMap
          ? _value.weekdayMap
          : weekdayMap // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomSplitImplCopyWith<$Res>
    implements $CustomSplitCopyWith<$Res> {
  factory _$$CustomSplitImplCopyWith(
          _$CustomSplitImpl value, $Res Function(_$CustomSplitImpl) then) =
      __$$CustomSplitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String name,
      @HiveField(2) int daysCount,
      @HiveField(3) List<SplitDay> days,
      @HiveField(4) DateTime createdAt,
      @HiveField(5, defaultValue: <int, int>{}) Map<int, int> weekdayMap});
}

/// @nodoc
class __$$CustomSplitImplCopyWithImpl<$Res>
    extends _$CustomSplitCopyWithImpl<$Res, _$CustomSplitImpl>
    implements _$$CustomSplitImplCopyWith<$Res> {
  __$$CustomSplitImplCopyWithImpl(
      _$CustomSplitImpl _value, $Res Function(_$CustomSplitImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? daysCount = null,
    Object? days = null,
    Object? createdAt = null,
    Object? weekdayMap = null,
  }) {
    return _then(_$CustomSplitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      daysCount: null == daysCount
          ? _value.daysCount
          : daysCount // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<SplitDay>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekdayMap: null == weekdayMap
          ? _value._weekdayMap
          : weekdayMap // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomSplitImpl implements _CustomSplit {
  const _$CustomSplitImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.name,
      @HiveField(2) required this.daysCount,
      @HiveField(3) required final List<SplitDay> days,
      @HiveField(4) required this.createdAt,
      @HiveField(5, defaultValue: <int, int>{})
      final Map<int, int> weekdayMap = const <int, int>{}})
      : _days = days,
        _weekdayMap = weekdayMap;

  factory _$CustomSplitImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomSplitImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
// UUID string (stored as string)
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final int daysCount;
// 2-6
  final List<SplitDay> _days;
// 2-6
  @override
  @HiveField(3)
  List<SplitDay> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  @HiveField(4)
  final DateTime createdAt;
// weekday (1=Mon … 7=Sun) → index into days list.
// Empty map = all days are rest days.
// @Default ensures backwards-compat: existing Hive records without this field
// deserialise to {} instead of null.
  final Map<int, int> _weekdayMap;
// weekday (1=Mon … 7=Sun) → index into days list.
// Empty map = all days are rest days.
// @Default ensures backwards-compat: existing Hive records without this field
// deserialise to {} instead of null.
  @override
  @JsonKey()
  @HiveField(5, defaultValue: <int, int>{})
  Map<int, int> get weekdayMap {
    if (_weekdayMap is EqualUnmodifiableMapView) return _weekdayMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_weekdayMap);
  }

  @override
  String toString() {
    return 'CustomSplit(id: $id, name: $name, daysCount: $daysCount, days: $days, createdAt: $createdAt, weekdayMap: $weekdayMap)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomSplitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.daysCount, daysCount) ||
                other.daysCount == daysCount) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._weekdayMap, _weekdayMap));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      daysCount,
      const DeepCollectionEquality().hash(_days),
      createdAt,
      const DeepCollectionEquality().hash(_weekdayMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomSplitImplCopyWith<_$CustomSplitImpl> get copyWith =>
      __$$CustomSplitImplCopyWithImpl<_$CustomSplitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomSplitImplToJson(
      this,
    );
  }
}

abstract class _CustomSplit implements CustomSplit {
  const factory _CustomSplit(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String name,
      @HiveField(2) required final int daysCount,
      @HiveField(3) required final List<SplitDay> days,
      @HiveField(4) required final DateTime createdAt,
      @HiveField(5, defaultValue: <int, int>{})
      final Map<int, int> weekdayMap}) = _$CustomSplitImpl;

  factory _CustomSplit.fromJson(Map<String, dynamic> json) =
      _$CustomSplitImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override // UUID string (stored as string)
  @HiveField(1)
  String get name;
  @override
  @HiveField(2)
  int get daysCount;
  @override // 2-6
  @HiveField(3)
  List<SplitDay> get days;
  @override
  @HiveField(4)
  DateTime get createdAt;
  @override // weekday (1=Mon … 7=Sun) → index into days list.
// Empty map = all days are rest days.
// @Default ensures backwards-compat: existing Hive records without this field
// deserialise to {} instead of null.
  @HiveField(5, defaultValue: <int, int>{})
  Map<int, int> get weekdayMap;
  @override
  @JsonKey(ignore: true)
  _$$CustomSplitImplCopyWith<_$CustomSplitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SplitDay _$SplitDayFromJson(Map<String, dynamic> json) {
  return _SplitDay.fromJson(json);
}

/// @nodoc
mixin _$SplitDay {
  @HiveField(0)
  String get dayName => throw _privateConstructorUsedError; // e.g. "Push A"
  @HiveField(1)
  List<String> get exerciseIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SplitDayCopyWith<SplitDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplitDayCopyWith<$Res> {
  factory $SplitDayCopyWith(SplitDay value, $Res Function(SplitDay) then) =
      _$SplitDayCopyWithImpl<$Res, SplitDay>;
  @useResult
  $Res call(
      {@HiveField(0) String dayName, @HiveField(1) List<String> exerciseIds});
}

/// @nodoc
class _$SplitDayCopyWithImpl<$Res, $Val extends SplitDay>
    implements $SplitDayCopyWith<$Res> {
  _$SplitDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayName = null,
    Object? exerciseIds = null,
  }) {
    return _then(_value.copyWith(
      dayName: null == dayName
          ? _value.dayName
          : dayName // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseIds: null == exerciseIds
          ? _value.exerciseIds
          : exerciseIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SplitDayImplCopyWith<$Res>
    implements $SplitDayCopyWith<$Res> {
  factory _$$SplitDayImplCopyWith(
          _$SplitDayImpl value, $Res Function(_$SplitDayImpl) then) =
      __$$SplitDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String dayName, @HiveField(1) List<String> exerciseIds});
}

/// @nodoc
class __$$SplitDayImplCopyWithImpl<$Res>
    extends _$SplitDayCopyWithImpl<$Res, _$SplitDayImpl>
    implements _$$SplitDayImplCopyWith<$Res> {
  __$$SplitDayImplCopyWithImpl(
      _$SplitDayImpl _value, $Res Function(_$SplitDayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayName = null,
    Object? exerciseIds = null,
  }) {
    return _then(_$SplitDayImpl(
      dayName: null == dayName
          ? _value.dayName
          : dayName // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseIds: null == exerciseIds
          ? _value._exerciseIds
          : exerciseIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SplitDayImpl implements _SplitDay {
  const _$SplitDayImpl(
      {@HiveField(0) required this.dayName,
      @HiveField(1) required final List<String> exerciseIds})
      : _exerciseIds = exerciseIds;

  factory _$SplitDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$SplitDayImplFromJson(json);

  @override
  @HiveField(0)
  final String dayName;
// e.g. "Push A"
  final List<String> _exerciseIds;
// e.g. "Push A"
  @override
  @HiveField(1)
  List<String> get exerciseIds {
    if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exerciseIds);
  }

  @override
  String toString() {
    return 'SplitDay(dayName: $dayName, exerciseIds: $exerciseIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplitDayImpl &&
            (identical(other.dayName, dayName) || other.dayName == dayName) &&
            const DeepCollectionEquality()
                .equals(other._exerciseIds, _exerciseIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, dayName, const DeepCollectionEquality().hash(_exerciseIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SplitDayImplCopyWith<_$SplitDayImpl> get copyWith =>
      __$$SplitDayImplCopyWithImpl<_$SplitDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SplitDayImplToJson(
      this,
    );
  }
}

abstract class _SplitDay implements SplitDay {
  const factory _SplitDay(
      {@HiveField(0) required final String dayName,
      @HiveField(1) required final List<String> exerciseIds}) = _$SplitDayImpl;

  factory _SplitDay.fromJson(Map<String, dynamic> json) =
      _$SplitDayImpl.fromJson;

  @override
  @HiveField(0)
  String get dayName;
  @override // e.g. "Push A"
  @HiveField(1)
  List<String> get exerciseIds;
  @override
  @JsonKey(ignore: true)
  _$$SplitDayImplCopyWith<_$SplitDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
