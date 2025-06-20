import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final double balance;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastTradeDate;
  final PlanetModel planet;
  final List<NFTModel> nftCollection;
  final List<String> achievements;
  final UserStats stats;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.balance,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastTradeDate,
    required this.planet,
    required this.nftCollection,
    required this.achievements,
    required this.stats,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? level,
    int? xp,
    int? xpToNextLevel,
    double? balance,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastTradeDate,
    PlanetModel? planet,
    List<NFTModel>? nftCollection,
    List<String>? achievements,
    UserStats? stats,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      balance: balance ?? this.balance,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastTradeDate: lastTradeDate ?? this.lastTradeDate,
      planet: planet ?? this.planet,
      nftCollection: nftCollection ?? this.nftCollection,
      achievements: achievements ?? this.achievements,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@JsonSerializable()
class PlanetModel {
  final String id;
  final PlanetType type;
  final int healthLevel; // 0-100
  final List<PlanetFeature> features;
  final int ecosystemPoints;
  final DateTime lastUpdate;

  const PlanetModel({
    required this.id,
    required this.type,
    required this.healthLevel,
    required this.features,
    required this.ecosystemPoints,
    required this.lastUpdate,
  });

  factory PlanetModel.fromJson(Map<String, dynamic> json) =>
      _$PlanetModelFromJson(json);
  Map<String, dynamic> toJson() => _$PlanetModelToJson(this);
}

@JsonSerializable()
class PlanetFeature {
  final String id;
  final PlanetFeatureType type;
  final int level;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const PlanetFeature({
    required this.id,
    required this.type,
    required this.level,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory PlanetFeature.fromJson(Map<String, dynamic> json) =>
      _$PlanetFeatureFromJson(json);
  Map<String, dynamic> toJson() => _$PlanetFeatureToJson(this);
}

@JsonSerializable()
class NFTModel {
  final String id;
  final String name;
  final String description;
  final NFTRarity rarity;
  final NFTCategory category;
  final String imageUrl;
  final Map<String, dynamic> attributes;
  final DateTime earnedAt;
  final bool isEquipped;

  const NFTModel({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.category,
    required this.imageUrl,
    required this.attributes,
    required this.earnedAt,
    required this.isEquipped,
  });

  factory NFTModel.fromJson(Map<String, dynamic> json) =>
      _$NFTModelFromJson(json);
  Map<String, dynamic> toJson() => _$NFTModelToJson(this);
}

@JsonSerializable()
class UserStats {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double totalVolume;
  final double totalPnL;
  final double winRate;
  final int daysActive;
  final int achievementsUnlocked;

  const UserStats({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.totalVolume,
    required this.totalPnL,
    required this.winRate,
    required this.daysActive,
    required this.achievementsUnlocked,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

enum PlanetType {
  @JsonValue('garden')
  garden,
  @JsonValue('castle')
  castle,
  @JsonValue('planet')
  planet,
  @JsonValue('space_station')
  spaceStation,
}

enum PlanetFeatureType {
  @JsonValue('trees')
  trees,
  @JsonValue('buildings')
  buildings,
  @JsonValue('decorations')
  decorations,
  @JsonValue('energy_source')
  energySource,
  @JsonValue('defense')
  defense,
}

enum NFTRarity {
  @JsonValue('common')
  common,
  @JsonValue('uncommon')
  uncommon,
  @JsonValue('rare')
  rare,
  @JsonValue('epic')
  epic,
  @JsonValue('legendary')
  legendary,
}

enum NFTCategory {
  @JsonValue('milestone')
  milestone,
  @JsonValue('achievement')
  achievement,
  @JsonValue('planet_decoration')
  planetDecoration,
  @JsonValue('trading_tool')
  tradingTool,
  @JsonValue('special_event')
  specialEvent,
}
