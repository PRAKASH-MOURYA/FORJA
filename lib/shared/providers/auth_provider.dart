import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../services/auth_service.dart';

// Provides the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stream provider for listening to authentication state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider for the current user session
final currentUserSessionProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user;
});

// Provider for tracking guest mode (local only)
final isGuestProvider = StateProvider<bool>((ref) => false);

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return UserProfileNotifier(repo);
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final ProfileRepository _repo;

  UserProfileNotifier(this._repo) : super(null) {
    _load();
  }

  void _load() {
    state = _repo.get();
  }

  Future<void> save(UserProfile profile) async {
    await _repo.save(profile);
    state = profile;
  }

  Future<void> update(UserProfile Function(UserProfile) updater) async {
    final current = state;
    if (current == null) return;
    final updated = updater(current);
    await _repo.save(updated);
    state = updated;
  }

  Future<void> clear() async {
    await _repo.delete();
    state = null;
  }

  bool get isOnboardingComplete => state?.onboardingComplete ?? false;
}
