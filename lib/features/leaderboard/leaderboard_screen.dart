import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;

  final List<Map<String, dynamic>> _leaderboardData = [
    {
      'rank': 1,
      'username': 'Hoossayn',
      'level': 4,
      'xp': 316,
      'avatar': '👑',
      'isCurrentUser': true,
    },
    {
      'rank': 2,
      'username': 'CryptoWhale',
      'level': 5,
      'xp': 289,
      'avatar': '🐋',
      'isCurrentUser': false,
    },
    {
      'rank': 3,
      'username': 'MoonLander',
      'level': 4,
      'xp': 267,
      'avatar': '🚀',
      'isCurrentUser': false,
    },
    {
      'rank': 4,
      'username': 'DiamondHands',
      'level': 3,
      'xp': 234,
      'avatar': '💎',
      'isCurrentUser': false,
    },
    {
      'rank': 5,
      'username': 'CosmicTrader',
      'level': 3,
      'xp': 198,
      'avatar': '🌟',
      'isCurrentUser': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTopThree(),
            Expanded(child: _buildLeaderboardList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Leaderboard', style: AppTheme.heading2),
          const SizedBox(height: 8),
          Text(
            'Top traders ranked by XP',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    final top3 = _leaderboardData.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 2nd place
          _buildPodiumPosition(top3[1], 2),
          // 1st place (larger)
          _buildPodiumPosition(top3[0], 1),
          // 3rd place
          _buildPodiumPosition(top3[2], 3),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(Map<String, dynamic> user, int position) {
    final isFirst = position == 1;
    final colors = _getPodiumColors(position);

    return Column(
      children: [
        // Avatar with crown/medal
        Stack(
          children: [
            Container(
              width: isFirst ? 80 : 64,
              height: isFirst ? 80 : 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user['avatar'],
                  style: TextStyle(fontSize: isFirst ? 32 : 24),
                ),
              ),
            ),
            if (isFirst)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.starYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: AppTheme.spaceDark,
                    size: 16,
                  ),
                ),
              ),
          ],
        ).animate().scale(
          delay: Duration(milliseconds: position * 200),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        ),

        const SizedBox(height: 12),

        // Rank
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '#$position',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.spaceDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Username
        Text(
          user['username'],
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: user['isCurrentUser']
                ? AppTheme.energyGreen
                : AppTheme.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // XP
        Text(
          '${user['xp']} XP',
          style: AppTheme.bodySmall.copyWith(
            color: colors[0],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    final remainingUsers = _leaderboardData.skip(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.cosmicBlue.withOpacity(0.3),
                  AppTheme.nebulaPurple.withOpacity(0.2),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'All Rankings',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.emoji_events, color: AppTheme.starYellow, size: 20),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: remainingUsers.length,
              itemBuilder: (context, index) {
                final user = remainingUsers[index];
                return _buildLeaderboardEntry(user, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(Map<String, dynamic> user, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: user['isCurrentUser']
                ? AppTheme.energyGreen.withOpacity(0.1)
                : AppTheme.spaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: user['isCurrentUser']
                ? Border.all(color: AppTheme.energyGreen.withOpacity(0.5))
                : null,
          ),
          child: Row(
            children: [
              // Rank
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.cosmicBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${user['rank']}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.cosmicBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.cosmicBlue.withOpacity(0.3),
                      AppTheme.nebulaPurple.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    user['avatar'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['username'],
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: user['isCurrentUser']
                                ? AppTheme.energyGreen
                                : AppTheme.white,
                          ),
                        ),
                        if (user['isCurrentUser'])
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.energyGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'YOU',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.energyGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${user['level']}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.gray400,
                      ),
                    ),
                  ],
                ),
              ),

              // XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user['xp']} XP',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.starYellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .slideX(
          begin: 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
  }

  List<Color> _getPodiumColors(int position) {
    switch (position) {
      case 1:
        return [AppTheme.starYellow, AppTheme.warningOrange];
      case 2:
        return [AppTheme.gray300, AppTheme.gray400];
      case 3:
        return [AppTheme.warningOrange, AppTheme.dangerRed];
      default:
        return [AppTheme.cosmicBlue, AppTheme.nebulaPurple];
    }
  }
}
