import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/env.dart';
import 'core/utils/logger.dart';
import 'core/utils/app_lifecycle_observer.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'core/utils/secure_local_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'application/providers/sync_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/providers.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'application/providers/settings_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await dotenv.load(fileName: '.env');
      await Supabase.initialize(
        url: Env.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: Env.supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: SecureLocalStorage(),
        ),
      );

      final container = ProviderContainer();
      final syncService = container.read(syncServiceProvider);
      await syncService.processQueue();
    } catch (e, stackTrace) {
      AppLogger.e('Background sync task failed: $e\n$stackTrace');
      return Future.value(false);
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  // Initialize Logger
  AppLogger.init();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      authOptions: FlutterAuthClientOptions(localStorage: SecureLocalStorage()),
    );
  } catch (e, stack) {
    AppLogger.e('Failed to initialize Supabase: $e');
    try {
      File(
        'C:\\Vaulted\\supabase_error.txt',
      ).writeAsStringSync('Error: $e\nStack: $stack');
    } catch (_) {}
  }

  // Initialize RevenueCat
  try {
    if (PlatformDispatcher.instance.defaultRouteName != 'test') {
      await Purchases.setLogLevel(
        Env.isProduction ? LogLevel.error : LogLevel.debug,
      );

      PurchasesConfiguration configuration;
      // In a real app, you would check Platform.isAndroid or Platform.isIOS to pass the right key.
      configuration = PurchasesConfiguration(Env.revenueCatApiKey);
      await Purchases.configure(configuration);
    }
  } catch (e) {
    AppLogger.e('Failed to initialize RevenueCat: $e');
  }

  // Initialize Workmanager
  try {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      'offline-sync-task',
      'processSyncQueue',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  } catch (e) {
    AppLogger.e('Failed to initialize Workmanager: $e');
  }

  // Initialize SharedPreferences
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    AppLogger.e('Failed to initialize SharedPreferences: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        if (prefs != null)
          sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const VaultedApp(),
    ),
  );
}

class VaultedApp extends ConsumerStatefulWidget {
  const VaultedApp({super.key});

  @override
  ConsumerState<VaultedApp> createState() => _VaultedAppState();
}

class _VaultedAppState extends ConsumerState<VaultedApp> {
  final AppLifecycleObserver _observer = AppLifecycleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_observer);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = ref.read(notificationServiceProvider);
      notificationService.init();
      notificationService.onNotificationPayload.listen((payload) {
        if (mounted) {
          final router = ref.read(appRouterProvider);
          router.go(payload);
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Vaulted',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
