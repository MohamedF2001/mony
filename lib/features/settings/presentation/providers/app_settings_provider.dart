import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final Locale locale;
  final String currency;
  final bool hasSetPrefs;

  AppSettings({
    required this.locale,
    required this.currency,
    this.hasSetPrefs = false,
  });

  AppSettings copyWith({
    Locale? locale,
    String? currency,
    bool? hasSetPrefs,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
      hasSetPrefs: hasSetPrefs ?? this.hasSetPrefs,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;
  static const String _hasSetPrefsKey = 'has_set_prefs';

  AppSettingsNotifier(this._prefs)
      : super(AppSettings(
          locale: Locale(_prefs.getString('language_code') ?? 'fr'),
          currency: _prefs.getString('currency') ?? 'F CFA',
          hasSetPrefs: _prefs.getBool(_hasSetPrefsKey) ?? false,
        ));

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString('language_code', locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setCurrency(String currency) async {
    await _prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> markPreferencesAsSet() async {
    await _prefs.setBool(_hasSetPrefsKey, true);
    state = state.copyWith(hasSetPrefs: true);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppSettingsNotifier(prefs);
});
