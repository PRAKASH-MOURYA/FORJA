/// Realistic dummy data for UI previews and empty states.
/// Does NOT replace real provider data — used only when real data is absent.
class DummyData {
  static const String sampleName = 'Alex Rivera';
  static const int sampleLevel = 12;
  static const int sampleXp = 2840;
  static const int xpToNextLevel = 4000;
  static const int sampleStreakWeeks = 8;

  // Weekly volume data (kg per day, Mon-Sun)
  static const Map<String, double> weeklyVolume = {
    'Mon': 4200,
    'Tue': 3800,
    'Wed': 0,
    'Thu': 5100,
    'Fri': 4600,
    'Sat': 3200,
    'Sun': 0,
  };

  // PR data — exercise name → weight (kg)
  static const Map<String, double> personalRecords = {
    'Barbell Bench Press': 100.0,
    'Barbell Squat': 130.0,
    'Deadlift': 160.0,
    'Overhead Press': 70.0,
    'Barbell Row': 95.0,
    'Incline Bench Press': 80.0,
  };

  // 1RM trends (last 4 weeks, exercise → weights)
  static const Map<String, List<double>> strengthTrends = {
    'Barbell Bench Press': [90.0, 92.5, 97.5, 100.0],
    'Barbell Squat': [115.0, 120.0, 125.0, 130.0],
    'Deadlift': [145.0, 150.0, 155.0, 160.0],
  };

  // Achievements/badges
  static const List<Map<String, dynamic>> achievements = [
    {'id': 'first_workout', 'name': 'First Rep', 'icon': '🏋️', 'earned': true},
    {'id': 'ten_workouts', 'name': '10 Sessions', 'icon': '🔟', 'earned': true},
    {'id': 'iron_week', 'name': 'Iron Week', 'icon': '🔥', 'earned': true},
    {'id': 'volume_lord', 'name': 'Volume Lord', 'icon': '⚡', 'earned': true},
    {'id': 'streak_shield', 'name': 'Streak Shield', 'icon': '🛡️', 'earned': true},
    {'id': 'pr_machine', 'name': 'PR Machine', 'icon': '📈', 'earned': true},
    {'id': 'early_bird', 'name': 'Early Bird', 'icon': '🌅', 'earned': false},
    {'id': 'night_owl', 'name': 'Night Owl', 'icon': '🦉', 'earned': false},
    {'id': 'century', 'name': 'Century Club', 'icon': '💯', 'earned': false},
    {'id': 'consistency', 'name': 'Consistent', 'icon': '📅', 'earned': false},
    {'id': 'heavy_lifter', 'name': 'Heavy Lifter', 'icon': '🏆', 'earned': false},
    {'id': 'beast_mode', 'name': 'Beast Mode', 'icon': '🦁', 'earned': false},
  ];

  // Recent workout logs (display data)
  static const List<Map<String, dynamic>> recentWorkouts = [
    {
      'date': '2024-03-15',
      'dayName': 'Push Day',
      'duration': '52 min',
      'volume': '4,800 kg',
      'exercises': 6,
    },
    {
      'date': '2024-03-13',
      'dayName': 'Pull Day',
      'duration': '48 min',
      'volume': '4,200 kg',
      'exercises': 5,
    },
    {
      'date': '2024-03-11',
      'dayName': 'Legs Day',
      'duration': '55 min',
      'volume': '6,100 kg',
      'exercises': 7,
    },
  ];

  // 12-week consistency heatmap (1 = workout, 0 = rest)
  static final List<List<int>> consistencyGrid = List.generate(
    12,
    (week) => List.generate(
      7,
      (day) {
        // Simulate realistic workout pattern (M/T/Th/F)
        if ([0, 1, 3, 4].contains(day) && week < 11) {
          return (week + day) % 5 == 0 ? 0 : 1;
        }
        return 0;
      },
    ),
  );

  // Level title mapping
  static String levelTitle(int level) {
    if (level < 5) return 'Rookie';
    if (level < 10) return 'Athlete';
    if (level < 15) return 'Ironclad';
    if (level < 20) return 'Elite';
    return 'Legend';
  }
}
