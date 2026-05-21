import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final Locale locale;
  final String currency;

  AppSettings({
    required this.locale,
    required this.currency,
  });

  AppSettings copyWith({
    Locale? locale,
    String? currency,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  AppSettingsNotifier(this._prefs)
      : super(AppSettings(
          locale: Locale(_prefs.getString('language_code') ?? 'fr'),
          currency: _prefs.getString('currency') ?? 'F CFA',
        ));

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString('language_code', locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setCurrency(String currency) async {
    await _prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
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
