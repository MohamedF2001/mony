// lib/core/entities/user.dart

import 'package:equatable/equatable.dart';
import '../../features/financial_profile/domain/entities/financial_profile.dart';

/// Entité représentant l'utilisateur complet de l'application
class User extends Equatable {
  final String? id;
  final String name;
  final String? email;
  final FinancialProfile? financialProfile;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPremium;
  final DateTime? premiumUntil;
  final String subscriptionType; // none, monthly, yearly, lifetime

  const User({
    this.id,
    required this.name,
    this.email,
    this.financialProfile,
    required this.createdAt,
    this.updatedAt,
    this.isPremium = false,
    this.premiumUntil,
    this.subscriptionType = 'none',
  });

  /// Vérifie si l'utilisateur a complété son profil financier
  bool get hasFinancialProfile => financialProfile != null;

  bool get hasActivePremium {
    if (!isPremium) return false;
    if (subscriptionType == 'lifetime') return true;
    if (premiumUntil == null) return false;
    return premiumUntil!.isAfter(DateTime.now());
  }

  bool get isPremiumExpired {
    return isPremium &&
        subscriptionType != 'lifetime' &&
        premiumUntil != null &&
        !premiumUntil!.isAfter(DateTime.now());
  }

  /// Vérifie si l'onboarding est complet
  bool get isOnboardingComplete => name.isNotEmpty && hasFinancialProfile;

  User copyWith({
    String? id,
    String? name,
    String? email,
    FinancialProfile? financialProfile,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremium,
    DateTime? premiumUntil,
    String? subscriptionType,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      financialProfile: financialProfile ?? this.financialProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      subscriptionType: subscriptionType ?? this.subscriptionType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        financialProfile,
        createdAt,
        updatedAt,
        isPremium,
        premiumUntil,
        subscriptionType,
      ];
}
