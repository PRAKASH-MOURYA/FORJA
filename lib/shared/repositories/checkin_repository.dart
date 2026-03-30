import '../models/check_in.dart';
import '../services/hive_service.dart';

class CheckInRepository {
  List<CheckIn> getAll() => HiveService.checkIns.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  CheckIn? getLatest() {
    final all = getAll();
    return all.isEmpty ? null : all.first;
  }

  CheckIn? getById(String id) => HiveService.checkIns.get(id);

  Future<void> save(CheckIn checkIn) =>
      HiveService.checkIns.put(checkIn.id, checkIn);

  Future<void> delete(String id) => HiveService.checkIns.delete(id);

  List<CheckIn> getLastN(int n) => getAll().take(n).toList();

  List<CheckIn> getPending() =>
      getAll().where((c) => c.syncStatus == 'pending').toList();
}
