import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/practice_providers.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/widgets/asset_dropdown.dart';
import '../../shared/widgets/direction_selector.dart';
import '../../shared/widgets/leverage_selector.dart';
import '../../shared/widgets/amount_selector.dart';
import 'widgets/practice_account_info.dart';
import 'widgets/practice_positions_list.dart';
import 'widgets/practice_trade_history.dart';
import 'widgets/practice_tutorial_overlay.dart';

class PracticeTradingScreen extends ConsumerStatefulWidget {
  const PracticeTradingScreen({super.key});

  @override
  ConsumerState<PracticeTradingScreen> createState() =>
      _PracticeTradingScreenState();
}

class _PracticeTradingScreenState extends ConsumerState<PracticeTradingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Trading form state
  String? selectedAsset;
  String selectedDirection = 'long';
  double selectedLeverage = 1.0;
  double? selectedAmount;
  double? stopLoss;
  double? takeProfit;

  // UI state
  bool _showRiskManagement = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceModeStateProvider);
    final accountAsync = ref.watch(practiceAccountProvider);
    final marketsAsync = ref.watch(marketsProvider);

    return Scaffold(
      backgroundColor: AppTheme.spaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.spaceDeep,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.energyGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.energyGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, color: AppTheme.energyGreen, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    'PRACTICE',
                    style: TextStyle(
                      color: AppTheme.energyGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showTutorial(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _resetAccount(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Account info
              accountAsync.when(
                data: (account) => account != null
                    ? PracticeAccountInfo(account: account)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Tab bar
              Container(
                color: AppTheme.spaceDeep,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.starYellow,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.starYellow,
                  tabs: const [
                    Tab(text: 'Trade'),
                    Tab(text: 'Positions'),
                    Tab(text: 'History'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTradeTab(marketsAsync),
                    const PracticePositionsList(),
                    const PracticeTradeHistory(),
                  ],
                ),
              ),
            ],
          ),

          // Tutorial overlay
          if (practiceState.showTutorial)
            PracticeTutorialOverlay(
              onComplete: () =>
                  ref.read(practiceModeStateProvider.notifier).hideTutorial(),
            ),
        ],
      ),
    );
  }

  Widget _buildTradeTab(AsyncValue marketsAsync) {
    return marketsAsync.when(
      data: (markets) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Asset selection
            AssetDropdown(
              selectedAsset: selectedAsset ?? '',
              onAssetSelected: (assetName) {
                setState(() {
                  selectedAsset = assetName;
                });
              },
            ),
            const SizedBox(height: 16),

            // Direction selection
            DirectionSelector(
              selectedDirection: selectedDirection,
              onDirectionChanged: (direction) {
                setState(() {
                  selectedDirection = direction;
                });
              },
            ),
            const SizedBox(height: 16),

            // Leverage selection
            LeverageSelector(
              selectedLeverage: selectedLeverage,
              onLeverageChanged: (leverage) {
                setState(() {
                  selectedLeverage = leverage;
                });
              },
            ),
            const SizedBox(height: 16),

            // Amount selection
            AmountSelector(
              selectedAmount: selectedAmount ?? 0.0,
              onAmountChanged: (amount) {
                setState(() {
                  selectedAmount = amount;
                });
              },
            ),
            const SizedBox(height: 16),

            // Risk management section
            _buildRiskManagementSection(),
            const SizedBox(height: 24),

            // Trade button
            _buildTradeButton(),
            const SizedBox(height: 16),

            // Practice info card
            _buildPracticeInfoCard(),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error loading markets: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildRiskManagementSection() {
    return Card(
      color: AppTheme.spaceDeep,
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Risk Management',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                _showRiskManagement
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showRiskManagement = !_showRiskManagement;
                });
              },
            ),
          ),
          if (_showRiskManagement) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stop Loss
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Stop Loss',
                      hintText: 'Enter stop loss price',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelStyle: const TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        stopLoss = double.tryParse(value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Take Profit
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Take Profit',
                      hintText: 'Enter take profit price',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelStyle: const TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        takeProfit = double.tryParse(value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTradeButton() {
    final isValid =
        selectedAsset != null && selectedAmount != null && selectedAmount! > 0;

    return ElevatedButton(
      onPressed: isValid && !_isLoading ? _executeTrade : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedDirection == 'long'
            ? AppTheme.energyGreen
            : Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              '${selectedDirection.toUpperCase()} ${selectedAsset ?? 'Asset'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildPracticeInfoCard() {
    return Card(
      color: AppTheme.spaceDeep.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.starYellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Practice Mode',
                  style: TextStyle(
                    color: AppTheme.starYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• Trade with virtual \$10,000\n'
              '• Real market prices\n'
              '• Risk-free learning environment\n'
              '• Track your performance',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeTrade() async {
    if (selectedAsset == null || selectedAmount == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(practiceTradingServiceProvider);

      await service.openTrade(
        symbol: selectedAsset!,
        direction: selectedDirection,
        size: selectedAmount!,
        leverage: selectedLeverage,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Practice trade opened: ${selectedDirection.toUpperCase()} $selectedAsset',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.energyGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Clear form
      setState(() {
        selectedAsset = null;
        selectedAmount = null;
        stopLoss = null;
        takeProfit = null;
        _showRiskManagement = false;
      });

      // Switch to positions tab to show the new trade
      _tabController.animateTo(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTutorial() {
    ref.read(practiceModeStateProvider.notifier).showTutorial();
  }

  Future<void> _resetAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spaceDeep,
        title: const Text(
          'Reset Practice Account',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will reset your practice account to \$10,000 and clear all trade history. This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(practiceTradingServiceProvider);
      await service.resetAccount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Practice account reset successfully'),
            backgroundColor: AppTheme.energyGreen,
          ),
        );
      }
    }
  }
}
