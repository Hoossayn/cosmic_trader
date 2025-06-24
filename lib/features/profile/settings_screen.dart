import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.spaceDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSettingsSection(),
                    const SizedBox(height: 32),
                    _buildLogoutSection(),
                    const SizedBox(height: 32),
                    _buildVersionInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppTheme.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text('Settings', style: AppTheme.heading2),
        ],
      ),
    ).animate().slideX(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  Widget _buildSettingsSection() {
    final settingsItems = [
      {
        'title': 'Account',
        'icon': Icons.person_outline,
        'hasArrow': true,
        'onTap': () {
          // TODO: Navigate to account settings
        },
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_outlined,
        'hasArrow': true,
        'onTap': () {
          // TODO: Navigate to notification settings
        },
      },
      {
        'title': 'Preferences',
        'icon': Icons.tune_outlined,
        'hasArrow': true,
        'onTap': () {
          // TODO: Navigate to preferences
        },
      },
      {
        'title': 'Wallet',
        'icon': Icons.account_balance_wallet_outlined,
        'hasArrow': true,
        'onTap': () {
          // TODO: Navigate to wallet settings
        },
      },
    ];

    final supportItems = [
      {
        'title': 'Report a problem',
        'icon': Icons.flag_outlined,
        'hasArrow': true,
        'onTap': () {
          // TODO: Navigate to report problem
        },
      },
      {
        'title': 'Terms of Service',
        'icon': Icons.description_outlined,
        'hasArrow': true,
        'onTap': () {
          // TODO: Navigate to terms of service
        },
      },
      {
        'title': 'Privacy Policy',
        'icon': Icons.privacy_tip_outlined,
        'hasArrow': true,
        'onTap': () {
          // TODO: Navigate to privacy policy
        },
      },
    ];

    return Column(
      children: [
        // Main settings section
        Container(
          decoration: BoxDecoration(
            color: AppTheme.spaceDeep,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
          ),
          child: Column(
            children: settingsItems.map((item) {
              final isLast = item == settingsItems.last;
              return _buildSettingsItem(
                title: item['title'] as String,
                icon: item['icon'] as IconData,
                hasArrow: item['hasArrow'] as bool,
                onTap: item['onTap'] as VoidCallback,
                isLast: isLast,
              );
            }).toList(),
          ),
        ).animate().slideY(
          begin: 0.3,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        ),

        const SizedBox(height: 24),

        // Support section
        Container(
          decoration: BoxDecoration(
            color: AppTheme.spaceDeep,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
          ),
          child: Column(
            children: supportItems.map((item) {
              final isLast = item == supportItems.last;
              return _buildSettingsItem(
                title: item['title'] as String,
                icon: item['icon'] as IconData,
                hasArrow: item['hasArrow'] as bool,
                onTap: item['onTap'] as VoidCallback,
                isLast: isLast,
              );
            }).toList(),
          ),
        ).animate().slideY(
          begin: 0.3,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    required bool hasArrow,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppTheme.cosmicBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: AppTheme.white, size: 24),
        title: Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.white,
          ),
        ),
        trailing: hasArrow
            ? const Icon(Icons.chevron_right, color: AppTheme.gray400, size: 24)
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const Icon(Icons.logout, color: AppTheme.dangerRed, size: 24),
        title: Text(
          'Log out',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.dangerRed,
          ),
        ),
        onTap: () {
          _showLogoutDialog();
        },
      ),
    ).animate().slideY(
      begin: 0.3,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Cosmic Trader v0.0.1',
      style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
    ).animate().fadeIn(duration: const Duration(milliseconds: 1200));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.spaceDeep,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.cosmicBlue.withOpacity(0.3)),
          ),
          title: Text(
            'Log Out',
            style: AppTheme.heading3.copyWith(color: AppTheme.white),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Logged out successfully',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    backgroundColor: AppTheme.energyGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: Text(
                'Log Out',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.dangerRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
