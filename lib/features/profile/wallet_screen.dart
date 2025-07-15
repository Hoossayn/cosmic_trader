import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet_kit/wallet_state/wallet_provider.dart';
import '../../core/theme/app_theme.dart';

enum TokenSymbol { BTC, ETH, FOCUS, USDC, USDT, STRK }

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final walletsState = ref.watch(walletsProvider);
    final selectedAccount = walletsState.wallets.isNotEmpty 
        ? walletsState.wallets.values.first.accounts.isNotEmpty 
            ? walletsState.wallets.values.first.accounts.values.first 
            : null
        : null;
    final totalBalance = _calculateTotalBalance(selectedAccount);

    return Scaffold(
      backgroundColor: AppTheme.spaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.spaceDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, color: AppTheme.white),
        ),
        title: Text('Wallet', style: AppTheme.heading2),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to wallet settings
            },
            icon: const Icon(Icons.settings, color: AppTheme.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBalanceSection(totalBalance),
          _buildActionButtons(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildNFTsTab(), _buildCryptosTab(selectedAccount)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(double totalBalance) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: AppTheme.heading1.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: AppTheme.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2);
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.qr_code,
              label: 'Receive',
              onTap: () => _showReceiveDialog(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: Icons.send,
              label: 'Send',
              onTap: () => _showSendDialog(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gray400, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TabBar(
        controller: _tabController,
        indicator: const BoxDecoration(),
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.gray400,
        labelStyle: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTheme.bodyMedium,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'NFTs'),
          Tab(text: 'Cryptos'),
        ],
      ),
    );
  }

  Widget _buildNFTsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No NFTs found',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptosTab(dynamic selectedAccount) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: TokenSymbol.values.length,
      itemBuilder: (context, index) {
        final token = TokenSymbol.values[index];
        final balance = selectedAccount?.balances[token.name] ?? 0.0;
        return _buildTokenCard(token, balance);
      },
    );
  }

  Widget _buildTokenCard(TokenSymbol token, double balance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray400, width: 1),
      ),
      child: Row(
        children: [
          _buildTokenIcon(token),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTokenDisplayName(token),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${balance.toStringAsFixed(1)} ${token.name}',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.gray400),
                ),
              ],
            ),
          ),
          Text(
            '\$${(balance * _getTokenPrice(token)).toStringAsFixed(2)}',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2);
  }

  Widget _buildTokenIcon(TokenSymbol token) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getTokenColor(token),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          _getTokenSymbol(token),
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _getTokenDisplayName(TokenSymbol token) {
    switch (token) {
      case TokenSymbol.BTC:
        return 'Bitcoin';
      case TokenSymbol.ETH:
        return 'Ethereum';
      case TokenSymbol.FOCUS:
        return 'Focus';
      case TokenSymbol.USDC:
        return 'USDC';
      case TokenSymbol.USDT:
        return 'Tether';
      case TokenSymbol.STRK:
        return 'Starknet';
    }
  }

  String _getTokenSymbol(TokenSymbol token) {
    switch (token) {
      case TokenSymbol.BTC:
        return '₿';
      case TokenSymbol.ETH:
        return 'Ξ';
      case TokenSymbol.FOCUS:
        return 'F';
      case TokenSymbol.USDC:
        return '\$';
      case TokenSymbol.USDT:
        return '\$';
      case TokenSymbol.STRK:
        return 'S';
    }
  }

  Color _getTokenColor(TokenSymbol token) {
    switch (token) {
      case TokenSymbol.BTC:
        return Colors.orange;
      case TokenSymbol.ETH:
        return Colors.blue;
      case TokenSymbol.FOCUS:
        return Colors.purple;
      case TokenSymbol.USDC:
        return Colors.green;
      case TokenSymbol.USDT:
        return Colors.green;
      case TokenSymbol.STRK:
        return AppTheme.cosmicBlue;
    }
  }

  double _getTokenPrice(TokenSymbol token) {
    // Mock prices - in real app, fetch from API
    switch (token) {
      case TokenSymbol.BTC:
        return 45000.0;
      case TokenSymbol.ETH:
        return 3000.0;
      case TokenSymbol.FOCUS:
        return 1.0;
      case TokenSymbol.USDC:
        return 1.0;
      case TokenSymbol.USDT:
        return 1.0;
      case TokenSymbol.STRK:
        return 0.50;
    }
  }

  double _calculateTotalBalance(dynamic selectedAccount) {
    if (selectedAccount?.balances == null) return 0.0;

    double total = 0.0;
    for (final token in TokenSymbol.values) {
      final balance = selectedAccount?.balances[token.name] ?? 0.0;
      total += balance * _getTokenPrice(token);
    }
    return total;
  }

  void _showReceiveDialog() {
    final walletsState = ref.read(walletsProvider);
    final selectedAccount = walletsState.wallets.isNotEmpty 
        ? walletsState.wallets.values.first.accounts.isNotEmpty 
            ? walletsState.wallets.values.first.accounts.values.first 
            : null
        : null;
    final address = selectedAccount?.address ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spaceDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.cosmicBlue.withOpacity(0.3)),
        ),
        title: Text(
          'Your Starknet address',
          style: AppTheme.heading3.copyWith(color: AppTheme.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Use this address to receive tokens\nand collectibles on Starknet.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.spaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gray400),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${address.substring(0, 6)}...${address.substring(address.length - 4)}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: address));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Address copied to clipboard',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                          backgroundColor: AppTheme.energyGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.copy,
                      color: AppTheme.gray400,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement share functionality
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.energyGreen,
                  foregroundColor: AppTheme.spaceDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Share',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.spaceDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.spaceDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.cosmicBlue.withOpacity(0.3)),
        ),
        title: Text(
          'Send Tokens',
          style: AppTheme.heading3.copyWith(color: AppTheme.white),
        ),
        content: Text(
          'Send functionality coming soon!',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.gray400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.cosmicBlue),
            ),
          ),
        ],
      ),
    );
  }
}
