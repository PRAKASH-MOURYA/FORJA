import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/forja_button.dart';
import '../../app/theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();
      final authService = ref.read(authServiceProvider);

      if (_isSignUp) {
        await authService.signUp(email: email, password: password, name: name);
      } else {
        await authService.signIn(email: email, password: password);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Radial ambient glow at top
          Positioned(
            top: -100,
            left: -80,
            right: -80,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.75,
                  colors: [
                    Color(0x1A6EE7B7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.hero),

                  // Logo mark
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppColors.accentShadow,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'F',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.bg,
                        ),
                      ),
                    ).animate().scale(
                          begin: const Offset(0.7, 0.7),
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.heroGradient.createShader(bounds),
                    child: const Text(
                      'FORJA',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .slideY(begin: -0.08, end: 0, delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    _isSignUp
                        ? 'Create an account to save your progress'
                        : 'Welcome back, ready to train?',
                    style: AppTextStyles.body(AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxxl + AppSpacing.md),

                  // Error banner
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      decoration: BoxDecoration(
                        color: AppColors.coralDim,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.coral.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.coral, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.body(AppColors.coral),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

                  // Fields
                  if (_isSignUp) ...[
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      delay: 300,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    delay: _isSignUp ? 360 : 300,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    delay: _isSignUp ? 420 : 360,
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  ForjaButton(
                    label: _isSignUp ? 'Sign Up' : 'Sign In',
                    onPressed: _submit,
                    isLoading: _isLoading,
                  ).animate().fadeIn(delay: 420.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : 'Need an account? Sign Up',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.5,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, AppColors.border],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Text(
                          'OR',
                          style: AppTextStyles.micro(AppColors.textTertiary),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.border, Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  ForjaButton.secondary(
                    label: 'Continue as Guest',
                    onPressed: () {
                      ref.read(isGuestProvider.notifier).state = true;
                    },
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int delay = 300,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.body(AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body(AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.cozy + 2,
        ),
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 350.ms,
        );
  }
}
