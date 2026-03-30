/// Maps onboarding quiz answers to one of 8 program template IDs.
class ProgramSelector {
  static String select({
    required String goal, // lose_fat | build_muscle | get_stronger | general
    required String experience, // beginner | some | intermediate
    required int daysPerWeek,
    required String
        equipment, // full_gym | home_dumbbells | home_bodyweight | hybrid
  }) {
    // No equipment → bodyweight program
    if (equipment == 'home_bodyweight') return 'home_bodyweight_3x';

    // Dumbbells only → dumbbell program
    if (equipment == 'home_dumbbells') return 'home_dumbbell_3x';

    // Hybrid (mix of gym + home)
    if (equipment == 'hybrid') return 'hybrid_gym_home';

    // Full gym below
    if (experience == 'beginner') {
      if (daysPerWeek <= 3) return 'full_body_3x';
      return 'upper_lower_4x';
    }

    if (experience == 'some') {
      if (goal == 'get_stronger') return 'strength_5x5_3x';
      if (daysPerWeek <= 3) return 'full_body_3x';
      if (daysPerWeek == 4) return 'upper_lower_4x';
      return 'ppl_5x';
    }

    // Intermediate
    if (goal == 'get_stronger') return 'strength_5x5_3x';
    if (daysPerWeek <= 4) return 'upper_lower_4x';
    return 'ppl_5x';
  }
}
