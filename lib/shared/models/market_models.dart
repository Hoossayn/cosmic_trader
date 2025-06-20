import 'package:json_annotation/json_annotation.dart';

part 'market_models.g.dart';

@JsonSerializable()
class MarketsResponse {
  final String status;
  final List<Market> data;

  const MarketsResponse({required this.status, required this.data});

  factory MarketsResponse.fromJson(Map<String, dynamic> json) =>
      _$MarketsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MarketsResponseToJson(this);
}

@JsonSerializable()
class Market {
  final String name;
  final String uiName;
  final String category;
  final String assetName;
  final int assetPrecision;
  final String collateralAssetName;
  final int collateralAssetPrecision;
  final bool active;
  final String status;
  final MarketStats marketStats;
  final TradingConfig tradingConfig;
  final L2Config l2Config;
  final bool visibleOnUi;
  final int createdAt;

  const Market({
    required this.name,
    required this.uiName,
    required this.category,
    required this.assetName,
    required this.assetPrecision,
    required this.collateralAssetName,
    required this.collateralAssetPrecision,
    required this.active,
    required this.status,
    required this.marketStats,
    required this.tradingConfig,
    required this.l2Config,
    required this.visibleOnUi,
    required this.createdAt,
  });

  factory Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);
  Map<String, dynamic> toJson() => _$MarketToJson(this);

  // Computed properties for easier UI use
  double get price => double.tryParse(marketStats.lastPrice) ?? 0.0;
  double get priceChange =>
      double.tryParse(marketStats.dailyPriceChange) ?? 0.0;
  double get priceChangePercentage =>
      double.tryParse(marketStats.dailyPriceChangePercentage) ?? 0.0;
  double get volume => double.tryParse(marketStats.dailyVolume) ?? 0.0;
  double get maxLeverageValue =>
      double.tryParse(tradingConfig.maxLeverage) ?? 1.0;

  bool get isPositive => priceChangePercentage >= 0;
}

@JsonSerializable()
class MarketStats {
  final String dailyVolume;
  final String dailyVolumeBase;
  final String dailyPriceChange;
  final String dailyPriceChangePercentage;
  final String dailyLow;
  final String dailyHigh;
  final String lastPrice;
  final String askPrice;
  final String bidPrice;
  final String markPrice;
  final String indexPrice;
  final String fundingRate;
  final int nextFundingRate;
  final String openInterest;
  final String openInterestBase;
  final DeleverageLevels deleverageLevels;

  const MarketStats({
    required this.dailyVolume,
    required this.dailyVolumeBase,
    required this.dailyPriceChange,
    required this.dailyPriceChangePercentage,
    required this.dailyLow,
    required this.dailyHigh,
    required this.lastPrice,
    required this.askPrice,
    required this.bidPrice,
    required this.markPrice,
    required this.indexPrice,
    required this.fundingRate,
    required this.nextFundingRate,
    required this.openInterest,
    required this.openInterestBase,
    required this.deleverageLevels,
  });

  factory MarketStats.fromJson(Map<String, dynamic> json) =>
      _$MarketStatsFromJson(json);
  Map<String, dynamic> toJson() => _$MarketStatsToJson(this);
}

@JsonSerializable()
class DeleverageLevels {
  final List<DeleverageLevel> shortPositions;
  final List<DeleverageLevel> longPositions;

  const DeleverageLevels({
    required this.shortPositions,
    required this.longPositions,
  });

  factory DeleverageLevels.fromJson(Map<String, dynamic> json) =>
      _$DeleverageLevelsFromJson(json);
  Map<String, dynamic> toJson() => _$DeleverageLevelsToJson(this);
}

@JsonSerializable()
class DeleverageLevel {
  final int level;
  final String rankingLowerBound;

  const DeleverageLevel({required this.level, required this.rankingLowerBound});

  factory DeleverageLevel.fromJson(Map<String, dynamic> json) =>
      _$DeleverageLevelFromJson(json);
  Map<String, dynamic> toJson() => _$DeleverageLevelToJson(this);
}

@JsonSerializable()
class TradingConfig {
  final String minOrderSize;
  final String minOrderSizeChange;
  final String minPriceChange;
  final String maxMarketOrderValue;
  final String maxLimitOrderValue;
  final String maxPositionValue;
  final String maxLeverage;
  final String maxNumOrders;
  final String limitPriceCap;
  final String limitPriceFloor;
  final List<RiskFactorConfig> riskFactorConfig;

  const TradingConfig({
    required this.minOrderSize,
    required this.minOrderSizeChange,
    required this.minPriceChange,
    required this.maxMarketOrderValue,
    required this.maxLimitOrderValue,
    required this.maxPositionValue,
    required this.maxLeverage,
    required this.maxNumOrders,
    required this.limitPriceCap,
    required this.limitPriceFloor,
    required this.riskFactorConfig,
  });

  factory TradingConfig.fromJson(Map<String, dynamic> json) =>
      _$TradingConfigFromJson(json);
  Map<String, dynamic> toJson() => _$TradingConfigToJson(this);
}

@JsonSerializable()
class RiskFactorConfig {
  final String upperBound;
  final String riskFactor;

  const RiskFactorConfig({required this.upperBound, required this.riskFactor});

  factory RiskFactorConfig.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RiskFactorConfigToJson(this);
}

@JsonSerializable()
class L2Config {
  final String type;
  final String collateralId;
  final String syntheticId;
  final int syntheticResolution;
  final int collateralResolution;

  const L2Config({
    required this.type,
    required this.collateralId,
    required this.syntheticId,
    required this.syntheticResolution,
    required this.collateralResolution,
  });

  factory L2Config.fromJson(Map<String, dynamic> json) =>
      _$L2ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$L2ConfigToJson(this);
}
