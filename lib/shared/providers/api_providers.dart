import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/network/api_client.dart';
import '../../core/network/market_api_service.dart';
import '../../core/network/positions_api_service.dart';
import '../../shared/models/market_models.dart';
import '../../shared/models/position_models.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Market API Service Provider
final marketApiServiceProvider = Provider<MarketApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketApiService(apiClient);
});

// Positions API Service Provider
final positionsApiServiceProvider = Provider<PositionsApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PositionsApiService(apiClient);
});

// User Positions Provider (legacy - for backward compatibility)
final userPositionsProvider = FutureProvider<List<Position>>((ref) async {
  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getUserPositions();
});

// Manual refresh trigger provider
final positionsRefreshTriggerProvider = StateProvider<int>((ref) => 0);

// Cached positions provider that responds to manual refresh
final cachedPositionsProvider = FutureProvider<List<Position>>((ref) async {
  // Watch the refresh trigger to invalidate cache when needed
  ref.watch(positionsRefreshTriggerProvider);

  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getUserPositions();
});

// Stream provider that combines auto-refresh with manual refresh capability
final realTimePositionsProvider = StreamProvider<List<Position>>((ref) {
  final positionsService = ref.watch(positionsApiServiceProvider);

  final controller = StreamController<List<Position>>();
  Timer? autoRefreshTimer;
  List<Position>? cachedPositions;
  bool isInitialLoad = true;

  Future<void> fetchAndUpdate() async {
    try {
      final positions = await positionsService.getUserPositions();
      cachedPositions = positions;

      if (!controller.isClosed) {
        controller.add(positions);
      }

      isInitialLoad = false;
    } catch (error) {
      // On error, emit cached data if available, otherwise emit error
      if (cachedPositions != null && !controller.isClosed) {
        controller.add(cachedPositions!);
      } else if (!controller.isClosed) {
        controller.addError(error);
      }
    }
  }

  // Listen to manual refresh trigger
  final refreshTriggerSubscription = ref.listen(
    positionsRefreshTriggerProvider,
    (previous, next) {
      if (previous != next && !isInitialLoad) {
        fetchAndUpdate();
      }
    },
  );

  // Initial fetch
  fetchAndUpdate();

  // Auto-refresh every 10 seconds (less aggressive for better performance)
  autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
    fetchAndUpdate();
  });

  ref.onDispose(() {
    autoRefreshTimer?.cancel();
    refreshTriggerSubscription.close();
    controller.close();
  });

  return controller.stream;
});

// All Positions Provider (including closed)
final allPositionsProvider = FutureProvider<List<Position>>((ref) async {
  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getAllPositions();
});

// Total Unrealized PnL Provider (real-time)
final realTimeUnrealizedPnlProvider = Provider<double>((ref) {
  final positionsAsync = ref.watch(realTimePositionsProvider);

  return positionsAsync.when(
    data: (positions) => positions.fold<double>(
      0.0,
      (sum, position) => sum + position.unrealisedPnlValue,
    ),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Total Margin Used Provider (real-time)
final realTimeMarginUsedProvider = Provider<double>((ref) {
  final positionsAsync = ref.watch(realTimePositionsProvider);

  return positionsAsync.when(
    data: (positions) => positions.fold<double>(
      0.0,
      (sum, position) => sum + position.marginValue,
    ),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Total Unrealized PnL Provider (legacy)
final totalUnrealizedPnlProvider = FutureProvider<double>((ref) async {
  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getTotalUnrealizedPnl();
});

// Total Margin Used Provider (legacy)
final totalMarginUsedProvider = FutureProvider<double>((ref) async {
  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getTotalMarginUsed();
});

// Positions by Market Provider
final positionsByMarketProvider = FutureProvider.family<List<Position>, String>(
  (ref, market) async {
    final positionsService = ref.watch(positionsApiServiceProvider);
    return await positionsService.getPositionsByMarket(market);
  },
);

// Positions by Side Provider (LONG/SHORT)
final positionsBySideProvider = FutureProvider.family<List<Position>, String>((
  ref,
  side,
) async {
  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getPositionsBySide(side);
});

// Markets Data Provider
final marketsProvider = FutureProvider<List<Market>>((ref) async {
  final marketService = ref.watch(marketApiServiceProvider);
  return await marketService.getMarkets();
});

// Markets by Category Provider
final marketsByCategoryProvider = FutureProvider.family<List<Market>, String>((
  ref,
  category,
) async {
  final marketService = ref.watch(marketApiServiceProvider);
  return await marketService.getMarketsByCategory(category);
});

// Markets by Volume Provider
final marketsByVolumeProvider = FutureProvider<List<Market>>((ref) async {
  final marketService = ref.watch(marketApiServiceProvider);
  return await marketService.getMarketsByVolume();
});

// Top Gainers Provider
final topGainersProvider = FutureProvider.family<List<Market>, int>((
  ref,
  limit,
) async {
  final marketService = ref.watch(marketApiServiceProvider);
  return await marketService.getTopGainers(limit: limit);
});

// Top Losers Provider
final topLosersProvider = FutureProvider.family<List<Market>, int>((
  ref,
  limit,
) async {
  final marketService = ref.watch(marketApiServiceProvider);
  return await marketService.getTopLosers(limit: limit);
});

// Single Market Provider
final marketProvider = FutureProvider.family<Market?, String>((
  ref,
  marketName,
) async {
  final marketService = ref.watch(marketApiServiceProvider);
  return await marketService.getMarket(marketName);
});

// Market Categories Provider (derived from markets data)
final marketCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final markets = await ref.watch(marketsProvider.future);
  final categories = markets.map((market) => market.category).toSet().toList();
  categories.sort();
  return categories;
});

// Helper function to manually trigger refresh
void triggerPositionsRefresh(WidgetRef ref) {
  final currentValue = ref.read(positionsRefreshTriggerProvider);
  ref.read(positionsRefreshTriggerProvider.notifier).state = currentValue + 1;
}
