import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/trading_models.dart';

class OpenTradesScreen extends StatefulWidget {
  const OpenTradesScreen({super.key});

  @override
  State<OpenTradesScreen> createState() => _OpenTradesScreenState();
}

class _OpenTradesScreenState extends State<OpenTradesScreen> {
  // Mock data for open trades
  final List<TradeModel> _openTrades = [
    TradeModel(
      id: '1',
      userId: 'user1',
      assetSymbol: 'BTC-USD',
      direction: TradeDirection.long,
      amount: 50.0,
      leverage: 2.0,
      entryPrice: 43250.0,
      status: TradeStatus.active,
      type: TradeType.market,
      pnl: 125.50,
      xpEarned: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    TradeModel(
      id: '2',
      userId: 'user1',
      assetSymbol: 'ETH-USD',
      direction: TradeDirection.short,
      amount: 100.0,
      leverage: 5.0,
      entryPrice: 2580.5,
      status: TradeStatus.active,
      type: TradeType.market,
      pnl: -45.20,
      xpEarned: 10,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _openTrades.isEmpty
                  ? _buildEmptyState()
                  : _buildTradesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          ),
          const SizedBox(width: 8),
          Text('Open Trades', style: AppTheme.heading2),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.energyGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.energyGreen.withOpacity(0.3)),
            ),
            child: Text(
              '${_openTrades.length} Active',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.energyGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.spaceDeep,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.trending_up,
              color: AppTheme.gray400,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text('No Open Trades', style: AppTheme.heading3),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any active positions right now.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/trade'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.energyGreen, AppTheme.cosmicBlue],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Start Trading',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.spaceDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildTradesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _openTrades.length,
      itemBuilder: (context, index) {
        final trade = _openTrades[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTradeCard(trade),
        );
      },
    );
  }

  Widget _buildTradeCard(TradeModel trade) {
    final isProfitable = trade.pnl >= 0;
    final currentPrice = _getCurrentPrice(trade.assetSymbol);
    final priceChange = currentPrice - trade.entryPrice;
    final priceChangePercent = (priceChange / trade.entryPrice) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isProfitable
              ? AppTheme.energyGreen.withOpacity(0.3)
              : AppTheme.dangerRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              // Asset info
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAssetColor(trade.assetSymbol).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getAssetIcon(trade.assetSymbol),
                  color: _getAssetColor(trade.assetSymbol),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.assetSymbol,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${trade.leverage.toStringAsFixed(0)}x ${trade.direction.name.toUpperCase()}',
                      style: AppTheme.bodySmall.copyWith(
                        color: trade.direction == TradeDirection.long
                            ? AppTheme.energyGreen
                            : AppTheme.dangerRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // P&L
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isProfitable ? '+' : ''}\$${trade.pnl.toStringAsFixed(2)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isProfitable
                          ? AppTheme.energyGreen
                          : AppTheme.dangerRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${isProfitable ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
                    style: AppTheme.bodySmall.copyWith(
                      color: isProfitable
                          ? AppTheme.energyGreen
                          : AppTheme.dangerRed,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Trade details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.spaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Amount:',
                  '\$${trade.amount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Entry Price:',
                  '\$${trade.entryPrice.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Current Price:',
                  '\$${currentPrice.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Position Size:',
                  '\$${trade.positionSize.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Time Open:',
                  _formatDuration(DateTime.now().difference(trade.createdAt)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _editTrade(trade),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cosmicBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.cosmicBlue),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit,
                          color: AppTheme.cosmicBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.cosmicBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _closeTrade(trade),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.dangerRed),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.close,
                          color: AppTheme.dangerRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Close',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.dangerRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2);
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
        ),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
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

  Color _getAssetColor(String symbol) {
    switch (symbol) {
      case 'BTC-USD':
        return AppTheme.energyGreen;
      case 'ETH-USD':
        return AppTheme.cosmicBlue;
      case 'SOL-USD':
        return AppTheme.starYellow;
      default:
        return AppTheme.gray400;
    }
  }

  double _getCurrentPrice(String symbol) {
    // Mock current prices
    switch (symbol) {
      case 'BTC-USD':
        return 43375.50;
      case 'ETH-USD':
        return 2535.30;
      case 'SOL-USD':
        return 104.42;
      default:
        return 0.0;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  void _editTrade(TradeModel trade) {
    // TODO: Implement edit trade functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit trade functionality coming soon!',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.cosmicBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _closeTrade(TradeModel trade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spaceDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Close Trade', style: AppTheme.heading3),
        content: Text(
          'Are you sure you want to close this ${trade.assetSymbol} position?',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _openTrades.removeWhere((t) => t.id == trade.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.energyGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trade closed successfully!',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppTheme.energyGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Close',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.dangerRed),
            ),
          ),
        ],
      ),
    );
  }
}
