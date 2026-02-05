// lib/features/dashboard/presentation/widgets/spending_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../transaction/domain/entities/transaction.dart';

class SpendingChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SpendingChart({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group transactions by category
    final Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
        totalExpense += transaction.amount;
      }
    }

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dépenses par catégorie',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _buildPieChartSections(categoryTotals, totalExpense),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildLegend(categoryTotals, totalExpense),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> data,
    double total,
  ) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total * 100);

      return PieChartSectionData(
        value: categoryEntry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color:
            AppColors.categoryColors[index % AppColors.categoryColors.length],
        radius: 50,
        titleStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<String, double> data, double total) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(5).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total * 100);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors
                    .categoryColors[index % AppColors.categoryColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                categoryEntry.key,
                style: AppTypography.textTheme.bodySmall,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
