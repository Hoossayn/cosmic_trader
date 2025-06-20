import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'market_api_service.dart';

/// Test class to verify API integration
/// This is not a unit test but a simple verification utility
class MarketApiTest {
  static Future<void> testMarketApi() async {
    if (kDebugMode) {
      print('🚀 Testing Extended Exchange API integration...');
    }

    try {
      final apiClient = ApiClient();
      final marketService = MarketApiService(apiClient);

      // Test 1: Fetch all markets
      if (kDebugMode) {
        print('📊 Fetching all markets...');
      }
      final markets = await marketService.getMarkets();
      if (kDebugMode) {
        print('✅ Successfully fetched ${markets.length} markets');

        // Show first few markets
        for (int i = 0; i < (markets.length > 5 ? 5 : markets.length); i++) {
          final market = markets[i];
          print(
            '   ${market.name}: \$${market.price.toStringAsFixed(4)} (${market.priceChangePercentage.toStringAsFixed(2)}%)',
          );
        }
      }

      // Test 2: Fetch markets by category
      if (kDebugMode) {
        print('\n🏷️ Fetching markets by category...');
      }
      final categories = markets.map((m) => m.category).toSet().toList();
      for (final category in categories.take(3)) {
        final categoryMarkets = await marketService.getMarketsByCategory(
          category,
        );
        if (kDebugMode) {
          print('   $category: ${categoryMarkets.length} markets');
        }
      }

      // Test 3: Fetch top gainers
      if (kDebugMode) {
        print('\n📈 Fetching top gainers...');
      }
      final gainers = await marketService.getTopGainers(limit: 3);
      for (final gainer in gainers) {
        if (kDebugMode) {
          print(
            '   ${gainer.name}: +${gainer.priceChangePercentage.toStringAsFixed(2)}%',
          );
        }
      }

      // Test 4: Fetch top losers
      if (kDebugMode) {
        print('\n📉 Fetching top losers...');
      }
      final losers = await marketService.getTopLosers(limit: 3);
      for (final loser in losers) {
        if (kDebugMode) {
          print(
            '   ${loser.name}: ${loser.priceChangePercentage.toStringAsFixed(2)}%',
          );
        }
      }

      // Test 5: Fetch specific market
      if (markets.isNotEmpty) {
        final firstMarketName = markets.first.name;
        if (kDebugMode) {
          print('\n🎯 Fetching specific market: $firstMarketName');
        }
        final specificMarket = await marketService.getMarket(firstMarketName);
        if (specificMarket != null) {
          if (kDebugMode) {
            print(
              '   Found: ${specificMarket.name} - \$${specificMarket.price.toStringAsFixed(4)}',
            );
          }
        }
      }

      if (kDebugMode) {
        print('\n🎉 All API tests completed successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ API test failed: $e');
      }
      rethrow;
    }
  }
}
