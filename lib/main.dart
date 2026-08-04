import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'core/config/env.dart';
import 'core/utils/logger.dart';
import 'core/utils/app_lifecycle_observer.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  AppLogger.init();

  // Initialize Firebase (Assuming default options are generated later)
  try {
    await Firebase.initializeApp();
    
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    AppLogger.e('Failed to initialize Firebase: $e');
  }

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: Env.supabaseAnonKey,
    );
  } catch (e) {
    AppLogger.e('Failed to initialize Supabase: $e');
  }

  // Initialize RevenueCat
  try {
    if (PlatformDispatcher.instance.defaultRouteName != 'test') {
      await Purchases.setLogLevel(Env.isProduction ? LogLevel.error : LogLevel.debug);
      
      PurchasesConfiguration configuration;
      // In a real app, you would check Platform.isAndroid or Platform.isIOS to pass the right key.
      configuration = PurchasesConfiguration(Env.revenueCatApiKey);
      await Purchases.configure(configuration);
    }
  } catch (e) {
    AppLogger.e('Failed to initialize RevenueCat: $e');
  }

  runApp(
    const ProviderScope(
      child: VaultedApp(),
    ),
  );
}

class VaultedApp extends StatefulWidget {
  const VaultedApp({super.key});

  @override
  State<VaultedApp> createState() => _VaultedAppState();
}

class _VaultedAppState extends State<VaultedApp> {
  final AppLifecycleObserver _observer = AppLifecycleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vaulted',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
