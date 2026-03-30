import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';
import '../../shared/providers/challenge_provider.dart';
import '../../shared/widgets/forja_card.dart';

class ChallengeScreen extends ConsumerStatefulWidget {
  const ChallengeScreen({super.key});

  @override
  ConsumerState<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(challengeNotifierProvider.notifier).loadMyChallenges(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenges = ref.watch(challengeListProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            onPressed: () => _showTypePicker(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.read(challengeNotifierProvider.notifier).loadMyChallenges(),
        child: challenges.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      'No challenges yet. Tap + to start one.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: challenges.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
                  return InkWell(
                    onTap: () => _showLeaderboard(challenge.id),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: ForjaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _labelForType(challenge.type),
                            style: AppTextStyles.heading(AppColors.textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${_date(challenge.startDate)} - ${_date(challenge.endDate)}',
                            style: AppTextStyles.body(AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Invite: ${challenge.inviteCode}',
                            style: AppTextStyles.caption(AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showTypePicker(BuildContext context) async {
    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypeTile(type: 'volume_battle', label: 'Volume Battle'),
            _TypeTile(type: 'consistency', label: 'Consistency'),
            _TypeTile(type: '30_day', label: '30-Day Challenge'),
          ],
        ),
      ),
    );

    if (type == null || !mounted) return;
    final challenge = await ref.read(challengeNotifierProvider.notifier).create(type);
    await SharePlus.instance.share(
      ShareParams(
        text: 'Join my FORJA challenge! forja://challenge/${challenge.inviteCode}',
      ),
    );
  }

  Future<void> _showLeaderboard(String challengeId) async {
    final leaderboard =
        await ref.read(challengeNotifierProvider.notifier).leaderboard(challengeId);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text(
          'Leaderboard',
          style: AppTextStyles.heading(AppColors.textPrimary),
        ),
        content: leaderboard.isEmpty
            ? Text(
                'No volume logged yet.',
                style: AppTextStyles.body(AppColors.textSecondary),
              )
            : SizedBox(
                width: 320,
                child: ListView(
                  shrinkWrap: true,
                  children: leaderboard.entries.map((entry) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        entry.key,
                        style: AppTextStyles.bodyStrong(AppColors.textPrimary),
                      ),
                      trailing: Text(
                        '${entry.value.toStringAsFixed(1)} kg',
                        style: AppTextStyles.body(AppColors.textSecondary),
                      ),
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _labelForType(String type) {
    switch (type) {
      case 'consistency':
        return 'Consistency';
      case '30_day':
        return '30-Day Challenge';
      default:
        return 'Volume Battle';
    }
  }

  String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type, required this.label});

  final String type;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: AppTextStyles.bodyStrong(AppColors.textPrimary)),
      onTap: () => Navigator.pop(context, type),
    );
  }
}
