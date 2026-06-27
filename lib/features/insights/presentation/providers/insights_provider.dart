import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/simulation_remote_datasource.dart';
import '../../data/repositories/simulation_repository_impl.dart';
import '../../domain/entities/simulation.dart';
import '../../domain/repositories/simulation_repository.dart';
import '../../domain/usecases/create_simulation.dart';
import '../../domain/usecases/delete_simulation.dart';
import '../../domain/usecases/get_my_simulations.dart';

final simulationRemoteDataSourceProvider =
    Provider<SimulationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SimulationRemoteDataSourceImpl(apiClient);
});

final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  final remoteDataSource = ref.watch(simulationRemoteDataSourceProvider);
  return SimulationRepositoryImpl(remoteDataSource);
});

final createSimulationUseCaseProvider = Provider<CreateSimulation>((ref) {
  final repository = ref.watch(simulationRepositoryProvider);
  return CreateSimulation(repository);
});

final getMySimulationsUseCaseProvider = Provider<GetMySimulations>((ref) {
  final repository = ref.watch(simulationRepositoryProvider);
  return GetMySimulations(repository);
});

final deleteSimulationUseCaseProvider = Provider<DeleteSimulation>((ref) {
  final repository = ref.watch(simulationRepositoryProvider);
  return DeleteSimulation(repository);
});

class InsightsState {
  final List<Simulation> simulations;
  final bool isLoading;
  final String? error;
  final Simulation? currentSimulation;

  InsightsState({
    this.simulations = const [],
    this.isLoading = false,
    this.error,
    this.currentSimulation,
  });

  InsightsState copyWith({
    List<Simulation>? simulations,
    bool? isLoading,
    String? error,
    Simulation? currentSimulation,
  }) {
    return InsightsState(
      simulations: simulations ?? this.simulations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSimulation: currentSimulation ?? this.currentSimulation,
    );
  }
}

class InsightsNotifier extends StateNotifier<InsightsState> {
  final GetMySimulations getMySimulationsUseCase;
  final CreateSimulation createSimulationUseCase;
  final DeleteSimulation deleteSimulationUseCase;

  InsightsNotifier({
    required this.getMySimulationsUseCase,
    required this.createSimulationUseCase,
    required this.deleteSimulationUseCase,
  }) : super(InsightsState());

  Future<void> fetchSimulations() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getMySimulationsUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (simulations) => state = state.copyWith(simulations: simulations, isLoading: false),
    );
  }

  Future<void> createSimulation(Simulation simulation) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await createSimulationUseCase(simulation);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (created) => state = state.copyWith(
        simulations: [created, ...state.simulations],
        currentSimulation: created,
        isLoading: false,
      ),
    );
  }

  Future<void> deleteSimulation(String id) async {
    final result = await deleteSimulationUseCase(id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        simulations: state.simulations.where((s) => s.id != id).toList(),
      ),
    );
  }
}

final insightsProvider =
    StateNotifierProvider<InsightsNotifier, InsightsState>((ref) {
  final getMySimulationsUseCase = ref.watch(getMySimulationsUseCaseProvider);
  final createSimulationUseCase = ref.watch(createSimulationUseCaseProvider);
  final deleteSimulationUseCase = ref.watch(deleteSimulationUseCaseProvider);
  return InsightsNotifier(
    getMySimulationsUseCase: getMySimulationsUseCase,
    createSimulationUseCase: createSimulationUseCase,
    deleteSimulationUseCase: deleteSimulationUseCase,
  );
});
