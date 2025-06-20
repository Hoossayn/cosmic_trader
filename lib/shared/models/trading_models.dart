import 'package:json_annotation/json_annotation.dart';

part 'trading_models.g.dart';

@JsonSerializable()
class AssetModel {
  final String symbol;
  final String name;
  final double price;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final String iconUrl;
  final bool isActive;

  const AssetModel({
    required this.symbol,
    required this.name,
    required this.price,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.iconUrl,
    required this.isActive,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) =>
      _$AssetModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssetModelToJson(this);

  AssetModel copyWith({
    String? symbol,
    String? name,
    double? price,
    double? priceChange24h,
    double? priceChangePercentage24h,
    String? iconUrl,
    bool? isActive,
  }) {
    return AssetModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      priceChange24h: priceChange24h ?? this.priceChange24h,
      priceChangePercentage24h:
          priceChangePercentage24h ?? this.priceChangePercentage24h,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}

@JsonSerializable()
class TradeModel {
  final String id;
  final String userId;
  final String assetSymbol;
  final TradeDirection direction;
  final double amount;
  final double leverage;
  final double entryPrice;
  final double? exitPrice;
  final TradeStatus status;
  final TradeType type;
  final double pnl;
  final int xpEarned;
  final DateTime createdAt;
  final DateTime? closedAt;
  final Map<String, dynamic>? metadata;

  const TradeModel({
    required this.id,
    required this.userId,
    required this.assetSymbol,
    required this.direction,
    required this.amount,
    required this.leverage,
    required this.entryPrice,
    this.exitPrice,
    required this.status,
    required this.type,
    required this.pnl,
    required this.xpEarned,
    required this.createdAt,
    this.closedAt,
    this.metadata,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) =>
      _$TradeModelFromJson(json);
  Map<String, dynamic> toJson() => _$TradeModelToJson(this);

  double get positionSize => amount * leverage;

  TradeModel copyWith({
    String? id,
    String? userId,
    String? assetSymbol,
    TradeDirection? direction,
    double? amount,
    double? leverage,
    double? entryPrice,
    double? exitPrice,
    TradeStatus? status,
    TradeType? type,
    double? pnl,
    int? xpEarned,
    DateTime? createdAt,
    DateTime? closedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TradeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assetSymbol: assetSymbol ?? this.assetSymbol,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      leverage: leverage ?? this.leverage,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      status: status ?? this.status,
      type: type ?? this.type,
      pnl: pnl ?? this.pnl,
      xpEarned: xpEarned ?? this.xpEarned,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int level;
  final int xp;
  final double totalPnL;
  final int totalTrades;
  final double winRate;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.totalPnL,
    required this.totalTrades,
    required this.winRate,
    required this.rank,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
}

@JsonSerializable()
class MarketData {
  final String symbol;
  final double price;
  final double high24h;
  final double low24h;
  final double volume24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final DateTime lastUpdated;

  const MarketData({
    required this.symbol,
    required this.price,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.lastUpdated,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) =>
      _$MarketDataFromJson(json);
  Map<String, dynamic> toJson() => _$MarketDataToJson(this);
}

enum TradeDirection {
  @JsonValue('long')
  long,
  @JsonValue('short')
  short,
}

enum TradeStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('active')
  active,
  @JsonValue('closed')
  closed,
  @JsonValue('cancelled')
  cancelled,
}

enum TradeType {
  @JsonValue('market')
  market,
  @JsonValue('limit')
  limit,
}

// Gamification reward for trades
@JsonSerializable()
class TradeReward {
  final int xp;
  final String? achievementUnlocked;
  final NFTReward? nftReward;
  final PlanetBonus? planetBonus;
  final String message;

  const TradeReward({
    required this.xp,
    this.achievementUnlocked,
    this.nftReward,
    this.planetBonus,
    required this.message,
  });

  factory TradeReward.fromJson(Map<String, dynamic> json) =>
      _$TradeRewardFromJson(json);
  Map<String, dynamic> toJson() => _$TradeRewardToJson(this);
}

@JsonSerializable()
class NFTReward {
  final String id;
  final String name;
  final String rarity;
  final String imageUrl;

  const NFTReward({
    required this.id,
    required this.name,
    required this.rarity,
    required this.imageUrl,
  });

  factory NFTReward.fromJson(Map<String, dynamic> json) =>
      _$NFTRewardFromJson(json);
  Map<String, dynamic> toJson() => _$NFTRewardToJson(this);
}

@JsonSerializable()
class PlanetBonus {
  final int healthPoints;
  final int ecosystemPoints;
  final String description;

  const PlanetBonus({
    required this.healthPoints,
    required this.ecosystemPoints,
    required this.description,
  });

  factory PlanetBonus.fromJson(Map<String, dynamic> json) =>
      _$PlanetBonusFromJson(json);
  Map<String, dynamic> toJson() => _$PlanetBonusToJson(this);
}
