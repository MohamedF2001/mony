// lib/core/providers/user_provider.dart

import 'dart:developer' as developer;
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

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserService _userService;
  final Ref _ref;

  UserNotifier(this._userService, this._ref) : super(const AsyncValue.loading()) {
    loadUser();
  }

  /// Charge l'utilisateur et son profil financier complet depuis l'API
  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    try {
      final authState = _ref.read(authProvider);
      if (authState.user != null) {
        final authUser = authState.user!;
        FinancialProfile? financialProfile;
        
        final apiClient = _ref.read(apiClientProvider);

        // 1. Récupérer le profil financier COMPLET via l'endpoint dédié
        try {
          final response = await apiClient.dio.get('/api/financial-profile');
          /*if (response.data != null && response.data['success'] == true) {
            final profileData = response.data['data']?['profile'];
            
            // On vérifie que c'est un objet valide (contenant au moins traitScores ou type)
            if (profileData != null && profileData is Map && 
                (profileData.containsKey('type') || profileData.containsKey('traitScores'))) {
              financialProfile = FinancialProfileModel.fromJson(
                Map<String, dynamic>.from(profileData),
              ).toEntity();
              developer.log('Profil financier récupéré avec succès: ${financialProfile.type}');
            }
          }*/
          try {
            final response = await apiClient.dio.get('/api/financial-profile');
            if (response.data != null && response.data['success'] == true) {
              final profileData = response.data['data']?['profile'];

              // LOG DE DÉBOGAGE POUR VOIR EXACTEMENT CE QUE DART REÇOIT
              print('DEBUG: Profile Data received: $profileData');

              if (profileData != null && profileData is Map) {
                try {
                  // On passe le Map directement au Model
                  financialProfile = FinancialProfileModel.fromJson(
                    Map<String, dynamic>.from(profileData),
                  ).toEntity();
                  developer.log('Profil financier parsé : ${financialProfile.type}');
                } catch (e) {
                  print('DEBUG: Error parsing profile: $e');
                }
              }
            }
          } catch (e) {
            developer.log('Erreur API financial-profile: $e');
          }

        } catch (e) {
          developer.log('Erreur lors de la récupération du profil financier: $e');
        }

        // 2. Fallback sur /api/auth/profile si le premier a échoué
        if (financialProfile == null) {
          try {
            final response = await apiClient.dio.get('/api/auth/profile');
            if (response.data != null && response.data['success'] == true) {
              final profileData = response.data['data']?['financialProfile'];
              if (profileData != null && profileData is Map && 
                  (profileData.containsKey('type') || profileData.containsKey('traitScores'))) {
                financialProfile = FinancialProfileModel.fromJson(
                  Map<String, dynamic>.from(profileData),
                ).toEntity();
              }
            }
          } catch (_) {}
        }

        final user = User(
          id: authUser.id,
          name: '${authUser.firstName} ${authUser.lastName}',
          financialProfile: financialProfile,
          createdAt: authUser.createdAt,
        );

        // Sauvegarde locale pour la persistance
        await _userService.saveUser(user);
        state = AsyncValue.data(user);
        return;
      }

      final localUser = await _userService.getCurrentUser();
      state = AsyncValue.data(localUser);
    } catch (e, stack) {
      developer.log('Erreur globale UserNotifier: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateName(String name) async {
    try {
      await _userService.updateName(name);
      await loadUser();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateFinancialProfile(FinancialProfile profile) async {
    try {
      await _userService.updateFinancialProfile(profile);
      await loadUser();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveUser(User user) async {
    try {
      await _userService.saveUser(user);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
