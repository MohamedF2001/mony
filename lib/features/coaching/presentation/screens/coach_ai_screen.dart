import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../providers/coaching_provider.dart';

class CoachAIScreen extends ConsumerStatefulWidget {
  const CoachAIScreen({super.key});

  @override
  ConsumerState<CoachAIScreen> createState() => _CoachAIScreenState();
}

class _CoachAIScreenState extends ConsumerState<CoachAIScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(coachingProvider.notifier).fetchReports());
  }

  @override
  Widget build(BuildContext context) {
    final coachingState = ref.watch(coachingProvider);
    final user = ref.watch(userProvider).value;

    return PremiumGate(
      title: 'Coaching IA Avancé',
      message: 'Activez Mony Premium pour générer des bilans IA et recevoir des alertes avancées.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Coach IA Financier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/monthly-report'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIStatusHeader(user),
            const SizedBox(height: 24),
            _buildActionCard(
              context,
              'Générer mon bilan mensuel',
              'L\'IA analyse vos revenus et dépenses pour vous donner un score de santé financière.',
              Icons.analytics_rounded,
              () => _generateReport(context),
              loading: coachingState.isLoading,
            ),
            const SizedBox(height: 24),
            const Text(
              'Conseils du jour',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              'Alerte Impulsivité',
              'Vous avez effectué 3 achats de catégorie "Loisirs" cette semaine. Attention à ne pas dépasser votre budget.',
              AppColors.error,
            ),
            _buildTipCard(
              'Optimisation Épargne',
              'En réduisant vos frais de "Restaurant" de 15%, vous pourriez épargner 50€ de plus par mois.',
              AppColors.success,
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAIStatusHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prêt à analyser, ${user?.name ?? ""}',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Votre profil est à jour. Je peux générer un nouveau bilan.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String desc, IconData icon, VoidCallback onTap, {bool loading = false}) {
    return InkWell(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (loading)
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            else
              const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String content, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  /*void _generateReport(BuildContext context) {
    final now = DateTime.now();
    ref.read(coachingProvider.notifier).generateReport(now.month, now.year).then((_) {
      Navigator.pushNamed(context, '/monthly-report');
    });
  }*/
  void _generateReport(BuildContext context) {
    final now = DateTime.now();
    ref.read(coachingProvider.notifier)
        .generateReport(now.month, now.year)
        .then((_) {
      Navigator.pushNamed(context, '/monthly-report');
    })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().contains('429')
              ? '⏳ Limite IA atteinte. Réessayez dans 1 minute.'
              : 'Erreur lors de la génération.'),
          backgroundColor: AppColors.error,
        ),
      );
    });
  }
}
