import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
//import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
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

enum Timeframe { h1, d1, w1, m1, ytd, all }

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
  bool _showYearView = false;
  double? _stopLoss;
  double? _takeProfit;
  final TextEditingController _customAmountController = TextEditingController();

  // Timeframe state for the chart
  Timeframe _selectedTimeframe = Timeframe.d1;

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
          _buildSparklineHeader(markets),
          const SizedBox(height: 16),
          _buildYearViewSection(),
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

  // Removed unused _buildTitle()

  Widget _buildAssetSelection() {
    return AssetDropdown(
      selectedAsset: _selectedAsset,
      onAssetSelected: (asset) {
        setState(() {
          _selectedAsset = asset;
          // collapse year view on asset change to keep context focused
          _showYearView = false;
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

  // ————————————————————————————————————————————————
  // Sparkline + Year View (non-candlestick)
  // ————————————————————————————————————————————————

  Widget _buildSparklineHeader(List<Market> markets) {
    // Note: header sparkline uses pseudo data around an anchor value
    final anchor =
        markets.where((mk) => mk.name == _selectedAsset).firstOrNull?.price ??
        50000.0;
    final points = _generateYearSeries(anchor);
    final color = (points.last.y >= points.first.y)
        ? AppTheme.energyGreen
        : AppTheme.warningOrange;

    return GestureDetector(
      onTap: () => setState(() => _showYearView = !_showYearView),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.spaceDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 28,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.25),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              _showYearView
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: AppTheme.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearViewSection() {
    if (!_showYearView) return const SizedBox.shrink();

    // Get current market price
    final currentPrice = _getCurrentMarketPrice();

    final interval = _selectedTimeframe == Timeframe.h1 ? 'PT1H' : 'P1D';
    final limit = _selectedTimeframe == Timeframe.h1 ? 90 : 330;
    final candlesAsync = ref.watch(
      priceHistoryProvider((
        market: _selectedAsset,
        interval: interval,
        limit: limit,
      )),
    );

    return candlesAsync.when(
      data: (spots) {
        if (spots.isEmpty) {
          return _buildEmptyChartCard();
        }

        // Get the actual current price from market data or use last spot
        final actualCurrentPrice = currentPrice ?? spots.last.y;

        final up = actualCurrentPrice >= spots.first.y;
        final trendColor = up ? AppTheme.energyGreen : AppTheme.warningOrange;
        final changePct =
            ((actualCurrentPrice - spots.first.y) / spots.first.y) * 100;
        final changeText = '${up ? '+' : ''}${changePct.toStringAsFixed(1)}%';
        final high = spots.map((e) => e.y).reduce(math.max);
        final low = spots.map((e) => e.y).reduce(math.min);

        // Ensure bounds include current price
        final chartLow = math.min(low, actualCurrentPrice);
        final chartHigh = math.max(high, actualCurrentPrice);

        // Add padding for better visualization
        final padding = (chartHigh - chartLow) * 0.05;
        final minY = chartLow - padding;
        final maxY = chartHigh + padding;

        // Create evenly spaced price levels
        const numberOfPriceLevels = 5;
        final priceStep = (maxY - minY) / (numberOfPriceLevels - 1);
        final priceLevels = List.generate(
          numberOfPriceLevels,
          (i) => minY + (priceStep * i),
        );

        String timeframeLabel() {
          switch (_selectedTimeframe) {
            case Timeframe.h1:
              return 'Past hour';
            case Timeframe.d1:
              return 'Today';
            case Timeframe.w1:
              return 'This week';
            case Timeframe.m1:
              return 'This month';
            case Timeframe.ytd:
              return 'This year';
            case Timeframe.all:
              return 'All time';
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.spaceDeep,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${timeframeLabel()} $changeText',
                    style: AppTheme.bodyMedium.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'High ${MarketUtils.formatPrice(high)} • Low ${MarketUtils.formatPrice(low)}',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: spots.length.toDouble() - 1,
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: priceStep,
                          getDrawingHorizontalLine: (value) {
                            // Highlight current price line
                            final isCurrentPrice =
                                (value - actualCurrentPrice).abs() <
                                priceStep * 0.1;
                            return FlLine(
                              color: isCurrentPrice
                                  ? trendColor.withOpacity(0.5)
                                  : AppTheme.gray600.withOpacity(0.2),
                              strokeWidth: isCurrentPrice ? 2 : 1,
                              dashArray: isCurrentPrice ? null : [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              interval: (spots.length / 4)
                                  .floorToDouble()
                                  .clamp(1.0, double.infinity),
                              getTitlesWidget: (value, meta) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                // Find if this is a price level we want to show
                                final isLevel = priceLevels.any(
                                  (level) =>
                                      (level - value).abs() < priceStep * 0.1,
                                );

                                // Check if this is near the current price
                                final isCurrentPrice =
                                    (value - actualCurrentPrice).abs() <
                                    priceStep * 0.1;

                                if (!isLevel) return const SizedBox.shrink();

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCurrentPrice
                                        ? trendColor.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: isCurrentPrice
                                        ? Border.all(
                                            color: trendColor.withOpacity(0.5),
                                          )
                                        : null,
                                  ),
                                  child: Text(
                                    MarketUtils.formatPrice(value),
                                    style: AppTheme.bodySmall.copyWith(
                                      color: isCurrentPrice
                                          ? trendColor
                                          : AppTheme.gray500,
                                      fontWeight: isCurrentPrice
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: trendColor,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) {
                                // Only show dot for the last point
                                return spot.x == spots.length - 1;
                              },
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: trendColor,
                                  strokeWidth: 2,
                                  strokeColor: AppTheme.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  trendColor.withOpacity(0.25),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            shadow: Shadow(
                              color: trendColor.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ),
                        ],
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: actualCurrentPrice,
                              color: trendColor,
                              strokeWidth: 1,
                              dashArray: [5, 3],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  right: 2,
                                  bottom: 2,
                                ),
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.w600,
                                  backgroundColor: trendColor,
                                ),
                                labelResolver: (line) =>
                                    ' ${MarketUtils.formatPrice(line.y)} ',
                              ),
                            ),
                          ],
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: AppTheme.spaceDark.withOpacity(
                              0.85,
                            ),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((ts) {
                                final price = ts.y;
                                final diffPct =
                                    ((price - spots.first.y) / spots.first.y) *
                                    100;
                                return LineTooltipItem(
                                  '${MarketUtils.formatPrice(price)}\n${diffPct >= 0 ? '+' : ''}${diffPct.toStringAsFixed(1)}%',
                                  AppTheme.bodySmall.copyWith(
                                    color: AppTheme.white,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTimeframeChips(),
              const SizedBox(height: 8),
              _buildVolatilityHeatBar(spots),
            ],
          ),
        );
      },
      loading: () => _buildLoadingChartCard(),
      error: (e, st) => _buildErrorChartCard(),
    );
  }

  Widget _buildLoadingChartCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.spaceDeep,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
    ),
    height: 210,
    child: const Center(
      child: CircularProgressIndicator(color: AppTheme.cosmicBlue),
    ),
  );

  Widget _buildEmptyChartCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.spaceDeep,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
    ),
    height: 210,
    child: Center(
      child: Text(
        'No data yet',
        style: AppTheme.bodySmall.copyWith(color: AppTheme.gray500),
      ),
    ),
  );

  Widget _buildErrorChartCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.spaceDeep,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
    ),
    height: 210,
    child: Center(
      child: Text(
        'Failed to load chart',
        style: AppTheme.bodySmall.copyWith(color: AppTheme.dangerRed),
      ),
    ),
  );

  Widget _buildTimeframeChips() {
    final items = const [
      Timeframe.h1,
      Timeframe.d1,
      // Timeframe.w1, // disabled for now
      // Timeframe.m1, // disabled for now
    ];
    String label(Timeframe t) {
      switch (t) {
        case Timeframe.h1:
          return '1H';
        case Timeframe.d1:
          return '1D';
        case Timeframe.w1:
          return '1W';
        case Timeframe.m1:
          return '1M';

        default:
          return '';
      }
    }

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          children: [
            for (final t in items) ...[
              GestureDetector(
                onTap: () => setState(() => _selectedTimeframe = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _selectedTimeframe == t
                        ? AppTheme.cosmicBlue.withOpacity(0.2)
                        : AppTheme.spaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedTimeframe == t
                          ? AppTheme.cosmicBlue
                          : AppTheme.cosmicBlue.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    label(t),
                    style: AppTheme.bodySmall.copyWith(
                      color: _selectedTimeframe == t
                          ? AppTheme.cosmicBlue
                          : AppTheme.gray400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // _buildTimeframeLabel removed per request

  // Deprecated: previously used for pseudo series (still used by sparkline header only)
  // Removed unused shim for timeframe series
  // List<FlSpot> _generateSeriesForTimeframe(double anchor, Timeframe t) =>
  //     _generateYearSeries(anchor);

  // Deprecated helper (not used after switching to real data)
  // List<FlSpot> _generateIntradaySeries(double anchor, {int totalPoints = 60}) { ... }

  // Deprecated helper (not used after switching to real data)
  // List<FlSpot> _generateDailySeries(double anchor, {int days = 30}) { ... }

  List<FlSpot> _generateYearSeries(double anchor, {int points = 64}) {
    // Generate friendly pseudo data around anchor for UI smoothness
    final rand = math.Random(_selectedAsset.hashCode);
    double value =
        anchor * (0.7 + rand.nextDouble() * 0.6); // start between -30%..+30%
    final spots = <FlSpot>[];
    for (int i = 0; i < points; i++) {
      final drift = 1 + (rand.nextDouble() - 0.48) * 0.02; // gentle trend
      final noise =
          (rand.nextDouble() - 0.5) * (anchor * 0.0025); // soft volatility
      value = (value * drift) + noise;
      value = value.clamp(anchor * 0.45, anchor * 1.6);
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  Widget _buildVolatilityHeatBar(List<FlSpot> spots) {
    // Simple rolling stddev heat: split into months (12 buckets)
    final bucket = (spots.length / 12).floor().clamp(1, spots.length);
    final vols = <double>[];
    for (int i = 0; i < 12; i++) {
      final start = (i * bucket).clamp(0, spots.length - 1);
      final end = math.min(spots.length, start + bucket);
      final slice = spots.sublist(start, end);
      final mean = slice.map((e) => e.y).reduce((a, b) => a + b) / slice.length;
      double varSum = 0;
      for (final s in slice) {
        final d = s.y - mean;
        varSum += d * d;
      }
      final std = math.sqrt(varSum / slice.length);
      vols.add(std);
    }
    final maxVol = vols.reduce(math.max).clamp(0.0001, double.infinity);

    return Row(
      children: List.generate(12, (i) {
        final t = (vols[i] / maxVol).clamp(0.0, 1.0);
        final color = Color.lerp(
          AppTheme.cosmicBlue.withOpacity(0.25),
          AppTheme.warningOrange.withOpacity(0.8),
          t,
        )!;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
  // (removed duplicate enum defined earlier)

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
