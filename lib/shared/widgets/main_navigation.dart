import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:vibration/vibration.dart';
import '../../core/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onTap(int index, String route) {
    setState(() {
      _currentIndex = index;
    });

    // Haptic feedback
    // Vibration.hasVibrator().then((hasVibrator) {
    //   if (hasVibrator == true) {
    //     Vibration.vibrate(duration: 50);
    //   }
    // });

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current location
    final location = GoRouterState.of(context).matchedLocation;
    _updateCurrentIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.spaceDark.withOpacity(0.8), AppTheme.spaceDeep],
          ),
          border: Border(
            top: BorderSide(
              color: AppTheme.cosmicBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.public,
                  label: 'Planet',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTap(0, '/planet'),
                ),
                _NavItem(
                  icon: Icons.trending_up,
                  label: 'Trade',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTap(1, '/trading'),
                ),
                _NavItem(
                  icon: Icons.leaderboard,
                  label: 'Leaders',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTap(2, '/leaderboard'),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onTap(3, '/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateCurrentIndex(String location) {
    switch (location) {
      case '/planet':
        _currentIndex = 0;
        break;
      case '/trading':
        _currentIndex = 1;
        break;
      case '/leaderboard':
        _currentIndex = 2;
        break;
      case '/profile':
        _currentIndex = 3;
        break;
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.energyGreen.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppTheme.energyGreen.withOpacity(0.5))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.energyGreen : AppTheme.gray500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.energyGreen : AppTheme.gray500,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.energyGreen,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
