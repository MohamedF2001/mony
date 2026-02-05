// lib/features/financial_profile/domain/entities/financial_trait.dart

import 'package:equatable/equatable.dart';

/// Représente un trait financier évalué par le questionnaire
enum FinancialTraitType {
  impulsivity,        // Impulsivité dans les dépenses
  discipline,         // Discipline financière
  savingCapacity,     // Capacité à épargner
  emotionalControl,   // Contrôle émotionnel face à l'argent
  organizationLevel,  // Niveau d'organisation financière
  riskTolerance,      // Tolérance au risque
}

/// Extension pour obtenir des métadonnées sur chaque trait
extension FinancialTraitTypeExtension on FinancialTraitType {
  String get label {
    switch (this) {
      case FinancialTraitType.impulsivity:
        return 'Impulsivité';
      case FinancialTraitType.discipline:
        return 'Discipline';
      case FinancialTraitType.savingCapacity:
        return 'Capacité d\'épargne';
      case FinancialTraitType.emotionalControl:
        return 'Contrôle émotionnel';
      case FinancialTraitType.organizationLevel:
        return 'Organisation';
      case FinancialTraitType.riskTolerance:
        return 'Tolérance au risque';
    }
  }

  String get description {
    switch (this) {
      case FinancialTraitType.impulsivity:
        return 'Tendance à dépenser sans réfléchir';
      case FinancialTraitType.discipline:
        return 'Capacité à suivre un plan financier';
      case FinancialTraitType.savingCapacity:
        return 'Aptitude à mettre de l\'argent de côté';
      case FinancialTraitType.emotionalControl:
        return 'Gestion des émotions liées à l\'argent';
      case FinancialTraitType.organizationLevel:
        return 'Suivi et organisation des finances';
      case FinancialTraitType.riskTolerance:
        return 'Acceptation de l\'incertitude financière';
    }
  }
}

/// Entité représentant un trait financier avec son score
class FinancialTrait extends Equatable {
  final FinancialTraitType type;
  final int score; // Score entre 0 et 100

  const FinancialTrait({
    required this.type,
    required this.score,
  });

  /// Niveau du trait basé sur le score
  TraitLevel get level {
    if (score >= 75) return TraitLevel.high;
    if (score >= 50) return TraitLevel.medium;
    if (score >= 25) return TraitLevel.low;
    return TraitLevel.veryLow;
  }

  FinancialTrait copyWith({
    FinancialTraitType? type,
    int? score,
  }) {
    return FinancialTrait(
      type: type ?? this.type,
      score: score ?? this.score,
    );
  }

  @override
  List<Object?> get props => [type, score];
}

/// Niveau d'intensité d'un trait
enum TraitLevel {
  veryLow,
  low,
  medium,
  high,
}

extension TraitLevelExtension on TraitLevel {
  String get label {
    switch (this) {
      case TraitLevel.veryLow:
        return 'Très faible';
      case TraitLevel.low:
        return 'Faible';
      case TraitLevel.medium:
        return 'Modéré';
      case TraitLevel.high:
        return 'Élevé';
    }
  }
}