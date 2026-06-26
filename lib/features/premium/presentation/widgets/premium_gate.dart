import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/routes/app_routes.dart';

class PremiumGate extends ConsumerWidget {
  final Widget child;
  final String title;
  final String message;

  const PremiumGate({
    super.key,
    required this.child,
    this.title = 'Fonction Premium',
    this.message = 'Activez Mony Premium pour accéder à cette fonctionnalité.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Premium')),
        body: Center(child: Text('Erreur: $error')),
      ),
      data: (user) {
        if (user?.hasActivePremium ?? false) {
          return child;
        }

        final isExpired = user?.isPremiumExpired ?? false;

        return Scaffold(
          appBar: AppBar(title: const Text('Mony Premium')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExpired
                        ? Icons.lock_clock_rounded
                        : Icons.workspace_premium_rounded,
                    size: 72,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isExpired ? 'Abonnement expiré' : title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isExpired
                        ? 'Votre période Premium est terminée. Renouvelez votre abonnement pour continuer.'
                        : message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.premium);
                      },
                      icon: const Icon(Icons.stars_rounded),
                      label: Text(isExpired ? 'Renouveler Premium' : 'Voir Premium'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
