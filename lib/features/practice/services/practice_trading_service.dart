import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../shared/models/practice_models.dart';

class PracticeTradingService {
  static const String _accountKey = 'practice_account';
  static const String _tradesKey = 'practice_trades';
  static const String _positionsKey = 'practice_positions';

  final math.Random _random = math.Random();
  Timer? _priceUpdateTimer;

  // Stream controllers for real-time updates
  final _accountController = StreamController<PracticeAccount>.broadcast();
  final _tradesController = StreamController<List<PracticeTrade>>.broadcast();
  final _positionsController =
      StreamController<List<TradePosition>>.broadcast();

  // Current state
  PracticeAccount? _currentAccount;
  List<PracticeTrade> _trades = [];
  List<TradePosition> _positions = [];
  Map<String, double> _currentPrices = {};

  // Streams
  Stream<PracticeAccount> get accountStream => _accountController.stream;
  Stream<List<PracticeTrade>> get tradesStream => _tradesController.stream;
  Stream<List<TradePosition>> get positionsStream =>
      _positionsController.stream;

  // Getters
  PracticeAccount? get currentAccount => _currentAccount;
  List<PracticeTrade> get trades => List.unmodifiable(_trades);
  List<TradePosition> get positions => List.unmodifiable(_positions);

  Future<void> initialize() async {
    await _loadData();
    _startPriceSimulation();
  }

  void dispose() {
    _priceUpdateTimer?.cancel();
    _accountController.close();
    _tradesController.close();
    _positionsController.close();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load account
    final accountJson = prefs.getString(_accountKey);
    if (accountJson != null) {
      _currentAccount = PracticeAccount.fromJson(jsonDecode(accountJson));
    } else {
      _currentAccount = PracticeAccount.initial();
      await _saveAccount();
    }

    // Load trades
    final tradesJson = prefs.getString(_tradesKey);
    if (tradesJson != null) {
      final List<dynamic> tradesList = jsonDecode(tradesJson);
      _trades = tradesList.map((json) => PracticeTrade.fromJson(json)).toList();
    }

    // Load positions
    final positionsJson = prefs.getString(_positionsKey);
    if (positionsJson != null) {
      final List<dynamic> positionsList = jsonDecode(positionsJson);
      _positions = positionsList
          .map((json) => TradePosition.fromJson(json))
          .toList();
    }

    // Emit initial data
    _accountController.add(_currentAccount!);
    _tradesController.add(_trades);
    _positionsController.add(_positions);
  }

  Future<void> _saveAccount() async {
    if (_currentAccount == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountKey, jsonEncode(_currentAccount!.toJson()));
    _accountController.add(_currentAccount!);
  }

  Future<void> _saveTrades() async {
    final prefs = await SharedPreferences.getInstance();
    final tradesJson = _trades.map((trade) => trade.toJson()).toList();
    await prefs.setString(_tradesKey, jsonEncode(tradesJson));
    _tradesController.add(_trades);
  }

  Future<void> _savePositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsJson = _positions
        .map((position) => position.toJson())
        .toList();
    await prefs.setString(_positionsKey, jsonEncode(positionsJson));
    _positionsController.add(_positions);
  }

  void _startPriceSimulation() {
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updatePrices();
      _checkOpenTrades();
    });
  }

  void _updatePrices() {
    // Simulate realistic price movements with volatility
    for (final symbol in _currentPrices.keys) {
      final currentPrice = _currentPrices[symbol]!;
      final volatility = _getVolatilityForSymbol(symbol);
      final change =
          (_random.nextDouble() - 0.5) * 2 * volatility * currentPrice;
      _currentPrices[symbol] = math.max(0.0001, currentPrice + change);
    }
  }

  double _getVolatilityForSymbol(String symbol) {
    // Different assets have different volatilities
    if (symbol.contains('BTC')) return 0.02; // 2% max move per update
    if (symbol.contains('ETH')) return 0.025; // 2.5% max move
    if (symbol.contains('SOL')) return 0.03; // 3% max move
    if (symbol.contains('DOGE') || symbol.contains('SHIB'))
      return 0.05; // 5% max move (meme coins)
    return 0.02; // Default 2%
  }

  void _checkOpenTrades() {
    final openTrades = _trades
        .where((trade) => trade.status == 'open')
        .toList();

    for (final trade in openTrades) {
      final currentPrice = _currentPrices[trade.symbol];
      if (currentPrice == null) continue;

      // Check for liquidation
      if (trade.shouldLiquidate(currentPrice)) {
        _liquidateTrade(trade, currentPrice);
        continue;
      }

      // Check for stop loss
      if (trade.shouldTriggerStopLoss(currentPrice)) {
        _closeTrade(trade, currentPrice, 'stop_loss');
        continue;
      }

      // Check for take profit
      if (trade.shouldTriggerTakeProfit(currentPrice)) {
        _closeTrade(trade, currentPrice, 'take_profit');
        continue;
      }
    }
  }

  Future<PracticeTrade> openTrade({
    required String symbol,
    required String direction,
    required double size,
    required double leverage,
    double? stopLoss,
    double? takeProfit,
  }) async {
    if (_currentAccount == null) throw Exception('No practice account found');

    // Get current price (simulate getting from market data)
    final currentPrice = _getCurrentPrice(symbol);
    final margin = size / leverage;
    final commission = size * 0.0006; // 0.06% commission

    // Check if account has enough balance
    if (margin + commission > _currentAccount!.balance) {
      throw Exception('Insufficient balance');
    }

    // Create trade
    final trade = PracticeTrade(
      id: 'trade_${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      direction: direction,
      entryPrice: currentPrice,
      size: size,
      leverage: leverage,
      margin: margin,
      openTime: DateTime.now(),
      status: 'open',
      commission: commission,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );

    // Update account balance
    _currentAccount = _currentAccount!.copyWith(
      balance: _currentAccount!.balance - margin - commission,
      totalVolume: _currentAccount!.totalVolume + size,
      totalTrades: _currentAccount!.totalTrades + 1,
      lastTradeAt: DateTime.now(),
    );

    // Add trade
    _trades.add(trade);

    // Update or create position
    _updatePosition(trade);

    // Check for achievements
    await _checkAchievements();

    // Save data
    await _saveAccount();
    await _saveTrades();
    await _savePositions();

    return trade;
  }

  Future<void> closeTrade(String tradeId, {double? partialPercentage}) async {
    final tradeIndex = _trades.indexWhere((t) => t.id == tradeId);
    if (tradeIndex == -1) throw Exception('Trade not found');

    final trade = _trades[tradeIndex];
    if (trade.status != 'open') throw Exception('Trade is not open');

    final currentPrice = _getCurrentPrice(trade.symbol);

    if (partialPercentage != null && partialPercentage < 1.0) {
      await _partialCloseTrade(trade, currentPrice, partialPercentage);
    } else {
      await _closeTrade(trade, currentPrice, 'manual');
    }
  }

  Future<void> _closeTrade(
    PracticeTrade trade,
    double exitPrice,
    String reason,
  ) async {
    final pnl = trade.calculateUnrealizedPnl(exitPrice);
    final pnlPercentage = trade.calculateUnrealizedPnlPercentage(exitPrice);

    // Update trade
    final closedTrade = trade.copyWith(
      exitPrice: exitPrice,
      closeTime: DateTime.now(),
      status: 'closed',
      pnl: pnl,
      pnlPercentage: pnlPercentage,
      closeReason: reason,
    );

    _trades[_trades.indexWhere((t) => t.id == trade.id)] = closedTrade;

    // Update account
    final newBalance = _currentAccount!.balance + trade.margin + pnl;
    final isWin = pnl > 0;

    _currentAccount = _currentAccount!.copyWith(
      balance: newBalance,
      totalPnl: _currentAccount!.totalPnl + pnl,
      winningTrades: isWin
          ? _currentAccount!.winningTrades + 1
          : _currentAccount!.winningTrades,
      losingTrades: !isWin
          ? _currentAccount!.losingTrades + 1
          : _currentAccount!.losingTrades,
      winRate: _calculateWinRate(),
      largestWin: isWin && pnl > _currentAccount!.largestWin
          ? pnl
          : _currentAccount!.largestWin,
      largestLoss: !isWin && pnl.abs() > _currentAccount!.largestLoss
          ? pnl.abs()
          : _currentAccount!.largestLoss,
      currentStreak: _updateStreak(isWin),
      lastTradeAt: DateTime.now(),
    );

    // Update positions
    _updatePositionAfterClose(trade);

    // Check for achievements
    await _checkAchievements();

    // Save data
    await _saveAccount();
    await _saveTrades();
    await _savePositions();
  }

  Future<void> _partialCloseTrade(
    PracticeTrade trade,
    double exitPrice,
    double percentage,
  ) async {
    final partialSize = trade.size * percentage;
    final partialMargin = trade.margin * percentage;
    final partialPnl = trade.calculateUnrealizedPnl(exitPrice) * percentage;

    // Create new trade for the closed portion
    final closedTrade = trade.copyWith(
      id: '${trade.id}_partial_${DateTime.now().millisecondsSinceEpoch}',
      size: partialSize,
      margin: partialMargin,
      exitPrice: exitPrice,
      closeTime: DateTime.now(),
      status: 'closed',
      pnl: partialPnl,
      pnlPercentage: (partialPnl / partialMargin) * 100,
      closeReason: 'partial_close',
    );

    // Update original trade
    final remainingTrade = trade.copyWith(
      size: trade.size - partialSize,
      margin: trade.margin - partialMargin,
    );

    // Replace original trade and add closed portion
    _trades[_trades.indexWhere((t) => t.id == trade.id)] = remainingTrade;
    _trades.add(closedTrade);

    // Update account
    final newBalance = _currentAccount!.balance + partialMargin + partialPnl;
    _currentAccount = _currentAccount!.copyWith(
      balance: newBalance,
      totalPnl: _currentAccount!.totalPnl + partialPnl,
    );

    // Update positions
    _updatePositionAfterPartialClose(trade, percentage);

    await _saveAccount();
    await _saveTrades();
    await _savePositions();
  }

  Future<void> _liquidateTrade(
    PracticeTrade trade,
    double liquidationPrice,
  ) async {
    final liquidationPnl = -trade.margin * 0.95; // Lose 95% of margin

    final liquidatedTrade = trade.copyWith(
      exitPrice: liquidationPrice,
      closeTime: DateTime.now(),
      status: 'liquidated',
      pnl: liquidationPnl,
      pnlPercentage: -95.0,
      closeReason: 'liquidation',
    );

    _trades[_trades.indexWhere((t) => t.id == trade.id)] = liquidatedTrade;

    // Update account (only return 5% of margin)
    _currentAccount = _currentAccount!.copyWith(
      balance: _currentAccount!.balance + (trade.margin * 0.05),
      totalPnl: _currentAccount!.totalPnl + liquidationPnl,
      losingTrades: _currentAccount!.losingTrades + 1,
      winRate: _calculateWinRate(),
      currentStreak: 0, // Reset streak on liquidation
    );

    _updatePositionAfterClose(trade);

    await _saveAccount();
    await _saveTrades();
    await _savePositions();
  }

  double _getCurrentPrice(String symbol) {
    // If we don't have a current price, generate a realistic starting price
    if (!_currentPrices.containsKey(symbol)) {
      _currentPrices[symbol] = _generateStartingPrice(symbol);
    }
    return _currentPrices[symbol]!;
  }

  double _generateStartingPrice(String symbol) {
    // Generate realistic starting prices based on symbol
    if (symbol.contains('BTC')) return 45000 + (_random.nextDouble() * 20000);
    if (symbol.contains('ETH')) return 2500 + (_random.nextDouble() * 1500);
    if (symbol.contains('SOL')) return 80 + (_random.nextDouble() * 120);
    if (symbol.contains('DOGE')) return 0.08 + (_random.nextDouble() * 0.15);
    if (symbol.contains('ADA')) return 0.35 + (_random.nextDouble() * 0.45);
    return 100 + (_random.nextDouble() * 500); // Default range
  }

  void _updatePosition(PracticeTrade trade) {
    final existingIndex = _positions.indexWhere(
      (p) => p.symbol == trade.symbol && p.direction == trade.direction,
    );

    if (existingIndex >= 0) {
      // Update existing position
      final existing = _positions[existingIndex];
      final newTotalSize = existing.totalSize + trade.size;
      final newTotalMargin = existing.totalMargin + trade.margin;
      final newAveragePrice =
          ((existing.averageEntryPrice * existing.totalSize) +
              (trade.entryPrice * trade.size)) /
          newTotalSize;

      _positions[existingIndex] = TradePosition(
        symbol: trade.symbol,
        direction: trade.direction,
        totalSize: newTotalSize,
        averageEntryPrice: newAveragePrice,
        totalMargin: newTotalMargin,
        tradeIds: [...existing.tradeIds, trade.id],
        firstOpenTime: existing.firstOpenTime,
        stopLoss: trade.stopLoss ?? existing.stopLoss,
        takeProfit: trade.takeProfit ?? existing.takeProfit,
      );
    } else {
      // Create new position
      _positions.add(
        TradePosition(
          symbol: trade.symbol,
          direction: trade.direction,
          totalSize: trade.size,
          averageEntryPrice: trade.entryPrice,
          totalMargin: trade.margin,
          tradeIds: [trade.id],
          firstOpenTime: trade.openTime,
          stopLoss: trade.stopLoss,
          takeProfit: trade.takeProfit,
        ),
      );
    }
  }

  void _updatePositionAfterClose(PracticeTrade trade) {
    final positionIndex = _positions.indexWhere(
      (p) => p.symbol == trade.symbol && p.direction == trade.direction,
    );

    if (positionIndex >= 0) {
      final position = _positions[positionIndex];
      final newTradeIds = position.tradeIds
          .where((id) => id != trade.id)
          .toList();

      if (newTradeIds.isEmpty) {
        // Remove position if no more trades
        _positions.removeAt(positionIndex);
      } else {
        // Recalculate position based on remaining trades
        final remainingTrades = _trades
            .where((t) => newTradeIds.contains(t.id) && t.status == 'open')
            .toList();

        if (remainingTrades.isNotEmpty) {
          final totalSize = remainingTrades.fold(0.0, (sum, t) => sum + t.size);
          final totalMargin = remainingTrades.fold(
            0.0,
            (sum, t) => sum + t.margin,
          );
          final avgPrice =
              remainingTrades.fold(
                0.0,
                (sum, t) => sum + (t.entryPrice * t.size),
              ) /
              totalSize;

          _positions[positionIndex] = TradePosition(
            symbol: position.symbol,
            direction: position.direction,
            totalSize: totalSize,
            averageEntryPrice: avgPrice,
            totalMargin: totalMargin,
            tradeIds: newTradeIds,
            firstOpenTime: position.firstOpenTime,
            stopLoss: position.stopLoss,
            takeProfit: position.takeProfit,
          );
        } else {
          _positions.removeAt(positionIndex);
        }
      }
    }
  }

  void _updatePositionAfterPartialClose(
    PracticeTrade trade,
    double percentage,
  ) {
    final positionIndex = _positions.indexWhere(
      (p) => p.symbol == trade.symbol && p.direction == trade.direction,
    );

    if (positionIndex >= 0) {
      final position = _positions[positionIndex];
      final newTotalSize = position.totalSize - (trade.size * percentage);
      final newTotalMargin = position.totalMargin - (trade.margin * percentage);

      _positions[positionIndex] = TradePosition(
        symbol: position.symbol,
        direction: position.direction,
        totalSize: newTotalSize,
        averageEntryPrice: position.averageEntryPrice,
        totalMargin: newTotalMargin,
        tradeIds: position.tradeIds,
        firstOpenTime: position.firstOpenTime,
        stopLoss: position.stopLoss,
        takeProfit: position.takeProfit,
      );
    }
  }

  double _calculateWinRate() {
    final totalClosedTrades =
        _currentAccount!.winningTrades + _currentAccount!.losingTrades;
    if (totalClosedTrades == 0) return 0.0;
    return (_currentAccount!.winningTrades / totalClosedTrades) * 100;
  }

  int _updateStreak(bool isWin) {
    if (isWin) {
      final newStreak = _currentAccount!.currentStreak >= 0
          ? _currentAccount!.currentStreak + 1
          : 1;
      return newStreak;
    } else {
      final newStreak = _currentAccount!.currentStreak <= 0
          ? _currentAccount!.currentStreak - 1
          : -1;
      return newStreak;
    }
  }

  Future<void> _checkAchievements() async {
    // Implementation would check for various achievements and add them to the account
    // This is a placeholder for the achievement system
  }

  Future<void> resetAccount() async {
    _currentAccount = PracticeAccount.initial();
    _trades.clear();
    _positions.clear();
    _currentPrices.clear();

    await _saveAccount();
    await _saveTrades();
    await _savePositions();
  }

  PracticeAnalytics calculateAnalytics() {
    final closedTrades = _trades.where((t) => t.status == 'closed').toList();

    if (closedTrades.isEmpty) {
      return const PracticeAnalytics(
        totalReturn: 0.0,
        totalReturnPercentage: 0.0,
        sharpeRatio: 0.0,
        maxDrawdown: 0.0,
        maxDrawdownPercentage: 0.0,
        averageWin: 0.0,
        averageLoss: 0.0,
        profitFactor: 0.0,
        consecutiveWins: 0,
        consecutiveLosses: 0,
        monthlyReturns: {},
        tradingFrequency: {},
        assetPerformance: {},
        dailyReturns: [],
      );
    }

    final winningTrades = closedTrades.where((t) => (t.pnl ?? 0) > 0).toList();
    final losingTrades = closedTrades.where((t) => (t.pnl ?? 0) < 0).toList();

    final totalReturn = _currentAccount!.totalPnl;
    final totalReturnPercentage =
        (totalReturn / 10000) * 100; // 10k starting balance

    final averageWin = winningTrades.isEmpty
        ? 0.0
        : winningTrades.fold(0.0, (sum, t) => sum + (t.pnl ?? 0)) /
              winningTrades.length;

    final averageLoss = losingTrades.isEmpty
        ? 0.0
        : losingTrades.fold(0.0, (sum, t) => sum + (t.pnl ?? 0).abs()) /
              losingTrades.length;

    final profitFactor = averageLoss == 0 ? 0.0 : averageWin / averageLoss;

    return PracticeAnalytics(
      totalReturn: totalReturn,
      totalReturnPercentage: totalReturnPercentage,
      sharpeRatio: 0.0, // Would require daily returns calculation
      maxDrawdown: _currentAccount!.maxDrawdown,
      maxDrawdownPercentage: 0.0, // Would require drawdown calculation
      averageWin: averageWin,
      averageLoss: averageLoss,
      profitFactor: profitFactor,
      consecutiveWins: _currentAccount!.currentStreak > 0
          ? _currentAccount!.currentStreak
          : 0,
      consecutiveLosses: _currentAccount!.currentStreak < 0
          ? _currentAccount!.currentStreak.abs()
          : 0,
      monthlyReturns: {},
      tradingFrequency: {},
      assetPerformance: {},
      dailyReturns: [],
    );
  }

  // Method to set price for testing/demo purposes
  void setPrice(String symbol, double price) {
    _currentPrices[symbol] = price;
  }

  double? getPrice(String symbol) {
    return _currentPrices[symbol];
  }
}
