import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/simulation_remote_datasource.dart';
import '../../data/repositories/simulation_repository_impl.dart';
import '../../domain/entities/simulation.dart';
import '../../domain/repositories/simulation_repository.dart';

final simulationRemoteDataSourceProvider = Provider<SimulationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SimulationRemoteDataSourceImpl(apiClient);
});

final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  final remoteDataSource = ref.watch(simulationRemoteDataSourceProvider);
  return SimulationRepositoryImpl(remoteDataSource);
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
  final SimulationRepository repository;

  InsightsNotifier(this.repository) : super(InsightsState());

  Future<void> fetchSimulations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final simulations = await repository.getMySimulations();
      state = state.copyWith(simulations: simulations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createSimulation(Simulation simulation) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final created = await repository.createSimulation(simulation);
      state = state.copyWith(
        simulations: [created, ...state.simulations],
        currentSimulation: created,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteSimulation(String id) async {
    try {
      await repository.deleteSimulation(id);
      state = state.copyWith(
        simulations: state.simulations.where((s) => s.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final insightsProvider = StateNotifierProvider<InsightsNotifier, InsightsState>((ref) {
  final repository = ref.watch(simulationRepositoryProvider);
  return InsightsNotifier(repository);
});
