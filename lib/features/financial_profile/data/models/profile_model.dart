// lib/features/financial_profile/data/models/profile_model.dart

import '../../domain/entities/financial_profile.dart';
import '../../domain/entities/financial_trait.dart';

class FinancialProfileModel {
  final String id;
  final int profileTypeIndex; // ProfileType.index
  final Map<int, double> traitScoresMap; // FinancialTraitType.index -> score
  final double confidenceScore;
  final String? aiFeedback;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FinancialProfileModel({
    required this.id,
    required this.profileTypeIndex,
    required this.traitScoresMap,
    required this.confidenceScore,
    this.aiFeedback,
    required this.createdAt,
    this.updatedAt,
  });

  factory FinancialProfileModel.fromEntity(FinancialProfile profile) {
    final traitScoresMap = <int, double>{};
    profile.traitScores.forEach((trait, score) {
      traitScoresMap[trait.index] = score;
    });

    return FinancialProfileModel(
      id: profile.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      profileTypeIndex: profile.type.index,
      traitScoresMap: traitScoresMap,
      confidenceScore: profile.confidenceScore,
      aiFeedback: profile.aiFeedback,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  FinancialProfile toEntity() {
    final traitScores = <FinancialTraitType, double>{};
    traitScoresMap.forEach((traitIndex, score) {
      traitScores[FinancialTraitType.values[traitIndex]] = score;
    });

    return FinancialProfile(
      id: id,
      type: ProfileType.values[profileTypeIndex],
      traitScores: traitScores,
      confidenceScore: confidenceScore,
      aiFeedback: aiFeedback,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FinancialProfileModel.fromJson(Map<String, dynamic> json) {
    final traitScores = Map<String, dynamic>.from(
      (json['traitScores'] as Map?) ?? const {},
    );
    final traitScoresMap = <int, double>{};

    for (final trait in FinancialTraitType.values) {
      final value = traitScores[trait.name];
      traitScoresMap[trait.index] = (value as num? ?? 50).toDouble();
    }

    // Détection robuste du type
    String? typeName = json['type']?.toString();
    
    // Fallback : si type est manquant mais qu'on a des traitScores, on peut essayer de deviner
    // ou simplement mettre balancedAware par défaut pour éviter un crash
    int typeIndex = -1;
    if (typeName != null) {
      typeIndex = ProfileType.values.indexWhere((type) => type.name == typeName);
    }
    
    // Si toujours pas trouvé, on met BalancedAware par défaut
    if (typeIndex == -1) {
      typeIndex = ProfileType.balancedAware.index;
    }

    return FinancialProfileModel(
      id: (json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      profileTypeIndex: typeIndex,
      traitScoresMap: traitScoresMap,
      confidenceScore: (json['confidenceScore'] as num? ?? 0).toDouble(),
      aiFeedback: json['aiFeedback']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toApiJson({List<Map<String, dynamic>> answers = const []}) {
    final traitScores = <String, double>{};
    traitScoresMap.forEach((traitIndex, score) {
      traitScores[FinancialTraitType.values[traitIndex].name] = score;
    });

    return {
      'type': ProfileType.values[profileTypeIndex].name,
      'traitScores': traitScores,
      'confidenceScore': confidenceScore,
      'aiFeedback': aiFeedback,
      'answers': answers,
    };
  }
}
