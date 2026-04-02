import '../../app/theme.dart';
import '../../shared/models/workout_log.dart';
import 'package:flutter/material.dart';

/// Classification for a single cell in the consistency heatmap.
enum CellState { workout, missed, neutral }

/// Classify a single calendar day for the consistency grid.
///
/// - [workout]: A WorkoutLog exists with startedAt on this date.
/// - [missed]: The user's split assigned a workout to this weekday (via
///   [weekdayMap]) but no WorkoutLog was recorded.
/// - [neutral]: Rest day, future date, or no split data to determine if missed.
CellState classifyDay(
    DateTime date, List<WorkoutLog> logs, Map<int, int>? weekdayMap) {
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);

  // Future dates are always neutral
  if (dateOnly.isAfter(todayOnly)) return CellState.neutral;

  // Check if a workout was logged on this date
  final hasLog = logs.any((log) {
    final logDate = log.startedAt.toLocal();
    return logDate.year == date.year &&
        logDate.month == date.month &&
        logDate.day == date.day;
  });
  if (hasLog) return CellState.workout;

  // If the user has a weekday map and this weekday is assigned, it's missed
  if (weekdayMap != null && weekdayMap.containsKey(date.weekday)) {
    return CellState.missed;
  }

  return CellState.neutral;
}

/// Compute a volume delta label comparing this week to last week.
///
/// Returns e.g. `'↑ 12%'` or `'↓ 8%'`, or `null` if last week had no volume.
String? volumeDeltaLabel(
    List<WorkoutLog> thisWeek, List<WorkoutLog> lastWeek) {
  double sum(List<WorkoutLog> logs) =>
      logs.fold(0.0, (acc, w) => acc + w.totalVolumeKg);
  final thisSum = sum(thisWeek);
  final lastSum = sum(lastWeek);
  if (lastSum == 0) return null;
  final pct = ((thisSum - lastSum) / lastSum * 100).round();
  return pct >= 0 ? '↑ $pct%' : '↓ ${pct.abs()}%';
}

/// Determine the color of a strength trend line based on the slope of the
/// last two data points.
///
/// - Positive slope → green (positive trend)
/// - Negative slope → red (danger)
/// - Insufficient data or flat → neutral (accent)
Color trendColor(List<double> data) {
  if (data.length < 2) return AppColors.accent;
  final slope = data.last - data[data.length - 2];
  if (slope > 0) return AppColors.positive;
  if (slope < 0) return AppColors.danger;
  return AppColors.accent;
}
