import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/statistics_providers.dart';

class AdvancedStackedChart extends ConsumerWidget {
  final StatisticsPeriod period;

  const AdvancedStackedChart({super.key, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendData = ref.watch(categoryTrendProvider);

    return Container(
      height: 380,
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
                'Analyse par Catégorie',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Icon(Icons.stacked_line_chart, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: trendData.when(
              data: (dataPoints) {
                if (dataPoints.isEmpty) {
                  return const Center(child: Text('Données insuffisantes'));
                }

                final categories = _getTopCategories(dataPoints);
                return LineChart(_buildChartData(dataPoints, categories));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur: $error')),
            ),
          ),
          const SizedBox(height: 16),
          _buildDynamicLegend(ref),
        ],
      ),
    );
  }

  List<String> _getTopCategories(List<CategoryTrendData> data) {
    final Map<String, double> totals = {};
    for (var d in data) {
      d.categories.forEach((k, v) {
        totals[k] = (totals[k] ?? 0) + v;
      });
    }
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  LineChartData _buildChartData(List<CategoryTrendData> dataPoints, List<String> categories) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10000,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.divider.withOpacity(0.3),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateBottomInterval(dataPoints.length),
            getTitlesWidget: (value, meta) => _buildBottomTitle(value.toInt(), dataPoints),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                _formatAmount(value),
                style: const TextStyle(fontSize: 9, color: AppColors.textTertiary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: categories.asMap().entries.map((entry) {
        return _buildStackedBar(dataPoints, categories, entry.key);
      }).toList().reversed.toList(), // Reversed to have largest on bottom in draw order if desired, but for stacked we need order
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => AppColors.primary.withOpacity(0.9),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${categories[spot.barIndex]}: ${_formatAmount(spot.y)} F',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildStackedBar(List<CategoryTrendData> dataPoints, List<String> categories, int catIndex) {
    final colors = [
      const Color(0xFF434371),
      const Color(0xFFD68152),
      const Color(0xFFF99B9B),
    ];
    final color = colors[catIndex % colors.length];

    return LineChartBarData(
      spots: dataPoints.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        double stackedVal = 0;
        for (int j = 0; j <= catIndex; j++) {
          stackedVal += p.categories[categories[j]] ?? 0;
        }
        return FlSpot(i.toDouble(), stackedVal);
      }).toList(),
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.85),
      ),
    );
  }

  double _calculateBottomInterval(int length) {
    if (length <= 7) return 1;
    if (length <= 15) return 2;
    return (length / 5).floorToDouble();
  }

  Widget _buildBottomTitle(int index, List<CategoryTrendData> dataPoints) {
    if (index < 0 || index >= dataPoints.length) return const SizedBox.shrink();
    final date = dataPoints[index].date;
    String label;
    switch (period) {
      case StatisticsPeriod.week:
        label = DateFormat('EE', 'fr_FR').format(date);
        break;
      case StatisticsPeriod.month:
        label = '${date.day}/${date.month}';
        break;
      case StatisticsPeriod.year:
        label = DateFormat('MMM', 'fr_FR').format(date);
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildDynamicLegend(WidgetRef ref) {
    final trendData = ref.watch(categoryTrendProvider);
    return trendData.maybeWhen(
      data: (data) {
        if (data.isEmpty) return const SizedBox.shrink();
        final categories = _getTopCategories(data);
        final colors = [
          const Color(0xFF434371),
          const Color(0xFFD68152),
          const Color(0xFFF99B9B),
        ];

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          children: categories.asMap().entries.map((entry) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: colors[entry.key % colors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.value,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          )).toList(),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  String _formatAmount(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}
