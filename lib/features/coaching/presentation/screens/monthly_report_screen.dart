import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../../domain/entities/financial_report.dart';
import '../providers/coaching_provider.dart';

class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coachingProvider);

    return PremiumGate(
      title: 'Historique Premium',
      message: 'Activez Mony Premium pour consulter vos bilans financiers et votre historique avancé.',
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Mes Bilans Financiers'),
      ),
      body: state.isLoading && state.reports.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.reports.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.reports.length,
                  itemBuilder: (context, index) {
                    final report = state.reports[index];
                    return _buildReportCard(context, report);
                  },
                ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, FinancialReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showReportDetails(context, report),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bilan de ${_getMonthName(report.startDate.month)} ${report.startDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  _buildScoreBadge(report.score),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(Icons.arrow_upward, Colors.green, 'Revenus', Formatters.formatMoney(report.summary.totalIncome)),
                  const SizedBox(width: 16),
                  _buildStat(Icons.arrow_downward, Colors.red, 'Dépenses', Formatters.formatMoney(report.summary.totalExpense)),
                ],
              ),
              const Divider(height: 24),
              Text(
                report.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Voir le détail', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.black38)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    Color color = Colors.green;
    if (score < 50) color = Colors.red;
    else if (score < 75) color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        'Score: $score/100',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return months[month - 1];
  }

  void _showReportDetails(BuildContext context, FinancialReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyse de ${_getMonthName(report.startDate.month)} ${report.startDate.year}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _buildFullAnalysis(report),
                    const SizedBox(height: 32),
                    const Text('Top Dépenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...report.summary.topCategories.map((c) => _buildCategoryRow(c)),
                    const SizedBox(height: 32),
                    if (report.alerts.isNotEmpty) ...[
                      const Text('Alertes IA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...report.alerts.map((a) => _buildAlertItem(a)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullAnalysis(FinancialReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Text(
        report.content,
        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
      ),
    );
  }

  Widget _buildCategoryRow(CategorySummary category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category.name, style: const TextStyle(fontSize: 15)),
          Text(Formatters.formatMoney(category.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AIAlert alert) {
    Color color = Colors.orange;
    if (alert.severity == 'high') color = Colors.red;
    else if (alert.severity == 'low') color = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(alert.message, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 80, color: Colors.black12),
          SizedBox(height: 16),
          Text('Aucun bilan généré pour le moment', style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}
