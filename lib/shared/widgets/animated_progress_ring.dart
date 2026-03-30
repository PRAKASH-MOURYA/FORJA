import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/theme.dart';

enum ProgressRingSize { sm, md, lg }

class AnimatedProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Widget? center;
  final ProgressRingSize size;
  final Gradient? progressGradient;
  final Color? trackColor;
  final bool pulseAtComplete;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.center,
    this.size = ProgressRingSize.md,
    this.progressGradient,
    this.trackColor,
    this.pulseAtComplete = true,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController.forward();
    if (widget.progress >= 1.0 && widget.pulseAtComplete) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedProgressRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _progressAnim = Tween<double>(
        begin: old.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController
        ..reset()
        ..forward();
      if (widget.progress >= 1.0 && widget.pulseAtComplete) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double get _diameter {
    switch (widget.size) {
      case ProgressRingSize.sm:
        return 64;
      case ProgressRingSize.md:
        return 120;
      case ProgressRingSize.lg:
        return 200;
    }
  }

  double get _strokeWidth {
    switch (widget.size) {
      case ProgressRingSize.sm:
        return 5;
      case ProgressRingSize.md:
        return 8;
      case ProgressRingSize.lg:
        return 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = widget.trackColor ??
        (isDark ? AppColors.bgElevated : AppColors.bgElevatedLight);

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnim, _pulseAnim]),
      builder: (context, _) {
        return Transform.scale(
          scale: widget.progress >= 1.0 ? _pulseAnim.value : 1.0,
          child: SizedBox(
            width: _diameter,
            height: _diameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(_diameter, _diameter),
                  painter: _RingPainter(
                    progress: _progressAnim.value,
                    strokeWidth: _strokeWidth,
                    trackColor: trackColor,
                    gradient: widget.progressGradient ?? AppColors.accentGradient,
                    diameter: _diameter,
                  ),
                ),
                if (widget.center != null) widget.center!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Gradient gradient;
  final double diameter;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.gradient,
    required this.diameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress arc with gradient
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
