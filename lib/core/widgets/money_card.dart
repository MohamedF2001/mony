// lib/core/widgets/money_card.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../utils/formatters.dart';

class MoneyCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const MoneyCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: gradient != null
                            ? AppColors.white.withOpacity(0.2)
                            : color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: gradient != null ? AppColors.white : color,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: gradient != null
                            ? AppColors.white.withOpacity(0.7)
                            : color.withOpacity(0.7),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: gradient != null
                        ? AppColors.white.withOpacity(0.9)
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount.toFormattedMoney(),
                  style: AppTypography.moneyMedium.copyWith(
                    fontSize: 18,
                    color: gradient != null ? AppColors.white : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
