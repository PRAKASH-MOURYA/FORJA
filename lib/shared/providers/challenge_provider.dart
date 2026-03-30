import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/challenge.dart';

final challengeNotifierProvider =
    StateNotifierProvider<ChallengeNotifier, List<Challenge>>((ref) {
  return ChallengeNotifier();
});

final challengeListProvider = Provider<List<Challenge>>((ref) {
  return ref.watch(challengeNotifierProvider);
});

class ChallengeNotifier extends StateNotifier<List<Challenge>> {
  ChallengeNotifier() : super(const []);

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loadMyChallenges() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      state = const [];
      return;
    }

    final rows = await _supabase
        .from('challenge_participants')
        .select('challenge_id')
        .eq('user_id', uid) as List<dynamic>;
    final ids = rows
        .map((r) => (r as Map<String, dynamic>)['challenge_id']?.toString())
        .whereType<String>()
        .toList();

    if (ids.isEmpty) {
      state = const [];
      return;
    }

    final challengeRows = await _supabase
        .from('challenges')
        .select()
        .inFilter('id', ids)
        .order('created_at', ascending: false) as List<dynamic>;

    state = challengeRows
        .map((row) => _mapChallenge(row as Map<String, dynamic>))
        .toList();
  }

  Future<Challenge> create(String type) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('User must be authenticated to create a challenge');
    }
    final today = DateTime.now();
    final endDate = today.add(_durationForType(type));
    final inserted = await _supabase
        .from('challenges')
        .insert({
          'creator_id': uid,
          'type': type,
          'start_date': _isoDate(today),
          'end_date': _isoDate(endDate),
        })
        .select()
        .single();

    await _supabase.from('challenge_participants').insert({
      'challenge_id': inserted['id'],
      'user_id': uid,
    });

    final challenge = _mapChallenge(inserted);
    state = [challenge, ...state];
    return challenge;
  }

  Future<Challenge> join(String inviteCode) async {
    if (_supabase.auth.currentUser?.id == null) {
      throw StateError('User must be authenticated to join a challenge');
    }

    final result = await _supabase.rpc(
      'join_challenge_by_invite_code',
      params: {'p_invite_code': inviteCode},
    ) as List<dynamic>;
    if (result.isEmpty) {
      throw StateError('Invalid or expired invite link');
    }
    final challenge = _mapChallenge(result.first as Map<String, dynamic>);
    final hasAlready = state.any((c) => c.id == challenge.id);
    if (!hasAlready) {
      state = [challenge, ...state];
    }
    return challenge;
  }

  Future<Challenge?> getByInviteCode(String inviteCode) async {
    final result = await _supabase.rpc(
      'get_challenge_by_invite_code',
      params: {'p_invite_code': inviteCode},
    ) as List<dynamic>;
    if (result.isEmpty) return null;
    return _mapChallenge(result.first as Map<String, dynamic>);
  }

  Future<Map<String, double>> leaderboard(String challengeId) async {
    final rows = await _supabase.rpc(
      'challenge_leaderboard',
      params: {'p_challenge_id': challengeId},
    ) as List<dynamic>;

    final entries = rows.map((row) {
      final map = row as Map<String, dynamic>;
      return MapEntry(
        map['user_id'].toString(),
        (map['total_volume'] as num).toDouble(),
      );
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {for (final entry in entries) entry.key: entry.value};
  }

  Challenge _mapChallenge(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'].toString(),
      creatorId: json['creator_id'].toString(),
      type: json['type'].toString(),
      startDate: DateTime.parse(json['start_date'].toString()),
      endDate: DateTime.parse(json['end_date'].toString()),
      inviteCode: json['invite_code'].toString(),
    );
  }

  Duration _durationForType(String type) {
    switch (type) {
      case 'consistency':
        return const Duration(days: 14);
      case '30_day':
        return const Duration(days: 30);
      case 'volume_battle':
      default:
        return const Duration(days: 7);
    }
  }

  String _isoDate(DateTime value) => value.toIso8601String().split('T').first;
}
