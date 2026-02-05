// lib/core/services/user_service.dart

import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../entities/user.dart';
import '../../features/financial_profile/domain/entities/financial_profile.dart';

/// Service pour gérer l'utilisateur dans Hive
class UserService {
  static const String _boxName = 'user_box';
  static const String _userKey = 'current_user';

  /// Sauvegarde l'utilisateur complet
  Future<void> saveUser(User user) async {
    final box = await Hive.openBox<UserModel>(_boxName);
    final userModel = UserModel.fromEntity(user);
    await box.put(_userKey, userModel);
  }

  /// Récupère l'utilisateur courant
  Future<User?> getCurrentUser() async {
    final box = await Hive.openBox<UserModel>(_boxName);
    final userModel = box.get(_userKey);
    return userModel?.toEntity();
  }

  /// Met à jour uniquement le nom
  Future<void> updateName(String name) async {
    final user = await getCurrentUser();
    if (user != null) {
      final updatedUser = user.copyWith(
        name: name,
        updatedAt: DateTime.now(),
      );
      await saveUser(updatedUser);
    } else {
      // Créer un nouvel utilisateur
      final newUser = User(
        name: name,
        createdAt: DateTime.now(),
      );
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
      // Créer un utilisateur avec le profil (sans nom pour l'instant)
      final newUser = User(
        name: '', // Sera rempli après
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

  /// Supprime l'utilisateur (pour reset)
  Future<void> deleteUser() async {
    final box = await Hive.openBox<UserModel>(_boxName);
    await box.delete(_userKey);
  }
}