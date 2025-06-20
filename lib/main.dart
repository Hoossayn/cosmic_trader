import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
