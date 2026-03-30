import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';
import '../models/set_log.dart';
import '../models/check_in.dart';
import '../models/user_profile.dart';
import '../models/challenge.dart';
import '../models/custom_split.dart';

class HiveService {
  static const _workoutLogsBox = 'workout_logs';
  static const _setLogsBox = 'set_logs';
  static const _checkInsBox = 'check_ins';
  static const _profileBox = 'user_profile';
  static const _prBox = 'personal_records';
  static const _challengesBox = 'challenges';
  static const _customSplitsBox = 'custom_splits';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters — order must match typeId values
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ExerciseAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(WorkoutLogAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SetLogAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(CheckInAdapter());
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ChallengeAdapter());
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(CustomSplitAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(SplitDayAdapter());

    await Future.wait([
      Hive.openBox<WorkoutLog>(_workoutLogsBox),
      Hive.openBox<SetLog>(_setLogsBox),
      Hive.openBox<CheckIn>(_checkInsBox),
      Hive.openBox<UserProfile>(_profileBox),
      Hive.openBox<Map>(_prBox),
      Hive.openBox<Challenge>(_challengesBox),
      Hive.openBox<CustomSplit>(_customSplitsBox),
    ]);
  }

  static Box<WorkoutLog> get workoutLogs =>
      Hive.box<WorkoutLog>(_workoutLogsBox);
  static Box<SetLog> get setLogs => Hive.box<SetLog>(_setLogsBox);
  static Box<CheckIn> get checkIns => Hive.box<CheckIn>(_checkInsBox);
  static Box<UserProfile> get profile => Hive.box<UserProfile>(_profileBox);
  static Box<Map> get prRecords => Hive.box<Map>(_prBox);
  static Box<Challenge> get challenges => Hive.box<Challenge>(_challengesBox);
  static Box<CustomSplit> get customSplits =>
      Hive.box<CustomSplit>(_customSplitsBox);

  /// Clear all boxes — use in debug/testing only
  static Future<void> clearAll() async {
    await workoutLogs.clear();
    await setLogs.clear();
    await checkIns.clear();
    await profile.clear();
    await prRecords.clear();
    await challenges.clear();
    await customSplits.clear();
  }
}
