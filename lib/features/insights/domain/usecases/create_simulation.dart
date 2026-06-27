import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/simulation.dart';
import '../repositories/simulation_repository.dart';

class CreateSimulation {
  final SimulationRepository repository;

  CreateSimulation(this.repository);

  Future<Either<Failure, Simulation>> call(Simulation simulation) async {
    return await repository.createSimulation(simulation);
  }
}
