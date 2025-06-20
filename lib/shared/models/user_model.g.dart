// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      level: (json['level'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      xpToNextLevel: (json['xpToNextLevel'] as num).toInt(),
      balance: (json['balance'] as num).toDouble(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      lastTradeDate: DateTime.parse(json['lastTradeDate'] as String),
      planet: PlanetModel.fromJson(json['planet'] as Map<String, dynamic>),
      nftCollection: (json['nftCollection'] as List<dynamic>)
          .map((e) => NFTModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'level': instance.level,
      'xp': instance.xp,
      'xpToNextLevel': instance.xpToNextLevel,
      'balance': instance.balance,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastTradeDate': instance.lastTradeDate.toIso8601String(),
      'planet': instance.planet,
      'nftCollection': instance.nftCollection,
      'achievements': instance.achievements,
      'stats': instance.stats,
      'createdAt': instance.createdAt.toIso8601String(),
    };

PlanetModel _$PlanetModelFromJson(Map<String, dynamic> json) => PlanetModel(
      id: json['id'] as String,
      type: $enumDecode(_$PlanetTypeEnumMap, json['type']),
      healthLevel: (json['healthLevel'] as num).toInt(),
      features: (json['features'] as List<dynamic>)
          .map((e) => PlanetFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
      ecosystemPoints: (json['ecosystemPoints'] as num).toInt(),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$PlanetModelToJson(PlanetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PlanetTypeEnumMap[instance.type]!,
      'healthLevel': instance.healthLevel,
      'features': instance.features,
      'ecosystemPoints': instance.ecosystemPoints,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };

const _$PlanetTypeEnumMap = {
  PlanetType.garden: 'garden',
  PlanetType.castle: 'castle',
  PlanetType.planet: 'planet',
  PlanetType.spaceStation: 'space_station',
};

PlanetFeature _$PlanetFeatureFromJson(Map<String, dynamic> json) =>
    PlanetFeature(
      id: json['id'] as String,
      type: $enumDecode(_$PlanetFeatureTypeEnumMap, json['type']),
      level: (json['level'] as num).toInt(),
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$PlanetFeatureToJson(PlanetFeature instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PlanetFeatureTypeEnumMap[instance.type]!,
      'level': instance.level,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };

const _$PlanetFeatureTypeEnumMap = {
  PlanetFeatureType.trees: 'trees',
  PlanetFeatureType.buildings: 'buildings',
  PlanetFeatureType.decorations: 'decorations',
  PlanetFeatureType.energySource: 'energy_source',
  PlanetFeatureType.defense: 'defense',
};

NFTModel _$NFTModelFromJson(Map<String, dynamic> json) => NFTModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: $enumDecode(_$NFTRarityEnumMap, json['rarity']),
      category: $enumDecode(_$NFTCategoryEnumMap, json['category']),
      imageUrl: json['imageUrl'] as String,
      attributes: json['attributes'] as Map<String, dynamic>,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      isEquipped: json['isEquipped'] as bool,
    );

Map<String, dynamic> _$NFTModelToJson(NFTModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'rarity': _$NFTRarityEnumMap[instance.rarity]!,
      'category': _$NFTCategoryEnumMap[instance.category]!,
      'imageUrl': instance.imageUrl,
      'attributes': instance.attributes,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'isEquipped': instance.isEquipped,
    };

const _$NFTRarityEnumMap = {
  NFTRarity.common: 'common',
  NFTRarity.uncommon: 'uncommon',
  NFTRarity.rare: 'rare',
  NFTRarity.epic: 'epic',
  NFTRarity.legendary: 'legendary',
};

const _$NFTCategoryEnumMap = {
  NFTCategory.milestone: 'milestone',
  NFTCategory.achievement: 'achievement',
  NFTCategory.planetDecoration: 'planet_decoration',
  NFTCategory.tradingTool: 'trading_tool',
  NFTCategory.specialEvent: 'special_event',
};

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      totalTrades: (json['totalTrades'] as num).toInt(),
      winningTrades: (json['winningTrades'] as num).toInt(),
      losingTrades: (json['losingTrades'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      totalPnL: (json['totalPnL'] as num).toDouble(),
      winRate: (json['winRate'] as num).toDouble(),
      daysActive: (json['daysActive'] as num).toInt(),
      achievementsUnlocked: (json['achievementsUnlocked'] as num).toInt(),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'totalTrades': instance.totalTrades,
      'winningTrades': instance.winningTrades,
      'losingTrades': instance.losingTrades,
      'totalVolume': instance.totalVolume,
      'totalPnL': instance.totalPnL,
      'winRate': instance.winRate,
      'daysActive': instance.daysActive,
      'achievementsUnlocked': instance.achievementsUnlocked,
    };
