// lib/core/services/navigation_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
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
    final prefs = await SharedPreferences.getInstance();

    // 0. Vérifier l'onboarding
    final hasSeenOnboarding = prefs.getBool(_keyHasSeenOnboarding) ?? false;
    if (!hasSeenOnboarding) {
      return '/onboarding';
    }

    // 1. Vérifier si les préférences (langue/devise) sont définies
    final hasSetPrefs = prefs.getBool('has_set_prefs') ?? false;
    if (!hasSetPrefs) {
      return '/initial-settings';
    }

    // 2. Vérifier si l'utilisateur est connecté (token présent)
    final hasToken = await _tokenService.hasToken();
    if (!hasToken) {
      return '/login';
    }

    // 3. Vérifier si l'utilisateur a complété le profil financier
    // On vérifie en local d'abord, mais idéalement on devrait aussi vérifier l'API
    try {
      final apiClient = ApiClient(
        //baseUrl: 'http://10.0.2.2:3000/',
        //baseUrl:'http://192.168.0.189:3000/',
        baseUrl: 'https://mony-api.vercel.app/',
        tokenService: _tokenService,
      );
      await apiClient.dio.get('/api/financial-profile');
      return '/home';
    } catch (_) {
      // Fallback local pour les anciens profils non synchronises.
    }

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
