class NFT {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final NFTRarity rarity;
  final NFTCategory category;
  final bool isOwned;
  final DateTime? earnedDate;
  final NFTEarnCondition earnCondition;

  const NFT({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.rarity,
    required this.category,
    required this.isOwned,
    this.earnedDate,
    required this.earnCondition,
  });

  NFT copyWith({
    String? id,
    String? name,
    String? emoji,
    String? description,
    NFTRarity? rarity,
    NFTCategory? category,
    bool? isOwned,
    DateTime? earnedDate,
    NFTEarnCondition? earnCondition,
  }) {
    return NFT(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
      isOwned: isOwned ?? this.isOwned,
      earnedDate: earnedDate ?? this.earnedDate,
      earnCondition: earnCondition ?? this.earnCondition,
    );
  }
}

enum NFTRarity { common, rare, epic, legendary, mythic }

enum NFTCategory { decoration, companion, structure, effect }

class NFTEarnCondition {
  final String description;
  final int? requiredTrades;
  final double? requiredPnL;
  final int? requiredStreak;
  final int? requiredXP;
  final int? requiredLevel;

  const NFTEarnCondition({
    required this.description,
    this.requiredTrades,
    this.requiredPnL,
    this.requiredStreak,
    this.requiredXP,
    this.requiredLevel,
  });
}

// Sample NFT data
class NFTData {
  static List<NFT> getAllNFTs() {
    return [
      // Decoration NFTs
      NFT(
        id: 'crystal_tree',
        name: 'Crystal Tree',
        emoji: '🌳',
        description: 'A mystical tree that grows on successful planets',
        rarity: NFTRarity.rare,
        category: NFTCategory.decoration,
        isOwned: true,
        earnedDate: DateTime.now().subtract(const Duration(days: 5)),
        earnCondition: const NFTEarnCondition(
          description: 'Complete 10 profitable trades',
          requiredTrades: 10,
        ),
      ),
      NFT(
        id: 'golden_meteor',
        name: 'Golden Meteor',
        emoji: '☄️',
        description: 'A rare golden meteor orbiting your planet',
        rarity: NFTRarity.epic,
        category: NFTCategory.decoration,
        isOwned: true,
        earnedDate: DateTime.now().subtract(const Duration(days: 12)),
        earnCondition: const NFTEarnCondition(
          description: 'Reach \$1000 total P&L',
          requiredPnL: 1000,
        ),
      ),
      NFT(
        id: 'cosmic_rings',
        name: 'Cosmic Rings',
        emoji: '💫',
        description: 'Beautiful cosmic rings surrounding your planet',
        rarity: NFTRarity.legendary,
        category: NFTCategory.decoration,
        isOwned: false,
        earnCondition: const NFTEarnCondition(
          description: 'Maintain 30-day trading streak',
          requiredStreak: 30,
        ),
      ),

      // Companion NFTs
      NFT(
        id: 'space_cat',
        name: 'Space Cat',
        emoji: '🐱',
        description: 'A cute space cat companion',
        rarity: NFTRarity.common,
        category: NFTCategory.companion,
        isOwned: true,
        earnedDate: DateTime.now().subtract(const Duration(days: 20)),
        earnCondition: const NFTEarnCondition(
          description: 'Complete first trade',
          requiredTrades: 1,
        ),
      ),
      NFT(
        id: 'cosmic_dragon',
        name: 'Cosmic Dragon',
        emoji: '🐉',
        description: 'A powerful cosmic dragon guardian',
        rarity: NFTRarity.mythic,
        category: NFTCategory.companion,
        isOwned: false,
        earnCondition: const NFTEarnCondition(
          description: 'Reach Level 10',
          requiredLevel: 10,
        ),
      ),

      // Structure NFTs
      NFT(
        id: 'trading_station',
        name: 'Trading Station',
        emoji: '🛰️',
        description: 'An advanced trading station',
        rarity: NFTRarity.epic,
        category: NFTCategory.structure,
        isOwned: false,
        earnCondition: const NFTEarnCondition(
          description: 'Complete 100 trades',
          requiredTrades: 100,
        ),
      ),
      NFT(
        id: 'crystal_palace',
        name: 'Crystal Palace',
        emoji: '🏰',
        description: 'A magnificent crystal palace',
        rarity: NFTRarity.legendary,
        category: NFTCategory.structure,
        isOwned: false,
        earnCondition: const NFTEarnCondition(
          description: 'Reach \$10,000 total P&L',
          requiredPnL: 10000,
        ),
      ),

      // Effect NFTs
      NFT(
        id: 'aurora_effect',
        name: 'Aurora Effect',
        emoji: '🌌',
        description: 'Beautiful aurora lights around your planet',
        rarity: NFTRarity.rare,
        category: NFTCategory.effect,
        isOwned: true,
        earnedDate: DateTime.now().subtract(const Duration(days: 8)),
        earnCondition: const NFTEarnCondition(
          description: 'Achieve 70% win rate',
        ),
      ),
      NFT(
        id: 'stardust_trail',
        name: 'Stardust Trail',
        emoji: '✨',
        description: 'Sparkling stardust trailing your planet',
        rarity: NFTRarity.epic,
        category: NFTCategory.effect,
        isOwned: false,
        earnCondition: const NFTEarnCondition(
          description: 'Reach 1000 XP',
          requiredXP: 1000,
        ),
      ),
    ];
  }

  static List<NFT> getOwnedNFTs() {
    return getAllNFTs().where((nft) => nft.isOwned).toList();
  }

  static List<NFT> getUnownedNFTs() {
    return getAllNFTs().where((nft) => !nft.isOwned).toList();
  }
}
