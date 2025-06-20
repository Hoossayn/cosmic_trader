// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketsResponse _$MarketsResponseFromJson(Map<String, dynamic> json) =>
    MarketsResponse(
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Market.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MarketsResponseToJson(MarketsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

Market _$MarketFromJson(Map<String, dynamic> json) => Market(
      name: json['name'] as String,
      uiName: json['uiName'] as String,
      category: json['category'] as String,
      assetName: json['assetName'] as String,
      assetPrecision: (json['assetPrecision'] as num).toInt(),
      collateralAssetName: json['collateralAssetName'] as String,
      collateralAssetPrecision:
          (json['collateralAssetPrecision'] as num).toInt(),
      active: json['active'] as bool,
      status: json['status'] as String,
      marketStats:
          MarketStats.fromJson(json['marketStats'] as Map<String, dynamic>),
      tradingConfig:
          TradingConfig.fromJson(json['tradingConfig'] as Map<String, dynamic>),
      l2Config: L2Config.fromJson(json['l2Config'] as Map<String, dynamic>),
      visibleOnUi: json['visibleOnUi'] as bool,
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$MarketToJson(Market instance) => <String, dynamic>{
      'name': instance.name,
      'uiName': instance.uiName,
      'category': instance.category,
      'assetName': instance.assetName,
      'assetPrecision': instance.assetPrecision,
      'collateralAssetName': instance.collateralAssetName,
      'collateralAssetPrecision': instance.collateralAssetPrecision,
      'active': instance.active,
      'status': instance.status,
      'marketStats': instance.marketStats,
      'tradingConfig': instance.tradingConfig,
      'l2Config': instance.l2Config,
      'visibleOnUi': instance.visibleOnUi,
      'createdAt': instance.createdAt,
    };

MarketStats _$MarketStatsFromJson(Map<String, dynamic> json) => MarketStats(
      dailyVolume: json['dailyVolume'] as String,
      dailyVolumeBase: json['dailyVolumeBase'] as String,
      dailyPriceChange: json['dailyPriceChange'] as String,
      dailyPriceChangePercentage: json['dailyPriceChangePercentage'] as String,
      dailyLow: json['dailyLow'] as String,
      dailyHigh: json['dailyHigh'] as String,
      lastPrice: json['lastPrice'] as String,
      askPrice: json['askPrice'] as String,
      bidPrice: json['bidPrice'] as String,
      markPrice: json['markPrice'] as String,
      indexPrice: json['indexPrice'] as String,
      fundingRate: json['fundingRate'] as String,
      nextFundingRate: (json['nextFundingRate'] as num).toInt(),
      openInterest: json['openInterest'] as String,
      openInterestBase: json['openInterestBase'] as String,
      deleverageLevels: DeleverageLevels.fromJson(
          json['deleverageLevels'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MarketStatsToJson(MarketStats instance) =>
    <String, dynamic>{
      'dailyVolume': instance.dailyVolume,
      'dailyVolumeBase': instance.dailyVolumeBase,
      'dailyPriceChange': instance.dailyPriceChange,
      'dailyPriceChangePercentage': instance.dailyPriceChangePercentage,
      'dailyLow': instance.dailyLow,
      'dailyHigh': instance.dailyHigh,
      'lastPrice': instance.lastPrice,
      'askPrice': instance.askPrice,
      'bidPrice': instance.bidPrice,
      'markPrice': instance.markPrice,
      'indexPrice': instance.indexPrice,
      'fundingRate': instance.fundingRate,
      'nextFundingRate': instance.nextFundingRate,
      'openInterest': instance.openInterest,
      'openInterestBase': instance.openInterestBase,
      'deleverageLevels': instance.deleverageLevels,
    };

DeleverageLevels _$DeleverageLevelsFromJson(Map<String, dynamic> json) =>
    DeleverageLevels(
      shortPositions: (json['shortPositions'] as List<dynamic>)
          .map((e) => DeleverageLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      longPositions: (json['longPositions'] as List<dynamic>)
          .map((e) => DeleverageLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeleverageLevelsToJson(DeleverageLevels instance) =>
    <String, dynamic>{
      'shortPositions': instance.shortPositions,
      'longPositions': instance.longPositions,
    };

DeleverageLevel _$DeleverageLevelFromJson(Map<String, dynamic> json) =>
    DeleverageLevel(
      level: (json['level'] as num).toInt(),
      rankingLowerBound: json['rankingLowerBound'] as String,
    );

Map<String, dynamic> _$DeleverageLevelToJson(DeleverageLevel instance) =>
    <String, dynamic>{
      'level': instance.level,
      'rankingLowerBound': instance.rankingLowerBound,
    };

TradingConfig _$TradingConfigFromJson(Map<String, dynamic> json) =>
    TradingConfig(
      minOrderSize: json['minOrderSize'] as String,
      minOrderSizeChange: json['minOrderSizeChange'] as String,
      minPriceChange: json['minPriceChange'] as String,
      maxMarketOrderValue: json['maxMarketOrderValue'] as String,
      maxLimitOrderValue: json['maxLimitOrderValue'] as String,
      maxPositionValue: json['maxPositionValue'] as String,
      maxLeverage: json['maxLeverage'] as String,
      maxNumOrders: json['maxNumOrders'] as String,
      limitPriceCap: json['limitPriceCap'] as String,
      limitPriceFloor: json['limitPriceFloor'] as String,
      riskFactorConfig: (json['riskFactorConfig'] as List<dynamic>)
          .map((e) => RiskFactorConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TradingConfigToJson(TradingConfig instance) =>
    <String, dynamic>{
      'minOrderSize': instance.minOrderSize,
      'minOrderSizeChange': instance.minOrderSizeChange,
      'minPriceChange': instance.minPriceChange,
      'maxMarketOrderValue': instance.maxMarketOrderValue,
      'maxLimitOrderValue': instance.maxLimitOrderValue,
      'maxPositionValue': instance.maxPositionValue,
      'maxLeverage': instance.maxLeverage,
      'maxNumOrders': instance.maxNumOrders,
      'limitPriceCap': instance.limitPriceCap,
      'limitPriceFloor': instance.limitPriceFloor,
      'riskFactorConfig': instance.riskFactorConfig,
    };

RiskFactorConfig _$RiskFactorConfigFromJson(Map<String, dynamic> json) =>
    RiskFactorConfig(
      upperBound: json['upperBound'] as String,
      riskFactor: json['riskFactor'] as String,
    );

Map<String, dynamic> _$RiskFactorConfigToJson(RiskFactorConfig instance) =>
    <String, dynamic>{
      'upperBound': instance.upperBound,
      'riskFactor': instance.riskFactor,
    };

L2Config _$L2ConfigFromJson(Map<String, dynamic> json) => L2Config(
      type: json['type'] as String,
      collateralId: json['collateralId'] as String,
      syntheticId: json['syntheticId'] as String,
      syntheticResolution: (json['syntheticResolution'] as num).toInt(),
      collateralResolution: (json['collateralResolution'] as num).toInt(),
    );

Map<String, dynamic> _$L2ConfigToJson(L2Config instance) => <String, dynamic>{
      'type': instance.type,
      'collateralId': instance.collateralId,
      'syntheticId': instance.syntheticId,
      'syntheticResolution': instance.syntheticResolution,
      'collateralResolution': instance.collateralResolution,
    };
