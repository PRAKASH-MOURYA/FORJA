import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/forja_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Ambient radial glow at bottom
          Positioned(
            bottom: -80,
            left: -60,
            right: -60,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Color(0x226EE7B7),
                    Color(0x003B82F6),
                  ],
                ),
              ),
            ),
          ),
          // Top ambient tint
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x0A6EE7B7), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // Logo mark
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: AppColors.accentShadow,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'F',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bg,
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // FORJA title
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.heroGradient.createShader(bounds),
                    child: Text(
                      'FORJA',
                      style: AppTextStyles.hero(Colors.white),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        delay: 300.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: AppSpacing.lg),

                  // Headline
                  Text(
                    'Forge a stronger\nversion of yourself.',
                    style: AppTextStyles.headingLarge(AppColors.textPrimary),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        delay: 500.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: AppSpacing.lg),

                  // Subheading
                  Text(
                    'A smart training companion that removes decision fatigue — just open the app and train.',
                    style: AppTextStyles.body(AppColors.textSecondary),
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 500.ms),

                  const Spacer(),

                  // CTA
                  ForjaButton(
                    label: 'Get Started',
                    onPressed: () => context.go('/quiz'),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 800.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
