// lib/core/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../entities/user.dart';
import '../../features/financial_profile/domain/entities/financial_profile.dart';
import '../../features/financial_profile/data/models/profile_model.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'api_providers.dart';

// Provider du service
final userServiceProvider = Provider((ref) => UserService());

// Provider de l'état utilisateur
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  return UserNotifier(ref.read(userServiceProvider), ref);
});

/// Notifier pour gérer l'état de l'utilisateur
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserService _userService;
  final Ref _ref;

  UserNotifier(this._userService, this._ref) : super(const AsyncValue.loading()) {
    loadUser();
  }

  /// Charge l'utilisateur depuis Hive ou API
  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    try {
      // Priorité à l'utilisateur authentifié
      final authState = _ref.read(authProvider);
      if (authState.user != null) {
        final authUser = authState.user!;
        FinancialProfile? financialProfile;
        try {
          final apiClient = _ref.read(apiClientProvider);
          final response = await apiClient.dio.get('/api/financial-profile');
          financialProfile = FinancialProfileModel.fromJson(
            Map<String, dynamic>.from(response.data['data']['profile'] as Map),
          ).toEntity();
        } catch (_) {
          financialProfile = null;
        }

        state = AsyncValue.data(User(
          id: authUser.id,
          name: '${authUser.firstName} ${authUser.lastName}',
          financialProfile: financialProfile,
          createdAt: authUser.createdAt,
        ));
        return;
      }

      final user = await _userService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Met à jour le nom de l'utilisateur
  Future<void> updateName(String name) async {
    try {
      await _userService.updateName(name);
      await loadUser(); // Recharger l'utilisateur
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Met à jour le profil financier
  Future<void> updateFinancialProfile(FinancialProfile profile) async {
    try {
      await _userService.updateFinancialProfile(profile);
      await loadUser();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sauvegarde l'utilisateur complet
  Future<void> saveUser(User user) async {
    try {
      await _userService.saveUser(user);
      await loadUser();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
