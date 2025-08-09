import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/market_api_service.dart';
import '../../core/network/positions_api_service.dart';
import '../../core/network/orders_api_service.dart';
import '../../shared/models/market_models.dart';
import '../../shared/models/position_models.dart';
import 'package:fl_chart/fl_chart.dart';

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

// Orders API Service Provider
final ordersApiServiceProvider = Provider<OrdersApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrdersApiService(apiClient);
});

// Open Positions Provider
final openPositionsProvider = FutureProvider<List<Position>>((ref) async {
  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getOpenPositions();
});

// Closed Positions Provider
final closedPositionsProvider = FutureProvider<List<Position>>((ref) async {
  final positionsService = ref.watch(positionsApiServiceProvider);
  return await positionsService.getClosedPositions();
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

// Price history provider using Extended candles
final priceHistoryProvider =
    FutureProvider.family<
      List<FlSpot>,
      ({String market, String interval, int limit})
    >((ref, args) async {
      final service = ref.watch(marketApiServiceProvider);
      return await service.getCandles(
        market: args.market,
        interval: args.interval,
        limit: args.limit,
      );
    });
