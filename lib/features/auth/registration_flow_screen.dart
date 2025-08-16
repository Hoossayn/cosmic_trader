import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({super.key});

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Focus nodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Focus states
  bool _emailHasFocus = false;
  bool _usernameHasFocus = false;
  bool _passwordHasFocus = false;
  bool _confirmPasswordHasFocus = false;

  // Validation states
  bool _isEmailValid = false;
  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Animation controllers
  late AnimationController _starAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _stepAnimationController;

  @override
  void initState() {
    super.initState();

    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Focus listeners
    _setupFocusListeners();

    // Text change listeners
    _setupTextListeners();
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() => _emailHasFocus = _emailFocusNode.hasFocus);
    });

    _usernameFocusNode.addListener(() {
      setState(() => _usernameHasFocus = _usernameFocusNode.hasFocus);
    });

    _passwordFocusNode.addListener(() {
      setState(() => _passwordHasFocus = _passwordFocusNode.hasFocus);
    });

    _confirmPasswordFocusNode.addListener(() {
      setState(
        () => _confirmPasswordHasFocus = _confirmPasswordFocusNode.hasFocus,
      );
    });
  }

  void _setupTextListeners() {
    _emailController.addListener(() {
      setState(() {
        _isEmailValid = _validateEmail(_emailController.text);
      });
    });

    _usernameController.addListener(() {
      setState(() {
        _isUsernameValid = _validateUsername(_usernameController.text);
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _isPasswordValid = _validatePassword(_passwordController.text);
        _isConfirmPasswordValid = _validateConfirmPassword(
          _passwordController.text,
          _confirmPasswordController.text,
        );
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        _isConfirmPasswordValid = _validateConfirmPassword(
          _passwordController.text,
          _confirmPasswordController.text,
        );
      });
    });
  }

  bool _validateEmail(String email) {
    return email.isNotEmpty && email.contains('@') && email.contains('.');
  }

  bool _validateUsername(String username) {
    return username.isNotEmpty && username.length >= 3;
  }

  bool _validatePassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  bool _validateConfirmPassword(String password, String confirmPassword) {
    return confirmPassword.isNotEmpty && password == confirmPassword;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _starAnimationController.dispose();
    _progressAnimationController.dispose();
    _stepAnimationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressAnimationController.animateTo((_currentStep + 1) / _totalSteps);
      _stepAnimationController.forward().then((_) {
        _stepAnimationController.reset();
      });
    } else {
      _completeRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressAnimationController.animateTo((_currentStep + 1) / _totalSteps);
    }
  }

  Future<void> _completeRegistration() async {
    // Simulate registration process
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    context.go('/planet');
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _isEmailValid;
      case 1:
        return _isUsernameValid;
      case 2:
        return _isPasswordValid && _isConfirmPasswordValid;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),

                // Main content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildEmailStep(),
                      _buildUsernameStep(),
                      _buildPasswordStep(),
                    ],
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.nebulaPurple,
            AppTheme.spaceDark,
            AppTheme.spaceDeep,
            AppTheme.cosmicBlue,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Floating stars
          ...List.generate(20, (index) {
            final double size = (index % 4) == 0
                ? 5
                : (index % 3) == 0
                ? 3
                : 2;
            final Color starColor = index % 5 == 0
                ? AppTheme.energyGreen
                : index % 3 == 0
                ? AppTheme.starYellow
                : AppTheme.cosmicBlue;

            return AnimatedBuilder(
              animation: _starAnimationController,
              builder: (context, child) {
                final double speedMultiplier = (index % 3) + 1;
                final double horizontalMovement =
                    (_starAnimationController.value * 40 * speedMultiplier) %
                    MediaQuery.of(context).size.width;
                final double verticalOffset =
                    Math.sin(
                      _starAnimationController.value * 2 * Math.pi + index,
                    ) *
                    8;

                return Positioned(
                  left:
                      (index * 41.0 + horizontalMovement) %
                      MediaQuery.of(context).size.width,
                  top:
                      ((index * 59.0) % MediaQuery.of(context).size.height) +
                      verticalOffset,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: starColor.withOpacity(
                        0.3 +
                            0.7 *
                                ((index + _starAnimationController.value) % 1),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: starColor.withOpacity(0.5),
                          blurRadius: size * 2,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_totalSteps, (index) {
              final bool isCompleted = index < _currentStep;
              final bool isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: isCompleted || isCurrent
                                ? [AppTheme.energyGreen, AppTheme.cosmicBlue]
                                : [
                                    AppTheme.gray600.withOpacity(0.3),
                                    AppTheme.gray500.withOpacity(0.3),
                                  ],
                          ),
                          boxShadow: isCompleted || isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppTheme.energyGreen.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    if (index < _totalSteps - 1) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Email', 0),
              _buildStepLabel('Username', 1),
              _buildStepLabel('Password', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int stepIndex) {
    final bool isCompleted = stepIndex < _currentStep;
    final bool isCurrent = stepIndex == _currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppTheme.energyGreen.withOpacity(0.2)
            : isCompleted
            ? AppTheme.cosmicBlue.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? AppTheme.energyGreen
              : isCompleted
              ? AppTheme.cosmicBlue
              : AppTheme.gray600.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            Icon(Icons.check_circle, size: 16, color: AppTheme.cosmicBlue)
          else if (isCurrent)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.energyGreen,
                shape: BoxShape.circle,
              ),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.gray600.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isCurrent
                  ? AppTheme.energyGreen
                  : isCompleted
                  ? AppTheme.cosmicBlue
                  : AppTheme.gray400,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return AnimatedBuilder(
      animation: _stepAnimationController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  200, // Account for progress indicator and navigation
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.cosmicBlue.withOpacity(0.2),
                        AppTheme.energyGreen.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.cosmicBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📧', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Step 1 of 3',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.cosmicBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().slideX(begin: -0.3, duration: 600.ms),

                const SizedBox(height: 24),

                Text(
                  'What\'s your\nemail address?',
                  style: AppTheme.heading1.copyWith(
                    height: 1.1,
                    color: AppTheme.white,
                  ),
                ).animate().slideY(begin: 0.3, duration: 700.ms),

                const SizedBox(height: 12),

                Text(
                  'We\'ll use this to keep your cosmic trading account secure.',
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.gray400),
                ).animate().slideY(begin: 0.3, duration: 800.ms),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTheme.bodyLarge,
                  decoration: _buildInputDecoration(
                    'Enter your email',
                    hasFocus: _emailHasFocus,
                    hasText: _emailController.text.isNotEmpty,
                    isValid: _isEmailValid,
                  ),
                  onChanged: (value) => setState(() {}),
                ).animate().slideY(begin: 0.4, duration: 900.ms),

                if (_emailController.text.isNotEmpty && !_isEmailValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please enter a valid email address',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.dangerRed,
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 40),

                // Fun fact
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.spaceDark.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.starYellow.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cosmic traders who verify their email earn 25% more XP in their first week!',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.starYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.3, duration: 1000.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsernameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              200, // Account for progress indicator and navigation
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.starYellow.withOpacity(0.2),
                    AppTheme.energyGreen.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.starYellow.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Step 2 of 3',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.starYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().slideX(begin: -0.3, duration: 600.ms),

            const SizedBox(height: 24),

            Text(
              'Choose your\ncosmic handle',
              style: AppTheme.heading1.copyWith(
                height: 1.1,
                color: AppTheme.white,
              ),
            ).animate().slideY(begin: 0.3, duration: 700.ms),

            const SizedBox(height: 12),

            Text(
              'This will be your unique identity in the cosmic trading universe.',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.gray400),
            ).animate().slideY(begin: 0.3, duration: 800.ms),

            const SizedBox(height: 40),

            TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              style: AppTheme.bodyLarge,
              decoration: _buildInputDecoration(
                'Enter your username',
                hasFocus: _usernameHasFocus,
                hasText: _usernameController.text.isNotEmpty,
                isValid: _isUsernameValid,
              ),
              onChanged: (value) => setState(() {}),
            ).animate().slideY(begin: 0.4, duration: 900.ms),

            if (_usernameController.text.isNotEmpty && !_isUsernameValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Username must be at least 3 characters long',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.dangerRed),
                ),
              ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 40),

            // Fun fact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.spaceDark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.energyGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Great usernames often include cosmic themes: StarTrader, NebulaKing, VoidMaster!',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.energyGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.3, duration: 1000.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              200, // Account for progress indicator and navigation
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Header
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
                border: Border.all(
                  color: AppTheme.energyGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔐', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Step 3 of 3',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.energyGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().slideX(begin: -0.3, duration: 600.ms),

            const SizedBox(height: 24),

            Text(
              'Secure your\ncosmic vault',
              style: AppTheme.heading1.copyWith(
                height: 1.1,
                color: AppTheme.white,
              ),
            ).animate().slideY(begin: 0.3, duration: 700.ms),

            const SizedBox(height: 12),

            Text(
              'Choose a strong password to protect your trading empire.',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.gray400),
            ).animate().slideY(begin: 0.3, duration: 800.ms),

            const SizedBox(height: 40),

            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: true,
              style: AppTheme.bodyLarge,
              decoration: _buildInputDecoration(
                'Enter your password',
                hasFocus: _passwordHasFocus,
                hasText: _passwordController.text.isNotEmpty,
                isValid: _isPasswordValid,
              ),
              onChanged: (value) => setState(() {}),
            ).animate().slideY(begin: 0.4, duration: 900.ms),

            const SizedBox(height: 20),

            TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              obscureText: true,
              style: AppTheme.bodyLarge,
              decoration: _buildInputDecoration(
                'Confirm your password',
                hasFocus: _confirmPasswordHasFocus,
                hasText: _confirmPasswordController.text.isNotEmpty,
                isValid: _isConfirmPasswordValid,
              ),
              onChanged: (value) => setState(() {}),
            ).animate().slideY(begin: 0.4, duration: 1000.ms),

            if (_passwordController.text.isNotEmpty && !_isPasswordValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Password must be at least 6 characters long',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.dangerRed),
                ),
              ).animate().fadeIn(duration: 300.ms),

            if (_confirmPasswordController.text.isNotEmpty &&
                !_isConfirmPasswordValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Passwords do not match',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.dangerRed),
                ),
              ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 40),

            // Fun fact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.spaceDark.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Strong passwords keep your cosmic assets safe from space pirates!',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.cosmicBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.3, duration: 1100.ms),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hint, {
    bool hasFocus = false,
    bool hasText = false,
    bool isValid = false,
  }) {
    return InputDecoration(
      hintText: (hasFocus || hasText) ? null : hint,
      filled: true,
      fillColor: AppTheme.spaceDeep.withOpacity(0.8),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid && hasText
              ? AppTheme.energyGreen.withOpacity(0.5)
              : AppTheme.cosmicBlue.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? AppTheme.energyGreen : AppTheme.cosmicBlue,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.dangerRed),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.dangerRed),
        borderRadius: BorderRadius.circular(16),
      ),
      hintStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.gray400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: _currentStep == 0
          ? _buildFullWidthContinueButton()
          : _buildButtonsWithBack(),
    );
  }

  Widget _buildFullWidthContinueButton() {
    return GestureDetector(
      onTap: _canProceed() ? _nextStep : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: _canProceed()
              ? const LinearGradient(
                  colors: [AppTheme.energyGreen, AppTheme.cosmicBlue],
                )
              : LinearGradient(
                  colors: [
                    AppTheme.gray600.withOpacity(0.5),
                    AppTheme.gray700.withOpacity(0.5),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _canProceed()
              ? [
                  BoxShadow(
                    color: AppTheme.energyGreen.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Text(
                'Continue',
                style: AppTheme.heading3.copyWith(
                  color: _canProceed() ? AppTheme.spaceDark : AppTheme.gray500,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(
      begin: 0.3,
      duration: 600.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildButtonsWithBack() {
    return Row(
      children: [
        // Animated back button
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          width: _currentStep > 0 ? 56 : 0,
          child: _currentStep > 0
              ? GestureDetector(
                      onTap: _previousStep,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.spaceDeep.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.gray600.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppTheme.gray400,
                          size: 24,
                        ),
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: -1.0,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms)
              : null,
        ),

        if (_currentStep > 0) const SizedBox(width: 16),

        // Continue button
        Expanded(
          child:
              GestureDetector(
                onTap: _canProceed() ? _nextStep : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: _canProceed()
                        ? const LinearGradient(
                            colors: [AppTheme.energyGreen, AppTheme.cosmicBlue],
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.gray600.withOpacity(0.5),
                              AppTheme.gray700.withOpacity(0.5),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _canProceed()
                        ? [
                            BoxShadow(
                              color: AppTheme.energyGreen.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == _totalSteps - 1 ? '🚀' : '✨',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _currentStep == _totalSteps - 1
                              ? 'Launch Journey'
                              : 'Continue',
                          style: AppTheme.heading3.copyWith(
                            color: _canProceed()
                                ? AppTheme.spaceDark
                                : AppTheme.gray500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().slideX(
                begin: 0.3,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
      ],
    );
  }
}
