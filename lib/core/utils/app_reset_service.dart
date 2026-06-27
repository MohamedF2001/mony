// lib/core/utils/app_reset_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class AppResetService {
  Future<void> resetAll() async {
    // Nettoyage complet des préférences partagées (cache utilisateur, token, etc.)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
