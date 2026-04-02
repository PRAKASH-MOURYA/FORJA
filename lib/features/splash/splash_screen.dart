import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _wordmarkCtrl;
  late AnimationController _taglineCtrl;
  late AnimationController _underlineCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _wordmarkFade;
  late Animation<Offset> _wordmarkSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _underlineWidth;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _wordmarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _underlineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _wordmarkFade = CurvedAnimation(parent: _wordmarkCtrl, curve: Curves.easeOut);
    _wordmarkSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _wordmarkCtrl, curve: Curves.easeOutCubic));
    _taglineFade = CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut);
    _underlineWidth = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _underlineCtrl, curve: Curves.easeOutCubic),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _wordmarkCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _taglineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _underlineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    await _exitCtrl.forward();

    if (mounted) context.go('/today');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _wordmarkCtrl.dispose();
    _taglineCtrl.dispose();
    _underlineCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _exitFade,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bg, AppColors.bgElevated],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Radial glow behind logo
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo icon
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                          boxShadow: AppColors.indigoGlow,
                        ),
                        child: const Center(
                          child: Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // FORJA wordmark
                  SlideTransition(
                    position: _wordmarkSlide,
                    child: FadeTransition(
                      opacity: _wordmarkFade,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.heroGradient.createShader(bounds),
                            child: Text(
                              'FORJA',
                              style: AppTextStyles.hero(Colors.white).copyWith(
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Animated underline
                          AnimatedBuilder(
                            animation: _underlineWidth,
                            builder: (context, _) => Container(
                              width: 160 * _underlineWidth.value,
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Tagline
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      'YOUR INTELLIGENT TRAINING COMPANION',
                      style: AppTextStyles.micro(AppColors.textTertiary)
                          .copyWith(letterSpacing: 4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
