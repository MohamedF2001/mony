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
      height: 320,
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
                'Répartition',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPeriodLabel(),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: categoryStats.when(
              data: (stats) {
                if (stats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune donnée',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 70,
                        startDegreeOffset: -90,
                        sections: _buildPieChartSections(stats),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            // On pourrait ajouter une interaction ici
                          },
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTotal(stats),
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (error, _) => Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel() {
    switch (period) {
      case StatisticsPeriod.week: return '7 jours';
      case StatisticsPeriod.month: return 'Ce mois';
      case StatisticsPeriod.year: return 'Cette année';
    }
  }

  String _formatTotal(Map<String, double> stats) {
    final total = stats.values.fold(0.0, (a, b) => a + b);
    if (total >= 1000000) return '${(total / 1000000).toStringAsFixed(1)}M';
    if (total >= 1000) return '${(total / 1000).toStringAsFixed(0)}K';
    return total.toStringAsFixed(0);
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> stats) {
    final total = stats.values.fold(0.0, (a, b) => a + b);
    final sortedEntries = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = (categoryEntry.value / total * 100);
      final color = AppColors.categoryColors[index % AppColors.categoryColors.length];

      return PieChartSectionData(
        value: categoryEntry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 25,
        showTitle: percentage > 5,
        titleStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
        badgeWidget: percentage > 15 ? _buildBadge(color) : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  Widget _buildBadge(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
        ],
      ),
    );
  }
}

