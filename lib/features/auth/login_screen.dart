import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  bool _rememberMe = false;

  late AnimationController _starAnimationController;
  late AnimationController _planetAnimationController;

  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _planetAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _starAnimationController.dispose();
    _planetAnimationController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    // Simulate login process
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Navigate to main app after successful login
    context.go('/planet');
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.gray400),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppTheme.spaceDeep.withOpacity(0.8),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.cosmicBlue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.energyGreen, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.dangerRed),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.dangerRed),
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Cosmic welcome message
                  _buildWelcomeSection(),

                  const SizedBox(height: 50),

                  // Login form
                  _buildLoginForm(),

                  const SizedBox(height: 32),

                  // Social login options
                  _buildSocialLogin(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            AppTheme.nebulaPurple,
            AppTheme.spaceDark,
            AppTheme.spaceDeep,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating stars
          ...List.generate(25, (index) {
            final double size = (index % 3) == 0
                ? 6
                : (index % 2) == 0
                ? 4
                : 3;
            final Color starColor = index % 4 == 0
                ? AppTheme.energyGreen
                : index % 3 == 0
                ? AppTheme.cosmicBlue
                : AppTheme.starYellow;

            return AnimatedBuilder(
              animation: _starAnimationController,
              builder: (context, child) {
                final double speedMultiplier = (index % 3) + 1;
                final double horizontalMovement =
                    (_starAnimationController.value * 60 * speedMultiplier) %
                    MediaQuery.of(context).size.width;
                final double verticalOffset =
                    Math.sin(
                      _starAnimationController.value * 2 * Math.pi + index,
                    ) *
                    10;

                return Positioned(
                  left:
                      (index * 43.0 + horizontalMovement) %
                      MediaQuery.of(context).size.width,
                  top:
                      ((index * 67.0) % MediaQuery.of(context).size.height) +
                      verticalOffset,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: starColor.withOpacity(
                        0.4 +
                            0.6 *
                                ((index + _starAnimationController.value * 2) %
                                    1),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: starColor.withOpacity(0.6),
                          blurRadius: size,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // Floating planet
          AnimatedBuilder(
            animation: _planetAnimationController,
            builder: (context, child) {
              return Positioned(
                right: -50 + (_planetAnimationController.value * 30),
                top: 100 + (_planetAnimationController.value * 20),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.cosmicBlue.withOpacity(0.3),
                        AppTheme.energyGreen.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🌍', style: TextStyle(fontSize: 60)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cosmic greeting
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.energyGreen.withOpacity(0.2),
                AppTheme.cosmicBlue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.energyGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚀', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Welcome back, Trader!',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.energyGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ).animate().slideX(begin: -0.3, duration: 600.ms),

        const SizedBox(height: 16),

        Text(
          'Ready to conquer\nthe cosmos?',
          style: AppTheme.heading1.copyWith(height: 1.1),
        ).animate().slideY(begin: 0.3, duration: 700.ms),

        const SizedBox(height: 12),

        Text(
          'Log in to continue your cosmic trading journey',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.gray400),
        ).animate().slideY(begin: 0.3, duration: 800.ms),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTheme.bodyMedium,
            decoration: _inputDecoration(
              'Email or Username',
              Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email or username is required';
              }
              return null;
            },
          ).animate().slideX(begin: -0.3, duration: 600.ms, delay: 200.ms),

          const SizedBox(height: 20),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: AppTheme.bodyMedium,
            decoration: _inputDecoration(
              'Password',
              Icons.lock_outline,
              suffix: IconButton(
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.gray400,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ).animate().slideX(begin: 0.3, duration: 600.ms, delay: 300.ms),

          const SizedBox(height: 20),

          // Remember me and forgot password
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _rememberMe
                            ? AppTheme.energyGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: _rememberMe
                              ? AppTheme.energyGreen
                              : AppTheme.gray500,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _rememberMe
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: AppTheme.spaceDark,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.gray400,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () {
                  // TODO: Implement forgot password
                },
                child: Text(
                  'Forgot password?',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.cosmicBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

          const SizedBox(height: 32),

          // Login button
          GestureDetector(
            onTap: _isSubmitting ? null : _onLogin,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.energyGreen, AppTheme.cosmicBlue],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.energyGreen.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.spaceDark,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🚀', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Text(
                            'Launch into Trading',
                            style: AppTheme.heading3.copyWith(
                              color: AppTheme.spaceDark,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ).animate().scale(
            duration: 700.ms,
            delay: 500.ms,
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 28),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to the cosmos? ',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              GestureDetector(
                onTap: () => context.go('/register'),
                child: Text(
                  'Create account',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.energyGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.gray600.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.gray600.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Practice mode button
        GestureDetector(
          onTap: () => context.go('/practice'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.spaceDeep.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.starYellow.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎮', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'Try Practice Mode',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.starYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.3, duration: 900.ms),
      ],
    );
  }
}
