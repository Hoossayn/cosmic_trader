import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/practice_models.dart';
import '../../../shared/providers/practice_providers.dart';

class PracticeAccountInfo extends ConsumerWidget {
  final PracticeAccount account;

  const PracticeAccountInfo({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unrealizedPnl = ref.watch(unrealizedPnlProvider);
    final equity = ref.watch(accountEquityProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.energyGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Main balance and equity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                title: 'Balance',
                value: '\$${account.balance.toStringAsFixed(2)}',
                color: Colors.white,
                icon: Icons.account_balance_wallet,
              ),
              _buildStatCard(
                title: 'Equity',
                value: '\$${equity.toStringAsFixed(2)}',
                color: equity >= account.balance
                    ? AppTheme.energyGreen
                    : Colors.red,
                icon: Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Unrealized P&L and Total P&L
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                title: 'Unrealized P&L',
                value:
                    '${unrealizedPnl >= 0 ? '+' : ''}\$${unrealizedPnl.toStringAsFixed(2)}',
                color: unrealizedPnl >= 0 ? AppTheme.energyGreen : Colors.red,
                icon: Icons.schedule,
              ),
              _buildStatCard(
                title: 'Total P&L',
                value:
                    '${account.totalPnl >= 0 ? '+' : ''}\$${account.totalPnl.toStringAsFixed(2)}',
                color: account.totalPnl >= 0
                    ? AppTheme.energyGreen
                    : Colors.red,
                icon: Icons.analytics,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trading statistics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallStat(
                'Win Rate',
                '${account.winRate.toStringAsFixed(1)}%',
              ),
              _buildSmallStat('Trades', '${account.totalTrades}'),
              _buildSmallStat('Wins', '${account.winningTrades}'),
              _buildSmallStat('Streak', '${account.currentStreak}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.spaceDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color.withOpacity(0.7), size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }
}
