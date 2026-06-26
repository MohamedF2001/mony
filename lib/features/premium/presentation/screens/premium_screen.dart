import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../providers/premium_provider.dart';
import 'kkiapay.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);
    final user = ref.watch(userProvider).value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Mony Premium', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Icon(Icons.star_rounded, size: 80, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Libérez votre plein potentiel financier',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Accédez à des outils exclusifs pour transformer vos habitudes.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  _buildFeatureItem(
                    Icons.psychology_rounded,
                    'Coaching IA Avancé',
                    'Analyses profondes et alertes comportementales en temps réel.',
                  ),
                  _buildFeatureItem(
                    Icons.trending_up_rounded,
                    'Pro Insights',
                    'Simulez votre avenir financier sur 12 mois avec différents scénarios.',
                  ),
                  _buildFeatureItem(
                    Icons.school_rounded,
                    'Académie Mony',
                    'Bibliothèque d\'Ebooks, mini-cours et templates exclusifs.',
                  ),
                  _buildFeatureItem(
                    Icons.history_rounded,
                    'Historique du Profil',
                    'Suivez l\'évolution de votre comportement financier mois après mois.',
                  ),
                  const SizedBox(height: 40),
                  if (user?.hasActivePremium ?? false) ...[
                    _buildActiveSubscription(user!),
                    const SizedBox(height: 20),
                    _buildPremiumAccessActions(context),
                  ] else
                    _buildPricingOptions(ref, context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions(WidgetRef ref, BuildContext context) {
    return Column(
      children: [
        _buildPriceCard(
          ref,
          context,
          'Mensuel',
          '4.99 € / mois',
          'monthly',
          'Idéal pour essayer toutes les fonctionnalités.',
        ),
        const SizedBox(height: 16),
        _buildPriceCard(
          ref,
          context,
          'Annuel',
          '39.99 € / an',
          'yearly',
          'Économisez 33% ! La meilleure valeur.',
          isPopular: true,
        ),
        const SizedBox(height: 16),
        _buildPriceCard(
          ref,
          context,
          'À vie',
          '99.99 € une fois',
          'lifetime',
          'Accès illimité pour toujours. Pas d\'abonnement.',
        ),
      ],
    );
  }

  Widget _buildPriceCard(
    WidgetRef ref,
    BuildContext context,
    String title,
    String price,
    String type,
    String description, {
    bool isPopular = false,
  }) {
    return InkWell(
      onTap: () {
        int amount = 0;
        if (type == 'monthly') amount = 3300;
        if (type == 'yearly') amount = 26500;
        if (type == 'lifetime') amount = 66000;

        kkiapayPayment(
          context,
          amount: amount,
          onSuccess: () {
            ref.read(premiumProvider.notifier).activatePremium(type);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPopular ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            if (isPopular)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPopular ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isPopular)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'POPULAIRE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPopular ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPopular ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscription(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
          const SizedBox(height: 10),
          const Text(
            'Vous êtes membre Premium !',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: ${user.subscriptionType.toUpperCase()}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          if (user.premiumUntil != null)
            Text(
              'Expire le: ${user.premiumUntil!.day}/${user.premiumUntil!.month}/${user.premiumUntil!.year}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumAccessActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vos accès Premium',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildAccessButton(
          context,
          Icons.psychology_rounded,
          'Coaching IA Avancé',
          AppRoutes.coachAi,
        ),
        _buildAccessButton(
          context,
          Icons.trending_up_rounded,
          'Pro Insights',
          AppRoutes.simulation,
        ),
        _buildAccessButton(
          context,
          Icons.school_rounded,
          'Académie Mony',
          AppRoutes.academy,
        ),
        _buildAccessButton(
          context,
          Icons.history_rounded,
          'Historique du Profil',
          AppRoutes.monthlyReport,
        ),
      ],
    );
  }

  Widget _buildAccessButton(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(title),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
