import 'package:flutter/material.dart';
import 'package:mony/core/constants/app_colors.dart';
import 'package:mony/core/constants/app_typography.dart';
import 'package:mony/features/onboarding/data/onboarding_data.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getIconForIndex(data.title),
                size: 80,
                color: data.color,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            style: AppTypography.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(String title) {
    if (title.contains('Bienvenue')) return Icons.account_balance_wallet;
    if (title.contains('dépenses')) return Icons.receipt_long;
    if (title.contains('budgets')) return Icons.savings;
    if (title.contains('Analysez')) return Icons.bar_chart;
    return Icons.check_circle;
  }
}
