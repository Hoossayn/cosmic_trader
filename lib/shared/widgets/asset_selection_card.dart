import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class AssetSelectionCard extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final bool isSelected;
  final VoidCallback onTap;

  const AssetSelectionCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? AppTheme.energyGreen : AppTheme.dangerRed;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.energyGreen.withOpacity(0.1)
              : AppTheme.spaceDeep,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.energyGreen
                : AppTheme.cosmicBlue.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.energyGreen.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Asset icon/avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getAssetColor(symbol),
                    _getAssetColor(symbol).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getAssetIcon(symbol),
                color: AppTheme.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Asset info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.energyGreen
                              : AppTheme.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        symbol,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.gray400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(price >= 1000 ? 0 : 2)}',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                          style: AppTheme.bodySmall.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.energyGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.spaceDark,
                  size: 16,
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.gray500, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getAssetColor(String symbol) {
    switch (symbol) {
      case 'BTC-USD':
        return const Color(0xFFF7931A);
      case 'ETH-USD':
        return const Color(0xFF627EEA);
      case 'SOL-USD':
        return const Color(0xFF9945FF);
      default:
        return AppTheme.cosmicBlue;
    }
  }

  IconData _getAssetIcon(String symbol) {
    switch (symbol) {
      case 'BTC-USD':
        return Icons.currency_bitcoin;
      case 'ETH-USD':
        return Icons.diamond;
      case 'SOL-USD':
        return Icons.wb_sunny;
      default:
        return Icons.monetization_on;
    }
  }
}
