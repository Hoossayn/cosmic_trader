// Practice Mode Models
import 'package:json_annotation/json_annotation.dart';

part 'practice_models.g.dart';

@JsonSerializable()
class PracticeAccount {
  final String id;
  final double balance;
  final double totalPnl;
  final double totalVolume;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double maxDrawdown;
  final double largestWin;
  final double largestLoss;
  final DateTime createdAt;
  final DateTime lastTradeAt;
  final Map<String, double> dailyPnl; // Date -> PnL
  final int currentStreak;
  final int maxStreak;
  final List<String> achievements;

  const PracticeAccount({
    required this.id,
    required this.balance,
    required this.totalPnl,
    required this.totalVolume,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.maxDrawdown,
    required this.largestWin,
    required this.largestLoss,
    required this.createdAt,
    required this.lastTradeAt,
    required this.dailyPnl,
    required this.currentStreak,
    required this.maxStreak,
    required this.achievements,
  });

  factory PracticeAccount.initial() {
    final now = DateTime.now();
    return PracticeAccount(
      id: 'practice_${now.millisecondsSinceEpoch}',
      balance: 10000.0,
      totalPnl: 0.0,
      totalVolume: 0.0,
      totalTrades: 0,
      winningTrades: 0,
      losingTrades: 0,
      winRate: 0.0,
      maxDrawdown: 0.0,
      largestWin: 0.0,
      largestLoss: 0.0,
      createdAt: now,
      lastTradeAt: now,
      dailyPnl: {},
      currentStreak: 0,
      maxStreak: 0,
      achievements: [],
    );
  }

  double get availableMargin =>
      balance * 0.95; // 95% of balance available for trading

  double get equity => balance + _calculateUnrealizedPnl();

  double _calculateUnrealizedPnl() {
    // This would be calculated from open positions
    // For now, returning 0 as positions will be managed separately
    return 0.0;
  }

  PracticeAccount copyWith({
    String? id,
    double? balance,
    double? totalPnl,
    double? totalVolume,
    int? totalTrades,
    int? winningTrades,
    int? losingTrades,
    double? winRate,
    double? maxDrawdown,
    double? largestWin,
    double? largestLoss,
    DateTime? createdAt,
    DateTime? lastTradeAt,
    Map<String, double>? dailyPnl,
    int? currentStreak,
    int? maxStreak,
    List<String>? achievements,
  }) {
    return PracticeAccount(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      totalPnl: totalPnl ?? this.totalPnl,
      totalVolume: totalVolume ?? this.totalVolume,
      totalTrades: totalTrades ?? this.totalTrades,
      winningTrades: winningTrades ?? this.winningTrades,
      losingTrades: losingTrades ?? this.losingTrades,
      winRate: winRate ?? this.winRate,
      maxDrawdown: maxDrawdown ?? this.maxDrawdown,
      largestWin: largestWin ?? this.largestWin,
      largestLoss: largestLoss ?? this.largestLoss,
      createdAt: createdAt ?? this.createdAt,
      lastTradeAt: lastTradeAt ?? this.lastTradeAt,
      dailyPnl: dailyPnl ?? this.dailyPnl,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      achievements: achievements ?? this.achievements,
    );
  }

  factory PracticeAccount.fromJson(Map<String, dynamic> json) =>
      _$PracticeAccountFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeAccountToJson(this);
}

@JsonSerializable()
class PracticeTrade {
  final String id;
  final String symbol;
  final String direction; // 'long' or 'short'
  final double entryPrice;
  final double? exitPrice;
  final double size;
  final double leverage;
  final double margin;
  final DateTime openTime;
  final DateTime? closeTime;
  final String status; // 'open', 'closed', 'liquidated'
  final double? pnl;
  final double? pnlPercentage;
  final double? stopLoss;
  final double? takeProfit;
  final double commission;
  final String?
  closeReason; // 'manual', 'stop_loss', 'take_profit', 'liquidation'

  const PracticeTrade({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.entryPrice,
    this.exitPrice,
    required this.size,
    required this.leverage,
    required this.margin,
    required this.openTime,
    this.closeTime,
    required this.status,
    this.pnl,
    this.pnlPercentage,
    this.stopLoss,
    this.takeProfit,
    required this.commission,
    this.closeReason,
  });

  double get notionalValue => size * entryPrice;

  double calculateUnrealizedPnl(double currentPrice) {
    if (status != 'open') return pnl ?? 0.0;

    final priceDiff = direction == 'long'
        ? currentPrice - entryPrice
        : entryPrice - currentPrice;

    return (priceDiff / entryPrice) * notionalValue;
  }

  double calculateUnrealizedPnlPercentage(double currentPrice) {
    if (status != 'open') return pnlPercentage ?? 0.0;

    final unrealizedPnl = calculateUnrealizedPnl(currentPrice);
    return (unrealizedPnl / margin) * 100;
  }

  bool shouldLiquidate(double currentPrice) {
    if (status != 'open') return false;

    final unrealizedPnlPerc = calculateUnrealizedPnlPercentage(currentPrice);
    return unrealizedPnlPerc <= -95.0; // Liquidate at 95% loss
  }

  bool shouldTriggerStopLoss(double currentPrice) {
    if (status != 'open' || stopLoss == null) return false;

    return direction == 'long'
        ? currentPrice <= stopLoss!
        : currentPrice >= stopLoss!;
  }

  bool shouldTriggerTakeProfit(double currentPrice) {
    if (status != 'open' || takeProfit == null) return false;

    return direction == 'long'
        ? currentPrice >= takeProfit!
        : currentPrice <= takeProfit!;
  }

  PracticeTrade copyWith({
    String? id,
    String? symbol,
    String? direction,
    double? entryPrice,
    double? exitPrice,
    double? size,
    double? leverage,
    double? margin,
    DateTime? openTime,
    DateTime? closeTime,
    String? status,
    double? pnl,
    double? pnlPercentage,
    double? stopLoss,
    double? takeProfit,
    double? commission,
    String? closeReason,
  }) {
    return PracticeTrade(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      direction: direction ?? this.direction,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      size: size ?? this.size,
      leverage: leverage ?? this.leverage,
      margin: margin ?? this.margin,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      status: status ?? this.status,
      pnl: pnl ?? this.pnl,
      pnlPercentage: pnlPercentage ?? this.pnlPercentage,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      commission: commission ?? this.commission,
      closeReason: closeReason ?? this.closeReason,
    );
  }

  factory PracticeTrade.fromJson(Map<String, dynamic> json) =>
      _$PracticeTradeFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeTradeToJson(this);
}

@JsonSerializable()
class TradePosition {
  final String symbol;
  final String direction;
  final double totalSize;
  final double averageEntryPrice;
  final double totalMargin;
  final List<String> tradeIds;
  final DateTime firstOpenTime;
  final double? stopLoss;
  final double? takeProfit;

  const TradePosition({
    required this.symbol,
    required this.direction,
    required this.totalSize,
    required this.averageEntryPrice,
    required this.totalMargin,
    required this.tradeIds,
    required this.firstOpenTime,
    this.stopLoss,
    this.takeProfit,
  });

  double get notionalValue => totalSize * averageEntryPrice;

  double calculateUnrealizedPnl(double currentPrice) {
    final priceDiff = direction == 'long'
        ? currentPrice - averageEntryPrice
        : averageEntryPrice - currentPrice;

    return (priceDiff / averageEntryPrice) * notionalValue;
  }

  double calculateUnrealizedPnlPercentage(double currentPrice) {
    final unrealizedPnl = calculateUnrealizedPnl(currentPrice);
    return (unrealizedPnl / totalMargin) * 100;
  }

  factory TradePosition.fromJson(Map<String, dynamic> json) =>
      _$TradePositionFromJson(json);

  Map<String, dynamic> toJson() => _$TradePositionToJson(this);
}

@JsonSerializable()
class PracticeAnalytics {
  final double totalReturn;
  final double totalReturnPercentage;
  final double sharpeRatio;
  final double maxDrawdown;
  final double maxDrawdownPercentage;
  final double averageWin;
  final double averageLoss;
  final double profitFactor;
  final int consecutiveWins;
  final int consecutiveLosses;
  final Map<String, double> monthlyReturns;
  final Map<String, int> tradingFrequency;
  final Map<String, double> assetPerformance;
  final List<double> dailyReturns;

  const PracticeAnalytics({
    required this.totalReturn,
    required this.totalReturnPercentage,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.maxDrawdownPercentage,
    required this.averageWin,
    required this.averageLoss,
    required this.profitFactor,
    required this.consecutiveWins,
    required this.consecutiveLosses,
    required this.monthlyReturns,
    required this.tradingFrequency,
    required this.assetPerformance,
    required this.dailyReturns,
  });

  factory PracticeAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PracticeAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$PracticeAnalyticsToJson(this);
}

enum PracticeAchievement {
  firstTrade,
  firstProfit,
  tenTrades,
  hundredTrades,
  profitableWeek,
  profitableMonth,
  winStreak5,
  winStreak10,
  noLossWeek,
  bigWin,
  riskManager,
  dayTrader,
  swingTrader,
  diversified,
}

extension PracticeAchievementExtension on PracticeAchievement {
  String get title {
    switch (this) {
      case PracticeAchievement.firstTrade:
        return 'First Trade';
      case PracticeAchievement.firstProfit:
        return 'First Profit';
      case PracticeAchievement.tenTrades:
        return 'Getting Started';
      case PracticeAchievement.hundredTrades:
        return 'Experienced Trader';
      case PracticeAchievement.profitableWeek:
        return 'Profitable Week';
      case PracticeAchievement.profitableMonth:
        return 'Profitable Month';
      case PracticeAchievement.winStreak5:
        return 'Win Streak';
      case PracticeAchievement.winStreak10:
        return 'Hot Streak';
      case PracticeAchievement.noLossWeek:
        return 'Perfect Week';
      case PracticeAchievement.bigWin:
        return 'Big Winner';
      case PracticeAchievement.riskManager:
        return 'Risk Manager';
      case PracticeAchievement.dayTrader:
        return 'Day Trader';
      case PracticeAchievement.swingTrader:
        return 'Swing Trader';
      case PracticeAchievement.diversified:
        return 'Diversified';
    }
  }

  String get description {
    switch (this) {
      case PracticeAchievement.firstTrade:
        return 'Complete your first practice trade';
      case PracticeAchievement.firstProfit:
        return 'Make your first profitable trade';
      case PracticeAchievement.tenTrades:
        return 'Complete 10 practice trades';
      case PracticeAchievement.hundredTrades:
        return 'Complete 100 practice trades';
      case PracticeAchievement.profitableWeek:
        return 'Be profitable for a week';
      case PracticeAchievement.profitableMonth:
        return 'Be profitable for a month';
      case PracticeAchievement.winStreak5:
        return 'Win 5 trades in a row';
      case PracticeAchievement.winStreak10:
        return 'Win 10 trades in a row';
      case PracticeAchievement.noLossWeek:
        return 'No losing trades for a week';
      case PracticeAchievement.bigWin:
        return 'Make a single trade profit of \$500+';
      case PracticeAchievement.riskManager:
        return 'Use stop losses on 10 consecutive trades';
      case PracticeAchievement.dayTrader:
        return 'Close 5 trades within the same day';
      case PracticeAchievement.swingTrader:
        return 'Hold a position for more than 7 days';
      case PracticeAchievement.diversified:
        return 'Trade 5 different assets in a week';
    }
  }

  String get icon {
    switch (this) {
      case PracticeAchievement.firstTrade:
        return '🚀';
      case PracticeAchievement.firstProfit:
        return '💰';
      case PracticeAchievement.tenTrades:
        return '📈';
      case PracticeAchievement.hundredTrades:
        return '🎯';
      case PracticeAchievement.profitableWeek:
        return '📅';
      case PracticeAchievement.profitableMonth:
        return '🗓️';
      case PracticeAchievement.winStreak5:
        return '🔥';
      case PracticeAchievement.winStreak10:
        return '⚡';
      case PracticeAchievement.noLossWeek:
        return '💎';
      case PracticeAchievement.bigWin:
        return '🎊';
      case PracticeAchievement.riskManager:
        return '🛡️';
      case PracticeAchievement.dayTrader:
        return '⚡';
      case PracticeAchievement.swingTrader:
        return '📊';
      case PracticeAchievement.diversified:
        return '🌟';
    }
  }
}
