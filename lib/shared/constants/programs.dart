// Program template data — references exercise IDs from kExerciseData in exercises.dart
// ignore_for_file: lines_longer_than_80_chars

/// A single training day within a program, defined by a name and a list of
/// exercise IDs that map to keys in [kExerciseData].
class ProgramDay {
  final String name;
  final List<String> exerciseIds;
  const ProgramDay({required this.name, required this.exerciseIds});
}

/// A complete program template describing a structured training plan.
///
/// [id]          — unique machine-readable identifier
/// [name]        — display name shown in the UI
/// [description] — one-sentence summary of the program's goal/audience
/// [daysPerWeek] — number of distinct training days per week
/// [equipment]   — primary equipment requirement key
/// [experience]  — target experience level ('beginner', 'intermediate', 'advanced')
/// [days]        — ordered list of [ProgramDay] objects
class ProgramTemplate {
  final String id;
  final String name;
  final String description;
  final int daysPerWeek;
  final String equipment;
  final String experience;
  final List<ProgramDay> days;

  const ProgramTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.daysPerWeek,
    required this.equipment,
    required this.experience,
    required this.days,
  });
}

/// All built-in program templates available in FORJA.
const List<ProgramTemplate> kPrograms = [
  // ─── 1. Full Body 3× / week ──────────────────────────────────────────────────
  ProgramTemplate(
    id: 'full_body_3x',
    name: 'Full Body 3×/Week',
    description:
        'A beginner-friendly full-body program training every major muscle group three times per week for rapid overall strength gains.',
    daysPerWeek: 3,
    equipment: 'full_gym',
    experience: 'beginner',
    days: [
      ProgramDay(
        name: 'Day 1 — Push Focus',
        exerciseIds: [
          'barbell_bench_press',
          'overhead_press',
          'barbell_row',
          'barbell_squat',
          'plank',
        ],
      ),
      ProgramDay(
        name: 'Day 2 — Pull Focus',
        exerciseIds: [
          'lat_pulldown',
          'dumbbell_row',
          'barbell_curl',
          'romanian_deadlift',
          'ab_wheel',
        ],
      ),
      ProgramDay(
        name: 'Day 3 — Legs & Core',
        exerciseIds: [
          'barbell_squat',
          'leg_press',
          'romanian_deadlift',
          'calf_raise',
          'hanging_knee_raise',
        ],
      ),
    ],
  ),

  // ─── 2. Upper / Lower 4× / week ─────────────────────────────────────────────
  ProgramTemplate(
    id: 'upper_lower_4x',
    name: 'Upper/Lower 4×/Week',
    description:
        'A classic upper/lower split training four days per week — ideal for beginners transitioning to intermediate training who want more volume per muscle group.',
    daysPerWeek: 4,
    equipment: 'full_gym',
    experience: 'beginner_intermediate',
    days: [
      ProgramDay(
        name: 'Upper A — Strength Focus',
        exerciseIds: [
          'barbell_bench_press',
          'barbell_row',
          'overhead_press',
          'lat_pulldown',
          'barbell_curl',
          'tricep_pushdown',
        ],
      ),
      ProgramDay(
        name: 'Lower A — Strength Focus',
        exerciseIds: [
          'barbell_squat',
          'romanian_deadlift',
          'leg_press',
          'leg_curl',
          'calf_raise',
        ],
      ),
      ProgramDay(
        name: 'Upper B — Hypertrophy Focus',
        exerciseIds: [
          'incline_dumbbell_press',
          'cable_row',
          'dumbbell_shoulder_press',
          'lat_pulldown',
          'hammer_curl',
          'tricep_overhead_extension',
        ],
      ),
      ProgramDay(
        name: 'Lower B — Hypertrophy Focus',
        exerciseIds: [
          'barbell_deadlift',
          'goblet_squat',
          'hip_thrust',
          'leg_extension',
          'calf_raise',
        ],
      ),
    ],
  ),

  // ─── 3. Push / Pull / Legs 5× / week ────────────────────────────────────────
  ProgramTemplate(
    id: 'ppl_5x',
    name: 'Push/Pull/Legs 5×/Week',
    description:
        'A high-frequency Push/Pull/Legs split for intermediate lifters seeking maximum hypertrophy by hitting each muscle group twice per week across five sessions.',
    daysPerWeek: 5,
    equipment: 'full_gym',
    experience: 'intermediate',
    days: [
      ProgramDay(
        name: 'Day 1 — Push',
        exerciseIds: [
          'barbell_bench_press',
          'incline_dumbbell_press',
          'cable_flyes',
          'overhead_press',
          'lateral_raises',
          'tricep_pushdown',
        ],
      ),
      ProgramDay(
        name: 'Day 2 — Pull',
        exerciseIds: [
          'barbell_row',
          'lat_pulldown',
          'cable_row',
          'face_pull',
          'barbell_curl',
          'hammer_curl',
        ],
      ),
      ProgramDay(
        name: 'Day 3 — Legs',
        exerciseIds: [
          'barbell_squat',
          'leg_press',
          'romanian_deadlift',
          'leg_curl',
          'calf_raise',
          'hanging_knee_raise',
        ],
      ),
      ProgramDay(
        name: 'Day 4 — Push (repeat)',
        exerciseIds: [
          'barbell_bench_press',
          'incline_dumbbell_press',
          'cable_flyes',
          'overhead_press',
          'lateral_raises',
          'tricep_pushdown',
        ],
      ),
      ProgramDay(
        name: 'Day 5 — Pull (repeat)',
        exerciseIds: [
          'barbell_row',
          'lat_pulldown',
          'cable_row',
          'face_pull',
          'barbell_curl',
          'hammer_curl',
        ],
      ),
    ],
  ),

  // ─── 4. Home Bodyweight 3× / week ───────────────────────────────────────────
  ProgramTemplate(
    id: 'home_bodyweight_3x',
    name: 'Home Bodyweight 3×/Week',
    description:
        'A zero-equipment home program using only bodyweight movements, perfect for beginners or anyone training without access to a gym or weights.',
    daysPerWeek: 3,
    equipment: 'home_bodyweight',
    experience: 'beginner',
    days: [
      ProgramDay(
        name: 'Day 1 — Push & Legs',
        exerciseIds: [
          'push_up',
          'diamond_push_up',
          'bodyweight_squat',
          'walking_lunge',
          'plank',
          'russian_twist',
        ],
      ),
      ProgramDay(
        name: 'Day 2 — Pull & Core',
        exerciseIds: [
          'pull_up',
          'push_up',
          'bodyweight_squat',
          'calf_raise',
          'ab_wheel',
          'russian_twist',
        ],
      ),
      ProgramDay(
        name: 'Day 3 — Full Body Finisher',
        exerciseIds: [
          'push_up',
          'diamond_push_up',
          'bodyweight_squat',
          'walking_lunge',
          'plank',
          'ab_wheel',
        ],
      ),
    ],
  ),

  // ─── 5. Home Dumbbell 3× / week ─────────────────────────────────────────────
  ProgramTemplate(
    id: 'home_dumbbell_3x',
    name: 'Home Dumbbell 3×/Week',
    description:
        'A complete home program using only dumbbells, covering all major muscle groups three times per week for balanced strength and muscle development.',
    daysPerWeek: 3,
    equipment: 'home_dumbbells',
    experience: 'beginner',
    days: [
      ProgramDay(
        name: 'Day 1 — Push & Legs',
        exerciseIds: [
          'dumbbell_bench_press',
          'dumbbell_shoulder_press',
          'dumbbell_row',
          'dumbbell_curl',
          'goblet_squat',
          'plank',
        ],
      ),
      ProgramDay(
        name: 'Day 2 — Pull & Hamstrings',
        exerciseIds: [
          'incline_dumbbell_press',
          'lateral_raises',
          'dumbbell_row',
          'hammer_curl',
          'dumbbell_romanian_deadlift',
          'ab_wheel',
        ],
      ),
      ProgramDay(
        name: 'Day 3 — Full Body',
        exerciseIds: [
          'dumbbell_bench_press',
          'dumbbell_shoulder_press',
          'dumbbell_row',
          'dumbbell_curl',
          'walking_lunge',
          'russian_twist',
        ],
      ),
    ],
  ),

  // ─── 6. 5×5 Strength 3× / week ──────────────────────────────────────────────
  ProgramTemplate(
    id: 'strength_5x5_3x',
    name: '5×5 Strength 3×/Week',
    description:
        'A proven beginner strength program based on 5 sets of 5 reps on the three primary compound lifts, adding weight each session for rapid early strength gains.',
    daysPerWeek: 3,
    equipment: 'full_gym',
    experience: 'beginner',
    days: [
      ProgramDay(
        // Weeks alternate A/B/A then B/A/B — use Day A on Mon/Fri, Day B on Wed
        name: 'Day A — Squat / Bench / Row',
        exerciseIds: [
          'barbell_squat', // 5×5 — add 2.5 kg each session
          'barbell_bench_press', // 5×5 — add 2.5 kg each session
          'barbell_row', // 5×5 — add 2.5 kg each session
        ],
      ),
      ProgramDay(
        name: 'Day B — Squat / Press / Deadlift',
        exerciseIds: [
          'barbell_squat', // 5×5 — add 2.5 kg each session
          'overhead_press', // 5×5 — add 2.5 kg each session
          'barbell_deadlift', // 1×5 — add 5 kg each session
        ],
      ),
    ],
  ),

  // ─── 7. Hybrid Gym + Home 4× / week ─────────────────────────────────────────
  ProgramTemplate(
    id: 'hybrid_gym_home',
    name: 'Hybrid Gym + Home 4×/Week',
    description:
        'A flexible four-day program alternating between gym sessions for heavy compound work and home sessions with dumbbells or bodyweight on non-gym days.',
    daysPerWeek: 4,
    equipment: 'full_gym',
    experience: 'intermediate',
    days: [
      ProgramDay(
        name: 'Gym Day 1 — Compound Push & Pull',
        exerciseIds: [
          'barbell_bench_press',
          'barbell_row',
          'barbell_squat',
          'overhead_press',
          'barbell_curl',
        ],
      ),
      ProgramDay(
        name: 'Home Day 1 — Dumbbell & Bodyweight',
        exerciseIds: [
          'push_up',
          'dumbbell_row',
          'bodyweight_squat',
          'lateral_raises',
          'plank',
        ],
      ),
      ProgramDay(
        name: 'Gym Day 2 — Deadlift & Accessories',
        exerciseIds: [
          'barbell_deadlift',
          'lat_pulldown',
          'incline_barbell_press',
          'leg_press',
          'tricep_pushdown',
        ],
      ),
      ProgramDay(
        name: 'Home Day 2 — Dumbbell & Bodyweight',
        exerciseIds: [
          'pull_up',
          'dumbbell_bench_press',
          'walking_lunge',
          'dumbbell_curl',
          'ab_wheel',
        ],
      ),
    ],
  ),

  // ─── 8. Quick 30-Minute 3× / week ───────────────────────────────────────────
  ProgramTemplate(
    id: 'quick_30min',
    name: 'Quick 30-Minute 3×/Week',
    description:
        'A time-efficient three-day program using five exercises per session, designed to be completed in 30 minutes or less while still covering all major muscle groups.',
    daysPerWeek: 3,
    equipment: 'full_gym',
    experience: 'beginner',
    days: [
      ProgramDay(
        // Use barbell variants at the gym, dumbbell variants at home
        name: 'Day 1 — Chest, Back & Biceps',
        exerciseIds: [
          'barbell_bench_press', // swap: dumbbell_bench_press
          'barbell_row', // swap: dumbbell_row
          'overhead_press',
          'barbell_curl',
          'plank',
        ],
      ),
      ProgramDay(
        name: 'Day 2 — Legs & Shoulders',
        exerciseIds: [
          'barbell_squat', // swap: goblet_squat
          'romanian_deadlift',
          'lat_pulldown',
          'lateral_raises',
          'ab_wheel',
        ],
      ),
      ProgramDay(
        name: 'Day 3 — Full Body & Core',
        exerciseIds: [
          'barbell_bench_press', // swap: dumbbell_bench_press
          'barbell_row', // swap: dumbbell_row
          'barbell_squat', // swap: goblet_squat
          'tricep_pushdown',
          'russian_twist',
        ],
      ),
    ],
  ),
];
