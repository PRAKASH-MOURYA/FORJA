import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/providers/challenge_provider.dart';
import '../../shared/widgets/forja_button.dart';

class ChallengeInviteScreen extends ConsumerStatefulWidget {
  const ChallengeInviteScreen({super.key, required this.inviteCode});

  final String inviteCode;

  @override
  ConsumerState<ChallengeInviteScreen> createState() =>
      _ChallengeInviteScreenState();
}

class _ChallengeInviteScreenState extends ConsumerState<ChallengeInviteScreen> {
  bool _joining = false;
  String? _error;
  Future<String?>? _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Join Challenge')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You've been invited to a FORJA challenge!",
              style: AppTextStyles.headingLarge(AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<String?>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Loading challenge details...',
                    style: AppTextStyles.body(AppColors.textSecondary),
                  );
                }
                if (snapshot.data == null) {
                  return Text(
                    'Invalid or expired invite link',
                    style: AppTextStyles.body(AppColors.coral),
                  );
                }
                return Text(
                  snapshot.data!,
                  style: AppTextStyles.body(AppColors.textSecondary),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  _error!,
                  style: AppTextStyles.body(AppColors.coral),
                ),
              ),
            ForjaButton(
              label: 'Join Challenge',
              isLoading: _joining,
              onPressed: _join,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _join() async {
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      await ref.read(challengeNotifierProvider.notifier).join(widget.inviteCode);
      if (!mounted) return;
      context.go('/challenges');
    } catch (_) {
      setState(() {
        _error = 'Invalid or expired invite link';
        _joining = false;
      });
    }
  }

  Future<String?> _loadDetails() async {
    final challenge =
        await ref.read(challengeNotifierProvider.notifier).getByInviteCode(
              widget.inviteCode,
            );
    if (challenge == null) return null;

    final typeLabel = () {
      switch (challenge.type) {
        case 'consistency':
          return 'Consistency';
        case '30_day':
          return '30-Day Challenge';
        default:
          return 'Volume Battle';
      }
    }();
    final start = _date(challenge.startDate);
    final end = _date(challenge.endDate);
    return '$typeLabel • $start to $end';
  }

  String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
