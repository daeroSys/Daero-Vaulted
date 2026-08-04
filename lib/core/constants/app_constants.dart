class AppConfig {
  static const String appName = 'Vaulted';
  static const String appVersion = '1.0.0';
}

class BuildConfig {
  static const bool isDebug = !bool.fromEnvironment('dart.vm.product');
}
