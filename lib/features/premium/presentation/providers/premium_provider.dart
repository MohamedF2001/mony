import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/user_provider.dart';
import '../../data/datasources/premium_remote_datasource.dart';
import '../../data/repositories/premium_repository_impl.dart';
import '../../domain/repositories/premium_repository.dart';

final premiumRemoteDataSourceProvider = Provider<PremiumRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PremiumRemoteDataSourceImpl(apiClient);
});

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  final remoteDataSource = ref.watch(premiumRemoteDataSourceProvider);
  return PremiumRepositoryImpl(remoteDataSource);
});

class PremiumState {
  final bool isLoading;
  final String? error;
  final bool success;

  PremiumState({this.isLoading = false, this.error, this.success = false});

  PremiumState copyWith({bool? isLoading, String? error, bool? success}) {
    return PremiumState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PremiumRepository repository;
  final Ref ref;

  PremiumNotifier(this.repository, this.ref) : super(PremiumState());

  Future<void> activatePremium(String type) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      // On active le premium sur le serveur et on récupère l'utilisateur mis à jour
      // qui contient maintenant le financialProfile (grâce à l'étape 1)
      final currentUser = ref.read(userProvider).valueOrNull;
      final updatedUser = await repository.activatePremium(type);
      final mergedUser = updatedUser.copyWith(
        financialProfile:
            updatedUser.financialProfile ?? currentUser?.financialProfile,
      );
      
      // Mettre à jour l'utilisateur dans le provider global
      // Cela garantit que le profil financier et le statut premium sont synchronisés
      await ref.read(userProvider.notifier).saveUser(mergedUser);
      
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return PremiumNotifier(repository, ref);
});
