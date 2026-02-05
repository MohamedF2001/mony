// lib/core/screens/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/screens/name_input_screen.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import '../../features/financial_profile/presentation/screens/questionnaire_screen.dart';

/// Écran de routage initial qui détermine où envoyer l'utilisateur
class AppRouter extends ConsumerWidget {
  final Widget dashboardScreen; // L'écran dashboard de votre app

  const AppRouter({
    Key? key,
    required this.dashboardScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userService = UserService();

    return FutureBuilder<Map<String, bool>>(
      future: _checkOnboardingStatus(userService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                ],
              ),
            ),
          );
        }

        final status = snapshot.data!;
        final hasFinancialProfile = status['hasFinancialProfile']!;
        final hasName = status['hasName']!;

        // Logique de routage
        if (!hasFinancialProfile) {
          // Pas de profil financier → Questionnaire
          return const QuestionnaireScreen();
        } else if (!hasName) {
          // Profil financier mais pas de nom → Saisie nom
          return const NameInputScreen();
        } else {
          // Tout est complet → Dashboard
          return dashboardScreen;
        }
      },
    );
  }

  Future<Map<String, bool>> _checkOnboardingStatus(UserService service) async {
    final hasFinancialProfile = await service.hasFinancialProfile();
    final hasName = await service.hasName();

    return {
      'hasFinancialProfile': hasFinancialProfile,
      'hasName': hasName,
    };
  }
}