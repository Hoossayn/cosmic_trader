import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/nft_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUserStats(),
              const SizedBox(height: 24),
              _buildAchievements(),
              const SizedBox(height: 24),
              _buildNFTCollection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.energyGreen, AppTheme.cosmicBlue],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.energyGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('👑', style: TextStyle(fontSize: 32)),
          ),
        ),

        const SizedBox(width: 20),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hoossayn', style: AppTheme.heading2),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.starYellow, AppTheme.energyGreen],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Level 4',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.spaceDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '316 XP',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.starYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cosmic Trader since Jan 2024',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
              ),
            ],
          ),
        ),
      ],
    ).animate().slideX(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  Widget _buildUserStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trading Stats', style: AppTheme.heading3),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'Total Trades',
                  value: '47',
                  icon: Icons.swap_horiz,
                  color: AppTheme.energyGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  title: 'Win Rate',
                  value: '68%',
                  icon: Icons.trending_up,
                  color: AppTheme.starYellow,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: 'Total P&L',
                  value: '+\$1,247',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.energyGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  title: 'Best Streak',
                  value: '12 days',
                  icon: Icons.local_fire_department,
                  color: AppTheme.warningOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'name': 'First Trade', 'icon': '🚀', 'earned': true},
      {'name': 'Week Warrior', 'icon': '⚔️', 'earned': true},
      {'name': 'Profit Master', 'icon': '💰', 'earned': false},
      {'name': 'Diamond Hands', 'icon': '💎', 'earned': false},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievements', style: AppTheme.heading3),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final isEarned = achievement['earned'] as bool;

              return Container(
                decoration: BoxDecoration(
                  color: isEarned
                      ? AppTheme.starYellow.withOpacity(0.2)
                      : AppTheme.spaceDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEarned
                        ? AppTheme.starYellow.withOpacity(0.5)
                        : AppTheme.gray600.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      achievement['icon'] as String,
                      style: TextStyle(
                        fontSize: 24,
                        color: isEarned ? null : AppTheme.gray600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['name'] as String,
                      style: AppTheme.caption.copyWith(
                        color: isEarned
                            ? AppTheme.starYellow
                            : AppTheme.gray600,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  Widget _buildNFTCollection() {
    final ownedNFTs = NFTData.getOwnedNFTs();
    final unownedNFTs = NFTData.getUnownedNFTs()
        .take(4)
        .toList(); // Show first 4 unowned

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NFT Collection', style: AppTheme.heading3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.starYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.starYellow.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${ownedNFTs.length}/${NFTData.getAllNFTs().length}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.starYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Owned NFTs section
          if (ownedNFTs.isNotEmpty) ...[
            Text(
              'Owned Rare NFTs',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.energyGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio:
                    0.85, // Slightly taller to accommodate content
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: ownedNFTs.length,
              itemBuilder: (context, index) {
                final nft = ownedNFTs[index];
                return _buildNFTCard(nft, isOwned: true);
              },
            ),
            const SizedBox(height: 20),
          ],

          // Unowned NFTs section
          if (unownedNFTs.isNotEmpty) ...[
            Text(
              'Unlock More NFTs',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.gray400,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio:
                    0.85, // Slightly taller to accommodate content
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: unownedNFTs.length,
              itemBuilder: (context, index) {
                final nft = unownedNFTs[index];
                return _buildNFTCard(nft, isOwned: false);
              },
            ),
          ],
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
    );
  }

  Widget _buildNFTCard(NFT nft, {required bool isOwned}) {
    return GestureDetector(
      onTap: () => _showNFTDetails(nft),
      child: Container(
        decoration: BoxDecoration(
          color: isOwned
              ? _getRarityColor(nft.rarity).withOpacity(0.2)
              : AppTheme.spaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOwned
                ? _getRarityColor(nft.rarity).withOpacity(0.5)
                : AppTheme.gray600.withOpacity(0.3),
            width: isOwned ? 2 : 1,
          ),
          boxShadow: isOwned
              ? [
                  BoxShadow(
                    color: _getRarityColor(nft.rarity).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  nft.emoji,
                  style: TextStyle(
                    fontSize: 24, // Slightly smaller emoji
                    color: isOwned ? null : AppTheme.gray600,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                flex: 2,
                child: Text(
                  nft.name,
                  style: AppTheme.caption.copyWith(
                    color: isOwned
                        ? _getRarityColor(nft.rarity)
                        : AppTheme.gray600,
                    fontWeight: FontWeight.w600,
                    fontSize: 9, // Slightly smaller text
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOwned) ...[
                const SizedBox(height: 1),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _getRarityColor(nft.rarity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getRarityText(nft.rarity),
                      style: AppTheme.caption.copyWith(
                        color: _getRarityColor(nft.rarity),
                        fontSize: 7, // Smaller rarity text
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(NFTRarity rarity) {
    switch (rarity) {
      case NFTRarity.common:
        return AppTheme.gray400;
      case NFTRarity.rare:
        return AppTheme.energyGreen;
      case NFTRarity.epic:
        return AppTheme.cosmicBlue;
      case NFTRarity.legendary:
        return AppTheme.starYellow;
      case NFTRarity.mythic:
        return AppTheme.warningOrange;
    }
  }

  String _getRarityText(NFTRarity rarity) {
    switch (rarity) {
      case NFTRarity.common:
        return 'COMMON';
      case NFTRarity.rare:
        return 'RARE';
      case NFTRarity.epic:
        return 'EPIC';
      case NFTRarity.legendary:
        return 'LEGEND';
      case NFTRarity.mythic:
        return 'MYTHIC';
    }
  }

  void _showNFTDetails(NFT nft) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppTheme.spaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.gray600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // NFT Display
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: nft.isOwned
                            ? _getRarityColor(nft.rarity).withOpacity(0.2)
                            : AppTheme.spaceDeep,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: nft.isOwned
                              ? _getRarityColor(nft.rarity)
                              : AppTheme.gray600,
                          width: 3,
                        ),
                        boxShadow: nft.isOwned
                            ? [
                                BoxShadow(
                                  color: _getRarityColor(
                                    nft.rarity,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          nft.emoji,
                          style: TextStyle(
                            fontSize: 60,
                            color: nft.isOwned ? null : AppTheme.gray600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NFT Info
                    Text(
                      nft.name,
                      style: AppTheme.heading2.copyWith(
                        color: nft.isOwned
                            ? _getRarityColor(nft.rarity)
                            : AppTheme.gray400,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRarityColor(nft.rarity).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getRarityColor(nft.rarity).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        _getRarityText(nft.rarity),
                        style: AppTheme.bodySmall.copyWith(
                          color: _getRarityColor(nft.rarity),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      nft.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.gray400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Earn condition or earned date
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.spaceDeep,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.cosmicBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            nft.isOwned ? 'Earned' : 'How to Earn',
                            style: AppTheme.bodyMedium.copyWith(
                              color: nft.isOwned
                                  ? AppTheme.energyGreen
                                  : AppTheme.starYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (nft.isOwned && nft.earnedDate != null)
                            Text(
                              'Earned on ${nft.earnedDate!.day}/${nft.earnedDate!.month}/${nft.earnedDate!.year}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.gray400,
                              ),
                            )
                          else
                            Text(
                              nft.earnCondition.description,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.gray400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cosmicBlue,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
