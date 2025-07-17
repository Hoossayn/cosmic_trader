import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
//import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_kit/services/wallet_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/asset_dropdown.dart';
import '../../shared/widgets/direction_selector.dart';
import '../../shared/widgets/amount_selector.dart';
import '../../shared/widgets/leverage_selector.dart';
import '../../shared/widgets/order_type_selector.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/models/market_models.dart';
import '../../shared/models/order_models.dart';
import '../../shared/utils/market_utils.dart';
import 'package:starknet_provider/starknet_provider.dart';
import '';

class TradingScreen extends ConsumerStatefulWidget {
  const TradingScreen({super.key});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;

  String _selectedAsset = 'BTC-USD'; // Default to Bitcoin
  String _selectedDirection = 'BUY';
  String _selectedOrderType = 'MARKET'; // Default to Market order
  double _selectedAmount = 25.0;
  double _selectedLeverage = 10.0;
  bool _isTrading = false;
  bool _showCustomAmountInput = false;
  bool _showRiskManagement = false;
  double? _stopLoss;
  double? _takeProfit;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketsAsync = ref.watch(marketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Place Order', style: AppTheme.heading2),
        backgroundColor: AppTheme.spaceDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.white),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push('/practice'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.energyGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.energyGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school,
                    color: AppTheme.energyGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Practice Mode',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.energyGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          marketsAsync.when(
            data: (markets) => _buildTradingContent(markets),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.energyGreen),
            ),
            error: (err, stack) => _buildErrorContent(),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.5708,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.3,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                AppTheme.energyGreen,
                AppTheme.starYellow,
                AppTheme.cosmicBlue,
                AppTheme.warningOrange,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingContent(List<Market> markets) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderTypeSelection(),
          const SizedBox(height: 24),
          _buildAssetSelection(),
          const SizedBox(height: 24),
          _buildDirectionSelection(),
          const SizedBox(height: 24),
          _buildAmountSelection(),
          const SizedBox(height: 24),
          _buildLeverageSelection(),
          const SizedBox(height: 24),
          _buildRiskManagementSection(),
          const SizedBox(height: 32),
          _buildTradePreview(markets),
          const SizedBox(height: 32),
          _buildTradeButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.dangerRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.dangerRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load market data',
              style: AppTheme.heading3.copyWith(color: AppTheme.dangerRed),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(marketsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your direction and amount',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.gray400),
        ),
      ],
    );
  }

  Widget _buildAssetSelection() {
    return AssetDropdown(
      selectedAsset: _selectedAsset,
      onAssetSelected: (asset) {
        setState(() {
          _selectedAsset = asset;
        });
      },
    );
  }

  Widget _buildDirectionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Direction', style: AppTheme.heading3),
        const SizedBox(height: 16),
        DirectionSelector(
          selectedDirection: _selectedDirection,
          onDirectionChanged: (direction) {
            setState(() {
              _selectedDirection = direction;
            });
            //Vibration.vibrate(duration: 50);
          },
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Type', style: AppTheme.heading3),
        const SizedBox(height: 16),
        OrderTypeSelector(
          selectedOrderType: _selectedOrderType,
          onOrderTypeChanged: (orderType) {
            setState(() {
              _selectedOrderType = orderType;
            });
            //Vibration.vibrate(duration: 50);
          },
        ),
      ],
    );
  }

  Widget _buildAmountSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Amount', style: AppTheme.heading3),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCustomAmountInput = !_showCustomAmountInput;
                  if (_showCustomAmountInput) {
                    _customAmountController.text = _selectedAmount
                        .toStringAsFixed(0);
                  }
                });
                //Vibration.vibrate(duration: 50);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _showCustomAmountInput
                      ? AppTheme.cosmicBlue.withOpacity(0.2)
                      : AppTheme.spaceDeep,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _showCustomAmountInput
                        ? AppTheme.cosmicBlue
                        : AppTheme.cosmicBlue.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: _showCustomAmountInput
                      ? AppTheme.cosmicBlue
                      : AppTheme.gray400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AmountSelector(
          selectedAmount: _selectedAmount,
          onAmountChanged: (amount) {
            setState(() {
              _selectedAmount = amount;
              _customAmountController.text = amount.toStringAsFixed(0);
            });
            //Vibration.vibrate(duration: 30);
          },
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showCustomAmountInput ? null : 0,
          child: _showCustomAmountInput
              ? _buildCustomAmountInput()
                    .animate()
                    .slideY(
                      begin: -0.5,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: const Duration(milliseconds: 200))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCustomAmountInput() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Amount',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.cosmicBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount...',
              hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              prefixText: '\$ ',
              prefixStyle: AppTheme.bodyLarge.copyWith(
                color: AppTheme.energyGreen,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: AppTheme.spaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.cosmicBlue.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.cosmicBlue.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.cosmicBlue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              if (amount != null && amount > 0) {
                setState(() {
                  _selectedAmount = amount;
                });
              }
            },
            onSubmitted: (value) {
              final amount = double.tryParse(value);
              if (amount != null && amount > 0) {
                setState(() {
                  _selectedAmount = amount;
                  _showCustomAmountInput = false;
                });
                //Vibration.vibrate(duration: 50);
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum: \$1 • Maximum: \$10,000',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildLeverageSelection() {
    return LeverageSelector(
      selectedLeverage: _selectedLeverage,
      onLeverageChanged: (leverage) {
        setState(() {
          _selectedLeverage = leverage;
        });
      },
    );
  }

  Widget _buildRiskManagementSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(left: 8),
            title: Text(
              'Risk Management',
              style: AppTheme.heading3.copyWith(fontWeight: FontWeight.w600),
            ),
            trailing: IconButton(
              icon: Icon(
                _showRiskManagement
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppTheme.white,
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  // Stop Loss
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Stop Loss',
                      hintText: 'Enter stop loss price',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.cosmicBlue.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.cosmicBlue.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.cosmicBlue,
                        ),
                      ),
                      labelStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.gray400,
                      ),
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.gray400,
                      ),
                      filled: true,
                      fillColor: AppTheme.spaceDark,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _stopLoss = double.tryParse(value);
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
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.cosmicBlue.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.cosmicBlue.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.cosmicBlue,
                        ),
                      ),
                      labelStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.gray400,
                      ),
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.gray400,
                      ),
                      filled: true,
                      fillColor: AppTheme.spaceDark,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _takeProfit = double.tryParse(value);
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

  Widget _buildTradePreview(List<Market> markets) {
    // Find the selected market data
    final selectedMarket = markets
        .where((market) => market.name == _selectedAsset)
        .firstOrNull;

    final positionSize = _selectedAmount * _selectedLeverage;
    final potentialXP = (_selectedAmount * 0.2).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Asset:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              Text(
                selectedMarket?.assetName ?? _selectedAsset,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Direction:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              Text(
                _selectedDirection,
                style: AppTheme.bodyMedium.copyWith(
                  color: _selectedDirection == 'BUY'
                      ? AppTheme.energyGreen
                      : AppTheme.dangerRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Type:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              Text(
                _selectedOrderType,
                style: AppTheme.bodyMedium.copyWith(
                  color: _selectedOrderType == 'MARKET'
                      ? AppTheme.energyGreen
                      : AppTheme.cosmicBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              Text(
                '\$${_selectedAmount.toStringAsFixed(0)}',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Leverage:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              Text(
                '${_selectedLeverage.toStringAsFixed(0)}x',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.starYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Position Size:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              Text(
                '\$${positionSize.toStringAsFixed(0)}',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (selectedMarket != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry Price:',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
                ),
                Text(
                  '\$${selectedMarket.price.toStringAsFixed(selectedMarket.price >= 1000 ? 0 : 4)}',
                  style: AppTheme.bodyMedium.copyWith(
                    //color: AppTheme.cosmicBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (_stopLoss != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stop Loss:',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
                ),
                Text(
                  MarketUtils.formatPrice(_stopLoss!),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.dangerRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (_takeProfit != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Take Profit:',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
                ),
                Text(
                  MarketUtils.formatPrice(_takeProfit!),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.energyGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Potential XP:',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              ),
              Text(
                '+$potentialXP XP',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.starYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTradeButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _isTrading ? null : _placeTrade,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: _isTrading
                  ? null
                  : const LinearGradient(
                      colors: [AppTheme.energyGreen, AppTheme.cosmicBlue],
                    ),
              color: _isTrading ? AppTheme.gray600 : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isTrading
                  ? null
                  : [
                      BoxShadow(
                        color: AppTheme.energyGreen.withOpacity(0.4),
                        blurRadius: 20 + (_pulseController.value * 10),
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isTrading)
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 12),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.white,
                    ),
                  )
                else
                  const Icon(
                    Icons.rocket_launch,
                    color: AppTheme.spaceDark,
                    size: 24,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isTrading
                      ? 'Placing Trade...'
                      : 'Place ${_selectedOrderType == 'MARKET' ? 'Market' : 'Limit'} Order',
                  style: AppTheme.heading3.copyWith(
                    color: _isTrading ? AppTheme.white : AppTheme.spaceDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _placeTrade() async {
    setState(() {
      _isTrading = true;
    });

    // Start pulse animation
    _pulseController.repeat(reverse: true);

    // Haptic feedback
    //Vibration.vibrate(duration: 100);

    try {
      final ordersService = ref.read(ordersApiServiceProvider);

      // Create the place order request
      final request = PlaceOrderRequest(
        market: _selectedAsset,
        orderType: _selectedOrderType.toLowerCase(),
        side: _selectedDirection.toLowerCase(),
        amount: _selectedAmount,
        //usdValue: _selectedAmount,
        price: _selectedOrderType == 'LIMIT' ? _getCurrentMarketPrice() : null,
        leverage: _selectedLeverage.toInt(),
        takeProfitPrice: _takeProfit,
        stopLossPrice: _stopLoss,
      );

      WalletService.newSeedPhrase();

      print('request object ${WalletService.newSeedPhrase()}');
      // Place the order
      final response = await ordersService.placeOrder(request);

      setState(() {
        _isTrading = false;
      });

      _pulseController.stop();

      // Show success feedback
      _confettiController.play();
      //Vibration.vibrate(duration: 200);

      final potentialXP = (_selectedAmount * 0.2).toInt();

      // Show success snackbar with order details
      if (mounted) {
        String message = 'Trade placed successfully! +$potentialXP XP earned!';
        if (response.orderId != null) {
          message += '\nOrder ID: ${response.orderId}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.celebration,
                  color: AppTheme.starYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.energyGreen,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Show risk management warnings if any
        _showRiskManagementWarnings(response);

        // Refresh positions data
        ref.invalidate(openPositionsProvider);

        // Navigate back to the previous screen (open trades) after successful trade
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      setState(() {
        _isTrading = false;
      });

      _pulseController.stop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to place order: ${e.toString()}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Gets the current market price for the selected asset
  double? _getCurrentMarketPrice() {
    final marketsAsync = ref.read(marketsProvider);
    return marketsAsync.whenOrNull(
      data: (markets) {
        final selectedMarket = markets
            .where((market) => market.name == _selectedAsset)
            .firstOrNull;
        return selectedMarket?.price;
      },
    );
  }

  /// Shows warnings for risk management issues
  void _showRiskManagementWarnings(PlaceOrderResponse response) {
    final warnings = <String>[];

    if (response.takeProfit?.success == false) {
      warnings.add(
        'Take Profit: ${response.takeProfit?.error ?? 'Failed to set'}',
      );
    }

    if (response.stopLoss?.success == false) {
      warnings.add('Stop Loss: ${response.stopLoss?.error ?? 'Failed to set'}');
    }

    if (warnings.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppTheme.starYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Risk Management Warnings:',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...warnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    '• $warning',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.white),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.warningOrange,
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
