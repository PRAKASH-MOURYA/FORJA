import '../models/user_profile.dart';

class XpService {
  static const Map<String, int> kXpRewards = {
    'workout': 100,
    'pr': 200,
    'checkin': 20,
  };

  static const Map<String, int> kLevelThresholds = {
    'novice': 0,
    'beginner': 500,
    'intermediate': 1500,
    'advanced': 3500,
    'elite': 7000,
  };

  static UserProfile awardXp(UserProfile profile, String eventType) {
    final reward = kXpRewards[eventType] ?? 0;
    final newXp = profile.xp + reward;
    return profile.copyWith(
      xp: newXp,
      level: _computeLevel(newXp),
    );
  }

  static String _computeLevel(int xp) {
    var result = 'novice';
    for (final entry in kLevelThresholds.entries) {
      if (xp >= entry.value) {
        result = entry.key;
      }
    }
    return result;
  }
}
