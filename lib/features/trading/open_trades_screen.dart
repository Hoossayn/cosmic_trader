import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../shared/models/position_models.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/widgets/asset_dropdown.dart';
import '../../shared/utils/market_utils.dart';

class OpenTradesScreen extends ConsumerStatefulWidget {
  const OpenTradesScreen({super.key});

  @override
  ConsumerState<OpenTradesScreen> createState() => _OpenTradesScreenState();
}

class _OpenTradesScreenState extends ConsumerState<OpenTradesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Track expanded state for each position card - separate for each tab
  final Set<String> _expandedOpenPositions = <String>{};
  final Set<String> _expandedClosedPositions = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final openPositionsAsync = ref.watch(openPositionsProvider);
    final closedPositionsAsync = ref.watch(closedPositionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Current Trades', style: AppTheme.heading2),
        backgroundColor: AppTheme.spaceDark,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildTabBar(openPositionsAsync),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOpenTradesTab(openPositionsAsync),
                _buildOrderHistoryTab(closedPositionsAsync),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/place-trade'),
        backgroundColor: AppTheme.energyGreen,
        foregroundColor: AppTheme.spaceDark,
        icon: const Icon(Icons.add_chart),
        label: Text(
          'New Trade',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.spaceDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    List<Position> positions,
    bool isLoading,
    String? error,
  ) {
    if (error != null && positions.isEmpty) {
      return _buildErrorState(error);
    }

    if (isLoading && positions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (positions.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPositionsList(positions, isOpenTab: true);
  }

  Widget _buildTabBar(AsyncValue<List<Position>> openPositionsAsync) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.cosmicBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.gray400,
        labelStyle: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTheme.bodyMedium,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, size: 18),
                const SizedBox(width: 8),
                Text('Open Trades'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.energyGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.energyGreen.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    openPositionsAsync.when(
                      data: (positions) => '${positions.length}',
                      loading: () => '0',
                      error: (_, __) => '0',
                    ),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.energyGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 18),
                SizedBox(width: 8),
                Text('Order History'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenTradesTab(AsyncValue<List<Position>> openPositionsAsync) {
    return openPositionsAsync.when(
      data: (positions) => _buildContent(positions, false, null),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildOrderHistoryTab(
    AsyncValue<List<Position>> closedPositionsAsync,
  ) {
    return closedPositionsAsync.when(
      data: (positions) {
        // Filter out positions with null exit_type or closed_time
        final filteredPositions = positions
            .where((pos) => pos.exitType != null && pos.closedTime != null)
            .toList();

        return filteredPositions.isEmpty
            ? _buildOrderHistoryEmptyState()
            : _buildClosedPositionsList(filteredPositions);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.energyGreen),
      ),
      error: (error, stack) => _buildOrderHistoryErrorState(error.toString()),
    );
  }

  Widget _buildOrderHistoryEmptyState() {
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
            child: const Icon(Icons.history, color: AppTheme.gray400, size: 40),
          ),
          const SizedBox(height: 24),
          Text('No Order History', style: AppTheme.heading3),
          const SizedBox(height: 8),
          Text(
            'You haven\'t placed any orders yet.\nStart trading to see your order history here.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => _tabController.animateTo(0),
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

  Widget _buildOrderHistoryErrorState(String error) {
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
              Icons.error_outline,
              color: AppTheme.dangerRed,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text('Error Loading Order History', style: AppTheme.heading3),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => ref.invalidate(openPositionsProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cosmicBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Retry',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
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
          Text('No Open Positions', style: AppTheme.heading3),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any active positions right now.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/trading'),
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

  Widget _buildErrorState(String error) {
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
              Icons.error_outline,
              color: AppTheme.dangerRed,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text('Error Loading Positions', style: AppTheme.heading3),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => ref.invalidate(openPositionsProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cosmicBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Retry',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedPositionsList(List<Position> positions) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(closedPositionsProvider);
        // Small delay to show refresh action
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: positions.length,
        itemBuilder: (context, index) {
          final position = positions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildClosedPositionCard(position),
          );
        },
      ),
    );
  }

  Widget _buildPositionsList(
    List<Position> positions, {
    required bool isOpenTab,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        if (isOpenTab) {
          ref.invalidate(openPositionsProvider);
        } else {
          ref.invalidate(closedPositionsProvider);
        }
        // Small delay to show refresh action
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: positions.length,
        itemBuilder: (context, index) {
          final position = positions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPositionCard(position, isOpenTab: isOpenTab),
          );
        },
      ),
    );
  }

  Widget _buildClosedPositionCard(Position position) {
    final isProfitable = position.realisedPnlValue >= 0;
    final positionKey = '${position.id}_closed'; // Use unique ID for key
    final isExpanded = _expandedClosedPositions.contains(positionKey);

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
          // Header row - always visible
          Row(
            children: [
              // Asset info
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAssetColor(position.market ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: AssetDropdown.buildAssetImage(
                    _getBaseAsset(position.market ?? ''),
                    'crypto',
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.market ?? 'Unknown',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${position.leverageValue.toStringAsFixed(0)}x ${position.side} • ${position.exitType}',
                      style: AppTheme.bodySmall.copyWith(
                        color: position.isLong
                            ? AppTheme.energyGreen
                            : AppTheme.dangerRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Realized P&L
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isProfitable ? '+' : ''}${MarketUtils.formatPrice(position.realisedPnlValue)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isProfitable
                          ? AppTheme.energyGreen
                          : AppTheme.dangerRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Realized P&L',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
                  ),
                ],
              ),

              // Expand/Collapse button
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedClosedPositions.remove(positionKey);
                    } else {
                      _expandedClosedPositions.add(positionKey);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gray400.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.gray400,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Expandable content - only show when expanded
          if (isExpanded) ...[
            const SizedBox(height: 16),

            // Position details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.spaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Size:',
                    '${position.sizeValue.toStringAsFixed(2)} ${_getBaseAsset(position.market ?? '')}',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Entry Price:',
                    MarketUtils.formatPrice(position.openPriceValue),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Exit Price:',
                    MarketUtils.formatPrice(position.exitPriceValue),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Realized P&L:',
                    '${isProfitable ? '+' : ''}${MarketUtils.formatPrice(position.realisedPnlValue)}',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Opened:',
                    _formatDateTime(
                      position.createdTimeDateTime ?? DateTime.now(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Closed:',
                    _formatDateTime(
                      position.closedTimeDateTime ?? DateTime.now(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Duration:',
                    _formatDuration(
                      (position.closedTimeDateTime ?? DateTime.now())
                          .difference(
                            position.createdTimeDateTime ?? DateTime.now(),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2);
  }

  Widget _buildPositionCard(Position position, {required bool isOpenTab}) {
    final isProfitable = position.isProfitable;
    final roiPercent = position.roiPercentage;
    final positionKey =
        '${position.id}_${isOpenTab ? 'open' : 'closed'}'; // Use unique ID for key
    final expandedSet = isOpenTab
        ? _expandedOpenPositions
        : _expandedClosedPositions;
    final isExpanded = expandedSet.contains(positionKey);

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
          // Header row - always visible
          Row(
            children: [
              // Asset info
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAssetColor(position.market ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: AssetDropdown.buildAssetImage(
                    _getBaseAsset(position.market ?? ''),
                    'crypto', // Default category for positions
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.market ?? 'Unknown',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${position.leverageValue.toStringAsFixed(0)}x ${position.side}',
                      style: AppTheme.bodySmall.copyWith(
                        color: position.isLong
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
                    '${isProfitable ? '+' : ''}${MarketUtils.formatPrice(position.unrealisedPnlValue)}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: isProfitable
                          ? AppTheme.energyGreen
                          : AppTheme.dangerRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${isProfitable ? '+' : ''}${roiPercent.toStringAsFixed(2)}%',
                    style: AppTheme.bodySmall.copyWith(
                      color: isProfitable
                          ? AppTheme.energyGreen
                          : AppTheme.dangerRed,
                    ),
                  ),
                ],
              ),

              // Expand/Collapse button
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      expandedSet.remove(positionKey);
                    } else {
                      expandedSet.add(positionKey);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gray400.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.gray400,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // Expandable content - only show when expanded
          if (isExpanded) ...[
            const SizedBox(height: 16),

            // Position details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.spaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Size:',
                    '${position.sizeValue.toStringAsFixed(2)} ${_getBaseAsset(position.market ?? '')}',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Value:',
                    MarketUtils.formatPrice(position.valueValue),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Entry Price:',
                    MarketUtils.formatPrice(position.openPriceValue),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Market Price:',
                    MarketUtils.formatPrice(position.markPriceValue),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Liquidation Price:',
                    MarketUtils.formatPrice(position.liquidationPriceValue),
                  ),
                  const SizedBox(height: 8),
                  /*   _buildDetailRow(
                    'Margin:',
                    MarketUtils.formatPrice(position.marginValue),
                  ),*/
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Time Open:',
                    _formatDuration(
                      DateTime.now().difference(
                        position.createdAtDateTime ?? DateTime.now(),
                      ),
                    ),
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
                    onTap: () => _editPosition(position),
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
                    onTap: () => _closePosition(position),
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

  Color _getAssetColor(String market) {
    final asset = _getBaseAsset(market);
    switch (asset.toUpperCase()) {
      case 'BTC':
        return AppTheme.energyGreen;
      case 'ETH':
        return AppTheme.cosmicBlue;
      case 'SOL':
        return AppTheme.starYellow;
      case 'STRK':
        return Colors.purple;
      case 'ADA':
        return Colors.blue;
      case 'DOT':
        return Colors.pink;
      case 'MATIC':
        return Colors.indigo;
      case 'AVAX':
        return Colors.red;
      case 'LINK':
        return Colors.cyan;
      default:
        return AppTheme.gray400;
    }
  }

  String _getBaseAsset(String market) {
    // Extract base asset from market pair (e.g., 'BTC-USD' -> 'BTC')
    return market.split('-').first;
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

  void _editPosition(Position position) {
    // TODO: Implement edit position functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit position functionality coming soon!',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.cosmicBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _closePosition(Position position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spaceDeep,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Close Position', style: AppTheme.heading3),
        content: Text(
          'Are you sure you want to close this ${position.market} position?\n\nCurrent P&L: ${position.isProfitable ? '+' : ''}\$${position.unrealisedPnlValue.toStringAsFixed(2)}',
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
              // TODO: Implement actual position closing API call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: AppTheme.cosmicBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Position closing API not yet implemented',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppTheme.cosmicBlue,
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
