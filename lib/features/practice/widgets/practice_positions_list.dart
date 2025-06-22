import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/practice_models.dart';
import '../../../shared/providers/practice_providers.dart';

class PracticePositionsList extends ConsumerWidget {
  const PracticePositionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openTrades = ref.watch(openTradesProvider);
    final service = ref.read(practiceTradingServiceProvider);

    if (openTrades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No Open Positions',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your practice trades will appear here',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: openTrades.length,
      itemBuilder: (context, index) {
        final trade = openTrades[index];
        final currentPrice = service.getPrice(trade.symbol);

        return _PositionCard(
          trade: trade,
          currentPrice: currentPrice,
          onClose: (percentage) => _closeTrade(ref, trade.id, percentage),
        );
      },
    );
  }

  Future<void> _closeTrade(
    WidgetRef ref,
    String tradeId,
    double? percentage,
  ) async {
    try {
      final service = ref.read(practiceTradingServiceProvider);
      await service.closeTrade(tradeId, partialPercentage: percentage);
    } catch (e) {
      // Handle error - could show snackbar
      debugPrint('Error closing trade: $e');
    }
  }
}

class _PositionCard extends StatelessWidget {
  final PracticeTrade trade;
  final double? currentPrice;
  final Function(double?) onClose;

  const _PositionCard({
    required this.trade,
    required this.currentPrice,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final unrealizedPnl = currentPrice != null
        ? trade.calculateUnrealizedPnl(currentPrice!)
        : 0.0;
    final unrealizedPnlPerc = currentPrice != null
        ? trade.calculateUnrealizedPnlPercentage(currentPrice!)
        : 0.0;

    final isProfit = unrealizedPnl >= 0;
    final pnlColor = isProfit ? AppTheme.energyGreen : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isProfit
              ? AppTheme.energyGreen.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Direction indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: trade.direction == 'long'
                        ? AppTheme.energyGreen.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trade.direction.toUpperCase(),
                    style: TextStyle(
                      color: trade.direction == 'long'
                          ? AppTheme.energyGreen
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Symbol and leverage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trade.symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${trade.leverage.toStringAsFixed(0)}x Leverage',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // P&L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfit ? '+' : ''}\$${unrealizedPnl.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${isProfit ? '+' : ''}${unrealizedPnlPerc.toStringAsFixed(2)}%',
                      style: TextStyle(color: pnlColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Position details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.spaceDark.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Trade details row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      'Size',
                      '\$${trade.size.toStringAsFixed(2)}',
                    ),
                    _buildDetailItem(
                      'Entry',
                      '\$${trade.entryPrice.toStringAsFixed(2)}',
                    ),
                    _buildDetailItem(
                      'Current',
                      currentPrice != null
                          ? '\$${currentPrice!.toStringAsFixed(2)}'
                          : '-',
                    ),
                    _buildDetailItem(
                      'Margin',
                      '\$${trade.margin.toStringAsFixed(2)}',
                    ),
                  ],
                ),

                if (trade.stopLoss != null || trade.takeProfit != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (trade.stopLoss != null)
                        _buildDetailItem(
                          'Stop Loss',
                          '\$${trade.stopLoss!.toStringAsFixed(2)}',
                        ),
                      if (trade.takeProfit != null)
                        _buildDetailItem(
                          'Take Profit',
                          '\$${trade.takeProfit!.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onClose(null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close 100%'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showPartialCloseDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.spaceDeep,
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[600]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Partial Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }

  void _showPartialCloseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spaceDeep,
        title: const Text(
          'Partial Close',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose percentage to close:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...{0.1, 0.25, 0.5, 0.75}.map(
              (percentage) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose(percentage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.spaceDark,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Close ${(percentage * 100).toInt()}%'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
