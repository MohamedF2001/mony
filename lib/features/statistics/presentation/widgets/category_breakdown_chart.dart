// lib/features/statistics/presentation/widgets/category_breakdown_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/statistics_providers.dart';

class CategoryBreakdownChart extends ConsumerWidget {
  final StatisticsPeriod period;

  const CategoryBreakdownChart({super.key, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryStats = ref.watch(categoryStatisticsProvider);

    return Container(
      height: 300,
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
            'Répartition des dépenses',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: categoryStats.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return const Center(
                    child: Text('Aucune donnée disponible'),
                  );
                }

                return PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _buildPieChartSections(stats),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> stats) {
    final total = stats.values.fold(0.0, (a, b) => a + b);
    
    return stats.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total * 100);

      return PieChartSectionData(
        value: categoryEntry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: AppColors.categoryColors[index % AppColors.categoryColors.length],
        radius: 50,
        titleStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      );
    }).toList();
  }
}

