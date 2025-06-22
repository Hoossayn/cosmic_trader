import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/practice_models.dart';
import '../../../shared/providers/practice_providers.dart';

class PracticeTradeHistory extends ConsumerWidget {
  const PracticeTradeHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closedTrades = ref.watch(closedTradesProvider);
    final analytics = ref.watch(practiceAnalyticsProvider);

    return Column(
      children: [
        // Analytics summary
        if (analytics != null && closedTrades.isNotEmpty)
          _AnalyticsSummary(analytics: analytics),

        // Trade history list
        Expanded(
          child: closedTrades.isEmpty
              ? _buildEmptyState()
              : _buildTradesList(closedTrades),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No Trade History',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your completed trades will appear here',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTradesList(List<PracticeTrade> trades) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _TradeHistoryCard(trade: trade);
      },
    );
  }
}

class _AnalyticsSummary extends StatelessWidget {
  final PracticeAnalytics analytics;

  const _AnalyticsSummary({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: analytics.totalReturnPercentage >= 0
              ? AppTheme.energyGreen.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Summary',
            style: TextStyle(
              color: AppTheme.starYellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // First row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                'Total Return',
                '${analytics.totalReturnPercentage >= 0 ? '+' : ''}${analytics.totalReturnPercentage.toStringAsFixed(2)}%',
                analytics.totalReturnPercentage >= 0
                    ? AppTheme.energyGreen
                    : Colors.red,
              ),
              _buildStat(
                'Profit Factor',
                analytics.profitFactor.toStringAsFixed(2),
                analytics.profitFactor >= 1.0
                    ? AppTheme.energyGreen
                    : Colors.red,
              ),
              _buildStat(
                'Avg Win',
                '\$${analytics.averageWin.toStringAsFixed(2)}',
                AppTheme.energyGreen,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                'Max DD',
                '${analytics.maxDrawdownPercentage.toStringAsFixed(2)}%',
                Colors.red,
              ),
              _buildStat(
                'Avg Loss',
                '\$${analytics.averageLoss.toStringAsFixed(2)}',
                Colors.red,
              ),
              _buildStat(
                'Win Streak',
                '${analytics.consecutiveWins}',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }
}

class _TradeHistoryCard extends StatelessWidget {
  final PracticeTrade trade;

  const _TradeHistoryCard({required this.trade});

  @override
  Widget build(BuildContext context) {
    final isProfit = (trade.pnl ?? 0) >= 0;
    final pnlColor = isProfit ? AppTheme.energyGreen : Colors.red;
    final isLiquidated = trade.status == 'liquidated';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLiquidated
              ? Colors.orange.withOpacity(0.3)
              : (isProfit
                    ? AppTheme.energyGreen.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                // Direction and symbol
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
                    '${trade.direction.toUpperCase()} ${trade.symbol}',
                    style: TextStyle(
                      color: trade.direction == 'long'
                          ? AppTheme.energyGreen
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (isLiquidated) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIQUIDATED',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // P&L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfit ? '+' : ''}\$${(trade.pnl ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${isProfit ? '+' : ''}${(trade.pnlPercentage ?? 0).toStringAsFixed(2)}%',
                      style: TextStyle(color: pnlColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Trade details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Size', '\$${trade.size.toStringAsFixed(2)}'),
                _buildDetailItem(
                  'Entry',
                  '\$${trade.entryPrice.toStringAsFixed(2)}',
                ),
                _buildDetailItem(
                  'Exit',
                  trade.exitPrice != null
                      ? '\$${trade.exitPrice!.toStringAsFixed(2)}'
                      : '-',
                ),
                _buildDetailItem(
                  'Leverage',
                  '${trade.leverage.toStringAsFixed(0)}x',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Time and close reason
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opened: ${DateFormat('MMM dd, HH:mm').format(trade.openTime)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                    if (trade.closeTime != null)
                      Text(
                        'Closed: ${DateFormat('MMM dd, HH:mm').format(trade.closeTime!)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                  ],
                ),

                if (trade.closeReason != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.spaceDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCloseReasonText(trade.closeReason!),
                      style: TextStyle(color: Colors.grey[300], fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
      ],
    );
  }

  String _getCloseReasonText(String reason) {
    switch (reason) {
      case 'manual':
        return 'Manual';
      case 'stop_loss':
        return 'Stop Loss';
      case 'take_profit':
        return 'Take Profit';
      case 'liquidation':
        return 'Liquidation';
      case 'partial_close':
        return 'Partial';
      default:
        return reason.toUpperCase();
    }
  }
}
