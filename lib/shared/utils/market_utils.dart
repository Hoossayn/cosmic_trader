import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/market_models.dart';
import '../../core/theme/app_theme.dart';

class MarketUtils {
  /// Converts a Market to the Map format expected by existing UI components
  static Map<String, dynamic> marketToMap(Market market) {
    return {
      'symbol': market.name,
      'name': _getAssetDisplayName(market.assetName),
      'price': market.price,
      'change': market.priceChange,
      'changePercent': market.priceChangePercentage,
      'color': market.isPositive ? AppTheme.energyGreen : AppTheme.dangerRed,
      'category': market.category,
      'volume': market.volume,
      'maxLeverage': market.maxLeverageValue,
      'active': market.active,
      'status': market.status,
    };
  }

  /// Converts a list of Markets to the List<Map> format expected by UI
  static List<Map<String, dynamic>> marketsToMapList(List<Market> markets) {
    return markets.map((market) => marketToMap(market)).toList();
  }

  /// Gets a user-friendly display name for assets
  static String _getAssetDisplayName(String assetName) {
    final assetNames = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'SOL': 'Solana',
      'ADA': 'Cardano',
      'DOT': 'Polkadot',
      'MATIC': 'Polygon',
      'AVAX': 'Avalanche',
      'LINK': 'Chainlink',
      'PENDLE': 'Pendle',
      'ENA': 'Ethena',
      'TAO': 'Bittensor',
      'TRUMP': 'Trump',
      'MOODENG': 'Moo Deng',
    };

    return assetNames[assetName] ?? assetName;
  }

  /// Gets an appropriate icon for an asset
  static IconData getAssetIcon(String assetName) {
    switch (assetName.toUpperCase()) {
      case 'BTC':
        return Icons.currency_bitcoin;
      case 'ETH':
        return Icons.diamond;
      case 'SOL':
        return Icons.wb_sunny;
      case 'ADA':
        return Icons.favorite;
      case 'DOT':
        return Icons.fiber_manual_record;
      case 'MATIC':
        return Icons.change_history;
      case 'AVAX':
        return Icons.ac_unit;
      case 'LINK':
        return Icons.link;
      case 'PENDLE':
        return Icons.pending_actions;
      case 'ENA':
        return Icons.energy_savings_leaf;
      case 'TAO':
        return Icons.psychology_alt;
      case 'TRUMP':
        return Icons.person;
      case 'MOODENG':
        return Icons.emoji_emotions;
      default:
        return Icons.monetization_on;
    }
  }

  /// Gets asset color based on category
  static Color getAssetCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'defi':
        return AppTheme.cosmicBlue;
      case 'l1':
        return AppTheme.energyGreen;
      case 'l2':
        return AppTheme.starYellow;
      case 'ai':
        return AppTheme.warningOrange;
      case 'meme':
        return Colors.pink;
      case 'gaming':
        return Colors.purple;
      case 'nft':
        return Colors.cyan;
      case 'web3':
        return Colors.indigo;
      default:
        return AppTheme.gray400;
    }
  }

  /// Formats large numbers (volume, etc.)
  static String formatLargeNumber(double number) {
    if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(1)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(1)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  /// Formats percentage with appropriate precision
  static String formatPercentage(double percentage) {
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%';
  }

  /// Formats price with appropriate precision and comma separators
  static String formatPrice(double price) {
    final numberFormat = NumberFormat('#,##0');
    final decimalFormat = NumberFormat('#,##0.00');
    final highPrecisionFormat = NumberFormat('#,##0.0000');

    if (price >= 1000) {
      return '\$${numberFormat.format(price)}';
    } else if (price >= 1) {
      return '\$${decimalFormat.format(price)}';
    } else {
      return '\$${highPrecisionFormat.format(price)}';
    }
  }
}
