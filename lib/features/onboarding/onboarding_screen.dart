import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to\nCosmic Trader',
      'subtitle': 'Gamified perpetual trading on Starknet',
      'description':
          'Trade crypto with game-like rewards, level up your skills, and build your cosmic empire.',
      'icon': '🚀',
      'color': AppTheme.energyGreen,
    },
    {
      'title': 'Grow Your\nPlanet',
      'subtitle': 'Your trading performance shapes your world',
      'description':
          'Each successful trade helps your planet flourish. Bad trades won\'t destroy it - your ecosystem rebuilds over time.',
      'icon': '🌍',
      'color': AppTheme.cosmicBlue,
    },
    {
      'title': 'Earn XP &\nLevel Up',
      'subtitle': 'Every trade earns experience points',
      'description':
          'Level up to unlock new features, earn rare NFTs, and compete on the global leaderboard.',
      'icon': '⭐',
      'color': AppTheme.starYellow,
    },
    {
      'title': 'Start Your\nJourney',
      'subtitle': 'Begin with practice trades',
      'description':
          'Learn the ropes with risk-free practice mode before trading with real assets.',
      'icon': '🎮',
      'color': AppTheme.nebulaPurple,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.spaceDark,
                  AppTheme.spaceDeep,
                  AppTheme.spaceDark,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => context.go('/planet'),
                      child: Text(
                        'Skip',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.gray400,
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(_onboardingData[index]);
                    },
                  ),
                ),

                // Bottom section
                _buildBottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  data['color'].withOpacity(0.3),
                  data['color'].withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(data['icon'], style: const TextStyle(fontSize: 60)),
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            data['title'],
            style: AppTheme.heading1.copyWith(color: data['color']),
            textAlign: TextAlign.center,
          ).animate().slideY(
            begin: 0.3,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            data['subtitle'],
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.gray300,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(
            begin: 0.3,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            data['description'],
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.gray400,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(
            begin: 0.3,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => _buildPageIndicator(index),
            ),
          ),

          const SizedBox(height: 32),

          // Next/Get Started button
          GestureDetector(
            onTap: () {
              if (_currentPage < _onboardingData.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                context.go('/planet');
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _onboardingData[_currentPage]['color'],
                    _onboardingData[_currentPage]['color'].withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _onboardingData[_currentPage]['color'].withOpacity(
                      0.3,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage < _onboardingData.length - 1
                        ? 'Next'
                        : 'Get Started',
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.spaceDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage < _onboardingData.length - 1
                        ? Icons.arrow_forward
                        : Icons.rocket_launch,
                    color: AppTheme.spaceDark,
                    size: 24,
                  ),
                ],
              ),
            ),
          ).animate().slideY(
            begin: 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _onboardingData[_currentPage]['color']
            : AppTheme.gray600,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
