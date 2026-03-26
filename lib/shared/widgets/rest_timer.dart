import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import 'forja_card.dart';

class RestTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const RestTimer({
    super.key,
    this.totalSeconds = 90,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;
    _start();
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        _tryVibrate();
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _tryVibrate() {
    try {
      // vibration package — wrapped in try/catch for emulator safety
      // Vibration.vibrate(duration: 500);
    } catch (_) {}
  }

  String _format(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remaining / widget.totalSeconds;

    return ForjaCard(
      child: Column(
        children: [
          Text('REST TIMER',
              style: AppTextStyles.labelUppercase(AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(_format(_remaining),
                  style: AppTextStyles.dataLarge(AppColors.warm))
              .animate()
              .fadeIn(duration: 200.ms),
          const SizedBox(height: 4),
          Text('of ${_format(widget.totalSeconds)}',
              style: AppTextStyles.body(AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.bgElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.warm),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              widget.onSkip();
            },
            child: const Text('Skip rest',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
