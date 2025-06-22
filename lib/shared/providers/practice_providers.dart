import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/practice_models.dart';
import '../../features/practice/services/practice_trading_service.dart';

// Practice Trading Service Provider
final practiceTradingServiceProvider = Provider<PracticeTradingService>((ref) {
  final service = PracticeTradingService();

  // Initialize service when first accessed
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// Practice Account Provider
final practiceAccountProvider = StreamProvider<PracticeAccount?>((ref) {
  final service = ref.watch(practiceTradingServiceProvider);
  return service.accountStream;
});

// Practice Trades Provider
final practiceTradesProvider = StreamProvider<List<PracticeTrade>>((ref) {
  final service = ref.watch(practiceTradingServiceProvider);
  return service.tradesStream;
});

// Practice Positions Provider
final practicePositionsProvider = StreamProvider<List<TradePosition>>((ref) {
  final service = ref.watch(practiceTradingServiceProvider);
  return service.positionsStream;
});

// Open Trades Provider (filtered from all trades)
final openTradesProvider = Provider<List<PracticeTrade>>((ref) {
  final tradesAsync = ref.watch(practiceTradesProvider);
  return tradesAsync.when(
    data: (trades) => trades.where((trade) => trade.status == 'open').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Closed Trades Provider (filtered from all trades)
final closedTradesProvider = Provider<List<PracticeTrade>>((ref) {
  final tradesAsync = ref.watch(practiceTradesProvider);
  return tradesAsync.when(
    data: (trades) => trades
        .where(
          (trade) => trade.status == 'closed' || trade.status == 'liquidated',
        )
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Practice Analytics Provider
final practiceAnalyticsProvider = Provider<PracticeAnalytics?>((ref) {
  final service = ref.watch(practiceTradingServiceProvider);
  final accountAsync = ref.watch(practiceAccountProvider);

  return accountAsync.when(
    data: (account) => account != null ? service.calculateAnalytics() : null,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Total Unrealized PnL Provider
final unrealizedPnlProvider = Provider<double>((ref) {
  final openTrades = ref.watch(openTradesProvider);
  final service = ref.watch(practiceTradingServiceProvider);

  double totalUnrealizedPnl = 0.0;

  for (final trade in openTrades) {
    final currentPrice = service.getPrice(trade.symbol);
    if (currentPrice != null) {
      totalUnrealizedPnl += trade.calculateUnrealizedPnl(currentPrice);
    }
  }

  return totalUnrealizedPnl;
});

// Account Equity Provider (balance + unrealized PnL)
final accountEquityProvider = Provider<double>((ref) {
  final accountAsync = ref.watch(practiceAccountProvider);
  final unrealizedPnl = ref.watch(unrealizedPnlProvider);

  return accountAsync.when(
    data: (account) => (account?.balance ?? 0.0) + unrealizedPnl,
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Practice Mode State Provider (for UI state management)
final practiceModeStateProvider =
    StateNotifierProvider<PracticeModeStateNotifier, PracticeModeState>((ref) {
      return PracticeModeStateNotifier();
    });

class PracticeModeState {
  final bool isPracticeMode;
  final bool showTutorial;
  final String? selectedSymbol;
  final String selectedDirection;
  final double selectedLeverage;
  final double? selectedAmount;
  final double? stopLoss;
  final double? takeProfit;

  const PracticeModeState({
    this.isPracticeMode = false,
    this.showTutorial = true,
    this.selectedSymbol,
    this.selectedDirection = 'long',
    this.selectedLeverage = 1.0,
    this.selectedAmount,
    this.stopLoss,
    this.takeProfit,
  });

  PracticeModeState copyWith({
    bool? isPracticeMode,
    bool? showTutorial,
    String? selectedSymbol,
    String? selectedDirection,
    double? selectedLeverage,
    double? selectedAmount,
    double? stopLoss,
    double? takeProfit,
  }) {
    return PracticeModeState(
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
      showTutorial: showTutorial ?? this.showTutorial,
      selectedSymbol: selectedSymbol ?? this.selectedSymbol,
      selectedDirection: selectedDirection ?? this.selectedDirection,
      selectedLeverage: selectedLeverage ?? this.selectedLeverage,
      selectedAmount: selectedAmount ?? this.selectedAmount,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
    );
  }
}

class PracticeModeStateNotifier extends StateNotifier<PracticeModeState> {
  PracticeModeStateNotifier() : super(const PracticeModeState());

  void enablePracticeMode() {
    state = state.copyWith(isPracticeMode: true);
  }

  void disablePracticeMode() {
    state = state.copyWith(isPracticeMode: false);
  }

  void showTutorial() {
    state = state.copyWith(showTutorial: true);
  }

  void hideTutorial() {
    state = state.copyWith(showTutorial: false);
  }

  void updateTradeParameters({
    String? symbol,
    String? direction,
    double? leverage,
    double? amount,
    double? stopLoss,
    double? takeProfit,
  }) {
    state = state.copyWith(
      selectedSymbol: symbol,
      selectedDirection: direction,
      selectedLeverage: leverage,
      selectedAmount: amount,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
    );
  }

  void clearTradeParameters() {
    state = state.copyWith(
      selectedSymbol: null,
      selectedDirection: 'long',
      selectedLeverage: 1.0,
      selectedAmount: null,
      stopLoss: null,
      takeProfit: null,
    );
  }
}
