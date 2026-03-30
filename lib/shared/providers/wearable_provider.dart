import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import '../services/wearable_service.dart';
import '../models/wearable_snapshot.dart';

// Global Health instance — CRITICAL: Health() is no longer a factory in v12+
final _health = Health();

final wearableServiceProvider = Provider<WearableService>((ref) => WearableService(_health));

/// Fetches wearable data once per day. Returns null if permission denied or no data.
final wearableProvider = FutureProvider<WearableSnapshot?>((ref) async {
  final service = ref.read(wearableServiceProvider);
  return service.fetchSnapshot();
});

/// True when permission was denied (to show nudge card)
final wearablePermissionDeniedProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(wearableServiceProvider);
  final granted = await service.requestPermission();
  return !granted;
});
