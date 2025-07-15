import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:secure_store/secure_store.dart';
import 'package:wallet_kit/secure_store.dart';
import 'package:wallet_kit/wallet_kit.dart';
import 'package:wallet_kit/wallet_state/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/xp_progress_bar.dart';
import '../../shared/widgets/planet_widget.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/models/market_models.dart';
import '../../shared/models/nft_model.dart';
import '../../shared/utils/market_utils.dart';

class PlanetScreen extends ConsumerStatefulWidget {
  const PlanetScreen({super.key});

  @override
  ConsumerState<PlanetScreen> createState() => _PlanetScreenState();
}

class _PlanetScreenState extends ConsumerState<PlanetScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Initialize wallet after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWallet();
    });
  }

  Future<void> _initializeWallet() async {
    final hasWallets = ref.read(
      walletsProvider.select((v) => v.wallets.isNotEmpty),
    );
    if (!hasWallets) {
      try {
        final secureStore = await getAvailableSecureStore(
          getPassword: () async {
            // Your password prompt implementation
            return await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Enter Password'),
                content: TextField(
                  obscureText: true,
                  onSubmitted: (value) => Navigator.pop(context, value),
                ),
              ),
            );
          },
        );
        ref.read(walletsProvider.notifier).addWallet(secureStore: secureStore);
      } catch (e) {
        // Handle wallet initialization error if needed
        debugPrint('Wallet initialization error: $e');
      }
    }
    final address = ref.watch(walletsProvider.select((v) => v.selectedAccount?.address));
    final selectedAccount = ref.watch(walletsProvider.select((value) => value.selectedAccount));
    final walletId = selectedAccount?.walletId;
    final accountId = selectedAccount?.id;
    print('Account address $address');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Invalidate the markets provider to force a refresh
    ref.invalidate(marketsProvider);

    // Wait for the new data to load
    try {
      await ref.read(marketsProvider.future);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to refresh market data: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _onRefresh,
          color: AppTheme.energyGreen,
          backgroundColor: AppTheme.spaceDeep,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header with user info and settings
                    _buildHeader(),

                    // Main planet view
                    SizedBox(height: 50),
                    _buildPlanetView(),
                    const SizedBox(height: 20),
                    Text(
                      'Your Planet',
                      style: AppTheme.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your trading performance shapes your world.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.gray400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Market overview section
                    // _buildMarketOverview(marketsAsync),

                    // Bottom stats and quick actions
                    _buildBottomSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level and XP info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.starYellow, AppTheme.energyGreen],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.spaceDark,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Level 4',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.spaceDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Streak indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warningOrange.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppTheme.warningOrange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '1🔥',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.warningOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // XP Progress
              XPProgressBar(currentXP: 316, totalXP: 400, width: 200),
            ],
          ),

          // Settings and notifications
          Row(
            children: [
              IconButton(
                onPressed: () {
                  //Vibration.vibrate(duration: 50);
                  // TODO: Show notifications
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.gray400,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  //Vibration.vibrate(duration: 50);
                  context.push('/settings');
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppTheme.gray400,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetView() {
    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Planet visualization
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * 3.14159,
                    child: PlanetWidget(
                      size: 280,
                      healthLevel: 92,
                      ownedNFTs: NFTData.getOwnedNFTs(),
                    ),
                  );
                },
              ),
            ),
          ),

          // Planet info
        ],
      ),
    );
  }

  Widget _buildMarketOverview(AsyncValue<List<Market>> marketsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Market Overview', style: AppTheme.heading3),
              marketsAsync.when(
                data: (markets) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.energyGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.energyGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${markets.length} Assets',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.energyGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                loading: () => const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.energyGreen,
                  ),
                ),
                error: (err, stack) => Icon(
                  Icons.error_outline,
                  color: AppTheme.dangerRed,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          marketsAsync.when(
            data: (markets) => _buildMarketCards(markets),
            loading: () => _buildLoadingCards(),
            error: (err, stack) => _buildErrorCard(err),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCards(List<Market> markets) {
    // Get top performers for display
    final topGainers =
        markets.where((m) => m.priceChangePercentage > 0).toList()..sort(
          (a, b) => b.priceChangePercentage.compareTo(a.priceChangePercentage),
        );

    final topLosers = markets.where((m) => m.priceChangePercentage < 0).toList()
      ..sort(
        (a, b) => a.priceChangePercentage.compareTo(b.priceChangePercentage),
      );

    final topVolume = markets.toList()
      ..sort((a, b) => b.volume.compareTo(a.volume));

    return Column(
      children: [
        // Top 3 markets by performance
        Row(
          children: [
            if (topGainers.isNotEmpty) ...[
              Expanded(
                child: _buildQuickMarketCard(topGainers.first, 'Top Gainer'),
              ),
              const SizedBox(width: 12),
            ],
            if (topLosers.isNotEmpty) ...[
              Expanded(
                child: _buildQuickMarketCard(topLosers.first, 'Biggest Drop'),
              ),
              const SizedBox(width: 12),
            ],
            if (topVolume.isNotEmpty)
              Expanded(
                child: _buildQuickMarketCard(topVolume.first, 'Most Active'),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Quick stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.spaceDeep,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMarketStat(
                'Gainers',
                '${topGainers.length}',
                AppTheme.energyGreen,
              ),
              _buildMarketStat(
                'Losers',
                '${topLosers.length}',
                AppTheme.dangerRed,
              ),
              _buildMarketStat(
                'Total Vol',
                MarketUtils.formatLargeNumber(
                  markets.fold(0.0, (sum, market) => sum + market.volume),
                ),
                AppTheme.cosmicBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMarketCard(Market market, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: market.isPositive
              ? AppTheme.energyGreen.withOpacity(0.3)
              : AppTheme.dangerRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
          ),
          const SizedBox(height: 4),
          Text(
            market.assetName,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            MarketUtils.formatPercentage(market.priceChangePercentage),
            style: AppTheme.bodySmall.copyWith(
              color: market.isPositive
                  ? AppTheme.energyGreen
                  : AppTheme.dangerRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
        ),
      ],
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.spaceDeep,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.cosmicBlue,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.spaceDeep,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.cosmicBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.dangerRed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load market data',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.dangerRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pull down to refresh',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Today's progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                icon: Icons.trending_up,
                value: '3',
                label: 'Trades Today',
                color: AppTheme.energyGreen,
              ),
              _buildStatCard(
                icon: Icons.monetization_on,
                value: '+\$127',
                label: 'Today\'s P&L',
                color: AppTheme.starYellow,
              ),
              _buildStatCard(
                icon: Icons.eco,
                value: '92%',
                label: 'Planet Health',
                color: AppTheme.energyGreen,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick action button
          GestureDetector(
            onTap: () {
              //Vibration.vibrate(duration: 100);
              context.push('/place-trade');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.energyGreen, AppTheme.cosmicBlue],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.energyGreen.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rocket_launch,
                    color: AppTheme.spaceDark,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Start Trading',
                    style: AppTheme.heading3.copyWith(
                      color: AppTheme.spaceDark,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().slideY(
            begin: 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.heading3.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
        ),
      ],
    );
  }
}
