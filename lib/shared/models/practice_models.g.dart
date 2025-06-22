// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeAccount _$PracticeAccountFromJson(Map<String, dynamic> json) =>
    PracticeAccount(
      id: json['id'] as String,
      balance: (json['balance'] as num).toDouble(),
      totalPnl: (json['totalPnl'] as num).toDouble(),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      totalTrades: (json['totalTrades'] as num).toInt(),
      winningTrades: (json['winningTrades'] as num).toInt(),
      losingTrades: (json['losingTrades'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
      maxDrawdown: (json['maxDrawdown'] as num).toDouble(),
      largestWin: (json['largestWin'] as num).toDouble(),
      largestLoss: (json['largestLoss'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastTradeAt: DateTime.parse(json['lastTradeAt'] as String),
      dailyPnl: (json['dailyPnl'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      currentStreak: (json['currentStreak'] as num).toInt(),
      maxStreak: (json['maxStreak'] as num).toInt(),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PracticeAccountToJson(PracticeAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'balance': instance.balance,
      'totalPnl': instance.totalPnl,
      'totalVolume': instance.totalVolume,
      'totalTrades': instance.totalTrades,
      'winningTrades': instance.winningTrades,
      'losingTrades': instance.losingTrades,
      'winRate': instance.winRate,
      'maxDrawdown': instance.maxDrawdown,
      'largestWin': instance.largestWin,
      'largestLoss': instance.largestLoss,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastTradeAt': instance.lastTradeAt.toIso8601String(),
      'dailyPnl': instance.dailyPnl,
      'currentStreak': instance.currentStreak,
      'maxStreak': instance.maxStreak,
      'achievements': instance.achievements,
    };

PracticeTrade _$PracticeTradeFromJson(Map<String, dynamic> json) =>
    PracticeTrade(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      direction: json['direction'] as String,
      entryPrice: (json['entryPrice'] as num).toDouble(),
      exitPrice: (json['exitPrice'] as num?)?.toDouble(),
      size: (json['size'] as num).toDouble(),
      leverage: (json['leverage'] as num).toDouble(),
      margin: (json['margin'] as num).toDouble(),
      openTime: DateTime.parse(json['openTime'] as String),
      closeTime: json['closeTime'] == null
          ? null
          : DateTime.parse(json['closeTime'] as String),
      status: json['status'] as String,
      pnl: (json['pnl'] as num?)?.toDouble(),
      pnlPercentage: (json['pnlPercentage'] as num?)?.toDouble(),
      stopLoss: (json['stopLoss'] as num?)?.toDouble(),
      takeProfit: (json['takeProfit'] as num?)?.toDouble(),
      commission: (json['commission'] as num).toDouble(),
      closeReason: json['closeReason'] as String?,
    );

Map<String, dynamic> _$PracticeTradeToJson(PracticeTrade instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'direction': instance.direction,
      'entryPrice': instance.entryPrice,
      'exitPrice': instance.exitPrice,
      'size': instance.size,
      'leverage': instance.leverage,
      'margin': instance.margin,
      'openTime': instance.openTime.toIso8601String(),
      'closeTime': instance.closeTime?.toIso8601String(),
      'status': instance.status,
      'pnl': instance.pnl,
      'pnlPercentage': instance.pnlPercentage,
      'stopLoss': instance.stopLoss,
      'takeProfit': instance.takeProfit,
      'commission': instance.commission,
      'closeReason': instance.closeReason,
    };

TradePosition _$TradePositionFromJson(Map<String, dynamic> json) =>
    TradePosition(
      symbol: json['symbol'] as String,
      direction: json['direction'] as String,
      totalSize: (json['totalSize'] as num).toDouble(),
      averageEntryPrice: (json['averageEntryPrice'] as num).toDouble(),
      totalMargin: (json['totalMargin'] as num).toDouble(),
      tradeIds:
          (json['tradeIds'] as List<dynamic>).map((e) => e as String).toList(),
      firstOpenTime: DateTime.parse(json['firstOpenTime'] as String),
      stopLoss: (json['stopLoss'] as num?)?.toDouble(),
      takeProfit: (json['takeProfit'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TradePositionToJson(TradePosition instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'direction': instance.direction,
      'totalSize': instance.totalSize,
      'averageEntryPrice': instance.averageEntryPrice,
      'totalMargin': instance.totalMargin,
      'tradeIds': instance.tradeIds,
      'firstOpenTime': instance.firstOpenTime.toIso8601String(),
      'stopLoss': instance.stopLoss,
      'takeProfit': instance.takeProfit,
    };

PracticeAnalytics _$PracticeAnalyticsFromJson(Map<String, dynamic> json) =>
    PracticeAnalytics(
      totalReturn: (json['totalReturn'] as num).toDouble(),
      totalReturnPercentage: (json['totalReturnPercentage'] as num).toDouble(),
      sharpeRatio: (json['sharpeRatio'] as num).toDouble(),
      maxDrawdown: (json['maxDrawdown'] as num).toDouble(),
      maxDrawdownPercentage: (json['maxDrawdownPercentage'] as num).toDouble(),
      averageWin: (json['averageWin'] as num).toDouble(),
      averageLoss: (json['averageLoss'] as num).toDouble(),
      profitFactor: (json['profitFactor'] as num).toDouble(),
      consecutiveWins: (json['consecutiveWins'] as num).toInt(),
      consecutiveLosses: (json['consecutiveLosses'] as num).toInt(),
      monthlyReturns: (json['monthlyReturns'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      tradingFrequency: Map<String, int>.from(json['tradingFrequency'] as Map),
      assetPerformance: (json['assetPerformance'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      dailyReturns: (json['dailyReturns'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$PracticeAnalyticsToJson(PracticeAnalytics instance) =>
    <String, dynamic>{
      'totalReturn': instance.totalReturn,
      'totalReturnPercentage': instance.totalReturnPercentage,
      'sharpeRatio': instance.sharpeRatio,
      'maxDrawdown': instance.maxDrawdown,
      'maxDrawdownPercentage': instance.maxDrawdownPercentage,
      'averageWin': instance.averageWin,
      'averageLoss': instance.averageLoss,
      'profitFactor': instance.profitFactor,
      'consecutiveWins': instance.consecutiveWins,
      'consecutiveLosses': instance.consecutiveLosses,
      'monthlyReturns': instance.monthlyReturns,
      'tradingFrequency': instance.tradingFrequency,
      'assetPerformance': instance.assetPerformance,
      'dailyReturns': instance.dailyReturns,
    };
