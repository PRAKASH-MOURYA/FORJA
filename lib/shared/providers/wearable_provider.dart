import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import '../services/wearable_service.dart';
import '../models/wearable_snapshot.dart';

// Health instance per service — NOT a global singleton
final wearableServiceProvider = Provider<WearableService>((ref) {
  final health = Health();
  return WearableService(health);
});

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
