// lib/core/services/navigation_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

/// Service pour gérer la logique de navigation de l'app
class NavigationService {
  static const String _keyHasSeenOnboarding = 'hasSeenOnboarding';
  static const String _keyIsInited = 'isInited';

  final UserService _userService;

  NavigationService(this._userService);

  /// Détermine quelle route afficher au démarrage
  Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Vérifier si l'utilisateur a vu l'onboarding
    final hasSeenOnboarding = prefs.getBool(_keyHasSeenOnboarding) ?? false;
    if (!hasSeenOnboarding) {
      return '/onboarding';
    }

    // 2. Vérifier si l'utilisateur a complété le profil financier
    final hasFinancialProfile = await _userService.hasFinancialProfile();
    if (!hasFinancialProfile) {
      return '/questionnaire';
    }

    // 3. Vérifier si l'utilisateur a renseigné son nom
    final hasName = await _userService.hasName();
    if (!hasName) {
      return '/name-input';
    }

    // 4. Tout est complet → Home
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