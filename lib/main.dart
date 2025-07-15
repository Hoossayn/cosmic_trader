import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:wallet_kit/wallet_kit.dart';
import 'package:wallet_kit/wallet_state/wallet_provider.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await WalletKit().init(
    accountClassHash: dotenv.env['ACCOUNT_CLASS_HASH']!,
    rpc: dotenv.env['RPC']!,
  );
  await Hive.initFlutter();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.spaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


  runApp(const ProviderScope(child: CosmicTraderApp()));
}

class CosmicTraderApp extends ConsumerWidget {
  const CosmicTraderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    final hasWallets = ref.watch(walletsProvider.select((v) => v.wallets.isNotEmpty));

    print('has wallets $hasWallets');

    return MaterialApp.router(
      title: 'Cosmic Trader',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling, // Prevent font scaling
          ),
          child: child!,
        );
      },
    );
  }
}
