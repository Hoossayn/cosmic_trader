import '../constants/api_constants.dart';
import '../../shared/models/market_models.dart';
import 'api_client.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketApiService {
  final ApiClient _apiClient;

  MarketApiService(this._apiClient);

  /// Fetches all available markets from Extended Exchange
  Future<List<Market>> getMarkets() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.markets,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'No data received',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      final marketsResponse = MarketsResponse.fromJson(response.data!);

      if (marketsResponse.status != 'OK') {
        throw ApiException(
          message: 'API returned non-OK status: ${marketsResponse.status}',
          statusCode: 500,
          type: ApiExceptionType.server,
        );
      }

      // Filter only active and visible markets
      final activeMarkets = marketsResponse.data
          .where((market) => market.active && market.visibleOnUi)
          .toList();

      return activeMarkets;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to parse markets data: $e',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Fetches a specific market by name
  Future<Market?> getMarket(String marketName) async {
    try {
      final markets = await getMarkets();
      return markets.where((market) => market.name == marketName).firstOrNull;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches markets filtered by category
  Future<List<Market>> getMarketsByCategory(String category) async {
    try {
      final markets = await getMarkets();
      return markets
          .where(
            (market) => market.category.toLowerCase() == category.toLowerCase(),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches markets sorted by volume (descending)
  Future<List<Market>> getMarketsByVolume() async {
    try {
      final markets = await getMarkets();
      markets.sort((a, b) => b.volume.compareTo(a.volume));
      return markets;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches top gainers (markets with positive price change)
  Future<List<Market>> getTopGainers({int limit = 10}) async {
    try {
      final markets = await getMarkets();
      final gainers = markets
          .where((market) => market.priceChangePercentage > 0)
          .toList();

      gainers.sort(
        (a, b) => b.priceChangePercentage.compareTo(a.priceChangePercentage),
      );

      return gainers.take(limit).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches top losers (markets with negative price change)
  Future<List<Market>> getTopLosers({int limit = 10}) async {
    try {
      final markets = await getMarkets();
      final losers = markets
          .where((market) => market.priceChangePercentage < 0)
          .toList();

      losers.sort(
        (a, b) => a.priceChangePercentage.compareTo(b.priceChangePercentage),
      );

      return losers.take(limit).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FlSpot>> getCandles({
    required String market,
    required String interval, // e.g. PT30M, PT1H, P1D
    int limit =100,
  }) async {
    final url =
        'https://app.extended.exchange/api/v1/info/candles/$market/trades';
    final resp = await _apiClient.get<Map<String, dynamic>>(
      url,
      queryParameters: {'interval': interval, 'limit': limit},
    );

    if (resp.data == null || resp.data!['status'] != 'OK') {
      throw ApiException(
        message: 'Failed to fetch candles',
        statusCode: 500,
        type: ApiExceptionType.server,
      );
    }

    final List<dynamic> data = resp.data!['data'] ?? [];
    final spots = <FlSpot>[];
    for (final item in data) {
      final cStr = item['c']?.toString() ?? '0';
      final close = double.tryParse(cStr) ?? 0.0;
      spots.add(FlSpot(spots.length.toDouble(), close));
    }
    return spots;
  }
}
