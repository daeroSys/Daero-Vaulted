import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'themeMode';

  ThemeModeNotifier(this._prefs) : super(_loadThemeMode(_prefs));

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value == 'ThemeMode.light') return ThemeMode.light;
    if (value == 'ThemeMode.dark') return ThemeMode.dark;
    return ThemeMode.system; // default
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.toString());
  }
}

final analyticsOptInProvider = StateNotifierProvider<AnalyticsOptInNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AnalyticsOptInNotifier(prefs);
});

class AnalyticsOptInNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'analyticsOptIn';

  AnalyticsOptInNotifier(this._prefs) : super(_prefs.getBool(_key) ?? true);

  Future<void> setOptIn(bool value) async {
    state = value;
    await _prefs.setBool(_key, value);
  }
}
