// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetModel _$AssetModelFromJson(Map<String, dynamic> json) => AssetModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      priceChange24h: (json['priceChange24h'] as num).toDouble(),
      priceChangePercentage24h:
          (json['priceChangePercentage24h'] as num).toDouble(),
      iconUrl: json['iconUrl'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$AssetModelToJson(AssetModel instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'price': instance.price,
      'priceChange24h': instance.priceChange24h,
      'priceChangePercentage24h': instance.priceChangePercentage24h,
      'iconUrl': instance.iconUrl,
      'isActive': instance.isActive,
    };

TradeModel _$TradeModelFromJson(Map<String, dynamic> json) => TradeModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      assetSymbol: json['assetSymbol'] as String,
      direction: $enumDecode(_$TradeDirectionEnumMap, json['direction']),
      amount: (json['amount'] as num).toDouble(),
      leverage: (json['leverage'] as num).toDouble(),
      entryPrice: (json['entryPrice'] as num).toDouble(),
      exitPrice: (json['exitPrice'] as num?)?.toDouble(),
      status: $enumDecode(_$TradeStatusEnumMap, json['status']),
      type: $enumDecode(_$TradeTypeEnumMap, json['type']),
      pnl: (json['pnl'] as num).toDouble(),
      xpEarned: (json['xpEarned'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TradeModelToJson(TradeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'assetSymbol': instance.assetSymbol,
      'direction': _$TradeDirectionEnumMap[instance.direction]!,
      'amount': instance.amount,
      'leverage': instance.leverage,
      'entryPrice': instance.entryPrice,
      'exitPrice': instance.exitPrice,
      'status': _$TradeStatusEnumMap[instance.status]!,
      'type': _$TradeTypeEnumMap[instance.type]!,
      'pnl': instance.pnl,
      'xpEarned': instance.xpEarned,
      'createdAt': instance.createdAt.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$TradeDirectionEnumMap = {
  TradeDirection.long: 'long',
  TradeDirection.short: 'short',
};

const _$TradeStatusEnumMap = {
  TradeStatus.pending: 'pending',
  TradeStatus.active: 'active',
  TradeStatus.closed: 'closed',
  TradeStatus.cancelled: 'cancelled',
};

const _$TradeTypeEnumMap = {
  TradeType.market: 'market',
  TradeType.limit: 'limit',
};

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      level: (json['level'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      totalPnL: (json['totalPnL'] as num).toDouble(),
      totalTrades: (json['totalTrades'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
      isCurrentUser: json['isCurrentUser'] as bool,
    );

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'level': instance.level,
      'xp': instance.xp,
      'totalPnL': instance.totalPnL,
      'totalTrades': instance.totalTrades,
      'winRate': instance.winRate,
      'rank': instance.rank,
      'isCurrentUser': instance.isCurrentUser,
    };

MarketData _$MarketDataFromJson(Map<String, dynamic> json) => MarketData(
      symbol: json['symbol'] as String,
      price: (json['price'] as num).toDouble(),
      high24h: (json['high24h'] as num).toDouble(),
      low24h: (json['low24h'] as num).toDouble(),
      volume24h: (json['volume24h'] as num).toDouble(),
      priceChange24h: (json['priceChange24h'] as num).toDouble(),
      priceChangePercentage24h:
          (json['priceChangePercentage24h'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$MarketDataToJson(MarketData instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'price': instance.price,
      'high24h': instance.high24h,
      'low24h': instance.low24h,
      'volume24h': instance.volume24h,
      'priceChange24h': instance.priceChange24h,
      'priceChangePercentage24h': instance.priceChangePercentage24h,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

TradeReward _$TradeRewardFromJson(Map<String, dynamic> json) => TradeReward(
      xp: (json['xp'] as num).toInt(),
      achievementUnlocked: json['achievementUnlocked'] as String?,
      nftReward: json['nftReward'] == null
          ? null
          : NFTReward.fromJson(json['nftReward'] as Map<String, dynamic>),
      planetBonus: json['planetBonus'] == null
          ? null
          : PlanetBonus.fromJson(json['planetBonus'] as Map<String, dynamic>),
      message: json['message'] as String,
    );

Map<String, dynamic> _$TradeRewardToJson(TradeReward instance) =>
    <String, dynamic>{
      'xp': instance.xp,
      'achievementUnlocked': instance.achievementUnlocked,
      'nftReward': instance.nftReward,
      'planetBonus': instance.planetBonus,
      'message': instance.message,
    };

NFTReward _$NFTRewardFromJson(Map<String, dynamic> json) => NFTReward(
      id: json['id'] as String,
      name: json['name'] as String,
      rarity: json['rarity'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$NFTRewardToJson(NFTReward instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'rarity': instance.rarity,
      'imageUrl': instance.imageUrl,
    };

PlanetBonus _$PlanetBonusFromJson(Map<String, dynamic> json) => PlanetBonus(
      healthPoints: (json['healthPoints'] as num).toInt(),
      ecosystemPoints: (json['ecosystemPoints'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$PlanetBonusToJson(PlanetBonus instance) =>
    <String, dynamic>{
      'healthPoints': instance.healthPoints,
      'ecosystemPoints': instance.ecosystemPoints,
      'description': instance.description,
    };
