import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, production }

class Env {
  static const Environment currentEnv = bool.hasEnvironment('dart.vm.product')
      ? Environment.production
      : Environment.development;

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSJ9.signature';

  static String get revenueCatApiKey =>
      dotenv.env['REVENUECAT_API_KEY'] ?? 'placeholder-rc-key';

  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  static String get googleIosClientId =>
      dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

  static bool get isProduction => currentEnv == Environment.production;
}
