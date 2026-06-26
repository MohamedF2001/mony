import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../providers/insights_provider.dart';
import '../../domain/entities/simulation.dart';
import 'package:mony/features/insights/domain/entities/simulation.dart' as insight;

class ScenariosScreen extends ConsumerStatefulWidget {
  const ScenariosScreen({super.key});

  @override
  ConsumerState<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends ConsumerState<ScenariosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(insightsProvider.notifier).fetchSimulations());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsProvider);

    return PremiumGate(
      title: 'Pro Insights',
      message: 'Activez Mony Premium pour accéder aux projections et scénarios financiers.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Mes Projections'),
      ),
      body: state.isLoading && state.simulations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.simulations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.simulations.length,
                  itemBuilder: (context, index) {
                    final sim = state.simulations[index];
                    return _buildSimulationCard(context, sim);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/simulation'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      ),
    );
  }

  Widget _buildSimulationCard(BuildContext context, insight.Simulation sim) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sim.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _buildScenarioBadge(sim.scenarioType),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => _confirmDelete(sim),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Investi', Formatters.formatMoney(sim.results.totalInvested)),
                _buildInfoColumn('Final', Formatters.formatMoney(sim.results.finalBalance), isBold: true),
                _buildInfoColumn('Durée', '${sim.parameters.durationMonths} mois'),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.black38),
                const SizedBox(width: 8),
                Text(
                  'Créé le ${sim.createdAt?.day}/${sim.createdAt?.month}/${sim.createdAt?.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Logic to set as current and go back to calculator or show details
                  },
                  child: const Text('Voir détails'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioBadge(ScenarioType type) {
    Color color = Colors.blue;
    String label = 'Réaliste';
    if (type == ScenarioType.optimistic) {
      color = Colors.green;
      label = 'Optimiste';
    } else if (type == ScenarioType.prudent) {
      color = Colors.orange;
      label = 'Prudent';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: Colors.black12),
          const SizedBox(height: 16),
          const Text('Aucune simulation enregistrée', style: TextStyle(color: Colors.black38)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/simulation'),
            child: const Text('Créer ma première simulation'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(insight.Simulation sim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Voulez-vous vraiment supprimer la simulation "${sim.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              ref.read(insightsProvider.notifier).deleteSimulation(sim.id!);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
