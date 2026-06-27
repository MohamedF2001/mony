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
  // ignore: unused_field
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
        String name = '${authUser.firstName} ${authUser.lastName}';
        bool isPremium = authUser.isPremium;
        String subscriptionType = authUser.subscriptionType;
        DateTime? premiumUntil = authUser.premiumUntil;
        
        final apiClient = _ref.read(apiClientProvider);

        try {
          final response = await apiClient.dio.get('/api/financial-profile');
          if (response.data != null && response.data['success'] == true) {
            final data = response.data['data'];
            
            // 1. Tenter de récupérer le profil depuis data.profile
            final profileData = data?['profile'];
            if (profileData != null && profileData is Map) {
              financialProfile = FinancialProfileModel.fromJson(
                Map<String, dynamic>.from(profileData),
              ).toEntity();
            }

            // 2. Si non trouvé, tenter de le récupérer depuis data.user.financialProfile
            final userData = data?['user'];
            if (userData != null && userData is Map) {
              if (financialProfile == null && userData['financialProfile'] != null) {
                if (userData['financialProfile'] is Map) {
                  financialProfile = FinancialProfileModel.fromJson(
                    Map<String, dynamic>.from(userData['financialProfile']),
                  ).toEntity();
                }
              }
              
              // Mettre à jour les infos utilisateur depuis la réponse API (plus à jour que authState)
              if (userData['firstName'] != null) {
                name = '${userData['firstName']} ${userData['lastName']}';
              }
              if (userData['isPremium'] != null) {
                isPremium = userData['isPremium'];
              }
              if (userData['subscriptionType'] != null) {
                subscriptionType = userData['subscriptionType'];
              }
              if (userData['premiumUntil'] != null) {
                premiumUntil = DateTime.parse(userData['premiumUntil']);
              }
            }
          }
        } catch (e) {
          developer.log('Erreur lors de la récupération du profil financier: $e');
        }

        final user = User(
          id: authUser.id,
          name: name,
          financialProfile: financialProfile,
          createdAt: authUser.createdAt,
          subscriptionType: subscriptionType,
          isPremium: isPremium,
          premiumUntil: premiumUntil,
        );

        developer.log('User chargé avec profil: ${user.financialProfile?.type} et sub: ${user.subscriptionType}');

        state = AsyncValue.data(user);
        return;
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      developer.log('Erreur globale UserNotifier: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateName(String name) async {
    // Cette méthode devrait désormais passer par l'API
    // await _userService.updateName(name);
    await loadUser();
  }

  Future<void> updateFinancialProfile(FinancialProfile profile) async {
    // Cette méthode devrait désormais passer par l'API
    // await _userService.updateFinancialProfile(profile);
    await loadUser();
  }

  Future<void> saveUser(User user) async {
    state = AsyncValue.data(user);
  }
}
