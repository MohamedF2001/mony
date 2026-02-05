// lib/core/entities/user.dart

import 'package:equatable/equatable.dart';
import '../../features/financial_profile/domain/entities/financial_profile.dart';

/// Entité représentant l'utilisateur complet de l'application
class User extends Equatable {
  final String? id;
  final String name;
  final FinancialProfile? financialProfile;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    required this.name,
    this.financialProfile,
    required this.createdAt,
    this.updatedAt,
  });

  /// Vérifie si l'utilisateur a complété son profil financier
  bool get hasFinancialProfile => financialProfile != null;

  /// Vérifie si l'onboarding est complet
  bool get isOnboardingComplete => name.isNotEmpty && hasFinancialProfile;

  User copyWith({
    String? id,
    String? name,
    FinancialProfile? financialProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      financialProfile: financialProfile ?? this.financialProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, financialProfile, createdAt, updatedAt];
}