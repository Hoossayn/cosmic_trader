import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
//import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/asset_dropdown.dart';
import '../../shared/widgets/direction_selector.dart';
import '../../shared/widgets/amount_selector.dart';
import '../../shared/widgets/leverage_selector.dart';
import '../../shared/providers/api_providers.dart';
import '../../shared/models/market_models.dart';

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
  String _selectedDirection = 'LONG';
  double _selectedAmount = 50.0;
  double _selectedLeverage = 2.0;
  bool _isTrading = false;
  bool _showCustomAmountInput = false;
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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: marketsAsync.when(
                    data: (markets) => _buildTradingContent(markets),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.energyGreen,
                      ),
                    ),
                    error: (err, stack) => _buildErrorContent(),
                  ),
                ),
              ],
            ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Trade', style: AppTheme.heading2),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/practice'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cosmicBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.cosmicBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.school,
                        color: AppTheme.cosmicBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Practice Mode',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.cosmicBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/open-trades'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                        Icons.list_alt,
                        color: AppTheme.energyGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Open Trades',
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
          //_buildTitle(),
          //const SizedBox(height: 24),
          _buildAssetSelection(),
          const SizedBox(height: 24),
          _buildDirectionSelection(),
          const SizedBox(height: 24),
          _buildAmountSelection(),
          const SizedBox(height: 24),
          _buildLeverageSelection(),
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
                  color: _selectedDirection == 'LONG'
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
                  _isTrading ? 'Placing Trade...' : 'Place Market Order',
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

    // Simulate trade execution
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isTrading = false;
    });

    _pulseController.stop();

    // Show success feedback
    _confettiController.play();
    //Vibration.vibrate(duration: 200);

    final potentialXP = (_selectedAmount * 0.2).toInt();

    // Show success snackbar
    if (mounted) {
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
              Text(
                'Trade placed! +$potentialXP XP earned!',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.energyGreen,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
