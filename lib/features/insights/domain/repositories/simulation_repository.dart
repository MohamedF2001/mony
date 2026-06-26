import '../entities/simulation.dart';

abstract class SimulationRepository {
  Future<Simulation> createSimulation(Simulation simulation);
  Future<List<Simulation>> getMySimulations();
  Future<void> deleteSimulation(String id);
}
