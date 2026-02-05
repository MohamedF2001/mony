// lib/features/financial_profile/domain/entities/profile_validation_result.dart

import 'package:equatable/equatable.dart';
import 'financial_profile.dart';

/// Résultat de validation d'un profil
class ProfileValidationResult extends Equatable {
  final bool isValid;
  final ProfileType confirmedProfile;
  final ProfileType? suggestedAlternative;
  final String? conflictReason;
  final double confidenceScore;

  const ProfileValidationResult({
    required this.isValid,
    required this.confirmedProfile,
    this.suggestedAlternative,
    this.conflictReason,
    required this.confidenceScore,
  });

  factory ProfileValidationResult.confirmed(
      ProfileType profile,
      double confidence,
      ) {
    return ProfileValidationResult(
      isValid: true,
      confirmedProfile: profile,
      confidenceScore: confidence,
    );
  }

  factory ProfileValidationResult.needsReview({
    required ProfileType detected,
    required ProfileType suggested,
    required String reason,
    required double confidence,
  }) {
    return ProfileValidationResult(
      isValid: false,
      confirmedProfile: detected,
      suggestedAlternative: suggested,
      conflictReason: reason,
      confidenceScore: confidence,
    );
  }

  @override
  List<Object?> get props => [
    isValid,
    confirmedProfile,
    suggestedAlternative,
    conflictReason,
    confidenceScore,
  ];
}