// lib/features/financial_profile/presentation/utils/financial_profile_ui_utils.dart

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/entities/financial_trait.dart';

class FinancialProfileUIUtils {
  static String getProfileLabel(ProfileType type, AppLocalizations l10n) {
    switch (type) {
      case ProfileType.impulsiveSpender:
        return l10n.impulsiveSpenderLabel;
      case ProfileType.balancedAware:
        return l10n.balancedAwareLabel;
      case ProfileType.strategicSaver:
        return l10n.strategicSaverLabel;
      case ProfileType.overController:
        return l10n.overControllerLabel;
      case ProfileType.financiallyDisorganized:
        return l10n.financiallyDisorganizedLabel;
      case ProfileType.cautiousOptimizer:
        return l10n.cautiousOptimizerLabel;
    }
  }

  static IconData getIconForProfileType(ProfileType type) {
    switch (type) {
      case ProfileType.impulsiveSpender:
        return Icons.shopping_bag;
      case ProfileType.balancedAware:
        return Icons.balance;
      case ProfileType.strategicSaver:
        return Icons.savings;
      case ProfileType.overController:
        return Icons.lock;
      case ProfileType.financiallyDisorganized:
        return Icons.shuffle;
      case ProfileType.cautiousOptimizer:
        return Icons.psychology;
    }
  }

  static Color getColorForProfileType(ProfileType type) {
    switch (type) {
      case ProfileType.impulsiveSpender:
        return const Color(0xFFFF6B6B);
      case ProfileType.balancedAware:
        return const Color(0xFF4CAF50);
      case ProfileType.strategicSaver:
        return const Color(0xFF2196F3);
      case ProfileType.overController:
        return const Color(0xFF9C27B0);
      case ProfileType.financiallyDisorganized:
        return const Color(0xFFFF9800);
      case ProfileType.cautiousOptimizer:
        return const Color(0xFF00BCD4);
    }
  }

  static String getLabelForTrait(FinancialTraitType type, AppLocalizations l10n) {
    switch (type) {
      case FinancialTraitType.impulsivity:
        return l10n.impulsivity;
      case FinancialTraitType.discipline:
        return l10n.discipline;
      case FinancialTraitType.savingCapacity:
        return l10n.savingCapacity;
      case FinancialTraitType.emotionalControl:
        return l10n.emotionalControl;
      case FinancialTraitType.organizationLevel:
        return l10n.organizationLevel;
      case FinancialTraitType.riskTolerance:
        return l10n.riskTolerance;
    }
  }

  static Color getColorForScore(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.blue;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }
}
