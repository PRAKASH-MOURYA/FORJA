import '../models/user_profile.dart';
import '../services/hive_service.dart';

class ProfileRepository {
  static const _key = 'profile';

  UserProfile? get() => HiveService.profile.get(_key);

  Future<void> save(UserProfile profile) =>
      HiveService.profile.put(_key, profile);

  Future<void> delete() => HiveService.profile.delete(_key);

  bool get exists => HiveService.profile.containsKey(_key);
}
