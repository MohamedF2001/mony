/*
// lib/features/financial_profile/data/models/profile_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/entities/financial_trait.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 13)
class FinancialProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int profileTypeIndex; // ProfileType.index

  @HiveField(2)
  final Map<int, double> traitScoresMap; // FinancialTraitType.index -> score

  @HiveField(3)
  final double confidenceScore;

  @HiveField(4)
  final String? aiFeedback;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
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
}*/

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
}
