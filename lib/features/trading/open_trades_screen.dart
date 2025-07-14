import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../shared/models/position_models.dart';
import '../../shared/models/order_models.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/widgets/asset_dropdown.dart';
import '../../shared/widgets/positions_summary_card.dart';
import '../../shared/utils/market_utils.dart';

class OpenTradesScreen extends ConsumerStatefulWidget {
  const OpenTradesScreen({super.key});

  @override
  ConsumerState<OpenTradesScreen> createState() => _OpenTradesScreenState();
}

class _OpenTradesScreenState extends ConsumerState<OpenTradesScreen>
    with SingleTickerProviderStateMixin {
  Timer? _refreshTimer;
  late StateProvider<List<Position>> _positionsStateProvider;
  late StateProvider<bool> _isLoadingProvider;
  late StateProvider<String?> _errorProvider;

  late TabController _tabController;

  // Track expanded state for each position card
  final Set<String> _expandedPositions = <String>{};

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _positionsStateProvider = StateProvider<List<Position>>((ref) => []);
    _isLoadingProvider = StateProvider<bool>((ref) => true);
    _errorProvider = StateProvider<String?>((ref) => null);

    // Start fetching data immediately
    _fetchPositions();

    // Set up periodic refresh only while this screen is active
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _fetchPositions();
      }
    });
  }

  @override
  void dispose() {
    // Clean up timer when screen is disposed
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPositions() async {
    if (!mounted) return;

    try {
      final positionsService = ref.read(positionsApiServiceProvider);
      final positions = await positionsService.getUserPositions();

      if (mounted) {
        ref.read(_positionsStateProvider.notifier).state = positions;
        ref.read(_isLoadingProvider.notifier).state = false;
        ref.read(_errorProvider.notifier).state = null;
      }
    } catch (error) {
      if (mounted) {
        ref.read(_isLoadingProvider.notifier).state = false;
        ref.read(_errorProvider.notifier).state = error.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final positions = ref.watch(_positionsStateProvider);
    final isLoading = ref.watch(_isLoadingProvider);
    final error = ref.watch(_errorProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOpenTradesTab(positions, isLoading, error),
                  _buildOrderHistoryTab(),
                ],
              ),
            ),
          ],
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

    return _buildPositionsList(positions);
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.white),
          ),
          const SizedBox(width: 8),
          Text('Trading Activity', style: AppTheme.heading2),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final positions = ref.watch(_positionsStateProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    '${positions.length}',
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

  Widget _buildOpenTradesTab(
    List<Position> positions,
    bool isLoading,
    String? error,
  ) {
    return _buildContent(positions, isLoading, error);
  }

  Widget _buildOrderHistoryTab() {
    final orderHistoryAsync = ref.watch(orderHistoryProvider);

    return orderHistoryAsync.when(
      data: (orders) => _buildOrderHistoryContent(orders),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.energyGreen),
      ),
      error: (error, stack) => _buildOrderHistoryErrorState(error.toString()),
    );
  }

  Widget _buildOrderHistoryContent(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildOrderHistoryEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(orderHistoryProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOrderCard(order),
          );
        },
      ),
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
            onTap: () => ref.invalidate(orderHistoryProvider),
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
            onTap: () => _fetchPositions(),
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

  Widget _buildPositionsList(List<Position> positions) {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchPositions();
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
            child: _buildPositionCard(position),
          );
        },
      ),
    );
  }

  Widget _buildPositionCard(Position position) {
    final isProfitable = position.isProfitable;
    final roiPercent = position.roiPercentage;
    final positionKey =
        '${position.market}_${position.side}_${position.createdAtDateTime.millisecondsSinceEpoch}';
    final isExpanded = _expandedPositions.contains(positionKey);

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
                  color: _getAssetColor(position.market).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: AssetDropdown.buildAssetImage(
                    _getBaseAsset(position.market),
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
                      position.market,
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
                      _expandedPositions.remove(positionKey);
                    } else {
                      _expandedPositions.add(positionKey);
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
                    '${position.sizeValue.toStringAsFixed(2)} ${_getBaseAsset(position.market)}',
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
                  _buildDetailRow(
                    'Margin:',
                    MarketUtils.formatPrice(position.marginValue),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Time Open:',
                    _formatDuration(
                      DateTime.now().difference(position.createdAtDateTime),
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

  Widget _buildOrderCard(Order order) {
    final isBuy = order.isBuy;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBuy
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
                  color: _getAssetColor(order.market).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: AssetDropdown.buildAssetImage(
                    _getBaseAsset(order.market),
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
                      order.market,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          order.side,
                          style: AppTheme.bodySmall.copyWith(
                            color: isBuy
                                ? AppTheme.energyGreen
                                : AppTheme.dangerRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order.status,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStatusColor(
                                order.status,
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            order.status,
                            style: AppTheme.bodySmall.copyWith(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Order amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${order.totalValue.toStringAsFixed(2)}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${order.filledQtyValue.toStringAsFixed(4)} ${_getBaseAsset(order.market)}',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.spaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow('Type:', order.type),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Price:',
                  '\$${order.priceValue.toStringAsFixed(4)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Average Price:',
                  '\$${order.averagePriceValue.toStringAsFixed(4)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Quantity:',
                  '${order.qtyValue.toStringAsFixed(4)} ${_getBaseAsset(order.market)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Filled:',
                  '${order.filledQtyValue.toStringAsFixed(4)} ${_getBaseAsset(order.market)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Fee:',
                  '\$${order.payedFeeValue.toStringAsFixed(4)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Time:',
                  _formatDateTime(order.createdAtDateTime),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'FILLED':
        return AppTheme.energyGreen;
      case 'CANCELLED':
        return AppTheme.dangerRed;
      case 'PARTIALLY_FILLED':
        return AppTheme.starYellow;
      case 'PENDING':
        return AppTheme.cosmicBlue;
      default:
        return AppTheme.gray400;
    }
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
