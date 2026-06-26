/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../../domain/entities/simulation.dart';
import '../providers/insights_provider.dart';
import 'package:mony/features/insights/domain/entities/simulation.dart' as insight;

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ma Simulation');
  final _initialAmountController = TextEditingController(text: '1000');
  final _monthlyContributionController = TextEditingController(text: '100');
  final _rateController = TextEditingController(text: '5');
  final _durationController = TextEditingController(text: '12');

  ScenarioType _selectedScenario = ScenarioType.realistic;

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _monthlyContributionController.dispose();
    _rateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  double _calculateInterval(List<YearlyBreakdown> breakdown) {
    if (breakdown.isEmpty) return 1;
    final maxBalance = breakdown.map((e) => e.balance).reduce((a, b) => a > b ? a : b);
    return maxBalance / 4; // 4 lignes de grille horizontales
  }

  void _runSimulation() {
    if (_formKey.currentState!.validate()) {
      final simulation = insight.Simulation(
        name: _nameController.text,
        parameters: SimulationParameters(
          initialAmount: double.parse(_initialAmountController.text),
          monthlyContribution: double.parse(_monthlyContributionController.text),
          annualReturnRate: double.parse(_rateController.text),
          durationMonths: int.parse(_durationController.text),
        ),
        results: const SimulationResults(
          totalInvested: 0,
          finalBalance: 0,
          totalInterest: 0,
          yearlyBreakdown: [],
        ),
        scenarioType: _selectedScenario,
      );

      ref.read(insightsProvider.notifier).createSimulation(simulation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsProvider);

    return PremiumGate(
      title: 'Pro Insights',
      message: 'Activez Mony Premium pour lancer des simulations financières avancées.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Simulations Financières'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/scenarios'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildForm(),
            const SizedBox(height: 30),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.currentSimulation != null)
              _buildResults(state.currentSimulation!)
            else
              _buildEmptyState(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du projet'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _initialAmountController,
                  decoration: const InputDecoration(labelText: 'Montant initial'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _monthlyContributionController,
                  decoration: const InputDecoration(labelText: 'Épargne mensuelle'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(labelText: 'Taux annuel (%)'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Durée (mois)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Scénario', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              _buildScenarioChip(ScenarioType.prudent, 'Prudent'),
              _buildScenarioChip(ScenarioType.realistic, 'Réaliste'),
              _buildScenarioChip(ScenarioType.optimistic, 'Optimiste'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _runSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lancer la simulation'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(ScenarioType type, String label) {
    final isSelected = _selectedScenario == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _selectedScenario = type),
        selectedColor: AppColors.primary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildResults(insight.Simulation simulation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        const Text('Résultats prévisionnels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildResultItem('Total Investi', Formatters.formatMoney(simulation.results.totalInvested)),
            _buildResultItem('Intérêts', Formatters.formatMoney(simulation.results.totalInterest), color: Colors.green),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('Solde Final Estimé', style: TextStyle(color: Colors.white70)),
              Text(
                Formatters.formatMoney(simulation.results.finalBalance),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text('Évolution du patrimoine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        */
/*SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: simulation.results.yearlyBreakdown
                      .map((e) => FlSpot(e.year.toDouble(), e.balance))
                      .toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),*//*


        SizedBox(
          height: 220, // un peu plus de hauteur pour laisser la place aux libellés
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(simulation.results.yearlyBreakdown),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.black.withOpacity(0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'An ${value.toInt()}',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        Formatters.formatMoneyCompact(value), // ex: "1.2M" plutôt que "1200000"
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: simulation.results.yearlyBreakdown
                      .map((e) => FlSpot(e.year.toDouble(), e.balance))
                      .toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.primary,
                  getTooltipItems: (spots) => spots.map((spot) {
                    return LineTooltipItem(
                      Formatters.formatMoney(spot.y),
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.insights, size: 64, color: Colors.black12),
            SizedBox(height: 16),
            Text('Aucune simulation active', style: TextStyle(color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}
*/



/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../../domain/entities/simulation.dart';
import '../providers/insights_provider.dart';
import 'package:mony/features/insights/domain/entities/simulation.dart' as insight;

// ─────────────────────────────────────────────────────────────
// AMÉLIORATION 2 : multiplicateurs de taux par scénario
// ─────────────────────────────────────────────────────────────
extension ScenarioMultiplier on ScenarioType {
  double get rateMultiplier {
    switch (this) {
      case ScenarioType.prudent:
        return 0.6;
      case ScenarioType.realistic:
        return 1.0;
      case ScenarioType.optimistic:
        return 1.4;
    }
  }

  String get label {
    switch (this) {
      case ScenarioType.prudent:
        return 'Prudent';
      case ScenarioType.realistic:
        return 'Réaliste';
      case ScenarioType.optimistic:
        return 'Optimiste';
    }
  }

  String get description {
    switch (this) {
      case ScenarioType.prudent:
        return 'Hypothèse conservatrice (-40%)';
      case ScenarioType.realistic:
        return 'Hypothèse de base';
      case ScenarioType.optimistic:
        return 'Hypothèse favorable (+40%)';
    }
  }
}

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ma Simulation');
  final _initialAmountController = TextEditingController(text: '1000');
  final _monthlyContributionController = TextEditingController(text: '100');
  final _rateController = TextEditingController(text: '5');
  final _durationController = TextEditingController(text: '12');

  ScenarioType _selectedScenario = ScenarioType.realistic;

  // ─── Taux effectif calculé selon le scénario ───
  double get _effectiveRate {
    final base = double.tryParse(_rateController.text) ?? 0;
    return base * _selectedScenario.rateMultiplier;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _monthlyContributionController.dispose();
    _rateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  double _calculateInterval(List<YearlyBreakdown> breakdown) {
    if (breakdown.isEmpty) return 1;
    final maxBalance =
    breakdown.map((e) => e.balance).reduce((a, b) => a > b ? a : b);
    return maxBalance / 4;
  }

  void _runSimulation() {
    if (_formKey.currentState!.validate()) {
      final simulation = insight.Simulation(
        name: _nameController.text,
        parameters: SimulationParameters(
          initialAmount: double.parse(_initialAmountController.text),
          monthlyContribution:
          double.parse(_monthlyContributionController.text),
          // ─── AMÉLIORATION 2 : on passe le taux effectif (ajusté par scénario) ───
          annualReturnRate: _effectiveRate,
          durationMonths: int.parse(_durationController.text),
        ),
        results: const SimulationResults(
          totalInvested: 0,
          finalBalance: 0,
          totalInterest: 0,
          yearlyBreakdown: [],
        ),
        scenarioType: _selectedScenario,
      );

      ref.read(insightsProvider.notifier).createSimulation(simulation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsProvider);

    return PremiumGate(
      title: 'Pro Insights',
      message:
      'Activez Mony Premium pour lancer des simulations financières avancées.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simulations Financières'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.pushNamed(context, '/scenarios'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildForm(),
              const SizedBox(height: 30),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                if (state.currentSimulation != null &&
                    // ─── AMÉLIORATION 1 : garde-fou si le calcul provider retourne 0 ───
                    state.currentSimulation!.results.finalBalance > 0)
                  _buildResults(state.currentSimulation!)
                else
                  _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Nom ───
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du projet'),
            validator: (v) =>
            (v == null || v
                .trim()
                .isEmpty) ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // ─── Montant initial / Épargne mensuelle ───
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _initialAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Montant initial',
                    // ─── AMÉLIORATION 1 : suffixe devise ───
                    suffixText: 'FCFA',
                  ),
                  keyboardType: TextInputType.number,
                  // ─── AMÉLIORATION 1 : validation ───
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Valeur invalide';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _monthlyContributionController,
                  decoration: const InputDecoration(
                    labelText: 'Épargne mensuelle',
                    suffixText: 'FCFA',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Valeur invalide';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Taux / Durée ───
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    labelText: 'Taux annuel',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  // rebuild pour mettre à jour l'affichage du taux effectif
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val <= 0 || val > 100) {
                      return 'Entre 0 et 100';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Durée',
                    suffixText: 'mois',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final val = int.tryParse(v ?? '');
                    if (val == null || val <= 0 || val > 600) {
                      return 'Entre 1 et 600';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── AMÉLIORATION 2 : Sélecteur de scénario avec taux affiché ───
          const Text('Scénario', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: ScenarioType.values
                .map((type) => _buildScenarioChip(type))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Taux effectif affiché dynamiquement
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: AppColors.primary.withOpacity(0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_selectedScenario.description} — '
                        'Taux appliqué : ${_effectiveRate.toStringAsFixed(
                        2)}% / an',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _runSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lancer la simulation'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(ScenarioType type) {
    final isSelected = _selectedScenario == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(type.label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedScenario = type),
        selectedColor: AppColors.primary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildResults(insight.Simulation simulation) {
    final breakdown = simulation.results.yearlyBreakdown;
    // ─── AMÉLIORATION 3 : détection mensuel/annuel ───
    final durationMonths = simulation.parameters.durationMonths;
    final useMonths = durationMonths < 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        const Text(
          'Résultats prévisionnels',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // ─── KPIs ───
        Row(
          children: [
            _buildResultItem(
              'Total Investi',
              Formatters.formatMoney(simulation.results.totalInvested),
            ),
            _buildResultItem(
              'Intérêts générés',
              Formatters.formatMoney(simulation.results.totalInterest),
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('Solde Final Estimé',
                  style: TextStyle(color: Colors.white70)),
              Text(
                Formatters.formatMoney(simulation.results.finalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ─── AMÉLIORATION 2 : rappel du taux utilisé ───
              const SizedBox(height: 4),
              Text(
                'Taux ${simulation.parameters.annualReturnRate.toStringAsFixed(
                    2)}% / an — ${simulation.scenarioType.label}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // ─── Graphique ───
        Text(
          useMonths
              ? 'Évolution mensuelle du patrimoine'
              : 'Évolution annuelle du patrimoine',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(breakdown),
                getDrawingHorizontalLine: (value) =>
                    FlLine(
                      color: Colors.black.withOpacity(0.05),
                      strokeWidth: 1,
                    ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final label = useMonths
                          ? 'M${value.toInt()}'
                          : 'An ${value.toInt()}';
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        Formatters.formatMoneyCompact(value),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: breakdown
                      .map((e) => FlSpot(e.year.toDouble(), e.balance))
                      .toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.primary,
                  getTooltipItems: (spots) =>
                      spots.map((spot) {
                        return LineTooltipItem(
                          Formatters.formatMoney(spot.y),
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ),

        // ─── AMÉLIORATION 3 : Tableau breakdown ───
        if (breakdown.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text(
            'Détail de la projection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBreakdownTable(breakdown, useMonths),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AMÉLIORATION 3 : tableau récapitulatif année par année
  // ─────────────────────────────────────────────────────────────
  Widget _buildBreakdownTable(List<YearlyBreakdown> breakdown, bool useMonths) {
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    );
    const cellStyle = TextStyle(fontSize: 12);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        children: [
          // En-tête
          TableRow(
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08)),
            children: [
              _tableCell(useMonths ? 'Mois' : 'Année', headerStyle),
              _tableCell('Investi', headerStyle, align: TextAlign.right),
              _tableCell('Intérêts', headerStyle, align: TextAlign.right),
              _tableCell('Solde', headerStyle, align: TextAlign.right),
            ],
          ),
          // Lignes de données
          ...breakdown
              .asMap()
              .entries
              .map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isEven = i.isEven;
            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? Colors.transparent : Colors.black.withOpacity(
                    0.02),
              ),
              children: [
                _tableCell(
                  useMonths ? 'M${row.year}' : 'An ${row.year}',
                  cellStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                _tableCell(
                  Formatters.formatMoneyCompact(row.totalInvested),
                  cellStyle,
                  align: TextAlign.right,
                ),
                _tableCell(
                  Formatters.formatMoneyCompact(row.totalInterest),
                  cellStyle.copyWith(color: Colors.green.shade700),
                  align: TextAlign.right,
                ),
                _tableCell(
                  Formatters.formatMoneyCompact(row.balance),
                  cellStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  align: TextAlign.right,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableCell(String text, TextStyle style,
      {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _buildResultItem(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.insights, size: 64, color: Colors.black12),
            SizedBox(height: 16),
            Text(
              'Aucune simulation active',
              style: TextStyle(color: Colors.black38, fontSize: 15),
            ),
            SizedBox(height: 8),
            Text(
              'Renseignez vos paramètres ci-dessus\npour projeter votre épargne.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black26, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../../domain/entities/simulation.dart';
import '../providers/insights_provider.dart';
import 'package:mony/features/insights/domain/entities/simulation.dart' as insight;

// ─────────────────────────────────────────────────────────────
// AMÉLIORATION 2 : multiplicateurs de taux par scénario
// ─────────────────────────────────────────────────────────────
extension ScenarioMultiplier on ScenarioType {
  double get rateMultiplier {
    switch (this) {
      case ScenarioType.prudent:
        return 0.6;
      case ScenarioType.realistic:
        return 1.0;
      case ScenarioType.optimistic:
        return 1.4;
    }
  }

  String get label {
    switch (this) {
      case ScenarioType.prudent:
        return 'Prudent';
      case ScenarioType.realistic:
        return 'Réaliste';
      case ScenarioType.optimistic:
        return 'Optimiste';
    }
  }

  String get description {
    switch (this) {
      case ScenarioType.prudent:
        return 'Hypothèse conservatrice (-40%)';
      case ScenarioType.realistic:
        return 'Hypothèse de base';
      case ScenarioType.optimistic:
        return 'Hypothèse favorable (+40%)';
    }
  }
}

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ma Simulation');
  final _initialAmountController = TextEditingController(text: '1000');
  final _monthlyContributionController = TextEditingController(text: '100');
  final _rateController = TextEditingController(text: '5');
  final _durationController = TextEditingController(text: '12');

  ScenarioType _selectedScenario = ScenarioType.realistic;

  // ─── Taux effectif calculé selon le scénario ───
  double get _effectiveRate {
    final base = double.tryParse(_rateController.text) ?? 0;
    return base * _selectedScenario.rateMultiplier;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _monthlyContributionController.dispose();
    _rateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  double _calculateInterval(List<YearlyBreakdown> breakdown) {
    if (breakdown.isEmpty) return 1;
    final maxBalance =
    breakdown.map((e) => e.balance).reduce((a, b) => a > b ? a : b);
    return maxBalance / 4;
  }

  void _runSimulation() {
    if (_formKey.currentState!.validate()) {
      final simulation = insight.Simulation(
        name: _nameController.text,
        parameters: SimulationParameters(
          initialAmount: double.parse(_initialAmountController.text),
          monthlyContribution:
          double.parse(_monthlyContributionController.text),
          // ─── AMÉLIORATION 2 : on passe le taux effectif (ajusté par scénario) ───
          annualReturnRate: _effectiveRate,
          durationMonths: int.parse(_durationController.text),
        ),
        results: const SimulationResults(
          totalInvested: 0,
          finalBalance: 0,
          totalInterest: 0,
          yearlyBreakdown: [],
        ),
        scenarioType: _selectedScenario,
      );

      ref.read(insightsProvider.notifier).createSimulation(simulation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsProvider);

    return PremiumGate(
      title: 'Pro Insights',
      message:
      'Activez Mony Premium pour lancer des simulations financières avancées.',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Simulations Financières'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.pushNamed(context, '/scenarios'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildForm(),
              const SizedBox(height: 30),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (state.currentSimulation != null &&
                  // ─── AMÉLIORATION 1 : garde-fou si le calcul provider retourne 0 ───
                  state.currentSimulation!.results.finalBalance > 0)
                _buildResults(state.currentSimulation!)
              else
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Nom ───
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nom du projet'),
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // ─── Montant initial / Épargne mensuelle ───
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _initialAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Montant initial',
                    // ─── AMÉLIORATION 1 : suffixe devise ───
                    suffixText: 'FCFA',
                  ),
                  keyboardType: TextInputType.number,
                  // ─── AMÉLIORATION 1 : validation ───
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Valeur invalide';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _monthlyContributionController,
                  decoration: const InputDecoration(
                    labelText: 'Épargne mensuelle',
                    suffixText: 'FCFA',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val < 0) return 'Valeur invalide';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Taux / Durée ───
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(
                    labelText: 'Taux annuel',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  // rebuild pour mettre à jour l'affichage du taux effectif
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val <= 0 || val > 100) {
                      return 'Entre 0 et 100';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Durée',
                    suffixText: 'mois',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final val = int.tryParse(v ?? '');
                    if (val == null || val <= 0 || val > 600) {
                      return 'Entre 1 et 600';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── AMÉLIORATION 2 : Sélecteur de scénario avec taux affiché ───
          const Text('Scénario', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: ScenarioType.values
                .map((type) => _buildScenarioChip(type))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Taux effectif affiché dynamiquement
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: AppColors.primary.withOpacity(0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_selectedScenario.description} — '
                        'Taux appliqué : ${_effectiveRate.toStringAsFixed(2)}% / an',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _runSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lancer la simulation'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(ScenarioType type) {
    final isSelected = _selectedScenario == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(type.label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedScenario = type),
        selectedColor: AppColors.primary.withOpacity(0.2),
      ),
    );
  }

  Widget _buildResults(insight.Simulation simulation) {
    final breakdown = simulation.results.yearlyBreakdown;
    // ─── AMÉLIORATION 3 : détection mensuel/annuel ───
    final durationMonths = simulation.parameters.durationMonths;
    final useMonths = durationMonths < 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        const Text(
          'Résultats prévisionnels',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // ─── KPIs ───
        Row(
          children: [
            _buildResultItem(
              'Total Investi',
              Formatters.formatMoney(simulation.results.totalInvested),
            ),
            _buildResultItem(
              'Intérêts générés',
              Formatters.formatMoney(simulation.results.totalInterest),
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('Solde Final Estimé',
                  style: TextStyle(color: Colors.white70)),
              Text(
                Formatters.formatMoney(simulation.results.finalBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ─── AMÉLIORATION 2 : rappel du taux utilisé ───
              const SizedBox(height: 4),
              Text(
                'Taux ${simulation.parameters.annualReturnRate.toStringAsFixed(2)}% / an — ${simulation.scenarioType.label}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // ─── Graphique ───
        Text(
          useMonths
              ? 'Évolution mensuelle du patrimoine'
              : 'Évolution annuelle du patrimoine',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(breakdown),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.black.withOpacity(0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final label = useMonths
                          ? 'M${value.toInt()}'
                          : 'An ${value.toInt()}';
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        Formatters.formatMoneyCompact(value),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: breakdown
                      .map((e) => FlSpot(e.year.toDouble(), e.balance))
                      .toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.primary,
                  getTooltipItems: (spots) => spots.map((spot) {
                    return LineTooltipItem(
                      Formatters.formatMoney(spot.y),
                      const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),

        // ─── AMÉLIORATION 3 : Tableau breakdown ───
        if (breakdown.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text(
            'Détail de la projection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBreakdownTable(breakdown, useMonths),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AMÉLIORATION 3 : tableau récapitulatif année par année
  // ─────────────────────────────────────────────────────────────
  Widget _buildBreakdownTable(
      List<YearlyBreakdown> breakdown, bool useMonths) {
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    );
    const cellStyle = TextStyle(fontSize: 12);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        children: [
          // En-tête
          TableRow(
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
            children: [
              _tableCell(useMonths ? 'Mois' : 'Année', headerStyle),
              _tableCell('Investi', headerStyle, align: TextAlign.right),
              _tableCell('Intérêts', headerStyle, align: TextAlign.right),
              _tableCell('Solde', headerStyle, align: TextAlign.right),
            ],
          ),
          // Lignes de données
          ...breakdown.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isEven = i.isEven;
            return TableRow(
              decoration: BoxDecoration(
                color: isEven ? Colors.transparent : Colors.black.withOpacity(0.02),
              ),
              children: [
                _tableCell(
                  useMonths ? 'M${row.year}' : 'An ${row.year}',
                  cellStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                _tableCell(
                  Formatters.formatMoneyCompact(row.totalInvestedDisplay),
                  cellStyle,
                  align: TextAlign.right,
                ),
                _tableCell(
                  Formatters.formatMoneyCompact(row.totalInterestDisplay),
                  cellStyle.copyWith(color: Colors.green.shade700),
                  align: TextAlign.right,
                ),
                _tableCell(
                  Formatters.formatMoneyCompact(row.balance),
                  cellStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  align: TextAlign.right,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableCell(String text, TextStyle style,
      {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _buildResultItem(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.insights, size: 64, color: Colors.black12),
            SizedBox(height: 16),
            Text(
              'Aucune simulation active',
              style: TextStyle(color: Colors.black38, fontSize: 15),
            ),
            SizedBox(height: 8),
            Text(
              'Renseignez vos paramètres ci-dessus\npour projeter votre épargne.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black26, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

