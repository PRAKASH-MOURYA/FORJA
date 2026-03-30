import '../models/workout_log.dart';
import '../models/set_log.dart';
import '../services/hive_service.dart';

class WorkoutRepository {
  List<WorkoutLog> getAll() => HiveService.workoutLogs.values.toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  WorkoutLog? getById(String id) => HiveService.workoutLogs.get(id);

  Future<void> save(WorkoutLog log) => HiveService.workoutLogs.put(log.id, log);

  Future<void> delete(String id) => HiveService.workoutLogs.delete(id);

  List<WorkoutLog> getForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return getAll()
        .where((w) =>
            w.startedAt.isAfter(weekStart) && w.startedAt.isBefore(weekEnd))
        .toList();
  }

  List<WorkoutLog> getPending() =>
      getAll().where((w) => w.syncStatus == 'pending').toList();

  // --- Set logs ---

  List<SetLog> getSetsForWorkout(String workoutLogId) =>
      HiveService.setLogs.values
          .where((s) => s.workoutLogId == workoutLogId)
          .toList()
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));

  List<SetLog> getPendingSetLogs() =>
      HiveService.setLogs.values
          .where((s) => s.syncStatus == 'pending')
          .toList();

  Future<void> saveSet(SetLog set) => HiveService.setLogs.put(set.id, set);

  Future<void> saveAllSets(List<SetLog> sets) async {
    final map = {for (final s in sets) s.id: s};
    await HiveService.setLogs.putAll(map);
  }
}
