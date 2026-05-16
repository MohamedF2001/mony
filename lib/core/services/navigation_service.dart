// lib/core/services/navigation_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'token_service.dart';
import '../services/user_service.dart';

/// Service pour gérer la logique de navigation de l'app
class NavigationService {
  static const String _keyHasSeenOnboarding = 'hasSeenOnboarding';
  static const String _keyIsInited = 'isInited';

  final UserService _userService;
  final TokenService _tokenService = TokenService();

  NavigationService(this._userService);

  /// Détermine quelle route afficher au démarrage
  Future<String> getInitialRoute() async {
    // 1. Vérifier si l'utilisateur est connecté (token présent)
    final hasToken = await _tokenService.hasToken();
    if (!hasToken) {
      return '/login';
    }

    // 2. Vérifier si l'utilisateur a complété le profil financier
    // On vérifie en local d'abord, mais idéalement on devrait aussi vérifier l'API
    final hasFinancialProfile = await _userService.hasFinancialProfile();
    if (!hasFinancialProfile) {
      return '/questionnaire';
    }

    // 3. Tout est complet → Home
    return '/home';
  }

  /// Marque l'onboarding comme vu
  Future<void> markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  /// Marque l'initialisation comme complète
  Future<void> markAsInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsInited, true);
  }

  /// Vérifie si l'onboarding a été vu
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Vérifie si l'app est initialisée
  Future<bool> isInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsInited) ?? false;
  }

  /// Reset complet (pour debug/logout)
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _userService.deleteUser();
  }
}
