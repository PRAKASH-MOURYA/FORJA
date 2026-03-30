import '../models/user_profile.dart';

class StreakService {
  static UserProfile evaluateStreak(
    UserProfile profile,
    DateTime lastWorkoutDate, {
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final lastWeek = _isoWeek(lastWorkoutDate);
    final currentWeek = _isoWeek(currentDate);
    final weekGap = currentWeek - lastWeek;

    if (weekGap <= 0) {
      return profile;
    }
    if (weekGap == 1) {
      return profile.copyWith(streakWeeks: profile.streakWeeks + 1);
    }
    if (profile.streakShields > 0) {
      return profile.copyWith(streakShields: profile.streakShields - 1);
    }
    return profile.copyWith(streakWeeks: 0);
  }

  static int _isoWeek(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    return ((date.difference(jan4).inDays + jan4.weekday) / 7).ceil();
  }
}
