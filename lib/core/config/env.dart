enum Environment { development, production }

class Env {
  static const Environment currentEnv =
      bool.hasEnvironment('dart.vm.product') ? Environment.production : Environment.development;

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-key',
  );
  
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'placeholder-rc-key',
  );

  static bool get isProduction => currentEnv == Environment.production;
}
