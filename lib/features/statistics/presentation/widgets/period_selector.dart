// lib/features/statistics/presentation/widgets/period_selector.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/statistics_providers.dart';

class PeriodSelector extends StatelessWidget {
  final StatisticsPeriod selectedPeriod;
  final Function(StatisticsPeriod) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Semaine',
            isSelected: selectedPeriod == StatisticsPeriod.week,
            onTap: () => onPeriodChanged(StatisticsPeriod.week),
          ),
          _PeriodButton(
            label: 'Mois',
            isSelected: selectedPeriod == StatisticsPeriod.month,
            onTap: () => onPeriodChanged(StatisticsPeriod.month),
          ),
          _PeriodButton(
            label: 'Année',
            isSelected: selectedPeriod == StatisticsPeriod.year,
            onTap: () => onPeriodChanged(StatisticsPeriod.year),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

