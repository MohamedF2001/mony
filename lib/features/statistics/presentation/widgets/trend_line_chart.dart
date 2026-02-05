/*
// lib/features/statistics/presentation/widgets/trend_line_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/statistics_providers.dart';

class TrendLineChart extends ConsumerWidget {
  final StatisticsPeriod period;

  const TrendLineChart({super.key, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            'Tendances',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: AppTypography.textTheme.labelSmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: AppTypography.textTheme.labelSmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Income Line
                  LineChartBarData(
                    spots: _generateDummyData(true),
                    isCurved: true,
                    color: AppColors.income,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.income.withOpacity(0.1),
                    ),
                  ),
                  // Expense Line
                  LineChartBarData(
                    spots: _generateDummyData(false),
                    isCurved: true,
                    color: AppColors.expense,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.expense.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateDummyData(bool isIncome) {
    // This would be replaced with real data
    return [
      FlSpot(0, isIncome ? 2000 : 1500),
      FlSpot(1, isIncome ? 2500 : 2000),
      FlSpot(2, isIncome ? 2200 : 1800),
      FlSpot(3, isIncome ? 3000 : 2500),
      FlSpot(4, isIncome ? 2800 : 2200),
      FlSpot(5, isIncome ? 3200 : 2800),
      FlSpot(6, isIncome ? 3500 : 3000),
    ];
  }
}*/


// lib/features/statistics/presentation/widgets/trend_line_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/statistics_providers.dart';

class TrendLineChart extends ConsumerWidget {
  final StatisticsPeriod period;

  const TrendLineChart({super.key, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendData = ref.watch(trendDataProvider);

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
          Row(
            children: [
              Text(
                'Tendances',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: trendData.when(
              data: (dataPoints) {
                if (dataPoints.isEmpty) {
                  return const Center(
                    child: Text('Aucune donnée disponible pour cette période'),
                  );
                }

                return LineChart(
                  _buildChartData(dataPoints),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text('Erreur: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendItem(color: AppColors.income, label: 'Revenus'),
        const SizedBox(width: 16),
        _LegendItem(color: AppColors.expense, label: 'Dépenses'),
      ],
    );
  }

  LineChartData _buildChartData(List<TrendDataPoint> dataPoints) {
    // Calculer les valeurs min et max pour l'échelle
    final allValues = dataPoints.expand((p) => [p.income, p.expense]).toList();
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    final minValue = allValues.reduce((a, b) => a < b ? a : b);

    // Arrondir les valeurs pour l'échelle
    final maxY = (maxValue * 1.2).ceilToDouble();
    final minY = (minValue * 0.8).floorToDouble();
        //.clamp(0, double.infinity);

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _calculateInterval(maxY - minY),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return _buildBottomTitle(value.toInt(), dataPoints);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: _calculateInterval(maxY - minY),
            getTitlesWidget: (value, meta) {
              return Text(
                _formatAmount(value),
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          //tooltipBgColor: AppColors.textPrimary.withOpacity(0.9),
          //tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = dataPoints[spot.x.toInt()].date;
              final isIncome = spot.barIndex == 0;
              final label = isIncome ? 'Revenus' : 'Dépenses';

              return LineTooltipItem(
                '$label\n${_formatTooltipDate(date)}\n${_formatAmount(spot.y)} F',
                TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        // Income Line
        LineChartBarData(
          spots: _buildSpots(dataPoints, true),
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.income,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.income,
                strokeWidth: 2,
                strokeColor: AppColors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.income.withOpacity(0.1),
          ),
        ),
        // Expense Line
        LineChartBarData(
          spots: _buildSpots(dataPoints, false),
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppColors.expense,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.expense,
                strokeWidth: 2,
                strokeColor: AppColors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.expense.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildSpots(List<TrendDataPoint> dataPoints, bool isIncome) {
    return dataPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      final value = isIncome ? point.income : point.expense;
      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  Widget _buildBottomTitle(int index, List<TrendDataPoint> dataPoints) {
    if (index < 0 || index >= dataPoints.length) {
      return const SizedBox.shrink();
    }

    final date = dataPoints[index].date;
    String label;

    switch (period) {
      case StatisticsPeriod.week:
      // Afficher les jours de la semaine
        final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        final dayIndex = date.weekday - 1;
        label = dayNames[dayIndex];
        break;

      case StatisticsPeriod.month:
      // Afficher les numéros de semaine ou dates
        label = '${date.day}/${date.month}';
        break;

      case StatisticsPeriod.year:
      // Afficher les mois
        final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
          'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
        label = monthNames[date.month - 1];
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        label,
        style: AppTypography.textTheme.labelSmall?.copyWith(
          fontSize: 10,
        ),
      ),
    );
  }

  double _calculateInterval(double range) {
    if (range <= 1000) return 200;
    if (range <= 5000) return 1000;
    if (range <= 10000) return 2000;
    if (range <= 50000) return 10000;
    if (range <= 100000) return 20000;
    return 50000;
  }

  String _formatAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  String _formatTooltipDate(DateTime date) {
    switch (period) {
      case StatisticsPeriod.week:
        return DateFormat('EEE d MMM', 'fr_FR').format(date);
      case StatisticsPeriod.month:
        return DateFormat('d MMM', 'fr_FR').format(date);
      case StatisticsPeriod.year:
        return DateFormat('MMM yyyy', 'fr_FR').format(date);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

