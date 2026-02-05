// lib/features/financial_profile/domain/entities/profile_type.dart

import 'package:flutter/material.dart';

/// Types de profils financiers détectables
enum ProfileType {
  impulsiveSpender,        // Dépensier impulsif
  balancedAware,           // Équilibré conscient
  strategicSaver,          // Économe stratégique
  overController,          // Sur-contrôleur
  financiallyDisorganized, // Désorganisé financier
  cautiousOptimizer,       // Prudent optimisateur
}

/// Extension pour obtenir les métadonnées de chaque profil
extension ProfileTypeExtension on ProfileType {
  /// Nom affiché du profil
  String get displayName {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return 'Dépensier Impulsif';
      case ProfileType.balancedAware:
        return 'Équilibré Conscient';
      case ProfileType.strategicSaver:
        return 'Économe Stratégique';
      case ProfileType.overController:
        return 'Sur-Contrôleur';
      case ProfileType.financiallyDisorganized:
        return 'Désorganisé Financier';
      case ProfileType.cautiousOptimizer:
        return 'Prudent Optimisateur';
    }
  }

  /// Description courte du profil
  String get shortDescription {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return 'Vous avez tendance à dépenser spontanément, guidé par vos émotions et vos envies du moment.';
      case ProfileType.balancedAware:
        return 'Vous maintenez un bon équilibre entre plaisir et épargne, avec une conscience financière développée.';
      case ProfileType.strategicSaver:
        return 'Vous êtes un épargnant méthodique qui planifie ses finances avec rigueur et vision long terme.';
      case ProfileType.overController:
        return 'Vous contrôlez vos finances avec une extrême rigueur, parfois au détriment du plaisir.';
      case ProfileType.financiallyDisorganized:
        return 'Vous manquez de structure dans la gestion de vos finances, ce qui peut créer du stress.';
      case ProfileType.cautiousOptimizer:
        return 'Vous êtes prudent mais ouvert, cherchant à optimiser sans prendre de risques inconsidérés.';
    }
  }

  /// Points forts du profil
  List<String> get strengths {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return [
          'Vous savez profiter de la vie',
          'Spontanéité et ouverture aux opportunités',
          'Capacité à vous faire plaisir',
        ];
      case ProfileType.balancedAware:
        return [
          'Excellente gestion de l\'équilibre vie/épargne',
          'Conscience financière développée',
          'Flexibilité et adaptabilité',
        ];
      case ProfileType.strategicSaver:
        return [
          'Discipline financière exemplaire',
          'Vision long terme claire',
          'Sécurité financière assurée',
        ];
      case ProfileType.overController:
        return [
          'Contrôle total de vos finances',
          'Aucune dépense superflue',
          'Épargne maximale',
        ];
      case ProfileType.financiallyDisorganized:
        return [
          'Grande marge de progression',
          'Potentiel d\'amélioration important',
          'Conscient du besoin de changement',
        ];
      case ProfileType.cautiousOptimizer:
        return [
          'Équilibre prudence/opportunité',
          'Réflexion avant action',
          'Gestion des risques maîtrisée',
        ];
    }
  }

  /// Points de vigilance du profil
  List<String> get warnings {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return [
          'Risque d\'épuisement des ressources',
          'Difficulté à épargner pour l\'avenir',
          'Dépenses émotionnelles fréquentes',
        ];
      case ProfileType.balancedAware:
        return [
          'Attention à ne pas relâcher la vigilance',
          'Gare aux périodes de stress',
          'Maintenir l\'équilibre demande des efforts',
        ];
      case ProfileType.strategicSaver:
        return [
          'Attention à ne pas vous priver excessivement',
          'Équilibrer épargne et qualité de vie',
          'Rigidité parfois excessive',
        ];
      case ProfileType.overController:
        return [
          'Risque de privation excessive',
          'Difficulté à profiter du présent',
          'Stress lié au contrôle permanent',
        ];
      case ProfileType.financiallyDisorganized:
        return [
          'Stress financier chronique',
          'Difficulté à atteindre vos objectifs',
          'Risque de découverts fréquents',
        ];
      case ProfileType.cautiousOptimizer:
        return [
          'Attention à ne pas être trop prudent',
          'Équilibrer sécurité et opportunités',
          'Paralysie par l\'analyse parfois',
        ];
    }
  }

  /// Recommandations principales
  List<String> get recommendations {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return [
          'Mettez en place une règle des 24h avant tout achat non essentiel',
          'Automatisez une épargne mensuelle fixe',
          'Identifiez vos déclencheurs émotionnels de dépense',
        ];
      case ProfileType.balancedAware:
        return [
          'Continuez vos bonnes habitudes',
          'Augmentez progressivement votre épargne',
          'Restez vigilant lors des périodes de stress',
        ];
      case ProfileType.strategicSaver:
        return [
          'Autorisez-vous un budget plaisir mensuel',
          'Diversifiez vos placements',
          'Trouvez l\'équilibre entre épargne et vie',
        ];
      case ProfileType.overController:
        return [
          'Définissez un budget plaisir non négociable',
          'Apprenez à lâcher prise sur les petites dépenses',
          'Travaillez sur votre relation à l\'argent',
        ];
      case ProfileType.financiallyDisorganized:
        return [
          'Commencez par suivre vos dépenses pendant 1 mois',
          'Créez 3 catégories de budget simples',
          'Automatisez vos paiements récurrents',
        ];
      case ProfileType.cautiousOptimizer:
        return [
          'Définissez des objectifs clairs',
          'Testez de petites optimisations',
          'Équilibrez sécurité et croissance',
        ];
    }
  }

  /// Icône représentant le profil
  IconData get icon {
    switch (this) {
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

  /// Couleur associée au profil
  Color get color {
    switch (this) {
      case ProfileType.impulsiveSpender:
        return const Color(0xFFFF6B6B); // Rouge
      case ProfileType.balancedAware:
        return const Color(0xFF4CAF50); // Vert
      case ProfileType.strategicSaver:
        return const Color(0xFF2196F3); // Bleu
      case ProfileType.overController:
        return const Color(0xFF9C27B0); // Violet
      case ProfileType.financiallyDisorganized:
        return const Color(0xFFFF9800); // Orange
      case ProfileType.cautiousOptimizer:
        return const Color(0xFF00BCD4); // Cyan
    }
  }
}