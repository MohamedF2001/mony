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

    // Group transactions by category name
    final Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        final categoryName = transaction.displayCategoryName;
        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + transaction.amount;
        totalExpense += transaction.amount;
      }
    }

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Répartition des dépenses',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Icon(Icons.pie_chart, color: AppColors.primary.withOpacity(0.5), size: 20),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 55,
                startDegreeOffset: -90,
                sections: _buildPieChartSections(categoryTotals, totalExpense),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildLegend(categoryTotals, totalExpense),
          ),
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
      final color = AppColors.categoryColors[index % AppColors.categoryColors.length];

      return PieChartSectionData(
        value: categoryEntry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 20,
        showTitle: percentage > 10,
        titleStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<String, double> data, double total) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(4).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total * 100);
      final color = AppColors.categoryColors[index % AppColors.categoryColors.length];

      return Container(
        width: 140,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                categoryEntry.key,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTypography.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
