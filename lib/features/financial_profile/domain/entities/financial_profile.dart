// lib/features/financial_profile/domain/entities/financial_profile.dart

import 'package:equatable/equatable.dart';
import 'financial_trait.dart';

/// Types de profils financiers
enum ProfileType {
  impulsiveSpender,          // Dépensier impulsif
  balancedAware,             // Équilibré conscient
  strategicSaver,            // Économe stratégique
  overController,            // Sur-contrôleur
  financiallyDisorganized,   // Désorganisé financier
  cautiousOptimizer,         // Prudent optimisateur
}

extension ProfileTypeExtension on ProfileType {
  String get label {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return 'Dépensier Impulsif';
      case ProfileType.balancedAware:
        return 'Équilibré Conscient';
      case ProfileType.strategicSaver:
        return 'Économe Stratégique';
      case ProfileType.overController:
        return 'Sur-contrôleur';
      case ProfileType.financiallyDisorganized:
        return 'Désorganisé Financier';
      case ProfileType.cautiousOptimizer:
        return 'Prudent Optimisateur';
    }
  }

  String get description {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return 'Vous avez tendance à céder facilement aux achats spontanés et coup de cœur.';
      case ProfileType.balancedAware:
        return 'Vous maintenez un bon équilibre entre plaisir et épargne avec conscience.';
      case ProfileType.strategicSaver:
        return 'Vous planifiez vos finances avec rigueur et épargnez systématiquement.';
      case ProfileType.overController:
        return 'Vous contrôlez chaque dépense au point de limiter vos plaisirs.';
      case ProfileType.financiallyDisorganized:
        return 'Vous manquez de structure dans la gestion de votre argent.';
      case ProfileType.cautiousOptimizer:
        return 'Vous cherchez le meilleur rapport qualité-prix avec prudence.';
    }
  }

  List<String> get strengths {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return [
          'Spontané et généreux',
          'Profite du moment présent',
          'Ouvert aux opportunités',
        ];
      case ProfileType.balancedAware:
        return [
          'Équilibre sain vie/finances',
          'Prise de décision réfléchie',
          'Adaptabilité aux situations',
        ];
      case ProfileType.strategicSaver:
        return [
          'Excellente planification',
          'Discipline remarquable',
          'Vision long terme',
        ];
      case ProfileType.overController:
        return [
          'Très organisé',
          'Aucune dette',
          'Excellente épargne',
        ];
      case ProfileType.financiallyDisorganized:
        return [
          'Flexibilité',
          'Pas de stress excessif',
          'Ouverture au changement',
        ];
      case ProfileType.cautiousOptimizer:
        return [
          'Recherche de valeur',
          'Décisions informées',
          'Gestion prudente',
        ];
    }
  }

  List<String> get vigilancePoints {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return [
          'Risque d\'endettement',
          'Épargne insuffisante',
          'Achats regrettés',
        ];
      case ProfileType.balancedAware:
        return [
          'Besoin de vigilance continue',
          'Risque de relâchement occasionnel',
        ];
      case ProfileType.strategicSaver:
        return [
          'Risque de sur-épargne',
          'Plaisirs sacrifiés',
          'Rigidité excessive',
        ];
      case ProfileType.overController:
        return [
          'Qualité de vie réduite',
          'Anxiété financière élevée',
          'Relations tendues (partage)',
        ];
      case ProfileType.financiallyDisorganized:
        return [
          'Factures impayées',
          'Pas de vision long terme',
          'Stress financier latent',
        ];
      case ProfileType.cautiousOptimizer:
        return [
          'Analyses paralysantes',
          'Opportunités manquées',
          'Indécision',
        ];
    }
  }
}

/// Profil financier complet
class FinancialProfile extends Equatable {
  final String? id;
  final ProfileType type;
  final Map<FinancialTraitType, double> traitScores;
  final double confidenceScore; // 0-100 (fiabilité du profil)
  final String? aiFeedback; // Feedback généré par l'IA
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FinancialProfile({
    this.id,
    required this.type,
    required this.traitScores,
    required this.confidenceScore,
    this.aiFeedback,
    required this.createdAt,
    this.updatedAt,
  });

  String get label => type.label;
  String get description => type.description;
  List<String> get strengths => type.strengths;
  List<String> get vigilancePoints => type.vigilancePoints;

  FinancialProfile copyWith({
    String? id,
    ProfileType? type,
    Map<FinancialTraitType, double>? traitScores,
    double? confidenceScore,
    String? aiFeedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialProfile(
      id: id ?? this.id,
      type: type ?? this.type,
      traitScores: traitScores ?? this.traitScores,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    traitScores,
    confidenceScore,
    aiFeedback,
    createdAt,
    updatedAt,
  ];
}