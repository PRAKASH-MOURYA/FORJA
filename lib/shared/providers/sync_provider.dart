import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/workout_repository.dart';
import '../repositories/checkin_repository.dart';
import '../services/hive_service.dart';
import 'workout_provider.dart' show workoutRepositoryProvider;

// --- State ---

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncAt,
    this.lastError,
  });

  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncAt;
  final String? lastError;

  SyncState copyWith({
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSyncAt,
    String? lastError,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: lastError,
    );
  }
}

// --- Providers ---

final checkInRepositoryProvider = Provider((ref) => CheckInRepository());

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(
    ref.read(workoutRepositoryProvider),
    ref.read(checkInRepositoryProvider),
  );
});

// --- Notifier ---

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier(this._workoutRepo, this._checkInRepo) : super(const SyncState()) {
    _refreshPendingCount();
    _listenConnectivity();
  }

  final WorkoutRepository _workoutRepo;
  final CheckInRepository _checkInRepo;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  void _refreshPendingCount() {
    final count = _workoutRepo.getPending().length +
        _workoutRepo.getPendingSetLogs().length +
        _checkInRepo.getPending().length;
    state = state.copyWith(pendingCount: count);
  }

  void _listenConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline && !state.isSyncing) {
        retryFailed().then((_) => syncPending());
      }
    });
  }

  Future<void> retryFailed() async {
    // Reset failed workout logs
    final failedLogs = _workoutRepo.getAll()
        .where((w) => w.syncStatus == 'failed')
        .toList();
    for (final log in failedLogs) {
      await _workoutRepo.save(log.copyWith(syncStatus: 'pending'));
    }

    // Reset failed set logs
    final failedSets = HiveService.setLogs.values
        .where((s) => s.syncStatus == 'failed')
        .toList();
    for (final set in failedSets) {
      await _workoutRepo.saveSet(set.copyWith(syncStatus: 'pending'));
    }

    // Reset failed check-ins
    final failedCheckIns = _checkInRepo.getAll()
        .where((c) => c.syncStatus == 'failed')
        .toList();
    for (final ci in failedCheckIns) {
      await _checkInRepo.save(ci.copyWith(syncStatus: 'pending'));
    }

    _refreshPendingCount();
  }

  Future<void> syncPending() async {
    if (state.isSyncing) return;
    
    final count = _workoutRepo.getPending().length +
        _workoutRepo.getPendingSetLogs().length +
        _checkInRepo.getPending().length;
    if (count == 0) return;

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return; // guest mode — skip sync

    state = state.copyWith(isSyncing: true, lastError: null);

    try {
      await _syncWorkoutLogs(supabase);
      await _syncSetLogs(supabase);
      await _syncCheckIns(supabase);

      _refreshPendingCount();
      state = state.copyWith(isSyncing: false, lastSyncAt: DateTime.now());
    } catch (e) {
      _refreshPendingCount();
      state = state.copyWith(isSyncing: false, lastError: e.toString());
    }
  }

  Future<void> _syncWorkoutLogs(SupabaseClient supabase) async {
    final pending = _workoutRepo.getPending();
    for (final log in pending) {
      try {
        await supabase.from('workout_logs').upsert({
          'id': log.id,
          'user_id': log.userId,
          'program_day_name': log.programDayName,
          'started_at': log.startedAt.toIso8601String(),
          'completed_at': log.completedAt?.toIso8601String(),
          'total_volume_kg': log.totalVolumeKg,
          'total_sets': log.totalSets,
          'duration_seconds': log.durationSeconds,
          'readiness_score': log.readinessScore,
        });
        await _workoutRepo.save(log.copyWith(syncStatus: 'synced'));
      } catch (_) {
        await _workoutRepo.save(log.copyWith(syncStatus: 'failed'));
      }
    }
  }

  Future<void> _syncSetLogs(SupabaseClient supabase) async {
    final pending = _workoutRepo.getPendingSetLogs();
    for (final set in pending) {
      try {
        await supabase.from('set_logs').upsert({
          'id': set.id,
          'workout_log_id': set.workoutLogId,
          'exercise_id': set.exerciseId,
          'set_number': set.setNumber,
          'weight_kg': set.weightKg,
          'reps': set.reps,
          'completed': set.completed,
          'failed': set.failed,
          'skipped': set.skipped,
        });
        await _workoutRepo.saveSet(set.copyWith(syncStatus: 'synced'));
      } catch (_) {
        await _workoutRepo.saveSet(set.copyWith(syncStatus: 'failed'));
      }
    }
  }

  Future<void> _syncCheckIns(SupabaseClient supabase) async {
    final pending = _checkInRepo.getPending();
    for (final checkIn in pending) {
      try {
        await supabase.from('check_ins').upsert({
          'id': checkIn.id,
          'user_id': checkIn.userId,
          'workout_log_id': checkIn.workoutLogId,
          'energy': checkIn.energy,
          'soreness': checkIn.soreness,
          'mood': checkIn.mood,
          'sleep_hours': checkIn.sleepHours,
          'stress': checkIn.stress,
        });
        await _checkInRepo.save(checkIn.copyWith(syncStatus: 'synced'));
      } catch (_) {
        await _checkInRepo.save(checkIn.copyWith(syncStatus: 'failed'));
      }
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
