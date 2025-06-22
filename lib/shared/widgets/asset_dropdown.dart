import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../models/market_models.dart';
import '../providers/api_providers.dart';
import '../utils/market_utils.dart';

class AssetDropdown extends ConsumerWidget {
  final String selectedAsset;
  final Function(String) onAssetSelected;

  const AssetDropdown({
    super.key,
    required this.selectedAsset,
    required this.onAssetSelected,
  });

  static String getAssetImageUrl(String assetName) {
    return 'https://cdn.extended.exchange/crypto/${assetName}.svg';
  }

  static Widget buildAssetImage(
    String assetName,
    String category, {
    double size = 24,
  }) {
    return SvgPicture.network(
      getAssetImageUrl(assetName),
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (context) =>
          _buildLoadingIcon(assetName, category, size),
      errorBuilder: (context, error, stackTrace) =>
          _buildFallbackIcon(assetName, category, size),
    );
  }

  static Widget _buildLoadingIcon(
    String assetName,
    String category,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MarketUtils.getAssetCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: MarketUtils.getAssetCategoryColor(category),
          ),
        ),
      ),
    );
  }

  static Widget _buildFallbackIcon(
    String assetName,
    String category,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MarketUtils.getAssetCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        MarketUtils.getAssetIcon(assetName),
        color: MarketUtils.getAssetCategoryColor(category),
        size: size * 0.6,
      ),
    );
  }

  Widget _buildAssetImage(
    String assetName,
    String category, {
    double size = 24,
  }) {
    return buildAssetImage(assetName, category, size: size);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketsAsync = ref.watch(marketsProvider);

    return marketsAsync.when(
      data: (markets) => _buildDropdown(context, markets),
      loading: () => _buildLoadingDropdown(),
      error: (err, stack) => _buildErrorDropdown(context, err),
    );
  }

  Widget _buildDropdown(BuildContext context, List<Market> markets) {
    // Find selected market or default to Bitcoin
    Market? selectedMarketData = markets
        .where((market) => market.name == selectedAsset)
        .firstOrNull;

    // If no asset is selected or selected asset not found, default to Bitcoin
    if (selectedMarketData == null) {
      selectedMarketData = markets
          .where((market) => market.assetName == 'BTC')
          .firstOrNull;
      if (selectedMarketData != null &&
          selectedAsset != selectedMarketData.name) {
        // Automatically select Bitcoin as default
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onAssetSelected(selectedMarketData!.name);
        });
      }
    }

    // Fallback to first market if Bitcoin not found
    selectedMarketData ??= markets.isNotEmpty ? markets.first : null;

    if (selectedMarketData == null) {
      return _buildErrorDropdown(context, 'No markets available');
    }

    return GestureDetector(
      onTap: () => _showAssetSelector(context, markets),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.spaceDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Asset icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MarketUtils.getAssetCategoryColor(
                  selectedMarketData.category,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: _buildAssetImage(
                  selectedMarketData.assetName,
                  selectedMarketData.category,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Asset info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedMarketData.assetName,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    selectedMarketData.name,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
                  ),
                ],
              ),
            ),

            // Price and change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  MarketUtils.formatPrice(selectedMarketData.price),
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedMarketData.isPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: 14,
                      color: selectedMarketData.isPositive
                          ? AppTheme.energyGreen
                          : AppTheme.dangerRed,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      MarketUtils.formatPercentage(
                        selectedMarketData.priceChangePercentage,
                      ),
                      style: AppTheme.bodySmall.copyWith(
                        color: selectedMarketData.isPositive
                            ? AppTheme.energyGreen
                            : AppTheme.dangerRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down, color: AppTheme.gray400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cosmicBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.gray600,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.gray600,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.gray600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.cosmicBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDropdown(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.spaceDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load markets',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.dangerRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Tap to retry',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
                ),
              ],
            ),
          ),
          const Icon(Icons.refresh, color: AppTheme.gray400, size: 20),
        ],
      ),
    );
  }

  void _showAssetSelector(BuildContext context, List<Market> markets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => AssetSelectorBottomSheet(
        markets: markets,
        selectedAsset: selectedAsset,
        onAssetSelected: (asset) {
          onAssetSelected(asset);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class AssetSelectorBottomSheet extends StatefulWidget {
  final List<Market> markets;
  final String selectedAsset;
  final Function(String) onAssetSelected;

  const AssetSelectorBottomSheet({
    super.key,
    required this.markets,
    required this.selectedAsset,
    required this.onAssetSelected,
  });

  @override
  State<AssetSelectorBottomSheet> createState() =>
      _AssetSelectorBottomSheetState();
}

class _AssetSelectorBottomSheetState extends State<AssetSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<Market> _filteredMarkets;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _filteredMarkets = widget.markets;
    _searchController.addListener(_filterAssets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAssets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMarkets = widget.markets.where((market) {
        final matchesSearch =
            market.assetName.toLowerCase().contains(query) ||
            market.name.toLowerCase().contains(query) ||
            market.category.toLowerCase().contains(query);

        final matchesCategory =
            _selectedCategory == 'All' || market.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();

      // Sort by volume (descending) to show most popular first
      _filteredMarkets.sort((a, b) => b.volume.compareTo(a.volume));
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterAssets();
  }

  @override
  Widget build(BuildContext context) {
    final otherCategories = widget.markets
        .map((m) => m.category)
        .toSet()
        .toList();
    otherCategories.sort();

    final categories = ['All', ...otherCategories];

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppTheme.spaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.gray600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('Select Asset', style: AppTheme.heading2),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppTheme.gray400),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: AppTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search assets...',
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.gray400,
                  ),
                  filled: true,
                  fillColor: AppTheme.spaceDeep,
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
                    borderSide: const BorderSide(color: AppTheme.cosmicBlue),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.gray400,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category filters
            Container(
              height: 40,
              padding: const EdgeInsets.only(left: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _selectCategory(category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.cosmicBlue.withOpacity(0.2)
                              : AppTheme.spaceDeep,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.cosmicBlue
                                : AppTheme.cosmicBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          category,
                          style: AppTheme.bodySmall.copyWith(
                            color: isSelected
                                ? AppTheme.cosmicBlue
                                : AppTheme.gray400,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Assets list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredMarkets.length,
                itemBuilder: (context, index) {
                  final market = _filteredMarkets[index];
                  final isSelected = market.name == widget.selectedAsset;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => widget.onAssetSelected(market.name),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.cosmicBlue.withOpacity(0.1)
                              : AppTheme.spaceDeep,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.cosmicBlue
                                : AppTheme.cosmicBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Asset icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: MarketUtils.getAssetCategoryColor(
                                  market.category,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: AssetDropdown.buildAssetImage(
                                  market.assetName,
                                  market.category,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Asset info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        market.assetName,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              MarketUtils.getAssetCategoryColor(
                                                market.category,
                                              ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          market.category,
                                          style: AppTheme.bodySmall.copyWith(
                                            color:
                                                MarketUtils.getAssetCategoryColor(
                                                  market.category,
                                                ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    market.name,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.gray400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Vol: ${MarketUtils.formatLargeNumber(market.volume)}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.gray500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Price and change
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  MarketUtils.formatPrice(market.price),
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      market.isPositive
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      size: 14,
                                      color: market.isPositive
                                          ? AppTheme.energyGreen
                                          : AppTheme.dangerRed,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      MarketUtils.formatPercentage(
                                        market.priceChangePercentage,
                                      ),
                                      style: AppTheme.bodySmall.copyWith(
                                        color: market.isPositive
                                            ? AppTheme.energyGreen
                                            : AppTheme.dangerRed,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (isSelected) ...[
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.cosmicBlue,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
