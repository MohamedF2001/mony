// lib/core/services/user_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/user.dart';
import '../../features/financial_profile/domain/entities/financial_profile.dart';
import '../../features/financial_profile/domain/entities/financial_trait.dart';
import '../../features/financial_profile/data/models/profile_model.dart';

/// Service pour gérer l'utilisateur en cache via SharedPreferences (JSON)
class UserService {
  static const String _userKey = 'current_user_json';

  /// Sauvegarde l'utilisateur complet
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final json = _userToJson(user);
    await prefs.setString(_userKey, jsonEncode(json));
  }

  /// Récupère l'utilisateur courant
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      final json = jsonDecode(userStr) as Map<String, dynamic>;
      return _userFromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Met à jour uniquement le nom
  Future<void> updateName(String name) async {
    final user = await getCurrentUser();
    if (user != null) {
      final updatedUser = user.copyWith(name: name, updatedAt: DateTime.now());
      await saveUser(updatedUser);
    } else {
      final newUser = User(name: name, createdAt: DateTime.now());
      await saveUser(newUser);
    }
  }

  /// Met à jour uniquement le profil financier
  Future<void> updateFinancialProfile(FinancialProfile profile) async {
    final user = await getCurrentUser();
    if (user != null) {
      final updatedUser = user.copyWith(
        financialProfile: profile,
        updatedAt: DateTime.now(),
      );
      await saveUser(updatedUser);
    } else {
      final newUser = User(
        name: '',
        financialProfile: profile,
        createdAt: DateTime.now(),
      );
      await saveUser(newUser);
    }
  }

  /// Vérifie si l'onboarding est complet
  Future<bool> isOnboardingComplete() async {
    final user = await getCurrentUser();
    return user?.isOnboardingComplete ?? false;
  }

  /// Vérifie si le profil financier existe
  Future<bool> hasFinancialProfile() async {
    final user = await getCurrentUser();
    return user?.hasFinancialProfile ?? false;
  }

  /// Vérifie si le nom est renseigné
  Future<bool> hasName() async {
    final user = await getCurrentUser();
    return user != null && user.name.isNotEmpty;
  }

  /// Supprime l'utilisateur (pour reset / logout)
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ---- Helpers de sérialisation ----

  Map<String, dynamic> _userToJson(User user) {
    Map<String, dynamic>? profileJson;
    if (user.financialProfile != null) {
      final model = FinancialProfileModel.fromEntity(user.financialProfile!);
      profileJson = model.toApiJson();
      profileJson['_id'] = model.id;
      profileJson['confidenceScore'] = model.confidenceScore;
      profileJson['aiFeedback'] = model.aiFeedback;
      profileJson['createdAt'] = model.createdAt.toIso8601String();
      profileJson['updatedAt'] = model.updatedAt?.toIso8601String();
    }
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'financialProfile': profileJson,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
      'isPremium': user.isPremium,
      'premiumUntil': user.premiumUntil?.toIso8601String(),
      'subscriptionType': user.subscriptionType,
    };
  }

  User _userFromJson(Map<String, dynamic> json) {
    FinancialProfile? profile;
    final profileData = json['financialProfile'];
    if (profileData != null && profileData is Map) {
      try {
        profile = FinancialProfileModel.fromJson(
          Map<String, dynamic>.from(profileData),
        ).toEntity();
      } catch (_) {
        profile = null;
      }
    }

    return User(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      financialProfile: profile,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      isPremium: json['isPremium'] as bool? ?? false,
      premiumUntil: json['premiumUntil'] != null
          ? DateTime.tryParse(json['premiumUntil'] as String)
          : null,
      subscriptionType: json['subscriptionType'] as String? ?? 'none',
    );
  }
}