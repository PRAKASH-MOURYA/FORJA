import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Shows a confetti-style celebration overlay for 2.5 seconds.
void showCelebrationOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _CelebrationWidget(
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _CelebrationWidget extends StatefulWidget {
  final VoidCallback onDismiss;
  const _CelebrationWidget({required this.onDismiss});

  @override
  State<_CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<_CelebrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
    _ctrl.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            ...List.generate(24, (i) => _ConfettiDot(index: i, ctrl: _ctrl)),
            Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  final t = _ctrl.value;
                  return Opacity(
                    opacity: (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.5 + t * 0.5,
                      child: const Text('🏆', style: TextStyle(fontSize: 72)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  final int index;
  final AnimationController ctrl;

  const _ConfettiDot({required this.index, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final angle = (index / 24) * 2 * math.pi;
    final colors = [AppColors.accent, AppColors.warm, AppColors.coral, AppColors.sky];
    final color = colors[index % colors.length];
    final size = 6.0 + (index % 4) * 2.0;
    final spread = 0.5 + 0.5 * (index % 3);

    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        final t = ctrl.value;
        final r = t * 180.0 * spread;
        final dx = r * math.cos(angle);
        final dy = r * math.sin(angle) - t * 60;
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + dx - size / 2,
          top: MediaQuery.of(context).size.height / 2 + dy - size / 2,
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: index.isEven ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: index.isOdd ? BorderRadius.circular(2) : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
