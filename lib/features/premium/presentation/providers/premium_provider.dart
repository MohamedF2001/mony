import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/user_provider.dart';
import '../../data/datasources/premium_remote_datasource.dart';
import '../../data/repositories/premium_repository_impl.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/activate_premium.dart';

final premiumRemoteDataSourceProvider =
    Provider<PremiumRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PremiumRemoteDataSourceImpl(apiClient);
});

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  final remoteDataSource = ref.watch(premiumRemoteDataSourceProvider);
  return PremiumRepositoryImpl(remoteDataSource);
});

final activatePremiumUseCaseProvider = Provider<ActivatePremium>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return ActivatePremium(repository);
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
  final ActivatePremium activatePremiumUseCase;
  final Ref ref;

  PremiumNotifier(this.activatePremiumUseCase, this.ref) : super(PremiumState());

  Future<void> activatePremium(String type) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    final result = await activatePremiumUseCase(type);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (updatedUser) async {
        final currentUser = ref.read(userProvider).valueOrNull;
        final mergedUser = updatedUser.copyWith(
          financialProfile:
              updatedUser.financialProfile ?? currentUser?.financialProfile,
        );

        // Mettre à jour l'utilisateur dans le provider global
        // Cela garantit que le profil financier et le statut premium sont synchronisés
        await ref.read(userProvider.notifier).saveUser(mergedUser);

        state = state.copyWith(isLoading: false, success: true);
      },
    );
  }
}

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final activatePremiumUseCase = ref.watch(activatePremiumUseCaseProvider);
  return PremiumNotifier(activatePremiumUseCase, ref);
});
